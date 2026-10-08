from copy import deepcopy
from datetime import datetime, timezone
import json
from pathlib import Path
import unittest

from content_validation import canonical_url, validate_settings, validate_project, validate_experience, validate_job
from migrate_profiles import build_profiles


class ContentValidationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.seed = json.loads(Path(__file__).with_name('seed_data.json').read_text(encoding='utf-8'))

    def test_actual_seed_is_valid_after_explicit_url_normalization(self):
        settings = validate_settings(self.seed['settings'], normalize_urls=True)
        self.assertTrue(settings['github'].startswith('https://'))
        for record in self.seed['projects']:
            validate_project(record, timestamps=False)
        for record in self.seed['experience']:
            validate_experience(record, timestamps=False)

    def test_unknown_legacy_fields_are_not_silently_discarded(self):
        settings = {**self.seed['settings'], 'privateNotes': 'not public'}
        with self.assertRaisesRegex(ValueError, 'unknown fields.*privateNotes'):
            validate_settings(settings, normalize_urls=True)
        with self.assertRaisesRegex(ValueError, 'unknown fields'):
            validate_project({**self.seed['projects'][0], 'ownerOnly': True}, timestamps=False)

    def test_typed_nested_lists_and_quiz_answers_are_validated(self):
        for field, value in (
            ('quiz', [{'q': 'Question', 'options': ['A', 'B'], 'answer': 2}]),
            ('skillGroups', [{'category': 'Skills', 'items': [7]}]),
            ('education', [{'when': 'Now', 'where': 'School', 'what': 'x' * 1001}]),
            ('certifications', [{'name': 'x' * 501}]),
            ('highlights', [{'label': 'Label', 'value': [], 'note': ''}]),
            ('personality', [{'label': 'Label', 'value': 'Value', 'secret': 'not allowed'}]),
            ('awards', ['x' * 2001]),
            ('now', ['line\nbreak']),
        ):
            with self.subTest(field=field), self.assertRaises(ValueError):
                validate_settings({**self.seed['settings'], field: value}, normalize_urls=True)

    def test_bounds_and_duplicate_ids_fail_preflight(self):
        for value in (['same', 'same'], ['bad/id'], list(map(str, range(101))), [True]):
            with self.subTest(value=value), self.assertRaises(ValueError):
                validate_settings({**self.seed['settings'], 'defaultProjectIds': value}, normalize_urls=True)
        with self.assertRaises(ValueError):
            validate_project({**self.seed['projects'][0], 'order': True}, timestamps=False)
        with self.assertRaises(ValueError):
            validate_experience({**self.seed['experience'][0], 'isActive': 'true'}, timestamps=False)

    def test_urls_are_canonicalized_only_when_requested_and_never_execute_scripts(self):
        self.assertEqual(canonical_url('github.com/owner', 'github', normalize_bare=True), 'https://github.com/owner')
        self.assertEqual(canonical_url('HTTPS://example.com/work', 'link'), 'https://example.com/work')
        self.assertEqual(canonical_url('/resume.pdf', 'resume', relative=True), '/resume.pdf')
        for value in ('javascript:alert(1)', '//example.com', 'file:///secret', 'https://user:pass@example.com',
                      'https://exa mple.com', 'https://example.com\\evil', 'https://example.com:99999'):
            with self.subTest(value=value), self.assertRaises(ValueError):
                canonical_url(value, 'link', relative=True, normalize_bare=True)
        with self.assertRaises(ValueError):
            canonical_url('github.com/owner', 'github')

    def test_migration_rejects_bad_timestamps_text_and_unknown_fields(self):
        now = datetime.now(timezone.utc)
        valid = {'slug': 'share', 'title': 'Role', 'company': 'Company', 'createdAt': now,
                 'updatedAt': now, 'isActive': True, 'projectIds': ['one'], 'experienceIds': []}
        self.assertEqual(validate_job(valid, 'job')['projectIds'], ['one'])
        for changes in ({'createdAt': 'yesterday'}, {'updatedAt': 123}, {'expiresAt': 'tomorrow'},
                        {'customAbout': 7}, {'customTagline': 'x' * 1001}, {'customAbout': 'x' * 10001},
                        {'privateExtra': 'review this'}, {'viewCount': -1}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                build_profiles({'job': {**valid, **changes}}, {})
        for job_id in ('bad/id', '', 'x' * 129):
            with self.subTest(job_id=job_id), self.assertRaises(ValueError):
                build_profiles({job_id: valid}, {})

    def test_validation_does_not_mutate_input(self):
        original = deepcopy(self.seed['settings'])
        validated = validate_settings(original, normalize_urls=True)
        self.assertEqual(original, self.seed['settings'])
        validated['highlights'][0]['label'] = 'Changed'
        self.assertNotEqual(original['highlights'][0]['label'], 'Changed')

    def test_migration_refuses_orphan_or_ambiguous_existing_share_records(self):
        now = datetime.now(timezone.utc)
        jobs = {'job': {'slug': 'share', 'title': 'Role', 'company': 'Company',
                        'createdAt': now, 'updatedAt': now, 'isActive': True}}
        _, profile = build_profiles(jobs, {})['share']
        expected = build_profiles(jobs, {})
        self.assertEqual(build_profiles(jobs, {'share': {'jobId': 'job'}}, {'share': profile}), expected)
        for reservations, profiles, message in (
            ({'orphan': {'jobId': 'missing'}}, {}, 'orphan or mismatched'),
            ({'share': {'jobId': 'job', 'extra': 'review this'}}, {}, 'expected only jobId'),
            ({'share': None}, {}, 'expected only jobId'),
            ({}, {'orphan': {**profile, 'slug': 'orphan'}}, 'orphan profile'),
            ({}, {'share': {**profile, 'privateNotes': 'not public'}}, 'unknown fields'),
            ({}, {'share': {**profile, 'slug': 'different'}}, 'mismatched slug'),
        ):
            with self.subTest(reservations=reservations, profiles=profiles), self.assertRaisesRegex(ValueError, message):
                build_profiles(jobs, reservations, profiles)


if __name__ == '__main__':
    unittest.main()
