"""Build staging Dart defines from CI variables, with no production fallback."""
import json
import os
from pathlib import Path

keys = ('FIREBASE_PROJECT_ID', 'FIREBASE_API_KEY', 'FIREBASE_APP_ID',
        'FIREBASE_MESSAGING_SENDER_ID', 'FIREBASE_AUTH_DOMAIN')
values = {key: os.environ.get(key, '') for key in keys}
if any(not value for value in values.values()):
    raise SystemExit('All Firebase staging web configuration variables are required.')
if values['FIREBASE_PROJECT_ID'] == 'lumen-f2e07' or values['FIREBASE_PROJECT_ID'].startswith('demo-'):
    raise SystemExit('Staging must target a separate real project.')
path = Path('config/staging.local.json')
path.parent.mkdir(exist_ok=True)
path.write_text(json.dumps({'APP_ENV': 'staging', **values}), encoding='utf-8')
