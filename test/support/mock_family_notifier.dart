import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart';

/// Mock FamilyNotifier pour les tests qui n'utilise pas ReactiveStateCoordinator
/// Évite complètement les problèmes de timer
class TestFamilyNotifier extends StateNotifier<FamilyState> {
  TestFamilyNotifier() : super(const FamilyState());

  // Méthode pour éviter l'appel à ReactiveStateCoordinator
  Future<void> loadFamily() async {
    // Ne rien faire - éviter complètement le ReactiveStateCoordinator
    // Pas d'appel à coordinateCriticalState()
  }
}
