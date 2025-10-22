// Family feature barrel exports
// This file provides centralized access to all family functionality

// Domain - Core Entities (from core/domain/entities/family)
export 'package:edulift/core/domain/entities/family.dart';
export '../../core/domain/entities/groups/group.dart';
export '../../core/domain/entities/invitations/invitation.dart';

// Domain - Feature-specific entities (composed/simple variants)
export 'domain/entities/child_assignment.dart';
// Note: FamilyPermissions and GroupInvitation are exported from core barrel instead
// to avoid ambiguous exports

// Domain - Repositories
export 'domain/repositories/family_repository.dart';
export 'domain/repositories/family_invitation_repository.dart';

// Domain - Requests
export 'domain/requests/index.dart';

// Data - Datasources
export 'data/datasources/family_remote_datasource.dart';
export 'data/datasources/family_local_datasource.dart';

// Data - Repositories
export 'data/repositories/family_repository_impl.dart';

// Presentation - Pages
export 'presentation/pages/add_child_page.dart';
export 'presentation/pages/vehicles_page.dart';
export 'presentation/pages/add_vehicle_page.dart';
export 'presentation/pages/edit_vehicle_page.dart';
export 'presentation/pages/vehicle_details_page.dart';
export 'presentation/pages/family_invitation_page.dart';

// Presentation - Providers
export 'presentation/providers/family_provider.dart' hide childProvider;
// Note: vehicles_provider.dart consolidated into family_provider.dart
export 'presentation/providers/family_invitation_provider.dart';

// Presentation - Screens
export 'presentation/pages/family_management_screen.dart';

// Error Handling - Use core/presentation/widgets/error_boundary_widget.dart for Clean Architecture
