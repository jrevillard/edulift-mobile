📌 Migration Plan for Codebase & Tests

This plan is designed so a junior developer can execute it step by step without breaking imports. Each step has clear rules, folder moves, and examples.

1. General Rules

Never rename files and folders in the same commit as moving them. First move, then fix imports.

After each move, run flutter analyze and flutter test and check that nothing is broken.

Commit often (one logical group of moves per commit).

2. Codebase Migration

Step 1 – Simplify Core/Infrastructure/Shared

Delete shared/ and infrastructure/ folders.

Move content into core/.

Old path

New path

lib/infrastructure/network/*

lib/core/network/*

lib/infrastructure/storage/*

lib/core/security/storage/*

lib/infrastructure/services/*

lib/core/services/*

lib/shared/services/*

lib/core/services/*

lib/shared/presentation/pages/*

lib/core/presentation/pages/*

lib/shared/presentation/widgets/*

lib/core/presentation/widgets/*

lib/shared/presentation/providers/*

lib/core/services/* (if global)

lib/shared/themes/*

lib/core/presentation/themes/*

✅ Commit 1: "Consolidated shared & infrastructure into core."

Step 2 – Flatten Feature Trees

For every feature (auth, family, dashboard, etc.):

Before:

features/family/data/datasources/persistence/specialized/

After:

features/family/data/datasources/

Merge screens/ into pages/.

Keep widgets/ only if there are ≥3 widgets.

✅ Commit 2: "Flattened feature subfolders (datasources, screens)."

Step 3 – Normalize Core

Move constants/ → core/config/

Move converters/ → core/utils/

Move validation/ → core/utils/validation/

Keep only truly cross-cutting entities in core/domain/. Others go to their feature.

✅ Commit 3: "Normalized core folder structure."

Step 4 – Cleanup & Verify

Remove empty folders (shared/, infrastructure/).

Run flutter pub run build_runner build --delete-conflicting-outputs.

Run flutter test and fix imports.

✅ Commit 4: "Removed old empty folders, verified build & tests."

3. Test Migration

Tests should mirror the new code structure.

Step 1 – High-Level Reorg

Keep root test groups:

unit/

integration/

goldens/

presentation/ (UI tests)

support/ (helpers, mocks)

architecture/ (rules)

✅ Commit 5: "Created cleaned test structure."

Step 2 – Match Features

For each feature, mirror data/domain/presentation.

Before:

test/unit/domain/family/entities/family_test.dart

After:

test/unit/features/family/domain/entities/family_test.dart

Before:

test/unit/data/family/repositories/family_repository_impl_test.dart

After:

test/unit/features/family/data/repositories/family_repository_impl_test.dart

✅ Commit 6: "Moved unit tests under unit/features/."

Step 3 – Core Tests

All cross-cutting tests stay in unit/core/*.

Example:

test/unit/core/network/api_client_test.dart

test/unit/core/security/crypto_service_test.dart

✅ Commit 7: "Cleaned up core tests."

Step 4 – Goldens & UI

Keep goldens per feature:

test/goldens/family/

Keep UI tests in presentation/<feature>.

✅ Commit 8: "Organized presentation & goldens tests."

Step 5 – Support

Keep helpers, mocks, fixtures in test/support/.

Example:

support/test_helpers.dart

support/mocks/auth_repository_mock.dart

✅ Commit 9: "Consolidated test helpers & mocks."

4. Final Structure (Target)

lib/
 ├── core/
 │   ├── config/
 │   ├── di/
 │   ├── errors/
 │   ├── interfaces/
 │   ├── network/
 │   ├── security/
 │   ├── services/
 │   ├── utils/
 │   └── presentation/
 │
 ├── features/
 │   ├── auth/
 │   │   ├── data/
 │   │   ├── domain/
 │   │   └── presentation/
 │   ├── family/
 │   ├── dashboard/
 │   ├── groups/
 │   ├── invitations/
 │   ├── onboarding/
 │   └── schedule/
 │
 ├── generated/
 ├── l10n/
 ├── edulift_app.dart
 └── main.dart

test/
 ├── unit/
 │   ├── core/
 │   └── features/<feature>/...
 ├── integration/
 ├── presentation/
 │   └── <feature>/...
 ├── goldens/
 │   └── <feature>/...
 ├── support/
 └── architecture/

