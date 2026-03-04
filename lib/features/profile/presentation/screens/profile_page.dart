import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../settings/presentation/screens/settings_page.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';
import '../../../schedule/domain/entities/schedule_item.dart';
import '../../../../core/utils/room_utils.dart';

const _kAvatarPathKey = 'user_avatar_path';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  bool _isEditing = false;
  File? _avatarFile;
  bool _isPickingAvatar = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _groupController;

  // Animations
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _headerScaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final List<Animation<double>> _staggeredFades = [];
  final List<Animation<Offset>> _staggeredSlides = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _groupController = TextEditingController();

    // Setup Entrance Animations
    _entranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    _headerScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _fadeAnim = CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut));

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    for (int i = 0; i < 4; i++) {
      double start = 0.3 + (i * 0.15);
      double end = start + 0.3;
      if (end > 1.0) end = 1.0;
      _staggeredFades.add(CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOut)));
      _staggeredSlides.add(
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
              CurvedAnimation(
                  parent: _entranceController,
                  curve: Interval(start, end, curve: Curves.easeOutCubic))));
    }

    // Setup Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _entranceController.forward();
    _loadSavedAvatar();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _groupController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_kAvatarPathKey);
    if (savedPath != null && savedPath.isNotEmpty) {
      final file = File(savedPath);
      if (await file.exists()) {
        setState(() => _avatarFile = file);
      }
    }
  }

  Future<void> _pickAvatar() async {
    if (_isPickingAvatar) return;
    setState(() => _isPickingAvatar = true);
    final l10n = ref.read(l10nProvider);

    try {
      final picker = ImagePicker();
      HapticFeedback.mediumImpact();
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.primaryMid,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.changeProfilePhoto,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ImageSourceOption(
                            icon: Icons.photo_library_rounded,
                            label: l10n.gallery,
                            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ImageSourceOption(
                            icon: Icons.camera_alt_rounded,
                            label: l10n.camera,
                            onTap: () => Navigator.pop(ctx, ImageSource.camera),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );

      if (source == null) {
        setState(() => _isPickingAvatar = false);
        return;
      }

      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked == null) {
        setState(() => _isPickingAvatar = false);
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${appDir.path}/avatars');
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      final ext = picked.path.split('.').last;
      final savedFile =
          await File(picked.path).copy('${avatarDir.path}/avatar.$ext');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAvatarPathKey, savedFile.path);

      setState(() {
        _avatarFile = savedFile;
        _isPickingAvatar = false;
      });

      _showSuccessSnackBar(l10n.avatarUpdated);
    } catch (e) {
      setState(() => _isPickingAvatar = false);
      _showErrorSnackBar('${l10n.errorOccurred}: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Text(message),
        ],
      ),
      backgroundColor: AppTheme.successColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.errorColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  void _initFields(User user) {
    if (_nameController.text.isEmpty && !_isEditing) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
      _groupController.text = user.groupCode ?? '';
    }
  }

  void _toggleEdit(User user) {
    final l10n = ref.read(l10nProvider);
    HapticFeedback.lightImpact();
    if (_isEditing) {
      _showSuccessSnackBar(l10n.profileSaved);
    }
    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value;
    final l10n = ref.watch(l10nProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    // Attempt to watch schedule provider if possible
    AsyncValue<List<ScheduleItem>>? scheduleState;
    if (user.groupCode != null && user.groupCode!.isNotEmpty) {
      scheduleState = ref.watch(scheduleProvider(user.groupCode!));
    }

    _initFields(user);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Gradient Animation
          Positioned(
            top: -100,
            left: -100,
            right: -100,
            height: MediaQuery.of(context).size.height * 0.45,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accent.withOpacity(0.2 + (_pulseController.value * 0.05)),
                        AppTheme.backgroundColor,
                      ],
                      center: Alignment.topCenter,
                      radius: 1.2,
                    ),
                  ),
                );
              },
            ),
          ),

          // Main ScrollView
          CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                  ),
                  child: Column(
                    children: [
                      _buildTopBar(l10n),
                      const SizedBox(height: 24),
                      _buildAvatar(user),
                      const SizedBox(height: 20),
                      _buildUserInfo(user, l10n),
                      const SizedBox(height: 28),
                      _buildQuickStats(user, l10n),
                      const SizedBox(height: 24),
                      if (scheduleState != null) _buildNextClassWidget(scheduleState, l10n),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(l10n.academicInfo, 0),
                      const SizedBox(height: 4),
                      // Note: admin-only
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline_rounded, size: 14, color: AppTheme.textSecondary.withOpacity(0.6)),
                            const SizedBox(width: 6),
                            Text(
                              l10n.academicFieldsNote,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildAcademicInfo(user, l10n),
                      const SizedBox(height: 32),
                      _buildSectionTitle(l10n.personalInfo, 1),
                      const SizedBox(height: 12),
                      _buildInfoCards(user, l10n),
                      const SizedBox(height: 32),
                      _buildActionButtons(user, l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(l10n) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.profile,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.dividerColor.withOpacity(0.5)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings_suggest_rounded,
                      color: AppTheme.textSecondary, size: 26),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/settings');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(User user) {
    return ScaleTransition(
      scale: _headerScaleAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onTap: _pickAvatar,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse Effect Behind
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 140 + (_pulseController.value * 15),
                    height: 140 + (_pulseController.value * 15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accent.withOpacity(0.1 - (_pulseController.value * 0.05)),
                    ),
                  );
                },
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accentLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryMid,
                      image: _avatarFile != null
                          ? DecorationImage(
                              image: FileImage(_avatarFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _avatarFile == null
                        ? Center(
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accent,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isPickingAvatar
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.accent),
                        )
                      : const Icon(Icons.edit_rounded,
                          color: AppTheme.accent, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user, l10n) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: user.role == 'ADMIN'
                  ? AppTheme.errorColor.withOpacity(0.15)
                  : AppTheme.successColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.role == 'ADMIN'
                      ? Icons.shield_rounded
                      : Icons.school_rounded,
                  color: user.role == 'ADMIN'
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  user.role == 'ADMIN' ? l10n.administrator : l10n.student,
                  style: TextStyle(
                    color: user.role == 'ADMIN'
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(User user, l10n) {
    return FadeTransition(
      opacity: _staggeredFades[0],
      child: SlideTransition(
        position: _staggeredSlides[0],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(l10n.group, user.groupCode ?? '—', Icons.people_alt_rounded),
                _buildDivider(),
                _buildStatItem(l10n.course, _determineCourse(user.groupCode), Icons.menu_book_rounded),
                _buildDivider(),
                _buildStatItem(l10n.status, l10n.active, Icons.check_circle_rounded, AppTheme.successColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _determineCourse(String? groupCode) {
    if (groupCode == null || groupCode.isEmpty) return '—';
    if (groupCode.contains('21') || groupCode.contains('22')) return '4';
    if (groupCode.contains('23')) return '3';
    if (groupCode.contains('24')) return '2';
    if (groupCode.contains('25')) return '1';
    return '—';
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? iconColor]) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.accent).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? AppTheme.accent, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: AppTheme.dividerColor,
    );
  }

  Widget _buildNextClassWidget(AsyncValue<List<ScheduleItem>> scheduleState, l10n) {
    return FadeTransition(
      opacity: _staggeredFades[0],
      child: SlideTransition(
        position: _staggeredSlides[0],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accent.withOpacity(0.15), AppTheme.accentLight.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
            ),
            child: scheduleState.when(
              data: (items) {
                if (items.isEmpty) return _buildEmptyNextClass(l10n.noClasses);
                
                final now = DateTime.now();
                ScheduleItem? nextItem;
                int? waitTime;

                for (var item in items) {
                  final partsStart = item.startTime.split(':');
                  if (partsStart.length == 2) {
                    final start = DateTime(now.year, now.month, now.day, int.parse(partsStart[0]), int.parse(partsStart[1]));
                    if (start.isAfter(now)) {
                      final diff = start.difference(now).inMinutes;
                      if (waitTime == null || diff < waitTime) {
                        waitTime = diff;
                        nextItem = item;
                      }
                    }
                  }
                }

                if (nextItem == null) return _buildEmptyNextClass(l10n.noMoreClasses);

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.class_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.nextClass,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextItem.subject,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 14, color: AppTheme.accent.withOpacity(0.8)),
                              const SizedBox(width: 4),
                              Text(nextItem.startTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              Icon(Icons.location_on_rounded, size: 14, color: AppTheme.accent.withOpacity(0.8)),
                              const SizedBox(width: 4),
                              Text(RoomUtils.displayCode(nextItem.room), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              )),
              error: (_, __) => _buildEmptyNextClass(l10n.loadingError),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyNextClass(String message) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.beach_access_rounded, color: AppTheme.textSecondary, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          message,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicInfo(User user, l10n) {
    return FadeTransition(
      opacity: _staggeredFades[1],
      child: SlideTransition(
        position: _staggeredSlides[1],
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAnimatedTextField(
                icon: Icons.account_balance_rounded,
                label: l10n.university,
                controller: TextEditingController(text: user.university ?? '—'),
                enabled: false,
                isFirst: true,
              ),
              _dividerRow(),
              _buildAnimatedTextField(
                icon: Icons.domain_rounded,
                label: l10n.faculty,
                controller: TextEditingController(text: user.faculty ?? '—'),
                enabled: false,
              ),
              _dividerRow(),
              _buildAnimatedTextField(
                icon: Icons.auto_stories_rounded,
                label: l10n.specialty,
                controller: TextEditingController(text: user.specialty ?? '—'),
                enabled: false,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards(User user, l10n) {
    return FadeTransition(
      opacity: _staggeredFades[1],
      child: SlideTransition(
        position: _staggeredSlides[1],
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  _buildAnimatedTextField(
                    icon: Icons.badge_rounded,
                    label: l10n.fullName,
                    controller: _nameController,
                    enabled: false,
                    isFirst: true,
                  ),
                  _dividerRow(),
                  _buildAnimatedTextField(
                    icon: Icons.alternate_email_rounded,
                    label: l10n.email,
                    controller: TextEditingController(text: user.email),
                    enabled: false,
                  ),
                  _dividerRow(),
                  _buildAnimatedTextField(
                    icon: Icons.phone_rounded,
                    label: l10n.phoneNumber,
                    controller: _phoneController,
                    enabled: _isEditing,
                    hint: '+7 (999) 000-00-00',
                    keyboardType: TextInputType.phone,
                  ),
                  _dividerRow(),
                  _buildAnimatedTextField(
                    icon: Icons.group_rounded,
                    label: l10n.group,
                    controller: _groupController,
                    enabled: _isEditing,
                    hint: 'ПР-21',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int staggerIndex) {
    return FadeTransition(
      opacity: _staggeredFades[staggerIndex],
      child: SlideTransition(
        position: _staggeredSlides[staggerIndex],
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dividerRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 68, right: 16),
      child: Divider(height: 1, color: AppTheme.dividerColor.withOpacity(0.5)),
    );
  }

  Widget _buildAnimatedTextField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    String? hint,
    TextInputType? keyboardType,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: enabled ? AppTheme.accent.withOpacity(0.05) : Colors.transparent,
      padding: EdgeInsets.only(
        left: 16, right: 16,
        top: isFirst ? 12 : 6,
        bottom: isLast ? 12 : 6,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? AppTheme.accent.withOpacity(0.15)
                  : AppTheme.primaryMid,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 22,
              color: enabled ? AppTheme.accent : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: enabled ? AppTheme.textPrimary : AppTheme.textPrimary.withOpacity(0.8),
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
                hintText: hint,
                hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.4)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: false,
              ),
            ),
          ),
          if (enabled)
            Icon(Icons.edit_rounded, size: 18, color: AppTheme.accent.withOpacity(0.8)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(User user, l10n) {
    return FadeTransition(
      opacity: _staggeredFades[2],
      child: SlideTransition(
        position: _staggeredSlides[2],
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (_isEditing)
                    BoxShadow(
                      color: AppTheme.successColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  else
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _toggleEdit(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing ? AppTheme.successColor : AppTheme.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isEditing ? Icons.check_circle_rounded : Icons.edit_rounded,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isEditing ? l10n.saveChanges : l10n.editProfile,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Sign out
            Center(
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(authProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor, size: 20),
                label: Text(
                  l10n.logoutFromAccount,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.accent),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
