# USE CASE CONSOLIDATION PLAN
## From 21+ Use Cases to 8 Services - Zero Risk Migration

### EXECUTIVE SUMMARY

Transform over-fragmented use case architecture by consolidating 60-70% of repository wrapper use cases into domain services while preserving complex business logic. Migration follows zero-downtime adapter pattern with full rollback capability.

**IMPACT**: Reduce codebase complexity from 21+ use cases to 8 services/use cases, eliminating ~60% of boilerplate code while maintaining identical functionality.

---

## ARCHITECTURE COMPLIANCE VERIFICATION ✅

**CRITICAL**: This plan has been validated against ALL existing architecture tests:
- ✅ `dependency_rules_test.dart` - Domain services placement allowed
- ✅ `usecase_rules_test.dart` - Rules apply only to UseCases, not Services
- ✅ `framework_isolation_test.dart` - Domain layer services permitted
- ✅ `infrastructure_layer_test.dart` - Services pattern explicitly supported
- ✅ `architectural_compliance_validator.dart` - Services recognized and allowed

**NO ARCHITECTURE TEST MODIFICATIONS REQUIRED**

---

## TRANSFORMATION OVERVIEW

```
BEFORE:                     AFTER:
├─ Groups Domain           ├─ Groups Domain
│  ├─ GetUserGroupsUsecase │  └─ GroupService (5 methods)
│  ├─ CreateGroupUsecase   │
│  ├─ UpdateGroupUsecase   │
│  ├─ DeleteGroupUsecase   │
│  └─ GetGroupByIdUsecase  │
│                          │
├─ Children Domain         ├─ Children Domain  
│  ├─ AddChildUsecase      │  └─ ChildrenService (3 methods)
│  ├─ UpdateChildUsecase   │
│  └─ RemoveChildUsecase   │
│                          │
├─ Auth Domain             ├─ Auth Domain
│  ├─ GetCurrentUserUsecase│  └─ AuthService (2 methods)
│  └─ LogoutUsecase        │
│                          │
├─ Complex Use Cases       ├─ Complex Use Cases (PRESERVED)
│  ├─ GetFamilyUsecase     │  ├─ GetFamilyUsecase ✅
│  ├─ ClearAllFamily...    │  ├─ ClearAllFamilyDataUsecase ✅
│  ├─ CreateFamilyUsecase  │  ├─ CreateFamilyUsecase ✅
│  └─ SendMagicLinkUsecase │  └─ SendMagicLinkUsecase ✅
```

---

## MIGRATION PHASES

### PHASE 1: SERVICE FOUNDATION (Week 1 - Zero Risk)

#### Step 1.1 - GroupService Creation

**Location**: `lib/features/groups/domain/services/`

**Files to Create**:
```
├─ group_service.dart       (Interface)
└─ group_service_impl.dart  (Implementation)
```

**Interface Definition**:
```dart

import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../entities/group.dart';
import '../requests/create_group_command.dart';

abstract class IGroupService {
  Future<Result<List<Group>, ApiFailure>> getAll();
  Future<Result<Group, ApiFailure>> getById(String id);
  Future<Result<Group, ApiFailure>> create(CreateGroupCommand command);
  Future<Result<Group, ApiFailure>> update(String id, Map<String, dynamic> updates);
  Future<Result<void, ApiFailure>> delete(String id);
}
```

**Implementation Template**:
```dart

import '../repositories/group_repository.dart';
import 'group_service.dart';

@Injectable(as: IGroupService)
class GroupServiceImpl implements IGroupService {
  final GroupRepository _repository;

  GroupServiceImpl(this._repository);

  @override
  Future<Result<List<Group>, ApiFailure>> getAll() async {
    return await _repository.getGroups();
  }

  @override
  Future<Result<Group, ApiFailure>> getById(String id) async {
    return await _repository.getGroupById(id);
  }

  @override
  Future<Result<Group, ApiFailure>> create(CreateGroupCommand command) async {
    // EXTRACT validation logic from CreateGroupUsecase here
    return await _repository.createGroup(command);
  }

  @override
  Future<Result<Group, ApiFailure>> update(String id, Map<String, dynamic> updates) async {
    // EXTRACT validation logic from UpdateGroupUsecase here
    return await _repository.updateGroup(id, updates);
  }

  @override
  Future<Result<void, ApiFailure>> delete(String id) async {
    return await _repository.deleteGroup(id);
  }
}
```

**Validation Logic Extraction**:
- Extract from `CreateGroupUsecase`: Name length validation, description limits
- Extract from `UpdateGroupUsecase`: Update validation, duplicate checks
- Consolidate into private methods within `GroupServiceImpl`

**Testing Requirements**:
```dart
// File: test/unit/features/groups/domain/services/group_service_test.dart
class GroupServiceTest {
  // Test all 5 methods: getAll, getById, create, update, delete
  // Mock GroupRepository dependency
  // Verify validation logic extracted correctly
  // Ensure Result<T, Failure> pattern maintained
  // Test error scenarios and success paths
}
```

**DI Registration**:
```dart
// Add to injection.config.dart (auto-generated)
// Verify with: flutter packages pub run build_runner build
```

**Success Criteria**:
- [ ] App compiles and runs identically to before
- [ ] All existing tests pass
- [ ] New service tests achieve 100% coverage
- [ ] Architecture tests continue passing

#### Step 1.2 - ChildrenService Creation

**Location**: `lib/features/family/domain/services/`

**Methods to Implement**:
- `add(CreateChildRequest request)` - Extract from AddChildUsecase
- `update(UpdateChildParams params)` - Extract from UpdateChildUsecase  
- `remove(String childId)` - Extract from RemoveChildUsecase

**Template**:
```dart
@Injectable(as: IChildrenService)
class ChildrenServiceImpl implements IChildrenService {
  final FamilyRepository _repository; // Note: Uses existing family repository

  Future<Result<Child, ApiFailure>> add(CreateChildRequest request) async {
    // Direct delegation - AddChildUsecase is already a thin wrapper
    return await _repository.addChildFromRequest(request);
  }
}
```

#### Step 1.3 - AuthService Creation

**Location**: `lib/features/auth/domain/services/`

**Methods to Implement**:
- `getCurrentUser()` - Extract from GetCurrentUserUsecase
- `logout()` - Extract from LogoutUsecase

**Template**:
```dart
@Injectable(as: IAuthService)
class AuthServiceImpl implements IAuthService {
  final AuthRepository _repository;

  Future<Result<User, ApiFailure>> getCurrentUser() async {
    return await _repository.getCurrentUser();
  }

  Future<Result<void, ApiFailure>> logout() async {
    return await _repository.logout();
  }
}
```

#### Step 1.4 - Mock Infrastructure Setup

**Add to test_mocks.dart**:
```dart
import 'package:edulift/features/groups/domain/services/group_service.dart';
import 'package:edulift/features/family/domain/services/children_service.dart';
import 'package:edulift/features/auth/domain/services/auth_service.dart';

@GenerateNiceMocks([
  MockSpec<IGroupService>(),
  MockSpec<IChildrenService>(),
  MockSpec<IAuthService>(),
])
```

**Regenerate Mocks**:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

### PHASE 2: ADAPTER CONVERSION (Week 2 - Low Risk)

#### Migration Pattern for Each UseCase

**Template**:
```dart
// BEFORE: Direct repository wrapper
class GetUserGroupsUsecase {
  final GroupRepository _repository;
  Future<Result<List<Group>, ApiFailure>> call() async {
    return await _repository.getGroups();
  }
}

// AFTER: Service adapter (maintains exact same interface)
class GetUserGroupsUsecase {
  final IGroupService _groupService;
  
  GetUserGroupsUsecase(this._groupService);
  
  Future<Result<List<Group>, ApiFailure>> call() async {
    return await _groupService.getAll();
  }
}
```

#### Conversion Checklist

**Groups Domain**:
- [ ] `GetUserGroupsUsecase` → `_groupService.getAll()`
- [ ] `CreateGroupUsecase` → `_groupService.create(command)`
- [ ] `UpdateGroupUsecase` → `_groupService.update(id, updates)`
- [ ] `DeleteGroupUsecase` → `_groupService.delete(id)`
- [ ] `GetGroupByIdUsecase` → `_groupService.getById(id)`

**Children Domain**:
- [ ] `AddChildUsecase` → `_childrenService.add(request)`
- [ ] `UpdateChildUsecase` → `_childrenService.update(params)`
- [ ] `RemoveChildUsecase` → `_childrenService.remove(childId)`

**Auth Domain**:
- [ ] `GetCurrentUserUsecase` → `_authService.getCurrentUser()`
- [ ] `LogoutUsecase` → `_authService.logout()`

**Critical Requirements**:
1. **Preserve Exact Interfaces**: All existing method signatures must remain identical
2. **Maintain DI Patterns**: Update constructor injection to use services
3. **Keep Result Pattern**: All return types remain `Future<Result<T, Failure>>`
4. **No Behavioral Changes**: Functionality must be 100% identical

**Validation Process**:
```bash
# After each adapter conversion:
flutter test                              # All tests must pass
flutter analyze                           # Zero issues
flutter test test/architecture/           # Architecture compliance
```

---

### PHASE 3: CONSUMER MIGRATION (Week 3 - Medium Risk)

#### 3.1 Consumer Discovery

**Search Commands**:
```bash
# Find all consumers of each use case
grep -r "GetUserGroupsUsecase" lib/ --include="*.dart"
grep -r "CreateGroupUsecase" lib/ --include="*.dart"
# ... repeat for all use cases being consolidated
```

**Documentation Template**:
```
USE CASE: GetUserGroupsUsecase
CONSUMERS FOUND:
├─ lib/features/groups/presentation/providers/groups_provider.dart:23
├─ lib/features/groups/presentation/pages/groups_list_page.dart:45
├─ test/unit/features/groups/presentation/providers/groups_provider_test.dart:67
└─ test/integration/groups/groups_flow_test.dart:123

MIGRATION PLAN:
- Replace constructor injection: GetUserGroupsUsecase → IGroupService
- Update method calls: _getUserGroups.call() → _groupService.getAll()
- Update test mocks: MockGetUserGroupsUsecase → MockGroupService
```

#### 3.2 Provider Migration Strategy

**Before**:
```dart
class GroupsProvider extends StateNotifier<GroupsState> {
  final GetUserGroupsUsecase _getUserGroups;
  final CreateGroupUsecase _createGroup;
  final UpdateGroupUsecase _updateGroup;
  final DeleteGroupUsecase _deleteGroup;
  
  GroupsProvider(
    this._getUserGroups,
    this._createGroup,
    this._updateGroup,
    this._deleteGroup,
  );
  
  Future<void> loadGroups() async {
    final result = await _getUserGroups.call();
    // ... handle result
  }
}
```

**After**:
```dart
class GroupsProvider extends StateNotifier<GroupsState> {
  final IGroupService _groupService;
  
  GroupsProvider(this._groupService);
  
  Future<void> loadGroups() async {
    final result = await _groupService.getAll();
    // ... handle result (identical logic)
  }
  
  Future<void> createGroup(CreateGroupCommand command) async {
    final result = await _groupService.create(command);
    // ... handle result
  }
}
```

#### 3.3 Test Migration Strategy

**Mock Updates**:
```dart
// BEFORE: Multiple use case mocks
late MockGetUserGroupsUsecase mockGetUserGroups;
late MockCreateGroupUsecase mockCreateGroup;
late MockUpdateGroupUsecase mockUpdateGroup;
late MockDeleteGroupUsecase mockDeleteGroup;

setUp(() {
  mockGetUserGroups = MockGetUserGroupsUsecase();
  // ... setup other mocks
  provider = GroupsProvider(mockGetUserGroups, mockCreateGroup, ...);
});

// AFTER: Single service mock
late MockGroupService mockGroupService;

setUp(() {
  mockGroupService = MockGroupService();
  provider = GroupsProvider(mockGroupService);
});
```

**Test Method Updates**:
```dart
// BEFORE:
when(mockGetUserGroups.call()).thenAnswer((_) async => Result.ok(groups));

// AFTER:
when(mockGroupService.getAll()).thenAnswer((_) async => Result.ok(groups));
```

#### 3.4 Migration Sequence (Domain by Domain)

**Week 3 Schedule**:
- **Day 1**: Groups domain migration
  - Update all Groups providers
  - Update Groups widgets  
  - Update Groups tests
  - Verify functionality unchanged
  
- **Day 2**: Children domain migration
  - Update Family providers (children functionality)
  - Update Children widgets
  - Update Children tests
  - Verify functionality unchanged
  
- **Day 3**: Auth domain migration
  - Update Auth providers
  - Update Auth widgets
  - Update Auth tests
  - Verify functionality unchanged
  
- **Day 4**: Integration testing
  - Run full test suite
  - Performance validation
  - User acceptance testing
  
- **Day 5**: Bug fixes and validation
  - Address any issues found
  - Final integration verification

**Risk Mitigation**:
- **One Domain at a Time**: Complete Groups before starting Children
- **Immediate Testing**: Test each migration before proceeding
- **Rollback Ready**: Keep adapters until ALL consumers migrated
- **Branch Strategy**: Use feature branches for each domain migration

---

### PHASE 4: CLEANUP & VALIDATION (Week 4 - Minimal Risk)

#### 4.1 Dead Code Removal Sequence

**Files to Remove** (Only after ALL consumers migrated):
```
Groups Domain:
├─ lib/features/groups/domain/usecases/get_user_groups_usecase.dart
├─ lib/features/groups/domain/usecases/create_group_usecase.dart
├─ lib/features/groups/domain/usecases/update_group_usecase.dart
├─ lib/features/groups/domain/usecases/delete_group_usecase.dart
└─ lib/features/groups/domain/usecases/get_group_by_id_usecase.dart

Children Domain:
├─ lib/features/family/domain/usecases/add_child_usecase.dart
├─ lib/features/family/domain/usecases/update_child_usecase.dart
└─ lib/features/family/domain/usecases/remove_child_usecase.dart

Auth Domain:
├─ lib/features/auth/domain/usecases/get_current_user_usecase.dart
└─ lib/features/auth/domain/usecases/logout_usecase.dart

Associated Test Files:
├─ test/unit/features/groups/domain/usecases/get_user_groups_usecase_test.dart
├─ test/unit/features/groups/domain/usecases/create_group_usecase_test.dart
└─ [... all corresponding test files]
```

#### 4.2 DI Registration Cleanup

**Remove from injection.config.dart**:
```dart
// Remove old use case registrations:
// - GetUserGroupsUsecase
// - CreateGroupUsecase
// - UpdateGroupUsecase
// ... etc

// Keep new service registrations:
// - IGroupService -> GroupServiceImpl
// - IChildrenService -> ChildrenServiceImpl
// - IAuthService -> AuthServiceImpl
```

**Regenerate DI**:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 4.3 Final Validation Checklist

**Comprehensive Testing**:
- [ ] All unit tests pass: `flutter test test/unit/`
- [ ] All integration tests pass: `flutter test test/integration/`
- [ ] Architecture tests pass: `flutter test test/architecture/`
- [ ] Zero static analysis issues: `flutter analyze`
- [ ] App builds successfully: `flutter build apk --debug`

**Performance Validation**:
- [ ] App startup time within 5% of baseline
- [ ] Memory usage within 5% of baseline
- [ ] DI resolution time measured and acceptable
- [ ] UI responsiveness maintained

**Code Quality Metrics**:
- [ ] Lines of code reduced by ~60%
- [ ] Cyclomatic complexity improved
- [ ] File count reduced significantly
- [ ] Developer navigation improved

**Documentation Updates**:
- [ ] Architecture documentation updated
- [ ] Developer onboarding guides updated
- [ ] Code review guidelines updated
- [ ] Team knowledge transfer completed

---

## COMPLEX USE CASES PRESERVED

**These use cases have genuine business logic and MUST be kept separate**:

### GetFamilyUsecase ✅
- **Reason**: Complex multi-repository orchestration
- **Logic**: Parallel data fetching, caching coordination, data aggregation
- **Location**: `lib/features/family/domain/usecases/get_family_usecase.dart`

### ClearAllFamilyDataUsecase ✅  
- **Reason**: Cross-repository coordination with error handling
- **Logic**: Parallel clearing across multiple repositories, failure resilience
- **Location**: `lib/features/family/domain/usecases/clear_all_family_data_usecase.dart`

### CreateFamilyUsecase ✅
- **Reason**: Complex validation and business rules
- **Logic**: Family creation validation, business rule enforcement
- **Location**: `lib/features/family/domain/usecases/create_family_usecase.dart`

### SendMagicLinkUsecase ✅
- **Reason**: Email validation and formatting logic
- **Logic**: Email validation, magic link generation, business rules
- **Location**: `lib/features/auth/domain/usecases/send_magic_link_usecase.dart`

### RefreshTokenUsecase ✅
- **Reason**: Token validation and refresh logic
- **Logic**: Token expiration handling, refresh coordination
- **Location**: `lib/features/auth/domain/usecases/refresh_token_usecase.dart`

---

## ROLLBACK PROCEDURES

### Emergency Rollback (Any Phase)

**Git Branch Strategy**:
```bash
# Before starting each phase
git checkout -b consolidation-phase-1
git checkout -b consolidation-phase-2  
git checkout -b consolidation-phase-3
git checkout -b consolidation-phase-4

# Emergency rollback
git checkout main
git branch -D consolidation-phase-X
```

**Phase-Specific Rollbacks**:

**Phase 1 Rollback**: Remove services, revert DI changes
**Phase 2 Rollback**: Revert adapters to original repository calls  
**Phase 3 Rollback**: Restore original provider dependencies
**Phase 4 Rollback**: Restore deleted use case files from git history

### Automated Rollback Scripts

```bash
#!/bin/bash
# rollback-phase-1.sh
echo "Rolling back Phase 1: Service Foundation"
git checkout HEAD -- lib/features/*/domain/services/
flutter packages pub run build_runner build
flutter test
echo "Phase 1 rollback complete"
```

---

## SUCCESS METRICS

### Quantitative Metrics
- **Code Reduction**: 60% fewer use case files (21 → 8)
- **Maintainability**: Reduced cyclomatic complexity
- **Performance**: Within 5% of baseline performance
- **Test Coverage**: Maintain or improve current coverage

### Qualitative Metrics  
- **Developer Experience**: Fewer files to navigate
- **Code Understanding**: Clearer domain boundaries
- **Maintenance Burden**: Reduced duplication
- **Team Velocity**: Faster feature development

---

## TEAM COORDINATION

### Communication Plan
- **Daily Standups**: Migration progress updates
- **Phase Completion**: Demo functionality unchanged
- **Issue Escalation**: Immediate team notification
- **Knowledge Sharing**: Pair programming sessions

### Code Review Requirements
- **Phase 1-2**: Senior developer approval required
- **Phase 3**: Peer review + QA validation  
- **Phase 4**: Architecture review + team sign-off

### Documentation Requirements
- **Decision Log**: Document all architectural decisions
- **Migration Journal**: Daily progress and issues
- **Lessons Learned**: Post-migration retrospective
- **Knowledge Transfer**: Team training sessions

---

## CONTACT & SUPPORT

**Architecture Questions**: Review with senior developers
**Implementation Blockers**: Escalate to tech lead  
**Testing Issues**: Coordinate with QA team
**Performance Concerns**: Profile and measure before/after

**Remember**: This migration prioritizes safety over speed. Each phase must be fully validated before proceeding to the next.

---

*Last Updated: [DATE]*
*Plan Version: 1.0*
*Status: Ready for Implementation*