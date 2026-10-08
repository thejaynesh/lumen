"""Pure schema preflight for maintenance scripts that bypass Firestore rules.

Return validated copies; never silently discard unknown legacy fields. Limits
mirror lib/models/portfolio_validation.dart and firestore.rules.
"""
from copy import deepcopy
from datetime import datetime
import re
from urllib.parse import urlsplit, urlunsplit


def _schema(data, allowed, required, path):
    if not isinstance(data, dict):
        raise ValueError(f'{path}: expected an object.')
    unknown = set(data) - set(allowed)
    missing = set(required) - set(data)
    if unknown:
        raise ValueError(f'{path}: unknown fields {sorted(unknown)}; review/migrate them explicitly before writing.')
    if missing:
        raise ValueError(f'{path}: missing required fields {sorted(missing)}.')


def _text(value, path, maximum=200, required=False, nullable=False):
    if nullable and value is None:
        return
    if not isinstance(value, str) or len(value) > maximum or (required and not value.strip()):
        raise ValueError(f'{path}: expected {"nonempty " if required else ""}text of at most {maximum} characters.')


def _integer(value, path, minimum=0, maximum=2**63-1):
    if type(value) is not int or not minimum <= value <= maximum:
        raise ValueError(f'{path}: expected an integer between {minimum} and {maximum}.')


def _boolean(value, path):
    if type(value) is not bool:
        raise ValueError(f'{path}: expected a boolean.')


def _date(value, path, nullable=False):
    if nullable and value is None:
        return
    if not isinstance(value, datetime):
        raise ValueError(f'{path}: expected a Firestore timestamp, not a string/number; repair before migration.')


def _timestamps(data, path, required):
    for field in ('createdAt', 'updatedAt'):
        if required or field in data:
            _date(data.get(field), f'{path}.{field}')


def _strings(value, path, maximum=50, item_maximum=2000):
    if not isinstance(value, list) or len(value) > maximum:
        raise ValueError(f'{path}: expected a list of at most {maximum} strings.')
    for index, item in enumerate(value):
        _text(item, f'{path}[{index}]', item_maximum)
        if '\n' in item or '\r' in item:
            raise ValueError(f'{path}[{index}]: each entry must be a single line.')


def validate_ids(value, path):
    if not isinstance(value, list) or len(value) > 100 or any(
        not isinstance(item, str) or not re.fullmatch(r'[a-zA-Z0-9_-]{1,128}', item) for item in value
    ) or len(set(value)) != len(value):
        raise ValueError(f'{path}: expected at most 100 unique IDs containing only letters, digits, hyphens or underscores.')


def canonical_url(value, path, relative=False, normalize_bare=False):
    if value is None or value == '':
        return value
    _text(value, path, 2000)
    if any(char.isspace() for char in value) or '\\' in value:
        raise ValueError(f'{path}: URL cannot contain whitespace or backslashes.')
    if relative and value.startswith('/') and not value.startswith('//'):
        return value
    if normalize_bare and '://' not in value and not value.startswith('/') and ':' not in value:
        value = f'https://{value}'
    try:
        parts = urlsplit(value)
        port = parts.port
    except ValueError as error:
        raise ValueError(f'{path}: invalid URL.') from error
    if parts.scheme.lower() not in ('https', 'http') or not parts.hostname or parts.username or parts.password:
        raise ValueError(f'{path}: expected an HTTP(S) URL{" or a site-relative path" if relative else ""}.')
    if port is not None and not 0 < port <= 65535:
        raise ValueError(f'{path}: invalid URL port.')
    normalized = urlunsplit((parts.scheme.lower(), parts.netloc, parts.path, parts.query, parts.fragment))
    _text(normalized, path, 2000)
    return normalized


def _objects(value, path, validator):
    if not isinstance(value, list) or len(value) > 12:
        raise ValueError(f'{path}: expected a list of at most 12 objects.')
    for index, item in enumerate(value):
        validator(item, f'{path}[{index}]')


def _highlight(value, path):
    _schema(value, ('label', 'value', 'note'), ('label', 'value'), path)
    _text(value['label'], f'{path}.label')
    _text(value['value'], f'{path}.value')
    _text(value.get('note', ''), f'{path}.note', 1000)


def _skill_group(value, path):
    _schema(value, ('category', 'items'), ('category', 'items'), path)
    _text(value['category'], f'{path}.category', required=True)
    _strings(value['items'], f'{path}.items', 30, 200)


def _education(value, path):
    _schema(value, ('when', 'where', 'what'), ('when', 'where', 'what'), path)
    for field, limit in (('when', 200), ('where', 500), ('what', 1000)):
        _text(value[field], f'{path}.{field}', limit)


def _quiz(value, path):
    _schema(value, ('q', 'options', 'answer', 'funFact'), ('q', 'options', 'answer'), path)
    _text(value['q'], f'{path}.q', 1000, required=True)
    _strings(value['options'], f'{path}.options', 8, 500)
    if len(value['options']) < 2:
        raise ValueError(f'{path}.options: at least two options are required.')
    _integer(value['answer'], f'{path}.answer', 0, len(value['options']) - 1)
    _text(value.get('funFact', ''), f'{path}.funFact', 2000)


def _personality(value, path):
    _schema(value, ('label', 'value'), ('label', 'value'), path)
    _text(value['label'], f'{path}.label')
    _text(value['value'], f'{path}.value', 1000)


def _certification(value, path):
    _schema(value, ('name', 'issuer', 'year'), ('name',), path)
    _text(value['name'], f'{path}.name', 500, required=True)
    _text(value.get('issuer', ''), f'{path}.issuer', 300)
    _text(value.get('year', ''), f'{path}.year', 50)


SETTINGS_FIELDS = ('name', 'initials', 'role', 'tagline', 'location', 'about', 'summary', 'email', 'phone',
                   'availability', 'github', 'linkedin', 'twitter', 'instagram', 'resumeUrl', 'highlights',
                   'skillGroups', 'awards', 'education', 'quiz', 'personality', 'certifications', 'now',
                   'defaultProjectIds', 'defaultExperienceIds')


def validate_settings(value, normalize_urls=False):
    path = 'settings/main'
    _schema(value, SETTINGS_FIELDS, ('name', 'tagline', 'email'), path)
    data = deepcopy(value)
    _text(data['name'], f'{path}.name', required=True)
    for field, limit in (('initials', 20), ('role', 200), ('tagline', 1000), ('location', 200),
                         ('about', 10000), ('summary', 10000), ('phone', 50), ('availability', 300)):
        _text(data.get(field, ''), f'{path}.{field}', limit)
    _text(data['email'], f'{path}.email', 320, required=True)
    if not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', data['email']):
        raise ValueError(f'{path}.email: invalid email address.')
    for field in ('github', 'linkedin', 'twitter', 'instagram', 'resumeUrl'):
        if field in data:
            data[field] = canonical_url(data[field], f'{path}.{field}', relative=field == 'resumeUrl', normalize_bare=normalize_urls)
    for field in ('defaultProjectIds', 'defaultExperienceIds'):
        validate_ids(data.get(field, []), f'{path}.{field}')
    for field in ('awards', 'now'):
        _strings(data.get(field, []), f'{path}.{field}')
    for field, validator in (('highlights', _highlight), ('skillGroups', _skill_group), ('education', _education),
                             ('quiz', _quiz), ('personality', _personality), ('certifications', _certification)):
        _objects(data.get(field, []), f'{path}.{field}', validator)
    return data


PROJECT_FIELDS = ('title', 'category', 'description', 'techStack', 'link', 'imageUrl', 'sourceUrl', 'colorHex',
                  'tags', 'tag', 'kpi', 'problem', 'contribution', 'outcome', 'order', 'isActive', 'createdAt', 'updatedAt')
EXPERIENCE_FIELDS = ('role', 'company', 'period', 'description', 'highlights', 'tags', 'city', 'order', 'isActive', 'createdAt', 'updatedAt')
JOB_FIELDS = ('slug', 'title', 'company', 'description', 'projectIds', 'experienceIds', 'customTagline', 'customAbout',
              'isActive', 'viewCount', 'createdAt', 'updatedAt', 'expiresAt')


def validate_project(value, path='projects/seed', timestamps=True):
    _schema(value, PROJECT_FIELDS, ('title', 'category', 'description', 'techStack', 'order', 'isActive'), path)
    data = deepcopy(value)
    _text(data['title'], f'{path}.title', required=True)
    _text(data['category'], f'{path}.category')
    for field in ('description', 'problem', 'contribution', 'outcome'):
        _text(data.get(field, ''), f'{path}.{field}', 10000)
    _text(data.get('tag', ''), f'{path}.tag', 300)
    _text(data.get('kpi', ''), f'{path}.kpi', 1000)
    for field in ('techStack', 'tags'):
        _strings(data.get(field, []), f'{path}.{field}', 50, 200)
    for field in ('link', 'imageUrl', 'sourceUrl'):
        if field in data:
            data[field] = canonical_url(data[field], f'{path}.{field}', relative=field == 'imageUrl')
    _integer(data.get('colorHex', 0xffff6b35), f'{path}.colorHex', 0, 0xffffffff)
    _integer(data['order'], f'{path}.order', 0, 100000)
    _boolean(data['isActive'], f'{path}.isActive')
    _timestamps(data, path, timestamps)
    return data


def validate_experience(value, path='experience/seed', timestamps=True):
    _schema(value, EXPERIENCE_FIELDS, ('role', 'company', 'period', 'description', 'order', 'isActive'), path)
    data = deepcopy(value)
    for field in ('role', 'company'):
        _text(data[field], f'{path}.{field}', required=True)
    _text(data['period'], f'{path}.period')
    _text(data.get('city', ''), f'{path}.city')
    _text(data['description'], f'{path}.description', 10000)
    _strings(data.get('highlights', []), f'{path}.highlights')
    _strings(data.get('tags', []), f'{path}.tags', 50, 200)
    _integer(data['order'], f'{path}.order', 0, 100000)
    _boolean(data['isActive'], f'{path}.isActive')
    _timestamps(data, path, timestamps)
    return data


def validate_job(value, job_id):
    path = f'jobs/{job_id}'
    validate_ids([job_id], 'job document ID')
    _schema(value, JOB_FIELDS, ('slug', 'title', 'company', 'createdAt', 'updatedAt'), path)
    data = deepcopy(value)
    # Historical jobs may predate selections/publication state. Missing state
    # remains unpublished; malformed present values still fail below.
    data.setdefault('projectIds', [])
    data.setdefault('experienceIds', [])
    data.setdefault('isActive', False)
    if not isinstance(data['slug'], str) or not re.fullmatch(r'[a-z0-9][a-z0-9-]{0,99}', data['slug']):
        raise ValueError(f'{path}.slug: invalid share slug.')
    for field in ('title', 'company'):
        _text(data[field], f'{path}.{field}', required=True)
    for field, limit in (('description', 10000), ('customTagline', 1000), ('customAbout', 10000)):
        _text(data.get(field), f'{path}.{field}', limit, nullable=True)
    for field in ('projectIds', 'experienceIds'):
        validate_ids(data[field], f'{path}.{field}')
    _boolean(data['isActive'], f'{path}.isActive')
    _integer(data.get('viewCount', 0), f'{path}.viewCount')
    _timestamps(data, path, True)
    _date(data.get('expiresAt'), f'{path}.expiresAt', nullable=True)
    return data
