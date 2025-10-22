// Auth feature barrel exports
// This file provides centralized access to all auth functionality

// Domain - Entities
export '../../core/domain/entities/user.dart';

// Data - Models (official DTOs)
export '../../core/network/models/auth/index.dart';

// Presentation - Pages
export 'presentation/pages/login_page.dart';
export 'presentation/pages/magic_link_page.dart';

// Presentation - Widgets (moved to pages)
export 'presentation/pages/biometric_auth_widget.dart';
