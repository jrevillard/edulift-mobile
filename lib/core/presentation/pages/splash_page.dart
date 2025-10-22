import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Delayed auth initialization to avoid modifying provider during build cycle
    // Using Future() instead of addPostFrameCallback to prevent pumpAndSettle conflicts
    Future(() {
      ref.read(authStateProvider.notifier).initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: Key('splash_page'),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
