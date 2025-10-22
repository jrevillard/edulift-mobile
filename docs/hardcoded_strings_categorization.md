# Hardcoded Strings Categorization and Priority Matrix

This document categorizes the 189 hardcoded strings identified by the internationalization audit tool, organized by feature area and priority level.

## Priority Definitions

- **P0 (Critical)**: Core user flows, error messages, navigation labels, onboarding steps
- **P1 (High)**: Feature-specific UI labels, confirmation dialogs, success messages
- **P2 (Medium)**: Help text, tooltips, descriptive content
- **P3 (Low)**: Developer tools, debug information, placeholder text

## Feature Area Categorization

### 1. Family Management (P0-P1)
Core functionality for managing family members, vehicles, and invitations.

**P0 Strings:**
- "Cancel" (multiple locations)
- "Delete" (family management)
- "Remove Member" (family management)
- "Leave Family" (family management)
- "Send Invitation" (invite member)
- "Edit Vehicle" (vehicle management)
- "Create Family" (onboarding)

**P1 Strings:**
- "Family Member" (member creation)
- "Reset" (form reset)
- "Invitation sent to $email" (success message)
- "Failed to send invitation: ${e.toString()}" (error message)
- "You have left the family" (success message)
- "Failed to leave family: ${e.toString()}" (error message)
- "Failed to remove member: ${e.toString()}" (error message)
- "Failed to update role: ${e.toString()}" (error message)

### 2. Authentication & Onboarding (P0)
Critical user journey for account creation and login.

**P0 Strings:**
- "Log In" (login screen)
- "Login failed: ${e.toString()}" (error message)
- "Biometric authentication failed: $error" (error message)
- "Create Your Family" (onboarding)
- "Accept Invitation" (onboarding)
- "Create New Family Instead" (onboarding)
- "Join Existing Family" (onboarding)
- "Enter Invitation Code" (onboarding)
- "Confirm Logout" (onboarding)
- "Are you sure you want to logout?" (confirmation)
- "Logout" (action)

### 3. Schedule Management (P0-P1)
Core scheduling functionality for family coordination.

**P0 Strings:**
- "Schedule Coordination" (main screen)
- "Day" (view selector)
- "Week" (view selector)
- "Month" (view selector)
- "Add Event" (event creation)
- "Conflict Resolution" (conflict handling)
- "Filter Options" (filtering)
- "Schedule refreshed" (refresh confirmation)

**P1 Strings:**
- "Week view implementation" (placeholder)
- "Month view implementation" (placeholder)
- "Implementation coming soon" (multiple locations)
- "Semaine précédente" (French - previous week)
- "Semaine suivante" (French - next week)
- "Optimiser" (French - optimize)
- "Actualiser" (French - refresh)
- "Chargement du planning..." (French - loading schedule)
- "Chargement des créneaux..." (French - loading slots)
- "Chargement des assignations..." (French - loading assignments)
- "Créer un créneau" (French - create slot)
- "Erreur de chargement" (French - loading error)
- "Réessayer" (French - try again)
- "Créneau" (French - slot)
- "Assigner" (French - assign)

### 4. Groups & Group Scheduling (P1)
Group-specific functionality for managing group schedules.

**P1 Strings:**
- "Unsaved Changes" (confirmation dialog)
- "Stay" (dialog option)
- "Leave" (dialog option)
- "Schedule configuration updated successfully" (success message)
- "Schedule Configuration" (page title)
- "Go Back" (navigation)
- "Try Again" (retry action)
- "Schedule Configuration Help" (help dialog)
- "Got it" (acknowledgment)
- "Weekdays Only" (weekday selector)
- "Mon - Fri" (weekday selector)
- "Weekends Only" (weekday selector)
- "Sat - Sun" (weekday selector)
- "All Days" (weekday selector)
- "Every day" (weekday selector)
- "Clear All" (weekday selector)

### 5. Vehicle Management (P1)
Vehicle-specific functionality for managing family vehicles.

**P1 Strings:**
- "Driver: 1 seat" (vehicle details)
- "Passengers: $passengerSeats seats" (vehicle details)
- "Edit" (vehicle actions)
- "${_getVehicleName(vehicle)} added successfully" (success message)
- "Failed to add vehicle: ${e.toString()}" (error message)
- "Failed to remove vehicle: ${e.toString()}" (error message)
- "${_getVehicleName(vehicle)} removed successfully" (success message)
- "Vehicle updated successfully" (success message)

### 6. Child Management (P1)
Child-specific functionality for managing family children.

**P1 Strings:**
- "Child updated successfully" (success message)
- "View Member Details" (member actions)
- "See member information" (member actions)
- "Remove yourself from this family" (member actions)
- "Remove this member from family" (member actions)

### 7. Invitations & Membership (P0-P1)
Invitation system and membership management.

**P0 Strings:**
- "Validate Code" (invitation validation)
- "Back to Login" (navigation)
- "Join ${validation.groupName ?? " (invitation acceptance)
- "Send Magic Link" (magic link)
- "Sign In to Join ${validation.groupName ?? " (login prompt)
- "Email: " (email label)
- "Cancel" (invitation actions)

**P1 Strings:**
- "Show Invitation Code" (invitation management)
- "Display the invitation code" (invitation management)
- "Remove this invitation" (invitation management)
- "Invitation cancelled successfully" (success message)
- "Failed to cancel: $e" (error message)
- "Invitation code not available" (error message)
- "Invitation Code" (dialog title)
- "Close" (dialog action)
- "Copy Code" (copy action)
- "Invitation code copied to clipboard" (success message)
- "Failed to copy code: $e" (error message)
- "Cancel" (invitation status)
- "Cancel Invitation" (invitation status)
- "Keep Invitation" (invitation status)
- "Invitation cancelled for ${invitation.recipientEmail}" (success message)

### 8. Dashboard & Navigation (P0)
Main dashboard and navigation components.

**P0 Strings:**
- "Dashboard" (main screen)
- "${family.totalMembers} members" (family stats)
- "${family.totalChildren} children" (family stats)
- "${family.totalVehicles} vehicles" (family stats)
- "Additional navigation options would appear here" (placeholder)
- "User Menu" (user menu)
- "User profile and settings options would appear here" (placeholder)

### 9. Error Handling & System Messages (P0-P1)
System-wide error messages and boundary handling.

**P0 Strings:**
- "Error" (error page)
- "Go Back" (error navigation)
- "• " (error boundary bullet)

**P1 Strings:**
- "Family Membership Conflict" (magic link conflict)
- "Stay in Current Family" (conflict resolution)
- "Invitation Error: $errorMessage" (magic link error)

### 10. Settings & Developer Tools (P2)
Settings and developer-specific functionality.

**P2 Strings:**
- "Log Level" (developer settings)
- "Log Export" (developer settings)
- "Exporting..." (export status)
- "Retry Export" (export retry)
- "Failed to export logs: $e" (export error)

### 11. Real-time Indicators (P2)
Real-time schedule conflict indicators.

**P2 Strings:**
- "Resolve" (conflict resolution)
- "Conflict resolution feature coming soon" (placeholder)

## Priority Matrix Summary

| Priority | Count | Description |
|----------|-------|-------------|
| P0 | 45 | Critical user flows and core functionality |
| P1 | 98 | Feature-specific UI and important messages |
| P2 | 44 | Help text, tooltips, and secondary features |
| P3 | 2 | Developer tools and debug information |

## Implementation Recommendations

1. **Phase 1 (P0 Strings)**: Focus on core user journeys - authentication, family management, schedule coordination
2. **Phase 2 (P1 Strings)**: Address feature-specific UI elements and confirmation dialogs
3. **Phase 3 (P2 Strings)**: Implement help text and descriptive content
4. **Phase 4 (P3 Strings)**: Handle developer tools and debug information

## Key Creation Conventions

When creating ARB keys for these strings, follow these conventions:

1. **Use descriptive, hierarchical key names**:
   - `familyManagement_removeMemberTitle`
   - `auth_loginFailedMessage`

2. **Include context for similar strings**:
   - `dialog_cancelAction`
   - `form_resetAction`
   - `navigation_goBackAction`

3. **Use ICU syntax for plurals and parameters**:
   - `{count, plural, one{1 member} other{{count} members}}`
   - `invitation_sentSuccessMessage{Invitation sent to {email}}`

4. **Maintain consistency with existing patterns**:
   - Follow the existing ARB structure in `lib/l10n/`
   - Use the same naming conventions as existing keys