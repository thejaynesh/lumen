"""Publish minimal share profiles for legacy private jobs without changing IDs."""
import re
from firestore_tools import arguments, connect, read_collection, apply_plan
from content_validation import validate_job

PUBLIC_FIELDS = ('slug', 'projectIds', 'experienceIds', 'customTagline', 'customAbout',
                 'isActive', 'expiresAt', 'createdAt', 'updatedAt')


def build_profiles(jobs, reservations, existing_profiles=None):
    for slug, reservation in reservations.items():
        if not isinstance(reservation, dict) or set(reservation) != {'jobId'}:
            raise ValueError(f'profileSlugs/{slug}: expected only jobId; review/repair existing fields before migration.')
    result = {}
    for job_id, job in jobs.items():
        job = validate_job(job, job_id)
        slug = job.get('slug', '')
        if not isinstance(slug, str) or not re.fullmatch(r'[a-z0-9][a-z0-9-]{0,99}', slug):
            raise ValueError(f'Invalid slug on jobs/{job_id}; resolve it before migration.')
        if slug in result or (slug in reservations and reservations[slug].get('jobId') != job_id):
            raise ValueError(f'Duplicate/conflicting slug {slug}; migration refused.')
        if not job.get('createdAt') or not job.get('updatedAt'):
            raise ValueError(f'Missing timestamps on jobs/{job_id}; repair before migration.')
        profile = {key: job.get(key) for key in PUBLIC_FIELDS}
        profile['projectIds'] = job.get('projectIds', [])
        profile['experienceIds'] = job.get('experienceIds', [])
        profile['isActive'] = job.get('isActive', False)
        if not isinstance(profile['isActive'], bool):
            raise ValueError(f'Invalid publication state on jobs/{job_id}.')
        for key in ('projectIds', 'experienceIds'):
            values = profile[key]
            if not isinstance(values, list) or len(values) > 100 or any(
                not isinstance(v, str) or not re.fullmatch(r'[a-zA-Z0-9_-]{1,128}', v) for v in values
            ) or len(set(values)) != len(values):
                raise ValueError(f'Invalid {key} on jobs/{job_id}.')
        result[slug] = (job_id, profile)
    # Never leave an old active share link outside the set being migrated.
    # Refuse ambiguous state rather than silently deleting or repurposing it.
    for slug, reservation in reservations.items():
        if slug not in result or reservation['jobId'] != result[slug][0]:
            raise ValueError(f'profileSlugs/{slug}: orphan or mismatched reservation; review/archive its public profile and repair ownership before migration.')
    for slug, profile in (existing_profiles or {}).items():
        if slug not in result:
            raise ValueError(f'publicProfiles/{slug}: orphan profile could remain publicly readable; review/archive it and repair ownership before migration.')
        if not isinstance(profile, dict):
            raise ValueError(f'publicProfiles/{slug}: expected an object; repair before migration.')
        unknown = set(profile) - set(PUBLIC_FIELDS)
        if unknown:
            raise ValueError(f'publicProfiles/{slug}: unknown fields {sorted(unknown)}; review/migrate them explicitly before writing.')
        if 'slug' in profile and profile['slug'] != slug:
            raise ValueError(f'publicProfiles/{slug}: mismatched slug; repair ownership before migration.')
    return result


def main():
    args = arguments(__doc__).parse_args()
    db = connect(args)
    jobs = read_collection(db, 'jobs')
    reservations = read_collection(db, 'profileSlugs')
    profiles = read_collection(db, 'publicProfiles')
    plan = build_profiles({key: doc.to_dict() for key, doc in jobs.items()},
                          {key: doc.to_dict() for key, doc in reservations.items()},
                          {key: doc.to_dict() for key, doc in profiles.items()})
    reads = {f'jobs/{key}': doc for key, doc in jobs.items()}
    writes = {}
    for slug, (job_id, profile) in plan.items():
        for collection, existing, data in (
            ('publicProfiles', profiles, profile), ('profileSlugs', reservations, {'jobId': job_id})
        ):
            path = f'{collection}/{slug}'
            reads[path] = existing.get(slug)
            if slug not in existing or existing[slug].to_dict() != data:
                writes[path] = data
    apply_plan(db, args, writes, reads, {
        'jobs': set(jobs), 'profileSlugs': set(reservations), 'publicProfiles': set(profiles),
    })


if __name__ == '__main__':
    main()
