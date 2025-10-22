# Flutter Test Coverage Analysis by Architectural Layer

**Analysis Date**: Sat Aug 23 09:39:49 AM CEST 2025
**Total Files Analyzed**: 297

## 📊 Coverage Summary by Layer

| Layer | Files | Line Coverage | Function Coverage | Branch Coverage |
|-------|-------|---------------|-------------------|------------------|
| Domain | 58 | 28.7% (622/2165) | 0.0% (0/0) | 0.0% (0/0) |
| Data | 56 | 20.9% (1192/5692) | 0.0% (0/0) | 0.0% (0/0) |
| Presentation | 71 | 20.9% (1811/8674) | 0.0% (0/0) | 0.0% (0/0) |
| Core | 33 | 24.4% (600/2460) | 0.0% (0/0) | 0.0% (0/0) |
| Generated | 3 | 3.3% (46/1413) | 0.0% (0/0) | 0.0% (0/0) |
| Other | 76 | 5.5% (371/6778) | 0.0% (0/0) | 0.0% (0/0) |

## 🎯 CRITICAL PRIORITY: Domain Layer Analysis

- **Total Domain Files**: 58
- **Critical Business Logic Files**: 56
- **Critical Files <95% Coverage**: 49

### 🚨 HIGHEST PRIORITY: Critical Domain Files Needing Coverage

| File | Line Coverage | Lines Missing | Priority |
|------|---------------|---------------|----------|
| `lib/core/domain/services/auth_service.dart` | 0.0% | 1 | 🔴 CRITICAL |
| `lib/features/family/domain/repositories/family_repository.dart` | 0.0% | 6 | 🔴 CRITICAL |
| `lib/features/family/domain/usecases/get_family_usecase.dart` | 0.0% | 12 | 🔴 CRITICAL |
| `lib/features/family/domain/usecases/add_child_usecase.dart` | 0.0% | 3 | 🔴 CRITICAL |
| `lib/features/family/domain/usecases/update_child_usecase.dart` | 0.0% | 5 | 🔴 CRITICAL |
| `lib/features/family/domain/usecases/remove_child_usecase.dart` | 0.0% | 3 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/child_assignment_data.dart` | 0.0% | 45 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/failed_change.dart` | 0.0% | 86 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/vehicle_schedule.dart` | 0.0% | 88 | 🔴 CRITICAL |
| `lib/features/family/domain/repositories/vehicles_repository.dart` | 0.0% | 1 | 🔴 CRITICAL |
| `lib/features/family/domain/usecases/create_family_usecase.dart` | 0.0% | 15 | 🔴 CRITICAL |
| `lib/features/schedule/domain/entities/day_of_week.dart` | 0.0% | 48 | 🔴 CRITICAL |
| `lib/features/schedule/domain/entities/recurrence_pattern.dart` | 0.0% | 89 | 🔴 CRITICAL |
| `lib/features/schedule/domain/entities/schedule_conflict.dart` | 0.0% | 25 | 🔴 CRITICAL |
| `lib/features/schedule/domain/entities/schedule_priority.dart` | 0.0% | 17 | 🔴 CRITICAL |
| `lib/features/schedule/domain/entities/schedule_time_slot.dart` | 0.0% | 22 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/seat_override.dart` | 0.0% | 64 | 🔴 CRITICAL |
| `lib/features/groups/domain/usecases/create_group_usecase.dart` | 0.0% | 19 | 🔴 CRITICAL |
| `lib/features/groups/domain/usecases/delete_group_usecase.dart` | 0.0% | 6 | 🔴 CRITICAL |
| `lib/features/groups/domain/usecases/get_group_by_id_usecase.dart` | 0.0% | 6 | 🔴 CRITICAL |
| `lib/features/groups/domain/usecases/get_user_groups_usecase.dart` | 0.0% | 3 | 🔴 CRITICAL |
| `lib/features/groups/domain/usecases/update_group_usecase.dart` | 0.0% | 28 | 🔴 CRITICAL |
| `lib/features/schedule/domain/usecases/assign_children_to_vehicle.dart` | 0.0% | 8 | 🔴 CRITICAL |
| `lib/features/schedule/domain/usecases/assign_vehicle_to_slot.dart` | 0.0% | 9 | 🔴 CRITICAL |
| `lib/features/schedule/domain/usecases/get_weekly_schedule.dart` | 0.0% | 4 | 🔴 CRITICAL |
| `lib/features/schedule/domain/usecases/manage_schedule_config.dart` | 0.0% | 25 | 🔴 CRITICAL |
| `lib/features/schedule/domain/usecases/manage_schedule_operations.dart` | 0.0% | 27 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/schedule.dart` | 0.9% | 110 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/family_invitation.dart` | 1.0% | 100 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/family_permissions.dart` | 2.9% | 33 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/transportation_assignment.dart` | 4.0% | 24 | 🔴 CRITICAL |
| `lib/features/groups/domain/entities/group.dart` | 5.1% | 204 | 🔴 CRITICAL |
| `lib/features/auth/domain/repositories/auth_repository.dart` | 5.9% | 32 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/family_assignment_context.dart` | 14.3% | 18 | 🔴 CRITICAL |
| `lib/features/schedule/domain/entities/schedule_config.dart` | 18.5% | 22 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/invitation.dart` | 21.0% | 98 | 🔴 CRITICAL |
| `lib/features/schedule/domain/entities/optimized_schedule.dart` | 25.0% | 24 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/schedule_assignment.dart` | 25.7% | 26 | 🔴 CRITICAL |
| `lib/features/onboarding/domain/entities/onboarding_state.dart` | 50.0% | 6 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/child_assignment_bridge.dart` | 52.2% | 33 | 🔴 CRITICAL |
| `lib/core/domain/entities/locale_info.dart` | 52.4% | 10 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/core_assignment.dart` | 55.6% | 12 | 🔴 CRITICAL |
| `lib/features/schedule/domain/entities/assignment.dart` | 57.1% | 12 | 🔴 CRITICAL |
| `lib/features/schedule/domain/entities/weekly_schedule.dart` | 60.0% | 12 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/child_assignment_composed.dart` | 67.5% | 26 | 🔴 CRITICAL |
| `lib/features/family/domain/entities/child_assignment.dart` | 72.1% | 12 | 🔴 CRITICAL |
| `lib/core/domain/services/deep_link_service.dart` | 84.1% | 7 | 🟡 HIGH |
| `lib/core/domain/entities/user.dart` | 86.9% | 11 | 🟡 HIGH |
| `lib/features/schedule/domain/entities/vehicle_assignment.dart` | 92.5% | 3 | 🟡 HIGH |

## 📉 Top 10 Lowest Coverage: Domain Layer

| Rank | File | Line Coverage | Function Coverage | Lines Missing |
|------|------|---------------|-------------------|---------------|
| 1 | `lib/core/domain/services/auth_service.dart` | 0.0% | 0.0% | 1 |
| 2 | `lib/features/family/domain/repositories/family_repository.dart` | 0.0% | 0.0% | 6 |
| 3 | `lib/features/family/domain/usecases/get_family_usecase.dart` | 0.0% | 0.0% | 12 |
| 4 | `lib/features/family/domain/usecases/add_child_usecase.dart` | 0.0% | 0.0% | 3 |
| 5 | `lib/features/family/domain/usecases/update_child_usecase.dart` | 0.0% | 0.0% | 5 |
| 6 | `lib/features/family/domain/usecases/remove_child_usecase.dart` | 0.0% | 0.0% | 3 |
| 7 | `lib/features/family/domain/entities/child_assignment_data.dart` | 0.0% | 0.0% | 45 |
| 8 | `lib/features/family/domain/entities/failed_change.dart` | 0.0% | 0.0% | 86 |
| 9 | `lib/features/family/domain/entities/vehicle_schedule.dart` | 0.0% | 0.0% | 88 |
| 10 | `lib/features/family/domain/repositories/vehicles_repository.dart` | 0.0% | 0.0% | 1 |

## 📉 Top 10 Lowest Coverage: Data Layer

| Rank | File | Line Coverage | Function Coverage | Lines Missing |
|------|------|---------------|-------------------|---------------|
| 1 | `lib/features/family/data/datasources/family_local_datasource.dart` | 0.0% | 0.0% | 276 |
| 2 | `lib/features/family/data/models/family_invitation_validation_dto.dart` | 0.0% | 0.0% | 20 |
| 3 | `lib/features/family/data/models/family_invitation_validation_dto.g.dart` | 0.0% | 0.0% | 23 |
| 4 | `lib/data/network/dio_api_client.dart` | 0.0% | 0.0% | 32 |
| 5 | `lib/features/family/data/datasources/children_remote_datasource.dart` | 0.0% | 0.0% | 45 |
| 6 | `lib/features/family/data/datasources/family_local_datasource_result_impl.dart` | 0.0% | 0.0% | 177 |
| 7 | `lib/features/family/data/datasources/family_members_remote_datasource.dart` | 0.0% | 0.0% | 13 |
| 8 | `lib/features/family/data/datasources/family_remote_datasource_result.dart` | 0.0% | 0.0% | 116 |
| 9 | `lib/features/family/data/repositories/children_repository_impl.dart` | 0.0% | 0.0% | 450 |
| 10 | `lib/features/family/data/repositories/family_members_repository_impl.dart` | 0.0% | 0.0% | 133 |

## 📉 Top 10 Lowest Coverage: Presentation Layer

| Rank | File | Line Coverage | Function Coverage | Lines Missing |
|------|------|---------------|-------------------|---------------|
| 1 | `lib/core/router/app_routes.dart` | 0.0% | 0.0% | 16 |
| 2 | `lib/shared/presentation/pages/error_page.dart` | 0.0% | 0.0% | 15 |
| 3 | `lib/core/router/route_factory.dart` | 0.0% | 0.0% | 7 |
| 4 | `lib/core/router/route_registration.dart` | 0.0% | 0.0% | 8 |
| 5 | `lib/features/dashboard/presentation/routing/dashboard_route_factory.dart` | 0.0% | 0.0% | 4 |
| 6 | `lib/features/family/presentation/routing/family_route_factory.dart` | 0.0% | 0.0% | 42 |
| 7 | `lib/features/groups/presentation/routing/groups_route_factory.dart` | 0.0% | 0.0% | 13 |
| 8 | `lib/features/schedule/presentation/routing/schedule_route_factory.dart` | 0.0% | 0.0% | 7 |
| 9 | `lib/features/onboarding/presentation/routing/onboarding_route_factory.dart` | 0.0% | 0.0% | 6 |
| 10 | `lib/shared/presentation/routing/shared_route_factory.dart` | 0.0% | 0.0% | 4 |

## 🎯 Actionable Recommendations for Phase 3.2

### Immediate Actions (Priority 1)

1. **Domain Layer Coverage (28.7%)**
   - 🚨 CRITICAL: Domain coverage below 90% threshold
   - Focus on use cases, entities, and repository interfaces
   - Target: Achieve 95%+ coverage for all domain files

2. **Data Layer Coverage (20.9%)**
   - Focus on repository implementations and data sources
   - Test error handling and edge cases

3. **Presentation Layer Coverage (20.9%)**
   - Add widget tests and BLoC/provider tests
   - Test user interaction flows

### Coverage Targets by Layer

| Layer | Current | Target | Action Required |
|-------|---------|--------|-----------------|
| Domain | 28.7% | 95% | 📈 Improve by 66.3% |
| Data | 20.9% | 85% | 📈 Improve by 64.1% |
| Presentation | 20.9% | 80% | 📈 Improve by 59.1% |
| Core | 24.4% | 90% | 📈 Improve by 65.6% |

### Implementation Strategy

1. **Week 1**: Focus on critical domain files with <80% coverage
2. **Week 2**: Address data layer repository implementations
3. **Week 3**: Improve presentation layer widget and state management tests
4. **Week 4**: Integration tests and edge case coverage

## 🔍 Detailed Coverage Gaps

### Files with Zero Coverage (152 files)


**Core Layer:**
- `lib/core/services/user_status_service.dart` (40 lines)
- `lib/core/constants/app_constants.dart` (37 lines)
- `lib/core/security/biometric_auth_service.dart` (57 lines)
- `lib/core/security/security_headers_service.dart` (146 lines)
- `lib/core/services/auth_service.dart` (196 lines)
- `lib/core/di/network_module.dart` (5 lines)
- `lib/core/security/certificate_pinning.dart` (50 lines)
- `lib/core/security/certificate_pinning_service.dart` (24 lines)
- `lib/core/utils/error_logger.dart` (34 lines)
- `lib/core/utils/secure_date_parser.dart` (13 lines)
- `lib/core/types/change_type.dart` (46 lines)

**Data Layer:**
- `lib/features/family/data/datasources/family_local_datasource.dart` (276 lines)
- `lib/features/family/data/models/family_invitation_validation_dto.dart` (20 lines)
- `lib/features/family/data/models/family_invitation_validation_dto.g.dart` (23 lines)
- `lib/data/network/dio_api_client.dart` (32 lines)
- `lib/features/family/data/datasources/children_remote_datasource.dart` (45 lines)
- `lib/features/family/data/datasources/family_local_datasource_result_impl.dart` (177 lines)
- `lib/features/family/data/datasources/family_members_remote_datasource.dart` (13 lines)
- `lib/features/family/data/datasources/family_remote_datasource_result.dart` (116 lines)
- `lib/features/family/data/repositories/children_repository_impl.dart` (450 lines)

---
*Analysis generated using actual LCOV coverage data*
