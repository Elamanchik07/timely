import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/timely_button.dart';
import '../../../../core/widgets/timely_input.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/biometric_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    debugPrint('[LOGIN] login_clicked');
    if (_isSubmitting) {
      debugPrint('[LOGIN] blocked: already submitting');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      debugPrint('[LOGIN] validation_failed');
      return;
    }

    debugPrint('[LOGIN] validation_ok');
    setState(() => _isSubmitting = true);

    try {
      debugPrint('[LOGIN] auth_request_started');
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      debugPrint('[LOGIN] auth_request_completed');

      // After login, check auth state and navigate
      final authState = ref.read(authProvider);
      authState.whenData((user) {
        if (user != null && mounted) {
          debugPrint('[LOGIN] user_loaded: ${user.email}, role=${user.role}, status=${user.status}');

          if (user.status == 'PENDING' || user.status == 'REJECTED') {
            debugPrint('[LOGIN] navigate_to_status');
            context.go('/status');
            return;
          }

          if (user.role == 'ADMIN') {
            debugPrint('[LOGIN] navigate_to_admin');
            context.go('/auth_gate');
          } else {
            debugPrint('[LOGIN] navigate_to_home');
            context.go('/');
          }
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleBiometricLogin(l10n) async {
     setState(() => _isSubmitting = true);
     try {
       await ref.read(authProvider.notifier).loginWithBiometrics(l10n.biometricReason);
       
       final authState = ref.read(authProvider);
       authState.whenData((user) {
         if (user != null && mounted) {
           if (user.status == 'PENDING' || user.status == 'REJECTED') {
             context.go('/status');
             return;
           }
           if (user.role == 'ADMIN') {
             context.go('/auth_gate');
           } else {
             context.go('/home');
           }
         }
       });
     } catch (e) {
       debugPrint('[LOGIN] biometric_login_error: $e');
     } finally {
       if (mounted) {
         setState(() => _isSubmitting = false);
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AsyncLoading;
    final l10n = ref.watch(l10nProvider);

    ref.listen(authProvider, (previous, next) {
      if (next is AsyncError) {
        debugPrint('[LOGIN] listener_error: ${next.error}');
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _mapErrorToMessage(next.error.toString(), l10n),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Language selector top-right
              Positioned(
                top: 12,
                right: 16,
                child: const LanguageSelector(compact: true),
              ),
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo / Title
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accent.withValues(alpha: 0.1),
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            size: 64,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Timely',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.welcomeBack,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 48),

                        // Email
                        TimelyInput(
                          controller: _emailController,
                          label: l10n.email,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.enterEmail;
                            if (!RegExp(r'^[\w.\-]+@[\w.\-]+\.\w{2,}$').hasMatch(value)) {
                              return l10n.invalidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TimelyInput(
                          controller: _passwordController,
                          label: l10n.password,
                          prefixIcon: Icons.lock_outline,
                          isPassword: !_isPasswordVisible,
                          suffixIcon: _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onSuffixPressed: () =>
                              setState(() => _isPasswordVisible = !_isPasswordVisible),
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.enterPassword;
                            if (value.length < 8) return l10n.passwordMin8;
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(
                              l10n.forgotPassword,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Login Button
                        Row(
                          children: [
                            Expanded(
                              child: TimelyButton(
                                title: l10n.login,
                                isLoading: isLoading || _isSubmitting,
                                onPressed: (isLoading || _isSubmitting) ? null : _handleLogin,
                              ),
                            ),
                            if (ref.watch(biometricEnabledProvider)) ...[
                              const SizedBox(width: 12),
                              FutureBuilder<bool>(
                                future: ref.read(biometricServiceProvider).isBiometricAvailable(),
                                builder: (context, snapshot) {
                                  if (snapshot.data == true) {
                                    return Container(
                                      height: 56,
                                      width: 56,
                                      decoration: BoxDecoration(
                                        color: AppTheme.accent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.fingerprint_rounded, color: AppTheme.accent, size: 28),
                                        onPressed: (_isSubmitting || isLoading) ? null : () => _handleBiometricLogin(l10n),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Register Link
                        TimelyButton(
                          title: l10n.noAccountRegister,
                          onPressed: () => context.push('/register'),
                          isOutlined: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String _mapErrorToMessage(String error, AppLocalizations l10n) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('wrong credentials') || 
        lowerError.contains('invalid credentials') || 
        lowerError.contains('401')) {
      return l10n.wrongCredentials;
    }
    
    if (lowerError.contains('socketexception') || 
        lowerError.contains('failed host lookup') || 
        lowerError.contains('503')) {
      return l10n.noConnection;
    }
    
    if (lowerError.contains('timeout')) {
      return l10n.connectionTimeout;
    }
    
    // Default fallback
    return error.replaceFirst('Exception: ', '').replaceFirst('error: ', '');
  }
}
