import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../services/app_services.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    if (AppServices.instance.configRepo.hasConfiguredServer) {
      await AppServices.instance.osState.hydrate();
    }

    final destination = await AppServices.instance.auth.resolveDestination();
    final route = switch (destination) {
      AuthDestination.auth => AppRoutes.auth,
      AuthDestination.onboarding => AppRoutes.onboarding,
      AuthDestination.shell => AppRoutes.shell,
    };

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, size: 56, color: colors.primary),
            const SizedBox(height: 20),
            Text(
              'Sanctum',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track. Observe. Learn.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
