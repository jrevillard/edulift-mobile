// Schedule feature barrel exports
// This file provides centralized access to all schedule functionality

// Domain - Entities from core
export 'package:edulift/core/domain/entities/schedule.dart';

// Data - Models
// Schedule models removed - use DTOs from network layer

// Data - Datasources
// REMOVED: schedule_remote_datasource.dart - orphaned datasource using deleted weekly schedule endpoints
export 'data/datasources/schedule_local_datasource.dart';

// Data - Providers
export 'data/providers/schedule_provider.dart';

// Presentation - Pages
export 'presentation/pages/schedule_page.dart';
export 'presentation/pages/create_schedule_page.dart';

// Presentation - Providers
export 'presentation/providers/realtime_schedule_provider.dart';

// Presentation - Screens
export 'presentation/pages/schedule_coordination_screen.dart';

// Presentation - Widgets
export 'presentation/widgets/schedule_slot_widget.dart';

// Error Handling - Use core/presentation/widgets/error_boundary_widget.dart for Clean Architecture
