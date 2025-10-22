// GOD OBJECT DECOMPOSITION - CHILDASSIGNMENT RESTRUCTURE
//
// This module provides the decomposed ChildAssignment entities following
// Interface Segregation and Single Responsibility principles.

// Interfaces
export '../interfaces/assignment_interfaces.dart';

// Focused Entities
export '../core_assignment.dart';
export '../transportation_assignment.dart';
export '../family_assignment_context.dart';

// Backward Compatibility Bridge
// NOTE: child_assignment_bridge.dart removed - not implemented yet

// MIGRATION GUIDE:
//
// 1. IMMEDIATE USAGE (Backward Compatible):
//    - Replace ChildAssignment imports with ChildAssignmentBridge
//    - All existing code continues to work unchanged
//
// 2. GRADUAL MIGRATION:
//    - Use specific interfaces (ICoreAssignment, ITransportationAssignment, etc.)
//    - Update clients to depend only on needed properties
//    - Replace direct property access with composed entity access
//
// 3. FINAL STATE (After Migration):
//    - Use ChildAssignmentComposed for new code
//    - Remove ChildAssignmentBridge once all clients are updated
//    - Clean separation of concerns achieved
//
// BENEFITS:
// - Interface Segregation: Clients depend only on what they need
// - Single Responsibility: Each entity handles one concern
// - Composition over Inheritance: Flexible entity composition
// - Testability: Easy to mock specific concerns
// - Maintainability: Changes isolated to specific entities
