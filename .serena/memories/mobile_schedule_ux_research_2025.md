# Mobile Schedule UX Research - January 2025

## Research Sources Summary

### Mobile Calendar UX Best Practices (2024-2025)
- **Swipeable Navigation**: Natural swipe gestures for day/week navigation (Google Calendar pattern)
- **Hybrid Input**: Visual pickers + manual input for flexibility
- **Large Touch Targets**: Minimum 44px (iOS/Android) for accessibility
- **Gesture-Based Controls**: Scrolling, swiping, long-press for context menus
- **View Flexibility**: Day/Week/Month views with seamless switching

### Bottom Sheet Patterns (Material Design 2024)
- **Modal Bottom Sheets**: Block interactions, best for critical actions
- **Expandable Bottom Sheets**: Start minimized (non-modal), expand to full-screen (modal)
- **Common Use Cases**: Sharing options, music players, map detail panels
- **Best Practices**: Support back button, quick transitions, draggable

### Progressive Disclosure Principles
- **Definition**: Defer advanced features to secondary UI, keep essentials in primary
- **Mobile Patterns**: Accordions, tabs, scrolling, conditional disclosure
- **Benefits**: Reduces cognitive load, faster task completion, improved accuracy

### Offline-First UX
- **Optimistic UI**: Immediate updates, assume success, revert on failure
- **Visual Indicators**: Network status bar, sync button, pending operation badges
- **Pending Operations**: WorkManager for background sync, clear UI feedback

### Accessibility Requirements (WCAG 2024)
- **Touch Targets**: AA = 24px minimum, AAA = 44px (iOS standard)
- **Color Contrast**: 4.5:1 minimum for text
- **Haptic Feedback**: Confirm actions, indicate errors
- **Screen Readers**: Semantic labels on all interactive elements

### Drag-and-Drop on Mobile
- **Challenges**: No hover state, fat-finger problem (1cm x 1cm space needed)
- **Implementation**: TouchEvent mapping, timing delay for grab detection
- **Haptic**: "Bumps" for grab/drop confirmation, different patterns for errors
- **Flutter**: interact.js for cross-platform touch gestures

### Real-World App Patterns
- **Google Calendar Mobile**: Vertical swipe between days, consistent design language
- **Calendly**: Consolidated steps (day + time on same page), large buttons
- **Doodle**: Color-coded availability, mobile-responsive grid
- **Team Scheduling Apps**: Card-based layouts, visual availability indicators

### Flutter-Specific Patterns
- **PageView**: Horizontal/vertical swipeable pages with PageController
- **calendar_view package**: Pre-built WeekView with customization
- **Infinite Scroll**: PageView with infinite week navigation
- **Stepper UI**: Thumb-friendly, one-step-at-a-time for multi-step processes

## Key Insights for EduLift Schedule Feature

### Current Implementation Issues
1. ListView instead of swipeable PageView
2. Desktop-oriented layout (not mobile-first)
3. Missing optimistic UI for offline operations
4. No progressive disclosure for complex assignments
5. Touch targets may not meet 44px standard

### Recommended Patterns
1. **PageView for Week Navigation**: Swipe between weeks horizontally
2. **Card-Based Day Layout**: One card per day, vertically scrollable
3. **Bottom Sheet for Assignments**: Modal for vehicle/child selection
4. **Progressive Disclosure**: Week → Day → Slot → Vehicle → Children (3-4 levels)
5. **Optimistic Updates**: Immediate UI feedback, background sync
6. **Capacity Visualization**: Circular progress indicators for seat capacity
7. **Conflict Indicators**: Color-coded borders, warning badges

### Design Principles
- **Mobile-First**: Design for 375px width (iPhone SE), scale up
- **Touch-Friendly**: All tap targets ≥ 48dp (Flutter standard)
- **Gesture-Rich**: Swipe to navigate, long-press for quick actions
- **Visual Hierarchy**: Color coding by day, status badges, capacity bars
- **Offline-Ready**: Pending operation badges, sync status indicator
