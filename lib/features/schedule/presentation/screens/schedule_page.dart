import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/schedule_provider.dart';
import '../../domain/entities/schedule_item.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/navigation_providers.dart';
import '../../../../core/utils/room_utils.dart';
import '../../../../core/widgets/timely_shimmer.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../widgets/smart_schedule_card.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentDayIndex = DateTime.now().weekday - 1;
  
  // Toggle states
  bool _isTeacherMode = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Color palette for lesson types
  static const _typeColors = {
    'lecture': Color(0xFF3A86FF),
    'practice': Color(0xFFFF9F1C),
    'lab': Color(0xFF00D68F),
    'seminar': Color(0xFF8338EC),
  };

  static const _typeIcons = {
    'lecture': Icons.menu_book_rounded,
    'practice': Icons.edit_note_rounded,
    'lab': Icons.science_rounded,
    'seminar': Icons.groups_rounded,
  };

  final Map<String, Color> _subjectColors = {};
  static const _colorPool = [
    Color(0xFF3A86FF), Color(0xFFFF6B6B), Color(0xFF00D68F),
    Color(0xFFFF9F1C), Color(0xFF8338EC), Color(0xFFFF006E),
    Color(0xFF06D6A0), Color(0xFFFFBE0B), Color(0xFF118AB2),
    Color(0xFFEF476F),
  ];

  Color _getSubjectColor(String subject) {
    return _subjectColors.putIfAbsent(
      subject,
      () => _colorPool[_subjectColors.length % _colorPool.length],
    );
  }

  @override
  void initState() {
    super.initState();
    if (_currentDayIndex > 6) _currentDayIndex = 0;
    _pageController = PageController(initialPage: _currentDayIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value;
    final groupCode = user?.groupCode ?? '';
    final isTeacherUser = user?.isTeacher ?? false;

    // Determine the query based on mode
    final currentQuery = _isTeacherMode ? _searchQuery : groupCode;
    
    // If the query is empty in teacher mode, we wait for input
    final scheduleAsync = (currentQuery.isEmpty && !_isTeacherMode) 
        ? const AsyncValue<List<ScheduleItem>>.data([]) 
        : ref.watch(scheduleProvider(currentQuery));

    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(context, groupCode, isTeacherUser, l10n),
          
          if (_isTeacherMode && !isTeacherUser)
             _buildTeacherSearch(l10n),

          // Day selector chips
          _buildDaySelector(context, l10n),
          const SizedBox(height: 8),
          
          // Schedule content
          Expanded(
            child: (currentQuery.isEmpty && _isTeacherMode) 
            ? _buildInitialTeacherState(l10n) 
            : scheduleAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: 4,
                itemBuilder: (ctx, idx) => TimelyShimmer(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              error: (err, stack) => _buildErrorState(context, err, currentQuery, l10n),
              data: (items) {
                 if (currentQuery.isEmpty && !_isTeacherMode) {
                   return _buildMissingGroupState(l10n);
                 }
                 return _buildScheduleContent(context, items, currentQuery, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingGroupState(AppLocalizations l10n) {
     return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_off_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(l10n.groupNotSpecified, style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text(l10n.contactAdmin, style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 14)),
          ],
        ),
     );
  }

  Widget _buildInitialTeacherState(AppLocalizations l10n) {
     return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(l10n.searchTeacherSchedule, style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text(l10n.enterTeacherName, style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 14)),
          ],
        ),
     );
  }

  Widget _buildTeacherSearch(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.teacherSurname,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ) : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String groupCode, bool isTeacherUser, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 12,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.primaryMid,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isTeacherUser ? l10n.mySchedule : l10n.scheduleTitle,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                onPressed: () {
                  final query = _isTeacherMode ? _searchQuery : groupCode;
                  if (query.isNotEmpty) {
                    ref.invalidate(scheduleProvider(query));
                  }
                },
              ),
            ],
          ),
          if (!isTeacherUser) ...[
            const SizedBox(height: 12),
            // Segmented Control
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isTeacherMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isTeacherMode ? AppTheme.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.myGroup,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isTeacherMode ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isTeacherMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isTeacherMode ? AppTheme.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.teachers,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isTeacherMode ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
             const SizedBox(height: 8),
             Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.teacher,
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ]
        ],
      ),
    );
  }


  Widget _buildDaySelector(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final isSelected = _currentDayIndex == index;
          final isToday = index == DateTime.now().weekday - 1;

          return GestureDetector(
            onTap: () {
              setState(() => _currentDayIndex = index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isToday && !isSelected
                    ? Border.all(color: AppTheme.accent.withOpacity(0.5), width: 1.5)
                    : null,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.daysShort[index],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppTheme.accent
                                : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (isToday && !isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object err, String groupCode, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: AppTheme.errorColor.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoad,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(scheduleProvider(groupCode)),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent(BuildContext context, List<ScheduleItem> items, String currentQuery, AppLocalizations l10n) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentDayIndex = index),
      itemCount: 7,
      itemBuilder: (context, dayIndex) {
        final dayItems = items
            .where((item) => item.dayOfWeek == dayIndex + 1)
            .toList()
          ..sort((a, b) => a.pairNumber.compareTo(b.pairNumber));

        if (dayItems.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              try {
                await ref.read(scheduleProvider(currentQuery).notifier).refresh();
              } catch (e) {
                if (context.mounted) AppToast.error(context, l10n.updateFailed);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: _buildEmptyDay(context, dayIndex, l10n),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            try {
              await ref.read(scheduleProvider(currentQuery).notifier).refresh();
            } catch (e) {
              if (context.mounted) AppToast.error(context, l10n.updateFailed);
            }
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: dayItems.length + 1, // +1 for header
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 4),
                child: Text(
                  l10n.daysFull[dayIndex],
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return _ScheduleCardAnimated(
              index: index - 1,
              child: SmartScheduleCard(
                item: dayItems[index - 1],
                isTeacherMode: _isTeacherMode,
                typeColor: _typeColors[dayItems[index - 1].type] ?? AppTheme.accent,
                subjectColor: _getSubjectColor(dayItems[index - 1].subject),
                typeLabel: l10n.classType(dayItems[index - 1].type),
                typeIcon: _typeIcons[dayItems[index - 1].type] ?? Icons.book_rounded,
                isToday: dayIndex + 1 == DateTime.now().weekday,
              ),
            );
          },
        ),
      );
      },
    );
  }

  Widget _buildEmptyDay(BuildContext context, int dayIndex, l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 56,
            color: AppTheme.successColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noClassesSchedule,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.daysFull[dayIndex],
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCardAnimated extends StatefulWidget {
  final int index;
  final Widget child;

  const _ScheduleCardAnimated({required this.index, required this.child});

  @override
  State<_ScheduleCardAnimated> createState() => _ScheduleCardAnimatedState();
}

class _ScheduleCardAnimatedState extends State<_ScheduleCardAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
