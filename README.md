# Lumen Portfolio

Jaynesh Bhandari's Flutter web portfolio, with the Index club design and an authenticated content studio. Firebase Authentication protects administration; Cloud Firestore stores profile content and tailored portfolio links; Firebase Hosting serves the web build.

The public interface pairs cobalt, apricot, and blue-gray with Manrope and DM Serif Display. Light mode is the first-visit default; a saved theme preference takes precedence. A top navigation bar becomes a mobile menu. The hero folder opens the project section. Projects and experience each use one shared folder with visible, keyboard-accessible tabs for every entry. Education and certifications share a consistent left edge, with dates beside or below the text according to available space. Folder hover and tab transitions animate smoothly, and AlgoView includes an interactive sorting illustration. Reduced-motion preferences disable these transitions. Published project data, tailored introductions, résumé links, experience, and contact details remain connected to the content studio.

The introduction groups location, availability, email, projects, and résumé actions. Email becomes a floating action only after the original button scrolls above the viewport, and hides when the contact section is reached. The page then presents projects and outcomes, professional experience, background and skills, credentials, and contact details. Project explanations lead the case studies; ClickDrobe uses a simplified ingestion diagram and AlgoView uses an illustrative sorting demo, with uploaded screenshots taking precedence when available.

The normal development target is **local emulators using `demo-lumen`**. Production requires `APP_ENV=production`. These repository changes do not imply that a Firebase project, production rules, account, or website has been deployed.

## What is included

- Responsive public portfolio, project case studies, résumé and contact links, bundled fonts, light/dark preference, and reduced-motion support.
- Optional guided tour and quiz/personality experiences at `/modes`.
- Admin editors for projects, experience, profile details, skills, education, certifications, awards, current focus, highlights, quiz questions, and personality details.
- Ordered homepage selections and tailored links with custom public text, publication state, expiry, preview, and sharing.
- Private application records separated from minimal public link documents, with transactional slug ownership and validated Firestore rules.
- Idempotent seed tooling, migration dry runs and backups, emulator rule tests, application tests, and an explicit production release workflow.

See [DOCUMENTATION.txt](DOCUMENTATION.txt) for architecture, data boundaries, release sequencing, and operational limits.

## Local development

The workflows pin Flutter **3.44.6**, Node **24**, Java **21**, and Python **3.12**. Use the Dart SDK bundled with Flutter; `pubspec.yaml` declares the Dart constraint separately. The current app supports **web only**.

Commands below use PowerShell from the repository root. On macOS/Linux, use the equivalent virtual-environment activation and the Firebase executable without `.cmd`.

Install the locked dependencies:

```powershell
flutter pub get --enforce-lockfile
npm ci --prefix tooling/firestore
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r scripts/requirements.txt
```

Start Auth and Firestore emulators in a separate terminal:

```powershell
.\tooling\firestore\node_modules\.bin\firebase.cmd emulators:start --project demo-lumen --only auth,firestore --config firebase.json --export-on-exit emulator-data
```

The Emulator UI is at `http://127.0.0.1:4000`; Firestore uses port `8080` and Auth uses `9099`. On a later run, add `--import emulator-data` if an export exists. Java 21 is needed for the Firestore emulator. Stop these processes before running the isolated emulator test command below if they occupy the same port.

Preview the seed plan, then populate only the emulator:

```powershell
python scripts/seed_firestore.py --project demo-lumen --emulator
python scripts/seed_firestore.py --project demo-lumen --emulator --apply
npm --prefix tooling/firestore run setup:emulator-user
flutter run -d chrome --web-port=50164
```

`flutter run` and a plain `flutter build web` use `APP_ENV=emulator` by default. No service-account key or real Firebase project is required for this path. The Python seed command sets its own default emulator address; an explicit `--emulator` flag is always required for a `demo-` project.

The seed creates Firestore content; `setup:emulator-user` separately creates or updates the verified local owner. Sign in at `/login` with **`thejaynesh@gmail.com`** and the disposable password **`Lumen-local-only-2026!`**. The deterministic emulator UID is `lumen-local-owner`. Set `LUMEN_EMULATOR_PASSWORD` before setup to use another local password; the helper never prints that override. These are emulator credentials and must not be reused for a real account.

The helper can also run directly with `node tooling/firestore/setup_emulator_user.mjs`. It only addresses `demo-lumen` at a validated loopback Auth emulator, defaults to `127.0.0.1:9099`, rejects cloud credential/project overrides, and refuses conflicting existing local identities. `AUTH_EMULATOR_HOST` or `FIREBASE_AUTH_EMULATOR_HOST` may select another loopback port; they must agree if both are set. It does not accept a production target or create any real account. The Emulator UI remains available for managing other test accounts.

## Routes and administration

| Route | Purpose |
| --- | --- |
| `/` | Main portfolio |
| `/portfolio?job=your-slug` | Tailored portfolio |
| `/?job=your-slug` | Same customization on the main route |
| `/modes` | Optional alternate experiences |
| `/login` | Owner sign-in |
| `/admin` | Protected content studio |
| `/access-denied` | Signed-in account without admin access |

The old `jobId` query parameter remains a compatibility alias; new links use `job`. Example slugs are not created automatically. Create a tailored link in the studio to test one. An unavailable, archived, or expired link falls back to the ordinary portfolio.

Admin authorization is identical in the client and Firestore rules: the token must contain `admin: true`, **or** the account must have the exact email `thejaynesh@gmail.com` and `email_verified: true`. Signing in alone does not grant editing rights. There is no public registration or permission-granting flow. In a real project, enable Email/Password authentication, provision the owner account, and complete email verification or assign a claim using privileged administrative tooling. Refresh the sign-in session after changing claims.

Projects and experience are archived rather than deleted, preserving references. Archived items are hidden publicly and can be published again. Tailored links can be archived or permanently deleted with confirmation. Their job title, organization, and application notes remain private. Custom introduction/summary fields are public when the link is published. Anyone with a published, unexpired URL can view that public selection; it is not a recipient login system.

An empty homepage selection means **all published items**. An empty tailored-link selection means **no selected items** for that section.

## Staging and production configuration

`lib/config/app_environment.dart` selects the environment at build time:

| `APP_ENV` | Target |
| --- | --- |
| `emulator` (default) | `demo-lumen`, loopback Auth/Firestore emulators |
| `staging` | A separate real Firebase project; complete configuration required |
| `production` | The committed web configuration for `lumen-f2e07` |

Emulator overrides are `FIREBASE_PROJECT_ID` (must start with `demo-`), `FIREBASE_EMULATOR_HOST` (loopback only), `FIRESTORE_EMULATOR_PORT`, and `AUTH_EMULATOR_PORT`.

For staging, supply `FIREBASE_PROJECT_ID`, `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, and `FIREBASE_AUTH_DOMAIN` as environment variables, then run:

```powershell
python scripts/write_staging_config.py
flutter run -d chrome --dart-define-from-file=config/staging.local.json
```

The script writes an ignored configuration file containing `APP_ENV=staging`. It rejects missing values, the production project ID, and `demo-` project IDs. The staging project must already have its Auth provider, authorized admin, Firestore database, deployed rules/indexes, and content configured. Hosting preview channels do not create an isolated database; the separate staging configuration provides that isolation.

A production build is explicit:

```powershell
python scripts/prepare_web.py --site-url https://lumen-f2e07.web.app
flutter build web --release --dart-define=APP_ENV=production
```

Replace the `--site-url` origin only when a different canonical HTTPS domain has been verified. For a preview build, use `python scripts/prepare_web.py --preview`. Preparation is repeatable: a later production invocation replaces the current canonical origin, removes preview noindex metadata, and restores the production robots/sitemap files. The script edits tracked files under `web/`, so inspect those changes. CI checks out a fresh revision before preparation.

To serve any completed build locally with SPA route fallback:

```powershell
python scripts/serve_spa.py 8090
```

The server serves `build/web` on loopback and does not change the build's backend environment. A production build served locally still talks to production.

## Seed and migration operations

Both maintenance tools require `--project` and default to a **read-only dry run**. Real-project access uses Application Default Credentials (`GOOGLE_APPLICATION_CREDENTIALS` is one option), or `--credentials` pointing to a service-account file outside the repository. Explicit service-account files are checked against the selected project.

- `seed_firestore.py`: validates `scripts/seed_data.json`, preserves matching legacy IDs, uses stable IDs for new content, and preserves existing homepage selections unless `--reset-defaults` is passed. Existing values present in the seed can overwrite later admin edits; review the plan before applying. It never wipes collections or seeds jobs.
- `migrate_profiles.py`: creates minimal `publicProfiles/{slug}` documents and private `profileSlugs/{slug}` reservations for existing jobs without changing job or content IDs. Conflicting slugs or invalid legacy data stop the migration.
- Applying to a real project additionally requires matching `--confirm-project` and a **new** `--backup` path. Plans over 450 writes are refused. Source documents are rechecked in the transaction before any writes commit.

Before the first production rollout, inspect the current data and make a full database backup/export using your operational backup process. Then review the migration plan:

```powershell
python scripts/migrate_profiles.py --project lumen-f2e07
```

For a deliberate manual application of the reviewed migration:

```powershell
python scripts/migrate_profiles.py --project lumen-f2e07 --apply --confirm-project lumen-f2e07 --backup backups/profiles-before-release-001.json
```

Use a different unused backup filename each time. These JSON backups contain before-images of documents the operation changes; they are not full database exports and there is no automatic restore command. Keep backups private and review any restoration separately. Do not run the seed against production as a routine release step.

Run the profile migration **before** deploying the stricter rules and new frontend so existing tailored links have their public documents ready. The production release workflow performs this migration before deployment.

## Verification

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
python -m unittest discover -s scripts -p 'test_*.py'
npm --prefix tooling/firestore run test:setup
npm --prefix tooling/firestore run test:emulator
flutter build web --release --no-pub
```

Install dependencies first. The rule tests launch an isolated Firestore emulator for `demo-lumen`; they do not exercise the production database. Application coverage includes model parsing, public data selection, routes/environment handling, view-event deduplication, public UI states, and admin editing. CI runs these checks and a web build; it does not certify live credentials, account claims, DNS, deployed rules, or every browser/device.

The development-only `tooling/firestore/package.json` includes targeted overrides for `@grpc/grpc-js` (1.14.5), the Pub/Sub dependency's `@opentelemetry/core` (2.11.0), the Gaxios dependency's `uuid` (11.1.1), and `re2` (1.27.0). These select patched transitive Firebase CLI dependencies while retaining the tested CLI version; they are not Flutter application dependencies. The locked tooling tree reported zero vulnerabilities in the audit performed for this update. Recheck with `npm audit --prefix tooling/firestore` when updating dependencies, and keep the lockfile and emulator tests aligned with any override change.

## GitHub workflows

- **Verify portfolio** (`ci.yml`): runs on main pushes and pull requests, and is reused by release/preview jobs. It checks formatting, analysis, Flutter tests, Python tests, Firestore rules in the emulator, and a web build.
- **Preview portfolio on staging**: runs after checks for same-repository PRs. Configure the `staging` environment with variables `FIREBASE_STAGING_PROJECT_ID`, `FIREBASE_STAGING_API_KEY`, `FIREBASE_STAGING_APP_ID`, `FIREBASE_STAGING_MESSAGING_SENDER_ID`, `FIREBASE_STAGING_AUTH_DOMAIN`, and secret `FIREBASE_SERVICE_ACCOUNT_STAGING`. Configuration is checked inside that environment: a fully unconfigured preview skips with a clear notice; partial configuration, production targets, or mismatched credentials fail. Preview publishing deploys Hosting only, so provision staging rules/data separately. Preview indexing is disabled.
- **Release portfolio**: automatically runs on pushes to `main` and deploys after checks pass. It can also be dispatched manually from `main` with `publish=true` (manual dispatch defaults to checks only). It uses the `production` environment, builds with explicit production configuration, backs up/migrates share profiles, and deploys Firestore rules, indexes, and Hosting. Configure secret `FIREBASE_SERVICE_ACCOUNT_LUMEN_F2E07` with the required Firestore/Hosting access and optional variable `SITE_URL`. Production releases are serialized. Migration backup artifacts are retained for seven days; preserve them separately if needed longer. Configure GitHub environment protection/reviewers if your release process requires approval.

`.firebaserc` still identifies production as the Firebase CLI default. Use an explicit `--project` for operational CLI commands. A push to `main` verifies code and then automatically deploys production when checks and release prerequisites succeed.

## Deliberate scope and limits

This is a single-owner web portfolio. It has no file-upload backend, generated PDF résumé, contact-email service, blog CMS, multi-user role manager, recipient-restricted links, or native app targets. Images and résumé links point to hosted URLs or bundled assets; the bundled PDF is `web/Jaynesh-Bhandari-Resume.pdf`.

The public HTML overview, social metadata, sitemap, and social image are repository assets, not a server-rendered copy of Firestore. Update/rebuild them when their content changes; admin profile edits do not rewrite those files. Published customized text is loaded by the Flutter app after startup.

Production can emit the generic Firebase Analytics event `portfolio_profile_view` once per tailored slug per service session. It sends no slug, job title, company, or application notes as event parameters; failures never block page loading. Legacy Firestore `viewCount` values are preserved but no longer updated by clients or shown as current analytics. Analytics collection/reporting still depends on the Firebase project's configuration, browser behavior, and any consent requirements of the deployment. There is no in-app analytics dashboard.
