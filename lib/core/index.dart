// Core module barrel exports
// This file provides centralized access to all core functionality

// Providers - use the main providers.dart for all provider access
// Individual provider files have been consolidated to eliminate duplications

// Services (from services/)
export 'services/auth_service.dart';
export 'services/app_state_provider.dart';
export 'services/invitation_error_mapper.dart';

// Themes
export 'presentation/themes/app_theme.dart';
export 'presentation/themes/app_colors.dart';
export 'presentation/themes/app_spacing.dart';
export 'presentation/themes/app_text_styles.dart';

// Widgets - Common
export 'presentation/widgets/global_loading_overlay.dart';
export 'presentation/widgets/offline_indicator.dart';
export 'presentation/widgets/loading_indicator.dart';
export 'presentation/widgets/main_shell.dart';

// Widgets - Navigation
export 'presentation/widgets/navigation/app_navigation.dart';

// Widgets - Accessibility
export 'presentation/widgets/accessibility/accessible_button.dart';
export 'presentation/widgets/accessibility/accessible_button_with_test_keys.dart';
export 'presentation/widgets/accessibility/screen_reader_support.dart';

// Widgets - Invitation (Shared between Family and Groups)
export 'presentation/widgets/invitation/invitation_error_display.dart';
export 'presentation/widgets/invitation/invitation_loading_state.dart';
export 'presentation/widgets/invitation/invitation_manual_code_input.dart';

// Widgets - Adaptive
export 'presentation/widgets/adaptive_widgets.dart';

// Widgets - Profile & Settings
export 'presentation/widgets/profile/profile_page.dart';
export 'presentation/widgets/settings/language_selector.dart';
export 'presentation/widgets/settings/settings_page.dart';

// Pages
export 'presentation/pages/splash_page.dart';

// Helpers
export 'presentation/helpers/icon_mapping_helper.dart';

// Domain
export 'domain/usecases/usecase.dart';

// Router
export 'router/shared_route_factory.dart';

// Network
export 'network/auth_api_client.dart';
export 'network/family_api_client.dart';
export 'network/schedule_api_client.dart';

// Error handling
export 'network/error_handler_service.dart';

// DI - Now using Riverpod providers with zero duplications
export 'di/providers/providers.dart';
