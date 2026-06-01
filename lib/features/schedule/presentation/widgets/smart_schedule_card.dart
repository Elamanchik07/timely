import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/navigation_providers.dart';
import '../../../../core/utils/room_utils.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../domain/entities/schedule_item.dart';

class SmartScheduleCard extends ConsumerStatefulWidget {
  final ScheduleItem item;
  final bool isTeacherMode;
  final Color typeColor;
  final Color subjectColor;
  final String typeLabel;
  final IconData typeIcon;
  final bool isToday;

  const SmartScheduleCard({
    super.key,
    required this.item,
    required this.isTeacherMode,
    required this.typeColor,
    required this.subjectColor,
    required this.typeLabel,
    required this.typeIcon,
    required this.isToday,
  });

  @override
  ConsumerState<SmartScheduleCard> createState() => _SmartScheduleCardState();
}

class _SmartScheduleCardState extends ConsumerState<SmartScheduleCard> {
  Timer? _timer;
  
  bool _isOngoing = false;
  bool _isNext = false;
  int _minutesWait = 0;
  int _minutesLeft = 0;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _updateStatus();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _updateStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SmartScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.startTime != widget.item.startTime || oldWidget.isToday != widget.isToday) {
      _updateStatus();
    }
  }

  void _updateStatus() {
    if (!widget.isToday) {
      if (_isOngoing || _isNext) {
        if (mounted) {
          setState(() {
            _isOngoing = false;
            _isNext = false;
          });
        }
      }
      return;
    }

    final now = DateTime.now();
    final partsStart = widget.item.startTime.split(':');
    final partsEnd = widget.item.endTime.split(':');
    
    if (partsStart.length != 2 || partsEnd.length != 2) return;

    final startTime = DateTime(now.year, now.month, now.day, int.parse(partsStart[0]), int.parse(partsStart[1]));
    final endTime = DateTime(now.year, now.month, now.day, int.parse(partsEnd[0]), int.parse(partsEnd[1]));

    bool newIsOngoing = false;
    bool newIsNext = false;
    int newMinutesWait = 0;
    int newMinutesLeft = 0;
    double newProgress = 0.0;

    if (now.isAfter(startTime) && now.isBefore(endTime)) {
      newIsOngoing = true;
      newMinutesLeft = endTime.difference(now).inMinutes;
      final totalDuration = endTime.difference(startTime).inMinutes;
      final elapsed = now.difference(startTime).inMinutes;
      if (totalDuration > 0) {
        newProgress = (elapsed / totalDuration).clamp(0.0, 1.0);
      }
    } else if (now.isBefore(startTime)) {
      final diffWait = startTime.difference(now).inMinutes;
      // Is next if it's within early range and not yet started
      // We'll consider it "Next" if it's the closest in the future starting within 60 minutes
      if (diffWait >= 0 && diffWait <= 60) {
        newIsNext = true;
        newMinutesWait = diffWait;
      }
    }

    if (_isOngoing != newIsOngoing || 
        _isNext != newIsNext || 
        _minutesLeft != newMinutesLeft || 
        _minutesWait != newMinutesWait || 
        _progress != newProgress) {
      if (mounted) {
        setState(() {
          _isOngoing = newIsOngoing;
          _isNext = newIsNext;
          _minutesLeft = newMinutesLeft;
          _minutesWait = newMinutesWait;
          _progress = newProgress;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isOngoing ? widget.typeColor : AppTheme.dividerColor.withOpacity(0.5),
          width: _isOngoing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (_isOngoing)
            BoxShadow(
              color: widget.typeColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 4,
            )
          else
            BoxShadow(
              color: widget.subjectColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [widget.subjectColor, widget.subjectColor.withOpacity(0.5)],
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner
                      if (_isOngoing)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.typeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.play_circle_filled_rounded, size: 14, color: widget.typeColor),
                              const SizedBox(width: 6),
                              Text(
                                l10n.classInProgress,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: widget.typeColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                l10n.endsInMinutes(_minutesLeft),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.typeColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_isNext)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: AppTheme.warningColor),
                              const SizedBox(width: 6),
                              Text(
                                l10n.nextClassLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.warningColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                l10n.startsInMinutes(_minutesWait),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.warningColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Top row: Subject + Type badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.subject,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildTypeBadge(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Info rows
                      Row(
                        children: [
                          // Time
                          Expanded(
                            child: _buildInfoChip(
                              Icons.access_time_rounded,
                              '${widget.item.startTime} – ${widget.item.endTime}',
                              AppTheme.accent,
                            ),
                          ),
                          // Room / Map Button
                          InkWell(
                            onTap: () {
                              ref.read(mapFocusProvider.notifier).state = RoomUtils.displayCode(widget.item.room);
                              ref.read(homeTabProvider.notifier).state = 2;
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_outlined, size: 16, color: AppTheme.warningColor),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      l10n.mapRoom(RoomUtils.displayCode(widget.item.room)),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.warningColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppTheme.warningColor.withOpacity(0.8)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Teacher or Group
                      _buildInfoChip(
                        widget.isTeacherMode ? Icons.group_outlined : Icons.person_outline_rounded,
                        widget.isTeacherMode ? l10n.myGroup : (widget.item.teacher.isNotEmpty ? widget.item.teacher : l10n.notAssigned),
                        AppTheme.accentLight,
                      ),

                      // Progress Bar
                      if (_isOngoing) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: widget.typeColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(widget.typeColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.typeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.typeIcon,
            size: 13,
            color: widget.typeColor,
          ),
          const SizedBox(width: 4),
          Text(
            widget.typeLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.typeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor.withOpacity(0.8)),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
