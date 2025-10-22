# EduLift Mobile E2E Testing with Patrol

## 🎯 Overview

This directory contains the **autonomous End-to-End (E2E) testing infrastructure** for the EduLift mobile application using [Patrol](https://patrol.leancode.co/), a powerful Flutter UI testing framework.

### 🚀 Key Features
- **🏗️ Autonomous System**: Complete Docker-based backend environment
- **🎯 Real Backend Testing**: Tests run against actual backend services (no mocks)
- **📧 Real Email Testing**: Email delivery testing with MailHog
- **🔒 Data Isolation**: Each test uses unique data to prevent conflicts  
- **⚡ Automated Lifecycle**: Docker services managed automatically
- **🔄 No Database Resets**: Tests accumulate data like production

## 🏗️ Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│   Backend API    │────▶│   PostgreSQL    │
│   (Patrol)      │     │ (Node.js:8030)   │     │   (Database)    │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌──────────────────┐     ┌─────────────────┐
                        │     MailHog      │     │     Redis       │
                        │ (Email UI:8031)  │     │   (Sessions)    │
                        └──────────────────┘     └─────────────────┘
```

**Important**: This E2E environment is **completely separate** from the web E2E tests:
- Mobile E2E: Backend port **8030**, MailHog port **8031**
- Web E2E: Backend port **8002**, MailHog port **8025**  
- Different databases: `edulift_mobile_e2e` vs `edulift_e2e`

## 📋 Prerequisites

### Required Tools
1. **Flutter & Dart**: Latest stable version
2. **Docker & Docker Compose**: For backend services
3. **Patrol CLI**: `dart pub global activate patrol_cli`
4. **Device**: Android emulator or iOS simulator

### System Check
```bash
make check-tools  # Verify all tools are installed
```

## 🚀 Quick Start

### 1. First Time Setup
```bash
# Install Flutter dependencies
make install

# Install Patrol CLI globally
dart pub global activate patrol_cli

# Bootstrap Patrol (one-time setup)
patrol bootstrap
```

### 2. Run E2E Tests
```bash
# Simple approach - everything automated
make e2e-test

# Or step by step:
make e2e-start     # Start Docker services
make e2e-test      # Run tests
make e2e-stop      # Stop services when done
```

### 3. View Results
- Test results appear in terminal
- Screenshots saved in `screenshots/` on failure
- Test reports in `test_results/` directory

## 📁 Directory Structure

```
integration_test/
├── docker-compose.yml              # 🐳 Docker services configuration
├── run_patrol_tests.sh            # 🤖 Main test runner script
├── patrol.yaml                    # ⚙️ Patrol configuration
├── helpers/
│   ├── test_data_generator.dart   # 🎲 Unique data generation
│   └── mailpit_helper.dart        # 📧 Email extraction (read-only)
└── README.md                      # 📖 This file

integration_test/
├── auth_e2e_test.dart             # 🔐 Authentication & signup flows
├── invitation_e2e_test.dart       # 💌 Unified invitation system
├── onboarding_e2e_test.dart       # 🚀 User onboarding & family creation
├── family_management_e2e_test.dart # 👨‍👩‍👧‍👦 Family features (existing)
├── real_backend_magic_link_e2e_test.dart # 🧪 Magic link flows (existing)
└── backend_connectivity_test.dart  # 🔌 Backend connectivity (existing)
```

## 🧪 Test Coverage Overview

### 🔐 Authentication Tests (`auth_e2e_test.dart`)
Tests based on Functional-Documentation.md authentication flows:

- **Complete user registration flow**: Email input → Magic link → Account verification
- **Existing user login flow**: Return user authentication with preserved session
- **Error handling**: Invalid emails, network issues, magic link expiration
- **Security features**: Magic link reuse prevention, token validation

### 💌 Invitation System Tests (`invitation_e2e_test.dart`) 
Tests the Unified Invitation System with all scenarios from Functional-Documentation.md:

- **Scenario 1**: Unauthenticated user receives invitation → Authentication → Auto family join
- **Scenario 2**: Authenticated user (no family) → Direct join flow
- **Scenario 3**: Authenticated user (has family) → Family conflict resolution
- **Scenario 4**: Error handling → Invalid codes, expired invitations, malformed URLs

### 🚀 Onboarding Tests (`onboarding_e2e_test.dart`)
Tests complete user onboarding workflow from Functional-Documentation.md:

- **New user path**: Registration → Family creation → Resource setup → Group readiness
- **Join existing family path**: Invitation-based onboarding with family membership
- **Family role management**: Admin/Member permissions, role promotion/demotion
- **Resource management**: Children and vehicles CRUD operations with validation

### 👨‍👩‍👧‍👦 Family Management Tests (existing)
Comprehensive family coordination tests (pre-existing):

- Family creation and invitation flows
- Member management and permissions
- Resource sharing and coordination

## 🧪 Writing New E2E Tests

### ✅ Data Isolation Strategy (CRITICAL)

**Every test MUST use unique data** to prevent conflicts:

```dart
import 'helpers/test_data_generator.dart';

patrolTest('user can create family', ($) async {
  // ✅ CORRECT: Generate unique data for THIS test
  final email = TestDataGenerator.generateUniqueEmail();
  final familyName = TestDataGenerator.generateUniqueFamilyName();
  
  // Use the unique data in your test
  await $.enterText(find.byKey(Key('emailField')), email);
  await $.enterText(find.byKey(Key('familyNameField')), familyName);
  // ... rest of test
});
```

**❌ NEVER do this:**
```dart
// ❌ BAD: Hardcoded data causes conflicts
await $.enterText(find.byKey(Key('emailField')), 'test@example.com');
```

### 🏗️ Test Structure Template

```dart
void main() {
  group('Feature E2E Tests', () {
    setUp(() async {
      // Clear emails before each test
      await MailHogHelper.clearAllEmails();
    });

    patrolTest('complete user journey', ($) async {
      // 1️⃣ SETUP: Generate unique test data
      final testEmail = TestDataGenerator.generateUniqueEmail();
      final familyName = TestDataGenerator.generateUniqueFamilyName();
      
      // 2️⃣ ACTION: Interact with real app UI
      await app.main();
      await $.pumpAndSettle();
      
      await $.tap(find.text('Sign Up'));
      await $.enterText(find.byKey(Key('emailField')), testEmail);
      await $.tap(find.text('Send Magic Link'));
      
      // 3️⃣ VERIFICATION: Check results with real backend
      await $.waitUntilVisible(find.text('Email Sent'));
      
      // 4️⃣ EMAIL INTERACTION: Handle real emails
      final magicLink = await MailHogHelper.waitForMagicLink(testEmail);
      expect(magicLink, isNotNull);
      
      await $.native.openUrl(magicLink!);
      await $.waitUntilVisible(find.text('Welcome'));
    });
  });
}
```

## 🐳 Docker Services

### Services Overview

| Service | Internal Port | External Port | Purpose |
|---------|---------------|---------------|---------|
| Backend | 3001 | **8030** | API server |
| PostgreSQL | 5432 | *(internal)* | Database |
| Redis | 6379 | *(internal)* | Sessions |
| MailHog SMTP | 1025 | **8027** | Email delivery |
| MailHog Web | 8025 | **8031** | Email UI |

### Managing Services

```bash
# Start services
make e2e-start

# Check status  
make e2e-status

# View logs
make e2e-logs

# Stop services (preserve data)
make e2e-stop

# Clean everything (remove data)
make e2e-clean
```

## ⚙️ Configuration

### Environment Variables
Tests automatically set:
- `E2E_TEST=true`
- `FLUTTER_TEST_MODE=e2e`  
- `E2E_ANDROID_EMULATOR=true`

### Backend Configuration
The Docker backend runs with:
- `NODE_ENV=test`
- Database: `edulift_mobile_e2e`
- Email: `mailpit-mobile-e2e:1025`

### Patrol Configuration (`patrol.yaml`)
- **Sequential execution** by default (safer)
- **App data clearing** between test files (Android)
- **Screenshots** on failure
- **3-minute timeout** per test

## 🏃‍♂️ Running Tests

### Execution Modes

#### Sequential (Recommended)
```bash
make e2e-test
# Tests run one after another - safest for data isolation
```

#### Parallel (Advanced)
```bash
make e2e-test-parallel  
# Tests run concurrently - faster but requires perfect isolation
```

#### Clean Start
```bash
make e2e-clean-test
# Removes all Docker data and starts fresh
```

### Run Specific Tests
```bash
# Run specific test file
patrol test --target integration_test/family_management_e2e_test.dart

# Run with custom device
patrol test --device-id emulator-5554
```

## 🐛 Debugging & Troubleshooting

### Common Issues & Solutions

#### ❌ Backend Not Starting
```bash
# Check logs
make e2e-logs

# Try clean restart
make e2e-clean && make e2e-start

# Check if ports are free
make show-ports
```

#### ❌ Tests Can't Connect to Backend
- **Android emulator**: Uses `10.0.2.2:8030` 
- **iOS simulator**: Uses `localhost:8030`
- Check `E2EConfig.dart` configuration

#### ❌ Emails Not Arriving  
```bash
# Check MailHog UI
open http://localhost:8031

# Check backend email logs
make e2e-logs | grep -i mail

# Debug email count
make e2e-mailpit-emails
```

#### ❌ Data Conflicts Between Tests
- Ensure using `TestDataGenerator` for ALL data
- Never hardcode emails, names, etc.
- Run sequential instead of parallel
- Check test isolation in code

#### ❌ App Not Found
```bash
# Build app first
make build-android  # or build-ios
```

### Debug Commands
```bash
# View all logs in real-time
make e2e-debug

# Access backend container shell  
make e2e-shell-backend

# Access database directly
make e2e-shell-db

# List all emails in MailHog
make e2e-mailpit-emails
```

## 🎯 Best Practices

### ✅ DO

- **Always use `TestDataGenerator`** for unique test data
- **Test complete user journeys** (true E2E)
- **Wait for UI elements** with `$.waitUntilVisible()`
- **Use meaningful test descriptions**
- **Group related tests** logically
- **Clean up MailHog** before tests: `MailHogHelper.clearAllEmails()`
- **Check real email delivery** for auth flows

### ❌ DON'T

- **Never hardcode test data** (emails, names, etc.)
- **Don't make direct API calls** in tests (except MailHog)
- **Don't reset the database** between tests
- **Don't assume test execution order**
- **Don't use production endpoints**
- **Don't skip email verification** in auth tests

### 📝 Naming Conventions

#### Test Files
- `*_e2e_test.dart` - E2E test files
- Group by feature: `auth_`, `family_`, `group_`, etc.

#### Test Data Prefixes  
```dart
// Use prefixes to categorize test data
final adminEmail = TestDataGenerator.generateEmailWithPrefix('admin');
final memberEmail = TestDataGenerator.generateEmailWithPrefix('member');
```

#### Test Descriptions
```dart
patrolTest('admin can invite family member via email magic link', ($) async {
  // Clear, specific description of the complete user journey
});
```

## 📊 Test Organization

### Test Categories

| Test File | Email Prefix | Purpose |
|-----------|-------------|---------|
| `auth_e2e_test.dart` | `auth_*` | Authentication & signup |
| `family_e2e_test.dart` | `family_*` | Family management |
| `invitation_e2e_test.dart` | `invite_*` | Magic link invitations |
| `group_e2e_test.dart` | `group_*` | Group features |

### Data Isolation Strategy

```dart
// Each test gets completely unique data
final testData = TestDataGenerator.generateUniqueFamilyProfile(prefix: 'test');
// Results in:
// {
//   'familyName': 'Family_1704123456789_a1b2c3d4',
//   'admin': {
//     'email': 'test_1704123456789_e5f6g7h8@e2e.edulift.com',
//     'firstName': 'FirstName_1704123456789',
//     'lastName': 'LastName_1704123456789'
//   }
// }
```

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
name: Mobile E2E Tests

on: [push, pull_request]

jobs:
  mobile-e2e:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Setup CI Environment
        run: make ci-setup
        
      - name: Run E2E Tests
        run: make ci-e2e
        
      - name: Upload Screenshots  
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: e2e-screenshots
          path: mobile_app/screenshots/
```

### Make Commands for CI
```bash
make ci-setup    # Install dependencies + Patrol
make ci-test     # Run lint, unit tests, build
make ci-e2e      # Run full E2E test suite
```

## 📈 Performance & Monitoring

### Execution Times
- **Sequential**: ~5-10 minutes (safer)
- **Parallel**: ~3-5 minutes (requires perfect isolation)
- **Clean start**: +2 minutes (Docker container rebuild)

### Resource Usage
- **Docker services**: ~2GB RAM
- **Test artifacts**: ~50MB per test run
- **Screenshots**: ~5MB per failure

### Optimization Tips
1. **Keep Docker running** between test iterations
2. **Use `.dockerignore`** to reduce build context
3. **Parallel tests** only if data is truly isolated  
4. **Clean old artifacts** regularly

## 📚 Learning Resources

### Essential Reading
- [Patrol Documentation](https://patrol.leancode.co/)
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Docker Compose Reference](https://docs.docker.com/compose/)

### Internal Documentation
- `../CLAUDE.md` - Project configuration
- `../../backend/README.md` - Backend setup
- `../../e2e/README.md` - Web E2E tests (different setup)

## 🤝 Contributing Guidelines

### Adding New E2E Tests

1. **Create test file** in `integration_test/`
2. **Use unique data prefix** for your feature
3. **Follow naming conventions**
4. **Include comprehensive test scenarios**
5. **Document complex test flows**
6. **Ensure tests pass both sequential and parallel**

### Test Review Checklist

- [ ] Uses `TestDataGenerator` for all test data
- [ ] No hardcoded emails, names, or IDs
- [ ] Tests complete user journeys (not just API calls)
- [ ] Includes both positive and negative scenarios
- [ ] Proper error handling and edge cases
- [ ] Clears MailHog before email tests
- [ ] Descriptive test names and comments
- [ ] Passes in both sequential and parallel modes

## 🆘 Getting Help

### Quick Diagnostics
```bash
make e2e-help      # Comprehensive E2E guide
make e2e-status    # Check all services
make e2e-debug     # Real-time log monitoring
```

### Support Channels
1. **Check logs first**: `make e2e-logs`
2. **Review this README** thoroughly  
3. **Check existing tests** for patterns
4. **Verify Docker services** are healthy

### Emergency Reset
```bash
# Nuclear option - reset everything
make e2e-clean
docker system prune -f
make e2e-start
```

## 💡 Tips & Tricks

### Speed Up Development
```bash
# Keep services running during development
make e2e-start
# ... run tests multiple times ...
make e2e-stop  # when finished
```

### Email Debugging
```bash
# Open MailHog UI
open http://localhost:8031

# Count emails programmatically
curl -s http://localhost:8031/api/v2/messages | jq '.count'
```

### Test Debugging
```dart
// Add debugging prints in tests
debugPrint('🔍 Generated test email: $testEmail');
debugPrint('📧 Waiting for email...');

// Take manual screenshots  
await $.screenshot('debug_screenshot');
```

### Database Inspection
```bash
# Access PostgreSQL directly
make e2e-shell-db

# Run queries
\dt  # List tables
SELECT * FROM users WHERE email LIKE '%e2e.edulift.com';
```

---

## 🎉 Success Indicators

You've successfully set up E2E testing when:

- ✅ `make e2e-test` runs without errors
- ✅ Docker services start automatically  
- ✅ Tests use unique data (no hardcoded values)
- ✅ Real emails are sent and verified
- ✅ Tests pass consistently (sequential mode)
- ✅ Screenshots capture failures
- ✅ Services can be started/stopped cleanly

---

**Remember**: These are **TRUE** end-to-end tests - no mocks, no shortcuts, just real user journeys against a real backend! 🚀

For questions or improvements to this documentation, please update this README with your findings to help future developers.