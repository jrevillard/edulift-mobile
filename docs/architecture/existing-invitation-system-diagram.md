# EXISTING Invitation System Architecture Diagram

**Based on analysis of current files** - showing what ACTUALLY exists and how it's connected.

## 📊 Current State Analysis - File-to-File Connections

```mermaid
graph TB
    %% =================================================
    %% PRESENTATION LAYER
    %% =================================================
    subgraph "🎨 PRESENTATION LAYER"
        FIP[FamilyInvitationProvider<br/>family_invitation_provider.dart]
        IP[InvitationsPage<br/>invitations_page.dart]
        FP[FamilyProvider<br/>family_provider.dart]
    end

    %% =================================================
    %% DOMAIN LAYER  
    %% =================================================
    subgraph "🏢 DOMAIN LAYER"
        IMU[InviteMemberUsecase<br/>invite_member_usecase.dart]
        IR[InvitationRepository<br/>invitation_repository.dart<br/>(INTERFACE)]
    end

    %% =================================================
    %% DATA LAYER
    %% =================================================
    subgraph "💾 DATA LAYER"
        IRI[InvitationRepositoryImpl<br/>invitation_repository_impl.dart<br/>(DELETED FILE)]
        FRDS[FamilyRemoteDataSourceImpl<br/>family_remote_datasource_impl.dart]
    end

    %% =================================================
    %% INFRASTRUCTURE LAYER
    %% =================================================
    subgraph "🔧 INFRASTRUCTURE LAYER"
        UIS[UnifiedInvitationService<br/>unified_invitation_service.dart]
        AC[ApiClient<br/>api_client.dart]
    end

    %% =================================================
    %% PROVIDER INJECTION CHAIN
    %% =================================================
    subgraph "🔌 PROVIDER SYSTEM"
        SP[ServiceProviders<br/>service_providers.dart]
        RP[RepositoryProviders<br/>repository_providers.dart]
        FPP[FamilyProviders<br/>providers.dart]
    end

    %% =================================================
    %% CONNECTION FLOW
    %% =================================================
    %% Presentation connections
    FIP -->|"watches unifiedInvitationServiceProvider"| UIS
    FIP -->|"watches authServiceProvider"| SP
    FIP -->|"calls _ref.read(familyProvider.notifier)"| FP
    
    %% Missing connection - UseCase not used!
    FIP -.->|"❌ MISSING:<br/>Should use InviteMemberUsecase"| IMU

    %% Domain connections
    IMU -->|"depends on"| IR
    
    %% Data layer - BROKEN!
    IR -.->|"❌ DELETED:<br/>implementation missing"| IRI
    IRI -.->|"❌ BROKEN:<br/>should delegate to"| FRDS
    
    %% Infrastructure connections - WORKS
    FRDS -->|"has getter for"| UIS
    UIS -->|"uses"| AC
    
    %% Provider connections
    SP -->|"provides"| UIS
    SP -->|"configures"| AC
    FPP -->|"re-exports"| SP
    FPP -->|"should provide"| RP
    RP -.->|"❌ MISSING:<br/>InvitationRepository provider"| IRI

    %% =================================================
    %% ISSUE INDICATORS
    %% =================================================
    classDef broken fill:#ff6b6b,stroke:#d63031,color:#fff
    classDef missing fill:#ffeaa7,stroke:#fdcb6e,color:#000
    classDef working fill:#55a3ff,stroke:#0984e3,color:#fff
    classDef deleted fill:#ff7675,stroke:#d63031,color:#fff
    
    class IRI deleted
    class IR,IMU missing
    class FIP,UIS,FRDS,AC,SP working
```

## 🚨 CRITICAL FINDINGS

### ❌ What's BROKEN:

1. **InvitationRepositoryImpl DELETED** - The bridge between domain and data is missing
2. **UseCase Pattern BYPASSED** - Presentation directly calls UnifiedInvitationService
3. **Clean Architecture VIOLATED** - Presentation → Infrastructure direct dependency
4. **Repository Interface ORPHANED** - Interface exists but no implementation

### ⚠️ What's INCONSISTENT:

1. **Mixed Patterns** - Some providers use repository pattern, others bypass it
2. **Validation Flow** - Validates via UnifiedInvitationService, accepts via same service
3. **Error Handling** - Multiple error handling approaches across layers

### ✅ What ACTUALLY WORKS:

1. **UnifiedInvitationService** - Core invitation logic implemented
2. **FamilyInvitationProvider** - Riverpod state management working
3. **ApiClient Integration** - HTTP calls to backend functional
4. **Service Providers** - Dependency injection configured

## 🔄 CURRENT EXECUTION FLOW

### For Invitation Validation:
```
UI → FamilyInvitationProvider 
   → UnifiedInvitationService.validateFamilyInvitation()
   → ApiClient.validateFamilyInvitationByCode()
   → Backend API
```

### For Invitation Acceptance:
```
UI → FamilyInvitationProvider
   → UnifiedInvitationService.acceptFamilyInvitation() 
   → ApiClient.acceptFamilyInvitationByCode()
   → Backend API
```

## 🎯 WHAT DEEP LINK HANDLER NEEDS

### Current Integration Points:
1. **FamilyInvitationProvider.validateInvitation(code)** - ✅ Available
2. **FamilyInvitationProvider.acceptInvitation(code)** - ✅ Available  
3. **Error handling for expired/invalid codes** - ✅ Implemented
4. **UI state management** - ✅ Working with FamilyInvitationState

### Missing for Deep Links:
1. **Route parameter extraction** - Need deep link route handler
2. **Authentication state check** - Need auth guard before validation
3. **Navigation after acceptance** - Need post-acceptance routing

## 📋 ARCHITECTURE VIOLATIONS TO FIX

### For Clean Architecture Compliance:
1. **Restore InvitationRepositoryImpl** - Bridge domain/data layers
2. **Use InviteMemberUsecase** - Follow domain-driven pattern  
3. **Remove direct service calls** - Go through repository interface
4. **Add missing providers** - Complete dependency injection

### Current Shortcut (Working but Violates Clean Architecture):
```dart
// FamilyInvitationProvider currently does:
final result = await _invitationService.validateFamilyInvitation(inviteCode);

// Should do:
final result = await _invitationUseCase.validate(ValidateInvitationParams(inviteCode));
```

## 🏗️ RECOMMENDATION FOR DEEP LINK INTEGRATION

**Use the EXISTING working flow** for deep links:
1. Extract invite code from deep link URL
2. Call `FamilyInvitationProvider.validateInvitation(code)`
3. Show validation result to user
4. Call `FamilyInvitationProvider.acceptInvitation(code)` if user confirms
5. Navigate based on acceptance result

**Don't try to "fix" the architecture first** - the current flow works and integrating deep links can use it as-is.