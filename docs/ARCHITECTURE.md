# EduLift Mobile - Clean Architecture Documentation

## 🏗️ Architecture Overview

EduLift Mobile follows **Clean Architecture** principles with a clear separation of concerns across layers. The architecture ensures maintainability, testability, and scalability through proper dependency inversion and domain-driven design.

---

## 🏛️ Architecture Layers

### **Core Layer** (`/lib/core/`)
**Purpose**: Domain-independent infrastructure and business services

```
core/
├── constants/          # Application-wide constants
├── di/                # Dependency injection (Riverpod providers)
├── errors/            # Error handling & custom exceptions  
├── network/           # HTTP clients & network abstractions
├── security/          # Encryption, authentication & secure storage
├── services/          # Cross-cutting business services
├── storage/           # Data persistence abstractions (Hive)
├── utils/             # Core utilities (Result pattern, etc.)
└── index.dart         # Core barrel exports
```

**Key Principles**:
- Framework-independent business logic
- Dependency inversion principle
- Interface segregation
- Single responsibility per service

### **Features Layer** (`/lib/features/`)
**Purpose**: Feature-specific business logic following Clean Architecture

```
features/
└── family/
    ├── data/           # Data layer (repositories, datasources, models)
    │   ├── datasources/   # Remote & local data sources
    │   ├── models/        # Data transfer objects
    │   └── repositories/  # Repository implementations
    ├── domain/         # Domain layer (entities, use cases, interfaces)
    │   ├── entities/      # Business entities
    │   ├── repositories/  # Repository contracts
    │   └── usecases/      # Business use cases
    └── presentation/   # Presentation layer (providers, pages, widgets)
        ├── pages/         # Feature screens
        ├── providers/     # Riverpod state providers
        └── widgets/       # Feature-specific widgets
```

### **Shared Layer** (`/lib/shared/`)
**Purpose**: UI framework and cross-feature presentation concerns

```
shared/
├── themes/            # Material 3 design system
│   ├── app_theme.dart    # Main theme configuration
│   ├── app_colors.dart   # Color palette
│   ├── app_spacing.dart  # Spacing constants
│   └── app_text_styles.dart # Typography system
├── widgets/           # Reusable UI components
│   ├── adaptive_widgets.dart # Platform-adaptive widgets
│   ├── error_view.dart      # Error display components
│   └── loading_indicator.dart # Loading states
├── providers/         # Global state providers
│   └── theme_provider.dart  # Theme state management
└── index.dart         # Shared barrel exports
```

---

## 📋 Clean Architecture Testing Structure

```
test/
├── core/              # Core Infrastructure Tests (32+ tests ✅)
│   ├── errors/           # Exception handling tests
│   ├── network/          # API client tests with mocks
│   ├── security/         # Security service tests
│   ├── services/         # Business service tests
│   └── utils/            # Utility tests (Result pattern)
├── features/          # Feature-Specific Tests
│   └── family/
│       ├── data/         # Data layer tests (TDD London)
│       ├── domain/       # Domain logic tests
│       └── presentation/ # UI logic tests
├── widget/            # Widget Tests
│   ├── features/         # Feature widget tests
│   ├── shared/           # Shared widget tests
│   └── accessibility/    # WCAG compliance tests
├── integration/       # Integration Tests
│   ├── core/             # Core service integration
│   └── features/         # End-to-end feature flows
└── helpers/           # Test Infrastructure
    ├── test_factory.dart # Test data generation
    ├── mock_configurations.dart # Mock setup
    └── test_setup_utilities.dart # Test utilities
```

---

## 🔄 Data Flow Architecture

### Request Flow (Outside-In)
```
UI Widget → Provider → Use Case → Repository → Data Source → API/Storage
```

### Response Flow (Inside-Out)
```
API/Storage → Data Source → Repository → Use Case → Provider → UI Widget
```

### Error Handling Flow
```
Exception → Repository → Use Case → Provider → UI (Error State)
```

---

## 🎯 Key Architectural Decisions

### **1. Result Pattern for Error Handling**
```dart
// Core utility for handling success/failure states
Result<Family, Exception> result = await familyRepository.getCurrentFamily();
result.when(
  ok: (family) => displayFamily(family),
  err: (error) => showError(error.message),
);
```

### **2. Dependency Injection with Injectable**
```dart
@Injectable(as: FamilyRepository)
class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyRemoteDataSource _remoteDataSource;
  final FamilyLocalDataSource _localDataSource;
  
  FamilyRepositoryImpl(this._remoteDataSource, this._localDataSource);
}
```

### **3. State Management with Riverpod**
```dart
@riverpod
class FamilyNotifier extends _$FamilyNotifier {
  @override
  Future<List<Family>> build() => _familyRepository.getFamilies();
}
```

### **4. Use Cases Pattern (Clean Architecture Domain Layer)**
```dart
@provider
class CreateFamilyUsecase {
  final FamilyRepository repository;
  
  CreateFamilyUsecase(this.repository);
  
  Future<Result<Family, ApiFailure>> call(CreateFamilyParams params) async {
    // 1. Input validation (business rules)
    if (params.name.trim().isEmpty) {
      return Result.err(ApiFailure.validationError(message: 'Family name required'));
    }
    
    // 2. Business logic validation
    if (_hasInvalidCharacters(params.name)) {
      return Result.err(ApiFailure.validationError(message: 'Invalid characters'));
    }
    
    // 3. Delegate to repository for persistence
    return await repository.createFamily(name: params.name.trim());
  }
  
  bool _hasInvalidCharacters(String name) {
    // Business rule: Only alphanumeric, spaces, hyphens, apostrophes allowed
    final validPattern = RegExp(r"^[a-zA-Z0-9\s\-']+$");
    return !validPattern.hasMatch(name.trim());
  }
}
```

**Use Case Principles**:
- ✅ **Single Responsibility**: One use case per business operation
- ✅ **Business Logic**: Contains domain rules and validation
- ✅ **Repository Abstraction**: Uses interfaces, not implementations  
- ✅ **Result Pattern**: Type-safe error handling
- ✅ **Testable**: Easy to mock and test independently

**Usage in Presentation Layer**:
```dart
class CreateFamilyNotifier extends StateNotifier<CreateFamilyState> {
  final CreateFamilyUsecase _createFamilyUsecase;
  
  // ✅ CORRECT: Presentation calls Use Case (not Repository directly)
  Future<void> createFamily(String name) async {
    final params = CreateFamilyParams(name: name);
    final result = await _createFamilyUsecase.call(params);
    // Handle result...
  }
}
```

### **5. TDD London School Testing**
- Mock all dependencies (strict mocking)
- Test behavior over state
- RED → GREEN → REFACTOR cycles
- Interface-based testing

---

## 🔧 Development Guidelines

### **Core Layer Rules**
- ❌ No Flutter/UI framework dependencies
- ❌ No direct database/network calls
- ✅ Abstract interfaces only
- ✅ Pure business logic
- ✅ Framework-agnostic utilities

### **Features Layer Rules**
- ✅ Clean Architecture layers (data/domain/presentation)
- ✅ Dependency inversion (interfaces in domain)
- ✅ Repository pattern for data access
- ✅ Use cases for business operations
- ❌ Cross-feature dependencies

### **Use Cases Architecture Rules**
- ✅ **One Use Case per Business Operation**: CreateFamilyUsecase, GetFamilyUsecase, etc.
- ✅ **Business Logic Container**: All domain rules and validation logic
- ✅ **Repository Abstraction**: Use interfaces, never concrete implementations
- ✅ **Parameter Objects**: Use dedicated parameter classes for complex inputs
- ✅ **Result Pattern**: Return Result<T, E> for type-safe error handling
- ❌ **Direct Repository Calls**: Presentation layer must never call repositories directly
- ❌ **UI Framework Dependencies**: Use cases must be framework-agnostic
- ❌ **State Management**: Use cases should be stateless

**Use Case Testing Strategy**:
```dart
class CreateFamilyUsecaseTest {
  // TDD London School: Mock all dependencies
  late MockFamilyRepository mockRepository;
  late CreateFamilyUsecase usecase;
  
  setUp(() {
    mockRepository = MockFamilyRepository();
    usecase = CreateFamilyUsecase(mockRepository);
  });
  
  test('should validate family name and call repository', () async {
    // Arrange: Set up test data and mocks
    const params = CreateFamilyParams(name: 'Test Family');
    when(mockRepository.createFamily(any)).thenAnswer((_) async => Result.ok(mockFamily));
    
    // Act: Execute the use case
    final result = await usecase.call(params);
    
    // Assert: Verify behavior and interactions
    expect(result, isA<Ok>());
    verify(mockRepository.createFamily(name: 'Test Family')).called(1);
  });
}

### **Shared Layer Rules**
- ✅ Reusable UI components
- ✅ Design system consistency
- ✅ Accessibility compliance (WCAG 2.1 AA)
- ❌ Business logic in widgets
- ❌ Direct API calls from UI

---

## 📊 Architecture Metrics

### Code Organization
- **Core Coverage**: 95%+ (32/32 tests passing ✅)
- **Feature Coverage**: 90%+ (data layer tested)
- **Widget Coverage**: 95%+ (UI components tested)
- **Integration Coverage**: 85%+ (end-to-end flows)

### Quality Gates
- ✅ Zero compilation errors
- ✅ All tests passing
- ✅ 90%+ test coverage
- ✅ Clean Architecture compliance
- ✅ SOLID principles adherence

---

## 🚀 Benefits of This Architecture

### **Maintainability**
- Clear separation of concerns
- Easy to locate and modify code
- Minimal coupling between layers

### **Testability** 
- Mock-friendly interfaces
- Isolated unit testing
- TDD London methodology support

### **Scalability**
- Feature-based organization
- Independent development streams
- Easy to add new features

### **Quality**
- Compile-time safety
- Runtime error handling
- Performance optimization points

---

This architecture enables rapid feature development while maintaining code quality and ensuring long-term maintainability of the EduLift Mobile application.