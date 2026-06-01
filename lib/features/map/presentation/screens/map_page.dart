import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/room_utils.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/navigation_providers.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../domain/map_room_data.dart';

// ═══════════════════════════════════════════════════════════════════
//  STATE
// ═══════════════════════════════════════════════════════════════════

class _MapState {
  final int floor;
  final RoomArea? selected;
  final List<RoomArea> results;
  final bool searching;
  const _MapState(
      {this.floor = 1,
      this.selected,
      this.results = const [],
      this.searching = false});
  _MapState copyWith(
          {int? floor,
          RoomArea? selected,
          bool clearSel = false,
          List<RoomArea>? results,
          bool? searching}) =>
      _MapState(
        floor: floor ?? this.floor,
        selected: clearSel ? null : (selected ?? this.selected),
        results: results ?? this.results,
        searching: searching ?? this.searching,
      );
}

class _MapNotifier extends StateNotifier<_MapState> {
  _MapNotifier() : super(const _MapState());
  void setFloor(int f) => state = state.copyWith(floor: f, clearSel: true);
  void search(String q) {
    if (q.trim().isEmpty) {
      state = state.copyWith(results: [], searching: false);
      return;
    }
    state = state.copyWith(results: MapRoomData.search(q), searching: true);
  }

  void clearSearch() =>
      state = state.copyWith(results: [], searching: false);
  void select(RoomArea r) => state = state.copyWith(
      selected: r, floor: r.floor, results: [], searching: false);
  void selectByCode(String code) {
    final r = MapRoomData.findByCode(code);
    if (r != null) select(r);
  }

  void clearSelection() => state = state.copyWith(clearSel: true);
}

final _mapProvider =
    StateNotifierProvider<_MapNotifier, _MapState>((ref) => _MapNotifier());

// ═══════════════════════════════════════════════════════════════════
//  HIGHLIGHT PAINTER — only draws selected room glow
// ═══════════════════════════════════════════════════════════════════

class _HighlightPainter extends CustomPainter {
  final RoomArea? room;
  final double pulse; // 0.0–1.0
  _HighlightPainter({this.room, this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    if (room == null) return;
    final r = room!;

    // Position strictly in center (centroid) of the specific room hitzone
    final cx = r.cx * size.width;
    final cy = r.cy * size.height;

    // Pin/Dot marker
    final paint = Paint()
      ..color = const Color(0xFF3A86FF)
      ..style = PaintingStyle.fill;

    // Pulse animation radius
    final radius = 6.0 + pulse * 3.0;

    // Outer pulse ring
    final ringPaint = Paint()
      ..color = const Color(0xFF3A86FF).withOpacity(0.35 * (1 - pulse))
      ..style = PaintingStyle.fill;

    // Draw outer pulse
    canvas.drawCircle(Offset(cx, cy), radius * 2.5, ringPaint);

    // Center dot with white border
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(cx, cy), radius, paint);
    canvas.drawCircle(Offset(cx, cy), radius, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _HighlightPainter old) =>
      old.room != room || old.pulse != pulse;
}

// ═══════════════════════════════════════════════════════════════════
//  MAP PAGE
// ═══════════════════════════════════════════════════════════════════

class MapPage extends ConsumerStatefulWidget {
  final String? initialRoomCode;
  const MapPage({super.key, this.initialRoomCode});
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage>
    with TickerProviderStateMixin {
  final _transformCtrl = TransformationController();
  final _searchCtrl = TextEditingController();
  final _mapKey = GlobalKey();
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  bool _isMapInitialized = false;
  BoxConstraints? _lastConstraints;

  @override
  void initState() {
    super.initState();
    assert(() {
      final loaded = MapRoomData.all.length;
      debugPrint('[MapPage] Loaded $loaded rooms/areas on the map.');
      return true;
    }());
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _searchCtrl.addListener(
        () => ref.read(_mapProvider.notifier).search(_searchCtrl.text));
    if (widget.initialRoomCode != null) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _focusRoom(widget.initialRoomCode!));
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  String _asset(int f) => f == 1
      ? 'lib/assets/первый.png'
      : f == 2
          ? 'lib/assets/второй.png'
          : 'lib/assets/третий.png';

  void _applyFitToScreen() {
    if (_lastConstraints == null) return;
    final constraints = _lastConstraints!;
    const imageWidth = 1567.0;
    const imageHeight = 783.0;

    final scaleX = constraints.maxWidth / imageWidth;
    final scaleY = constraints.maxHeight / imageHeight;
    final scale = math.min(scaleX, scaleY) * 0.95; // 95% for tiny padding

    final dx = (constraints.maxWidth - imageWidth * scale) / 2;
    final dy = (constraints.maxHeight - imageHeight * scale) / 2;

    _animateTo(Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale));
  }

  void _focusRoom(String code) {
    if (code.isEmpty) return;
    final r = MapRoomData.findByCode(code);
    if (r != null) {
      ref.read(_mapProvider.notifier).select(r);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _zoomToSelected());
    } else {
      ref.read(_mapProvider.notifier).clearSelection();
      if (mounted) {
        final l10n = ref.read(l10nProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.roomNotFound(code),
              style: const TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  void _selectAndFocus(RoomArea r) {
    ref.read(_mapProvider.notifier).select(r);
    _searchCtrl.clear();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _zoomToSelected());
  }

  void _zoomToSelected() {
    final s = ref.read(_mapProvider);
    final r = s.selected;
    if (r == null) return;

    final viewSize = MediaQuery.of(context).size;

    final mapBox =
        _mapKey.currentContext?.findRenderObject() as RenderBox?;
    if (mapBox == null) return;
    final ms = mapBox.size;

    final cx = r.cx * ms.width;
    final cy = r.cy * ms.height;

    const scale = 3.5;
    final target = Matrix4.identity();
    target.storage[0] = scale;
    target.storage[5] = scale;
    target.storage[12] = viewSize.width / 2 - (cx * scale);
    target.storage[13] = viewSize.height / 2 - (cy * scale);
    _animateTo(target);
  }

  void _animateTo(Matrix4 target) {
    final start = _transformCtrl.value.clone();
    final ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    final curve =
        CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic);
    ctrl.addListener(() {
      final t = curve.value;
      final m = Matrix4.identity();
      for (int i = 0; i < 16; i++) {
        m.storage[i] =
            ui.lerpDouble(start.storage[i], target.storage[i], t)!;
      }
      _transformCtrl.value = m;
    });
    ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) ctrl.dispose();
    });
    ctrl.forward();
  }

  void _zoomBy(double factor) {
    final c = _transformCtrl.value.clone();
    final currentScale = c.storage[0];
    final newScale = (currentScale * factor).clamp(0.5, 6.0);
    final actualFactor = newScale / currentScale;

    final cx = MediaQuery.of(context).size.width / 2;
    final cy = MediaQuery.of(context).size.height / 2;

    final t1 = Matrix4.identity();
    t1.storage[12] = cx;
    t1.storage[13] = cy;

    final s = Matrix4.identity();
    s.storage[0] = actualFactor;
    s.storage[5] = actualFactor;

    final t2 = Matrix4.identity();
    t2.storage[12] = -cx;
    t2.storage[13] = -cy;

    final result = t1 * s * t2;
    _animateTo((result as Matrix4) * c);
  }

  @override
  Widget build(BuildContext context) {
    final ms = ref.watch(_mapProvider);
    final l10n = ref.watch(l10nProvider);

    // External focus from schedule
    final focusRoom = ref.watch(mapFocusProvider);
    if (focusRoom != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusRoom(focusRoom);
        ref.read(mapFocusProvider.notifier).state = null;
      });
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearch(context, l10n),
            _buildFloors(context, ms, l10n),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (!_isMapInitialized || _lastConstraints?.maxWidth != constraints.maxWidth) {
                    _isMapInitialized = true;
                    _lastConstraints = constraints;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _applyFitToScreen();
                    });
                  }
                  
                  return Container(
                    color: AppTheme.backgroundColor,
                    child: Stack(
                      children: [
                        // ─── Image + highlight overlay ───
                        InteractiveViewer(
                          transformationController: _transformCtrl,
                          minScale: 0.1,
                          maxScale: 6.0,
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(1000),
                          child: GestureDetector(
                            onTapUp: (details) {
                              final box = _mapKey.currentContext?.findRenderObject() as RenderBox?;
                              if (box == null) return;
                              final local = box.globalToLocal(details.globalPosition);
                              final rx = local.dx / box.size.width;
                              final ry = local.dy / box.size.height;
                              final r = MapRoomData.byFloor(ms.floor)
                                  .cast<RoomArea?>()
                                  .firstWhere(
                                (z) =>
                                    z != null &&
                                    rx >= z.rect.left &&
                                    rx <= z.rect.right &&
                                    ry >= z.rect.top &&
                                    ry <= z.rect.bottom,
                                orElse: () => null,
                              );
                              if (r != null) {
                                ref.read(_mapProvider.notifier).select(r);
                              } else {
                                ref.read(_mapProvider.notifier).clearSelection();
                              }
                            },
                            child: AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => SizedBox(
                                width: 1567,
                                height: 783,
                                child: Stack(
                                  children: [
                                    Image.asset(_asset(ms.floor),
                                        key: _mapKey,
                                        width: 1567,
                                        height: 783,
                                        fit: BoxFit.fill,
                                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 64, color: AppTheme.textSecondary))),
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: CustomPaint(
                                          painter: _HighlightPainter(room: ms.selected, pulse: _pulseAnim.value),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Search results
                        if (ms.searching && ms.results.isNotEmpty) _buildResults(context, ms, l10n),
                        // Room info card
                        if (ms.selected != null) _buildInfo(context, ms.selected!, l10n),
                        // Zoom controls
                        _buildZoom(context, l10n),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Bar ──────────────────────────────────────
  Widget _buildSearch(BuildContext context, l10n) {
    return Container(
      padding: const EdgeInsets.only(
          top: 8, left: 16, right: 16, bottom: 8),
      color: AppTheme.primaryMid,
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: l10n.searchPlaceholder,
          hintStyle: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.textSecondary),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchCtrl.clear();
                    ref.read(_mapProvider.notifier).clearSearch();
                    ref.read(_mapProvider.notifier).clearSelection();
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.accent, width: 1.5)),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  // ─── Floor Selector ────────────────────────────────
  Widget _buildFloors(BuildContext context, _MapState ms, l10n) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppTheme.surfaceColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final f = i + 1;
          final sel = ms.floor == f;
          final cnt = MapRoomData.byFloor(f).length;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref.read(_mapProvider.notifier).setFloor(f);
                _applyFitToScreen();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      sel ? AppTheme.accent : AppTheme.primaryMid,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel
                          ? AppTheme.accent
                          : AppTheme.dividerColor),
                ),
                child: Text(l10n.floorLabel(f, cnt),
                    style: TextStyle(
                        color: sel
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight:
                            sel ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13)),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Search Results ────────────────────────────────
  Widget _buildResults(BuildContext context, _MapState ms, l10n) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryMid,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: ms.results.length,
            separatorBuilder: (_, __) => const Divider(
                height: 1, color: AppTheme.dividerColor),
            itemBuilder: (_, i) {
              final r = ms.results[i];
              return ListTile(
                dense: true,
                leading: Icon(
                    r.isArea
                        ? Icons.meeting_room_rounded
                        : Icons.door_front_door_rounded,
                    color: r.isArea
                        ? AppTheme.warningColor
                        : AppTheme.accent,
                    size: 20),
                title: Text(r.code,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white)),
                subtitle: Text('${r.label} • ${l10n.floor(r.floor)}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary)),
                onTap: () => _selectAndFocus(r),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Room Info Card ────────────────────────────────
  Widget _buildInfo(BuildContext context, RoomArea r, l10n) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 100,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryMid.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: AppTheme.accent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(
                  r.isArea
                      ? Icons.meeting_room_rounded
                      : Icons.door_front_door_rounded,
                  color: AppTheme.accent,
                  size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(r.code,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(r.label,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                      '${l10n.floor(r.floor)} • ${r.isArea ? l10n.roomTypeArea : l10n.roomTypeRoom}',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              AppTheme.accent.withOpacity(0.8))),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () =>
                  ref.read(_mapProvider.notifier).clearSelection(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.close_rounded,
                    color: AppTheme.textSecondary, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Zoom Controls ─────────────────────────────────
  Widget _buildZoom(BuildContext context, AppLocalizations l10n) {
    Widget btn(IconData icon, VoidCallback onTap, {String? tooltip}) =>
        Tooltip(
          message: tooltip ?? '',
          child: Material(
            color: AppTheme.primaryMid,
            borderRadius: BorderRadius.circular(12),
            elevation: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.dividerColor),
                ),
                child:
                    Icon(icon, color: AppTheme.accent, size: 20),
              ),
            ),
          ),
        );

    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 110,
      child: Column(
        children: [
          btn(Icons.add_rounded, () => _zoomBy(1.5), tooltip: l10n.zoomIn),
          const SizedBox(height: 8),
          btn(Icons.remove_rounded, () => _zoomBy(1 / 1.5), tooltip: l10n.zoomOut),
          const SizedBox(height: 8),
          btn(Icons.fit_screen_rounded, () => _applyFitToScreen(), tooltip: l10n.resetZoom),
        ],
      ),
    );
  }
}
