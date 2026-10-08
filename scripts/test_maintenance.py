import argparse
from datetime import datetime, timezone
import os
import unittest
from unittest.mock import patch
from seed_firestore import plan_records
from migrate_profiles import build_profiles
from firestore_tools import validate_target


class MaintenanceTests(unittest.TestCase):
    def test_legacy_ids_survive_seed_reruns(self):
        content = {'title': 'Example', 'description': 'A real project'}
        first = plan_records([content], {'old-random-id': content}, 'projects')
        second = plan_records([content], first, 'projects')
        self.assertEqual(first, second)
        self.assertEqual(list(second), ['old-random-id'])

    def test_new_seed_ids_are_stable_and_duplicates_fail(self):
        content = {'title': 'Example'}
        self.assertEqual(list(plan_records([content], {}, 'projects')), ['example'])
        with self.assertRaises(ValueError):
            plan_records([content], {'a': content, 'b': content}, 'projects')

    def test_private_notes_never_enter_profile(self):
        now = datetime.now(timezone.utc)
        job = {'slug': 'example', 'title': 'Private role', 'company': 'Private company',
               'description': 'Private notes', 'viewCount': 99, 'createdAt': now,
               'updatedAt': now, 'projectIds': ['legacy-id'], 'isActive': True}
        _, profile = build_profiles({'job': job}, {})['example']
        self.assertFalse({'title', 'company', 'description', 'viewCount', 'jobId'} & profile.keys())
        self.assertEqual(profile['projectIds'], ['legacy-id'])
        self.assertIsNone(profile['expiresAt'])
        with self.assertRaises(ValueError):
            build_profiles({'one': job, 'two': job}, {})
        with self.assertRaises(ValueError):
            build_profiles({'job': job}, {'example': {'jobId': 'other'}})

    def test_real_writes_require_explicit_target_and_new_backup(self):
        args = argparse.Namespace(project='lumen-f2e07', emulator=False, apply=True, confirm_project=None, backup=None)
        with patch.dict(os.environ, {}, clear=True), self.assertRaises(ValueError):
            validate_target(args)
        args.emulator = True
        with self.assertRaises(ValueError):
            validate_target(args)
        args.project = 'demo-lumen'
        with patch.dict(os.environ, {}, clear=True):
            validate_target(args)
            self.assertEqual(os.environ['FIRESTORE_EMULATOR_HOST'], '127.0.0.1:8080')


if __name__ == '__main__':
    unittest.main()
