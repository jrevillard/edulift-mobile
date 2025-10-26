# Release Process

This document describes the release process and CI/CD strategy for EduLift Mobile.

## Build Flavors

The app has three build flavors:

- **development** - For internal development and continuous testing
- **staging** - For UAT, pre-production testing, and final validation
- **prod** - For production releases to App Store and Play Store

## CI/CD Strategy

Our CI/CD pipeline follows modern best practices by building specific flavors for specific purposes:

### Development Builds
- **Trigger**: Push to `main` branch
- **Flavor**: `development` only
- **Purpose**: Continuous integration testing
- **Distribution**: Firebase App Distribution to internal testers
- **Frequency**: Every merge to main

### Staging Builds
- **Trigger**: Pre-release tags (e.g., `v1.0.0-rc.1`, `v1.0.0-beta.1`)
- **Flavor**: `staging` only
- **Purpose**: Release candidate for UAT and final business approval
- **Distribution**: Manual (via artifacts or store beta tracks)
- **Frequency**: When preparing for a release

### Production Builds
- **Trigger**: Production tags (e.g., `v1.0.0`)
- **Flavor**: `prod` only
- **Purpose**: Official release to app stores
- **Distribution**: App Store and Play Store
- **Frequency**: When staging build is approved

## Release Workflow

### 1. Development Phase
```bash
# Regular development - merge features to main
git checkout main
git merge feature/my-feature
git push origin main
# → Triggers development build
```

### 2. Prepare Release Candidate
```bash
# Create release candidate tag
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1
# → Triggers staging build only
```

**Test the staging build thoroughly:**
- Run UAT tests
- Get business approval
- Test against staging backend
- Verify all features work as expected

If issues are found, fix them and create `v1.0.0-rc.2`, `v1.0.0-rc.3`, etc.

### 3. Create Production Release
```bash
# Once staging is approved, create production tag
git tag v1.0.0
git push origin v1.0.0
# → Triggers prod build only
```

The production tag triggers:
- Production build for Android and iOS
- GitHub Release creation
- Artifacts ready for store submission

### 4. Submit to Stores
- Download production artifacts from GitHub Actions
- Submit to Apple App Store Connect
- Submit to Google Play Console

## Tag Naming Convention

Follow [Semantic Versioning](https://semver.org/):

- **Production**: `v1.0.0`, `v1.2.3`
- **Pre-release**: `v1.0.0-rc.1`, `v1.0.0-beta.1`, `v1.0.0-alpha.1`

**Important:**
- Pre-release tags (with suffixes) build **staging** flavor
- Production tags (without suffixes) build **prod** flavor
- Never use environment names in tags (e.g., ~~`v1.0.0-staging`~~)

## Manual Builds

You can also trigger builds manually via GitHub Actions:

1. Go to Actions → CD Pipeline → Run workflow
2. Select parameters:
   - **build_type**: `debug` or `release`
   - **platform**: `android`, `ios`, `both`, or `android-fast`
3. Builds `development` flavor by default

## Benefits of This Strategy

1. **Efficiency**: No wasted CI minutes building unnecessary flavors
2. **Clarity**: Each trigger has a clear, single purpose
3. **Safety**: Production tags exclusively create production builds
4. **Traceability**: Clear version history tied to specific builds
5. **Promotion**: Test the exact artifacts that go to production

## Example Timeline

```
Day 1-10: Development
├─ Multiple feature merges to main
├─ Each triggers development build
└─ Continuous testing by dev team

Day 11: Release Preparation
├─ Create v1.0.0-rc.1 tag
├─ Triggers staging build
└─ Begin UAT testing

Day 12: Bug fixes
├─ Fix issues found in UAT
├─ Create v1.0.0-rc.2 tag
└─ Triggers new staging build

Day 13: Approval
├─ Staging approved by stakeholders
├─ Create v1.0.0 production tag
├─ Triggers prod build
└─ Submit to stores

Day 14: Release
└─ App goes live in stores
```

## Troubleshooting

**Q: I need to rebuild staging without creating a new tag**
A: Use manual workflow dispatch and modify the workflow temporarily, or create a new rc tag (e.g., rc.3)

**Q: Can I build multiple flavors at once?**
A: Not recommended. Each flavor should be built for its specific purpose through the appropriate trigger.

**Q: What if I need an emergency prod hotfix?**
A: Fix the issue, merge to main, create a new production tag (e.g., `v1.0.1`)
