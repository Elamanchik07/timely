import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/news_repository.dart';
import '../../domain/entities/news_item.dart';

class NewsItemCard extends ConsumerStatefulWidget {
  final NewsItem item;
  final VoidCallback onTap;
  final int index;

  const NewsItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.index = 0,
  });

  @override
  ConsumerState<NewsItemCard> createState() => _NewsItemCardState();
}

class _NewsItemCardState extends ConsumerState<NewsItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> _reactionCounts = {};
  String? _myReaction;
  bool _reactionInProgress = false;

  final Map<String, String> _reactionEmojis = {
    'heart': '❤️',
    'thumbsUp': '👍',
    'fire': '🔥',
    'party': '🎉',
  };

  @override
  void initState() {
    super.initState();
    _reactionCounts = Map<String, dynamic>.from(widget.item.reactionCounts);
    
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateReactionState(widget.item.reactions);
  }

  void _updateReactionState(List<Map<String, dynamic>> reactions) {
    final user = ref.read(authProvider).asData?.value;
    if (user != null) {
      final myR = reactions.where((r) {
        final userId = r['userId'];
        if (userId is Map) return userId['_id']?.toString() == user.id;
        return userId?.toString() == user.id;
      }).firstOrNull;
      _myReaction = myR?['type'] as String?;
    } else {
      _myReaction = null;
    }
  }

  @override
  void didUpdateWidget(covariant NewsItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _reactionCounts = Map<String, dynamic>.from(widget.item.reactionCounts);
      _updateReactionState(widget.item.reactions);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleReaction(String type) async {
    if (_reactionInProgress) return;
    final user = ref.read(authProvider).asData?.value;
    if (user == null) return;

    final oldReaction = _myReaction;
    final oldCounts = Map<String, dynamic>.from(_reactionCounts);

    setState(() {
      _reactionInProgress = true;
      if (_myReaction == type) {
        _myReaction = null;
        _reactionCounts[type] = (_reactionCounts[type] as int? ?? 1) - 1;
      } else {
        if (_myReaction != null) {
          _reactionCounts[_myReaction!] = (_reactionCounts[_myReaction!] as int? ?? 1) - 1;
        }
        _myReaction = type;
        _reactionCounts[type] = (_reactionCounts[type] as int? ?? 0) + 1;
      }
    });
    HapticFeedback.lightImpact();

    try {
      final repo = ref.read(newsRepositoryProvider);
      final result = await repo.toggleReaction(widget.item.id, type);
      if (mounted) {
        setState(() {
          _reactionCounts = result['reactionCounts'];
          _updateReactionState(List<Map<String, dynamic>>.from(result['reactions']));
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _myReaction = oldReaction;
          _reactionCounts = oldCounts;
        });
      }
    } finally {
      if (mounted) setState(() => _reactionInProgress = false);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Urgent':
        return Colors.redAccent;
      case 'Events':
        return Colors.orangeAccent;
      case 'Academic':
        return Colors.blueAccent;
      default:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final baseUrl = AppConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = widget.item.mediaPath != null ? '$baseUrl${widget.item.mediaPath}' : null;
    final authorName = widget.item.author?['fullName'] ?? l10n.adminAuthor;
    final initial = authorName.isNotEmpty ? authorName[0].toUpperCase() : 'T';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.item.isPinned ? AppTheme.accent.withOpacity(0.5) : AppTheme.dividerColor.withOpacity(0.6),
                width: widget.item.isPinned ? 1.5 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pinned & Category Badges
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        if (widget.item.isPinned)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.push_pin_rounded, size: 12, color: AppTheme.accent),
                                const SizedBox(width: 4),
                                Text(l10n.pinned, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(widget.item.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.newsCategory(widget.item.category),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _getCategoryColor(widget.item.category)),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.item.viewCount}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Header: Avatar + Author + Time ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent, Color(0xFF7C3AED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
                              const SizedBox(height: 2),
                              Text(TimeUtils.relativeTime(widget.item.createdAt), style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Title ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppTheme.textPrimary, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // ── Content preview ──
                  if (widget.item.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        widget.item.content,
                        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // ── Image ──
                  if (imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 220,
                            color: AppTheme.primaryLight.withOpacity(0.1),
                            child: const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                          ),
                        ),
                      ),
                    ),

                  // ── Reactions Row ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    child: Row(
                      children: [
                        ..._reactionEmojis.entries.map((e) {
                          final type = e.key;
                          final emoji = e.value;
                          final count = _reactionCounts[type] as int? ?? 0;
                          final isActive = _myReaction == type;

                          return GestureDetector(
                            onTap: () => _toggleReaction(type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isActive ? AppTheme.accent.withOpacity(0.15) : AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive ? AppTheme.accent : AppTheme.dividerColor.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 16)),
                                  if (count > 0) ...[
                                    const SizedBox(width: 4),
                                    Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? AppTheme.accent : AppTheme.textSecondary)),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_outlined, size: 20, color: AppTheme.textSecondary),
                          onPressed: () {
                            final text = '${widget.item.title}\n\n${widget.item.content}';
                            Share.share(text);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
