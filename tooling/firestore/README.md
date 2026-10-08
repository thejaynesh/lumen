# Firestore contract and regression tests

This suite uses the local Firestore emulator with the `demo-lumen` project. It
refuses nonlocal emulator hosts and never uses production credentials.

```sh
npm ci
npm run test:emulator
```

Java 21+ must be available for the Firebase emulator. The suite loads the actual
repository rules and current seed data, so a successful run validates their
compatibility as well as the permission boundaries.

## Data contract

- `settings/main` is the owner's intentionally public portfolio/contact profile.
  Only this exact settings document can be read publicly; collection listing is
  denied. The owner can edit it but cannot delete it through the client.
- `projects` and `experience` are public only when `isActive == true`. Public
  queries include that condition. Client deletion archives the record, retaining
  references in curated selections and allowing restoration.
- `jobs` contains private application title, company, notes, selected content,
  overrides, expiry and historical view counters. It is admin-only.
- `profileSlugs/{slug}` is an admin-only `{jobId}` reservation. Transactional
  reads prevent simultaneous creations from claiming the same slug.
- `publicProfiles/{slug}` contains only the slug, selected IDs, custom public
  tagline/bio, active status, expiry and timestamps. Visitors can retrieve an
  active, unexpired known link but cannot list all links. Copying a link gives
  access to that published variant; this is a sharing feature, not recipient
  authentication.
- Jobs, reservations and public projections are written together. Rules compare
  their final transaction state, preventing divergent public copy, unreserved
  slugs, stale renamed links, and partial deletion. Internal job IDs, application
  titles, companies, notes and counters never enter the public projection.

Owner authorization is a verified `thejaynesh@gmail.com` identity or a trusted
`admin == true` custom claim. Claims must be assigned through trusted server-side
administration, never through a client-writable document.

All creates and updates call the same schema validators. Rules enforce owner
authorization, known top-level fields/types, scalar text/URL bounds and array
structure. Nested profile lists allow 12 entries; detailed
nested keys, text lengths, and quiz-answer indices are validated by Dart and the
Python maintenance preflight, not by Firestore rules. An authorized owner using
another client can bypass those content-quality checks; the privacy boundaries
still apply. This keeps full settings saves inside Firestore's 1000-expression
budget. String lists allow 50 entries and selected IDs allow 100 unique IDs.
Selected documents are read in parallel groups of 30, preserving order and
omitting each archived/deleted item independently. Creation timestamps are immutable, modification timestamps
use server time, and legacy counters cannot be rewritten from edit dialogs.

## Migration and deployment

Before switching the public client and tightening the rules, migrate existing
jobs to both reservations and minimal public profiles. Stop on duplicate slugs
instead of choosing an arbitrary winner. Preserve existing IDs and creation
timestamps, and populate nullable expiry explicitly. Follow the repository
migration script's dry-run and backup workflow. Roll out the migrated data,
tested rules/indexes and new client together; the old public client reads the
now-private jobs collection and must not remain the active release.

Historical counters are retained as historical data. New profile visits are
emitted through the injected analytics callback, deduplicated per service
session, and never write to `jobs`. Analytics failure does not block content.

## Attack coverage

The emulator suite exercises unauthenticated/private reads, forbidden public
listing, unpublished/expired links, inactive selected content, anonymous writes,
unverified owner identities, untrusted self-assigned roles, create/update
validation bypasses, schema pollution, invalid arrays/URLs, required and
immutable timestamps, counter replay, projection mismatches, atomic lifecycle
changes, and competing slug reservations. Admin-only nested/subcollection paths
remain denied by the default rule unless explicitly listed above.

These are prototype Security Rules backed by regression tests. Test production
deployment separately and review them as the data model or authentication
configuration changes; emulator success is not evidence of deployed state.
