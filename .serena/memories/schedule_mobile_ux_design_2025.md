# Mobile-First UX Design - Schedule Management 2025

**Date**: 2025-10-09  
**Updated**: 2025-10-10
**Research**: Gemini Pro expert analysis
**Status**: VALIDATED - Ready for implementation

**⚠️ DEFERRED FEATURES**: Offline/Sync functionality (Priority 3) will be implemented in Phase 2. All other features must be 100% complete for Phase 1.

## Executive Summary

**Recommandation Clé**: Architecture **PageView swipeable + Cards + Bottom Sheets**

### Navigation Recommandée
- **Horizontal Swipe**: Semaines (PageView infini)
- **Vertical Scroll**: Jours dans la semaine (ListView de Cards)
- **Tap**: Ouvre Bottom Sheets pour assignations

### Hiérarchie 3 Niveaux
1. **Level 1**: Vue semaine (cards des jours)
2. **Level 2**: Assignation véhicules (Bottom Sheet 60%)
3. **Level 3**: Assignation enfants (Bottom Sheet 90%)

---

## ⚠️ PHASE 1 vs PHASE 2 Features

### ✅ PHASE 1 - Must be 100% Complete
- Level 1: Week View (all features)
- Level 2: Vehicle Assignment (all features)
- Level 3: Child Assignment (all features)
- Pull-to-refresh
- Dynamic week loading
- Long-press quick actions
- Date picker on week indicator
- School information display
- Accessibility (touch targets, semantic labels, haptic, keyboard nav, reduced motion)

### ⏸️ PHASE 2 - Deferred to Later
- **Offline/Sync Strategy** (lines 284-345):
  - Optimistic updates with offline queue
  - Pending indicators (orange pulsing border, global banner)
  - Background sync (WorkManager/BGTaskScheduler)
  - Conflict resolution dialog
  - Auto-merge for non-conflicting changes
  
**Rationale**: Phase 1 focuses on complete online workflow. Offline/sync adds complexity better addressed after core features validated.

---

[... rest of the UX plan content remains exactly the same ...]

## Priorités Implémentation

### Priority 1: Core Navigation ⭐⭐⭐ (3-5 jours) - PHASE 1
**Critique**: Foundation navigation

**Components**:
- PageView week swipe
- ListView day cards
- Week indicator + date picker
- Pull-to-refresh

**Acceptance**:
- Swipe left/right smooth
- Infinite scroll with dynamic week loading
- Week indicator updates
- Tap week indicator opens date picker
- Pull-to-refresh triggers sync

---

### Priority 2: Bottom Sheets ⭐⭐⭐ (4-6 jours) - PHASE 1
**Critique**: Core assignment workflow

**Components**:
- VehicleAssignmentSheet (Level 2)
- ChildAssignmentSheet (Level 3)
- DraggableScrollableSheet + transitions
- Back navigation

**Acceptance**:
- Tap slot → Level 2 (60%)
- Tap vehicle → Level 3 (90%)
- Back → Level 2
- Swipe down → Dismiss Level 1
- Touch targets ≥ 48dp
- School information displayed per child

---

### Priority 3: Offline Sync ⭐⭐ (5-7 jours) - ⏸️ DEFERRED TO PHASE 2
**Important**: Instant feedback mobile

**Components** (DEFERRED):
- Optimistic state updates with offline queue
- Pending indicators (cloud, orange pulsing border)
- Background sync (WorkManager/BGTaskScheduler)
- Conflict resolution
- Global offline banner

**Phase 1 Behavior**: All operations require online connection. Show loading spinners and error messages for network failures. No optimistic updates or offline queue.

---

### Priority 4: Visual Polish ⭐⭐ (3-4 jours) - PHASE 1
**Important**: Professional + accessibility

**Components**:
- Color coding par jour
- Progress bars capacity
- Status badges
- Haptic feedback (light/medium/heavy)
- Semantic labels for screen readers
- Keyboard navigation (Tab order, Enter/Space, Escape, Arrow keys)
- Reduced motion support (respect prefers-reduced-motion)
- High contrast mode
- Dynamic text sizing (200% zoom test)

**Acceptance**:
- Touch ≥ 48dp (measured)
- Contrast ≥ 4.5:1 (verified with tool)
- VoiceOver/TalkBack reads correctly
- Haptic on: assign, conflict, capacity full
- Keyboard navigation works without mouse
- Animations disable when reduced motion requested

---

### Priority 5: Advanced ⭐ (Backlog) - PHASE 1
**Important**: Efficiency features

**Components**:
- Long-press vehicle cards → Context menu (Edit / Remove / Copy to other days / View all)
- ContextMenuRegion with 500ms threshold
- Haptic medium impact on menu open

**Acceptance**:
- Long-press (500ms) opens context menu
- Menu options work correctly
- Haptic feedback triggers

---

## Success Metrics

### Task Completion
- **Assign vehicle**: < 30s
- **Assign children**: < 60s

### Error Rate
- **Capacity conflicts**: < 5% (prevented by UI)

### Accessibility
- **WCAG 2.2 AA**: 100% compliance (Lighthouse)
- **Keyboard navigation**: 100% functionality
- **Screen reader**: 100% semantic labels
- **Touch targets**: 100% ≥ 48dp
- **Color contrast**: 100% ≥ 4.5:1

### User Satisfaction
- **Post-launch**: ≥ 4.0/5.0 usability

---

**Research**: Nielsen Norman Group, Material Design 3, Flutter docs, WCAG 2.2  
**Apps analysés**: Google Calendar, Calendly, Doodle, When2Meet mobile  
**Date**: January 2025  
**Updated**: October 2025 - Phase 1/2 split defined