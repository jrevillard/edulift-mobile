// Groups feature barrel exports
// This file provides centralized access to all groups functionality

// Domain - Entities (now consolidated in core)
export '../../core/domain/entities/groups/group.dart';

// Data - Models (removed - migrated to core/network/models)

// Data - Providers
export 'data/providers/groups_provider.dart';

// Domain - Repositories
export 'domain/repositories/group_repository.dart';
// Data - Repositories
export 'data/repositories/groups_repository_impl.dart';

// Presentation - Pages
export 'presentation/pages/groups_page.dart';
export 'presentation/pages/group_details_page.dart';

// Presentation - Widgets
export 'presentation/widgets/group_card.dart';
