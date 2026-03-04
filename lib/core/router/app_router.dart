import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/status_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verify_code_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/settings/presentation/screens/help_faq_page.dart';
import '../../features/settings/presentation/screens/privacy_policy_page.dart';
import '../../features/settings/presentation/screens/settings_page.dart';
import '../../screens/home_screen.dart';

// Smooth fade transition page
CustomTransitionPage<void> _fadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final currentPath = state.uri.toString();

      // Allow splash screen always
      if (currentPath == '/splash') return null;

      final isLoggedIn = authState.asData?.value != null;
      final isAuthRoute = currentPath == '/login' ||
          currentPath == '/register' ||
          currentPath == '/register-success' ||
          currentPath == '/forgot-password' ||
          currentPath == '/verify-code' ||
          currentPath == '/reset-password';

      // Still loading auth state
      if (authState is AsyncLoading && !isAuthRoute && currentPath != '/splash') {
        return '/splash';
      }

      // Not logged in → allow auth routes, redirect others to login
      if (!isLoggedIn && isAuthRoute) return null;
      if (!isLoggedIn) return '/login';

      // Logged in
      final user = authState.asData!.value!;

      // Admin redirect
      if (user.role == 'ADMIN') {
        if (!currentPath.startsWith('/admin')) return '/admin';
        return null;
      }

      // Student redirects
      if (isAuthRoute || currentPath == '/splash') {
        if (user.status == 'PENDING') return '/status';
        return '/home';
      }

      if (user.status == 'PENDING' && currentPath != '/status') return '/status';
      if (user.status == 'APPROVED' && currentPath == '/status') return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/register-success',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const RegisterSuccessScreen(),
        ),
      ),
      GoRoute(
        path: '/status',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const StatusScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const AdminDashboard(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/help-faq',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const HelpFaqPage(),
        ),
      ),
      GoRoute(
        path: '/privacy-policy',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const PrivacyPolicyPage(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/verify-code',
        pageBuilder: (context, state) {
          final email = state.extra as String? ?? '';
          return _fadeTransitionPage(
            key: state.pageKey,
            child: VerifyCodeScreen(email: email),
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) {
          final resetToken = state.extra as String? ?? '';
          return _fadeTransitionPage(
            key: state.pageKey,
            child: ResetPasswordScreen(resetToken: resetToken),
          );
        },
      ),
    ],
  );
});
