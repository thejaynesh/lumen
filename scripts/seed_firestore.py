"""Idempotent, atomic seeding with stable IDs and preservation of legacy references.

Default is a dry run. --apply opts into writes; --wipe is intentionally unsupported.
"""
import json
from pathlib import Path
import re
from firestore_tools import arguments, connect, read_collection, apply_plan
from content_validation import validate_settings, validate_project, validate_experience


def stable_id(value):
    result = re.sub(r'[^a-z0-9]+', '-', value.lower()).strip('-')[:100]
    if not result:
        raise ValueError('A seed record needs a stable identifier.')
    return result


def plan_records(records, existing, collection):
    """Match a legacy random ID before assigning a stable ID to a new record."""
    fields = ('title',) if collection == 'projects' else ('company', 'role', 'period')
    planned = {}
    used = set()
    for index, record in enumerate(records):
        if any(not isinstance(record.get(field), str) or not record[field].strip() for field in fields):
            raise ValueError(f'{collection} record lacks identifying fields.')
        key = tuple(record[field] for field in fields)
        matches = [doc_id for doc_id, data in existing.items() if tuple(data.get(field) for field in fields) == key]
        if len(matches) > 1:
            raise ValueError(f'Ambiguous legacy duplicates in {collection}: {key}. Resolve before seeding.')
        doc_id = matches[0] if matches else record.get('id', stable_id('-'.join(key)))
        if doc_id in used or not re.fullmatch(r'[a-zA-Z0-9_-]{1,128}', doc_id):
            raise ValueError(f'Duplicate/invalid seed ID: {doc_id}')
        if doc_id in existing and doc_id not in matches:
            raise ValueError(f'Seed ID collides with unrelated {collection}/{doc_id}.')
        used.add(doc_id)
        data = {**existing.get(doc_id, {}), **{k: v for k, v in record.items() if k != 'id'}}
        data['order'] = index
        data.setdefault('isActive', True)
        if type(data['isActive']) is not bool:
            raise ValueError('isActive must be a boolean.')
        if collection == 'projects':
            for field in ('problem', 'contribution', 'outcome', 'sourceUrl'):
                data.setdefault(field, '')
        planned[doc_id] = data
    return planned


def main():
    parser = arguments(__doc__)
    parser.add_argument('--data', default=str(Path(__file__).with_name('seed_data.json')))
    parser.add_argument('--reset-defaults', action='store_true', help='Explicitly replace existing featured selections')
    args = parser.parse_args()
    seed = json.loads(Path(args.data).read_text(encoding='utf-8'))
    if not all(key in seed for key in ('settings', 'projects', 'experience')):
        raise ValueError('Seed data requires settings, projects and experience.')
    db = connect(args)
    from google.cloud import firestore
    writes, reads, defaults, collections = {}, {}, {}, {}
    for collection in ('projects', 'experience'):
        snapshots = read_collection(db, collection)
        collections[collection] = set(snapshots)
        reads.update({f'{collection}/{key}': snap for key, snap in snapshots.items()})
        existing = {key: snap.to_dict() for key, snap in snapshots.items()}
        planned = plan_records(seed[collection], existing, collection)
        defaults[collection] = list(planned)
        for doc_id, data in planned.items():
            path = f'{collection}/{doc_id}'
            reads[path] = snapshots.get(doc_id)
            original = existing.get(doc_id, {})
            validator = validate_project if collection == 'projects' else validate_experience
            data = validator(data, path=path, timestamps=bool(original))
            if any(original.get(key) != value for key, value in data.items() if key not in ('createdAt', 'updatedAt')):
                data['createdAt'] = original.get('createdAt', firestore.SERVER_TIMESTAMP)
                data['updatedAt'] = firestore.SERVER_TIMESTAMP
                writes[path] = data
    settings_snap = db.document('settings/main').get()
    reads['settings/main'] = settings_snap
    previous = settings_snap.to_dict() or {}
    settings = {**previous, **seed['settings']}
    settings.setdefault('availability', '')
    for field, collection in (('defaultProjectIds', 'projects'), ('defaultExperienceIds', 'experience')):
        settings[field] = defaults[collection] if args.reset_defaults or field not in previous else previous[field]
    settings = validate_settings(settings, normalize_urls=True)
    if settings != previous:
        writes['settings/main'] = settings
    apply_plan(db, args, writes, reads, collections)


if __name__ == '__main__':
    main()
