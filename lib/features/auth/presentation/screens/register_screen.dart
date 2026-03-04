import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/timely_button.dart';
import '../../../../core/widgets/timely_input.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../core/providers/locale_provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedCourse;
  String? _selectedGroup;
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  final List<String> _groups = [
    for (var i = 1; i <= 9; i++) '230$i',
    for (var i = 1; i <= 9; i++) '240$i',
    for (var i = 1; i <= 9; i++) '250$i',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    ref.read(authProvider.notifier).register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          course: int.tryParse(_selectedCourse ?? ''),
          groupCode: _selectedGroup,
          faculty: 'IT',
        );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerStateProvider);
    final isLoading = registerState is AsyncLoading;
    final l10n = ref.watch(l10nProvider);

    ref.listen(registerStateProvider, (previous, next) {
      if (next is AsyncError) {
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
                    next.error.toString().replaceFirst('Exception: ', ''),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      if (next is AsyncData && next.value != null) {
        // Registration successful → navigate to register-success screen
        setState(() => _isSubmitting = false);
        context.go('/register-success');
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with language selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary),
                    ),
                    Text(
                      l10n.registration,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const LanguageSelector(compact: true),
                    const SizedBox(width: 4),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accent.withOpacity(0.1),
                          ),
                          child: const Icon(Icons.person_add_rounded,
                              size: 48, color: AppTheme.accent),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.createAccount,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.registerSubtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),

                        TimelyInput(
                          controller: _nameController,
                          label: l10n.fullName,
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? l10n.enterFullName : null,
                        ),
                        const SizedBox(height: 16),
                        TimelyInput(
                          controller: _emailController,
                          label: l10n.email,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return l10n.enterEmail;
                            if (!RegExp(r'^[\w.\-]+@[\w.\-]+\.\w{2,}$')
                                .hasMatch(v)) {
                              return l10n.invalidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TimelyInput(
                          controller: _phoneController,
                          label: l10n.phone,
                          hint: '+7...',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              !RegExp(r'^\+7\d{10}$').hasMatch(v ?? '')
                                  ? l10n.phoneFormat
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        // Course + Group row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCourse,
                                dropdownColor: AppTheme.primaryMid,
                                decoration: InputDecoration(
                                  labelText: l10n.course,
                                  prefixIcon: const Icon(Icons.school_outlined),
                                ),
                                items: ['1', '2', '3', '4']
                                    .map((c) => DropdownMenuItem(
                                        value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedCourse = v),
                                validator: (v) =>
                                    v == null ? l10n.selectCourse : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGroup,
                                dropdownColor: AppTheme.primaryMid,
                                decoration: InputDecoration(
                                  labelText: l10n.group,
                                  prefixIcon: const Icon(Icons.group_outlined),
                                ),
                                items: _groups
                                    .map((g) => DropdownMenuItem(
                                        value: g, child: Text(g)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedGroup = v),
                                validator: (v) =>
                                    v == null ? l10n.selectGroup : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TimelyInput(
                          controller: _passwordController,
                          label: l10n.password,
                          prefixIcon: Icons.lock_outline,
                          isPassword: !_isPasswordVisible,
                          suffixIcon: _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onSuffixPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible),
                          validator: (v) => (v?.length ?? 0) < 8
                              ? l10n.passwordMin8
                              : null,
                        ),
                        const SizedBox(height: 32),

                        TimelyButton(
                          title: l10n.register,
                          isLoading: isLoading || _isSubmitting,
                          onPressed: _handleRegister,
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
}
