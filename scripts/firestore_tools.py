"""Shared safeguards for explicit, dry-run-first Firestore maintenance."""
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
from urllib.parse import urlparse


def arguments(description):
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('--project', required=True, help='Explicit Firebase project ID')
    parser.add_argument('--emulator', action='store_true')
    parser.add_argument('--credentials', help='Optional service account path; otherwise ADC')
    parser.add_argument('--apply', action='store_true', help='Commit the printed plan (default: dry run)')
    parser.add_argument('--confirm-project', help='Required for writes to a real project')
    parser.add_argument('--backup', help='New JSON backup path, required for real-project writes')
    return parser


def validate_target(args):
    host = os.environ.get('FIRESTORE_EMULATOR_HOST')
    if args.emulator:
        if not args.project.startswith('demo-'):
            raise ValueError('Emulator work must target a demo- project.')
        os.environ.setdefault('FIRESTORE_EMULATOR_HOST', '127.0.0.1:8080')
        target = urlparse('http://' + os.environ['FIRESTORE_EMULATOR_HOST'])
        if target.hostname not in ('127.0.0.1', 'localhost', '::1') or not target.port or target.path or target.username:
            raise ValueError('Emulator host must be a loopback hostname with a valid port.')
    elif host:
        raise ValueError('FIRESTORE_EMULATOR_HOST is set; pass --emulator explicitly.')
    elif args.project.startswith('demo-'):
        raise ValueError('A demo- project requires --emulator.')
    elif args.apply and (args.confirm_project != args.project or not args.backup):
        raise ValueError('Real-project writes require --confirm-project matching --project and --backup.')
    if args.backup and Path(args.backup).exists():
        raise ValueError('Backup path already exists. Choose a new file; existing backups are never overwritten.')


def connect(args):
    validate_target(args)
    from google.cloud import firestore
    if args.emulator:
        from google.auth.credentials import AnonymousCredentials
        return firestore.Client(project=args.project, credentials=AnonymousCredentials())
    if args.credentials:
        from google.oauth2 import service_account
        info = json.loads(Path(args.credentials).read_text(encoding='utf-8'))
        if info.get('project_id') != args.project:
            raise ValueError('Credential project does not match --project.')
        return firestore.Client(project=args.project, credentials=service_account.Credentials.from_service_account_info(info))
    return firestore.Client(project=args.project)


def read_collection(db, name):
    return {doc.id: doc for doc in db.collection(name).stream()}


def encode_backup(value):
    if isinstance(value, datetime):
        return {'__timestamp__': value.isoformat()}
    raise TypeError(f'Unsupported backup type: {type(value).__name__}')


def apply_plan(db, args, writes, reads, collections=None):
    """Recheck all source documents in one transaction before applying any write."""
    if len(writes) > 450:
        raise ValueError('Plan exceeds 450 writes. Split migration into reviewed batches.')
    for path, data in writes.items():
        before = reads.get(path)
        existing = before.to_dict() if before is not None and before.exists else {}
        changes = sorted(key for key, value in data.items() if existing.get(key) != value)
        print(f'{path}: {", ".join(changes) or "replace projection"}')
    print(f'{len(writes)} writes planned for {args.project}; {"APPLY" if args.apply else "DRY RUN"}.')
    if not args.apply or not writes:
        return
    backup = {'project': args.project, 'createdAt': datetime.now(timezone.utc).isoformat(),
              'documents': {path: (snap.to_dict() if snap and snap.exists else None)
                            for path, snap in reads.items() if path in writes}}
    if args.backup:
        destination = Path(args.backup)
        destination.parent.mkdir(parents=True, exist_ok=True)
        with destination.open('x', encoding='utf-8') as stream:
            json.dump(backup, stream, indent=2, default=encode_backup)
    from google.cloud import firestore
    transaction = db.transaction()

    @firestore.transactional
    def commit(tx):
        for name, expected_ids in (collections or {}).items():
            current_ids = {doc.id for doc in db.collection(name).stream(transaction=tx)}
            if current_ids != set(expected_ids):
                raise RuntimeError(f'{name} membership changed after planning; rerun the dry run.')
        for path, original in reads.items():
            current = db.document(path).get(transaction=tx)
            expected_time = original.update_time if original and original.exists else None
            if (current.update_time if current.exists else None) != expected_time:
                raise RuntimeError(f'{path} changed after planning; rerun the dry run.')
        for path, data in writes.items():
            tx.set(db.document(path), data)
    commit(transaction)
    print('Committed atomically.')
