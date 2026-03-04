// Room hit-zone on the map. Coordinates are relative (0.0–1.0) to image size.
import 'dart:ui';

class RoomArea {
  final String fullCode;
  final String label;
  final String building;
  final String block;
  final int floor;
  final bool isArea;
  final Rect rect;

  const RoomArea(this.fullCode, this.label, this.building, this.block, this.floor, this.isArea, this.rect);

  double get cx => rect.center.dx;
  double get cy => rect.center.dy;
  String get code => fullCode;
}

class MapRoomData {
  MapRoomData._();

  static String normalizeRoomCode(String s) {
    if (s.isEmpty) return '';
    s = s.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    s = s.replaceAll('-', '.').replaceAll('_', '.');
    s = s.replaceAll(RegExp(r'\.+'), '.');
    
    // Normalize Cyrillic to Latin for suffixes
    const m = {
      'С':'C', 'А':'A', 'Е':'E', 'О':'O', 'Р':'P', 'М':'M', 'Т':'T', 
      'Х':'X', 'К':'K', 'Л':'L', 'П':'P', 'В':'B', 'У':'Y', 'Н':'H',
    };
    m.forEach((cyr, lat) => s = s.replaceAll(cyr, lat));
    return s.trim();
  }

  static RoomArea? findByCode(String code, {int? floor, String? block}) {
    if (code.isEmpty) return null;
    final rCode = normalizeRoomCode(code);
    
    // 1. Fast exact match first
    for (final r in all) {
      if (r.fullCode.toUpperCase() == rCode) return r;
    }
    
    // 1b. Handle 2-part codes like "C1.201" → try "201"
    String searchCode = rCode;
    if (rCode.startsWith('C1.') && rCode.split('.').length == 2) {
      searchCode = rCode.substring(3); // strip "C1."
    }
    
    // 2. Match ignoring building/block (from "225" expecting "C1.1.225")
    final candidates = all.where((r) {
      final parts = r.fullCode.split('.');
      final roomPart = parts.last.toUpperCase();
      final pCode = parts.length > 2 ? '${parts[1]}.${parts.last}'.toUpperCase() : '';
      final bCode = parts.length > 2 ? '${parts[0]}.${parts[1]}.${parts.last}'.toUpperCase() : '';
      return roomPart == searchCode || pCode == searchCode || bCode == searchCode ||
             roomPart == rCode || pCode == rCode || bCode == rCode;
    }).toList();

    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;
    
    // 3. Ambiguous match. Try to resolve using floor or block hints if provided by schedule
    if (floor != null || block != null) {
      final resolved = candidates.where((c) {
        bool match = true;
        if (floor != null && c.floor != floor) match = false;
        if (block != null && c.block != block) match = false;
        return match;
      }).toList();
      if (resolved.length == 1) return resolved.first;
      if (resolved.isNotEmpty) return resolved.first;
    }
    
    // 4. Return first candidate (best effort) instead of null
    return candidates.first;
  }

  static List<RoomArea> search(String q) {
    if (q.trim().isEmpty) return [];
    final n = normalizeRoomCode(q);
    return all.where((r) {
      final code = normalizeRoomCode(r.fullCode);
      final label = normalizeRoomCode(r.label);
      if (code == n) return true;
      if (code.contains('.$n')) return true; // Match short code specifically
      if (code.startsWith(n)) return true;
      if (label.contains(n)) return true;
      return false;
    }).toList();
  }

  static List<RoomArea> byFloor(int f) => all.where((r) => r.floor == f).toList();

  // ═══ FLOOR 1 ═══════════════════════════════════════
  // Coordinates read from первый.png (1567×783 px)
  static const _f1 = <RoomArea>[
    // Areas
    RoomArea('C1.LIBRARY', 'Библиотека', 'C1', '1', 1, true, Rect.fromLTWH(0.013, 0.57, 0.095, 0.26)),
    RoomArea('C1.ASSEMBLY_HALL_1', 'Актовый зал', 'C1', '1', 1, true, Rect.fromLTWH(0.130, 0.57, 0.115, 0.24)),
    RoomArea('C1.COWORKING', 'Коворкинг', 'C1', '1', 1, true, Rect.fromLTWH(0.340, 0.08, 0.240, 0.25)),
    RoomArea('C1.ATRIUM', 'Атриум', 'C1', '1', 1, true, Rect.fromLTWH(0.385, 0.44, 0.195, 0.28)),
    RoomArea('C1.DINING_HALL', 'Столовая', 'C1', '1', 1, true, Rect.fromLTWH(0.845, 0.60, 0.140, 0.30)),
    // C1.1 upper
    RoomArea('C1.1.139', 'Аудитория 139', 'C1', '1.1', 1, false, Rect.fromLTWH(0.170, 0.08, 0.030, 0.07)),
    RoomArea('C1.1.140', 'Аудитория 140', 'C1', '1.1', 1, false, Rect.fromLTWH(0.210, 0.06, 0.025, 0.05)),
    RoomArea('C1.1.143', 'Аудитория 143', 'C1', '1.1', 1, false, Rect.fromLTWH(0.175, 0.18, 0.060, 0.12)),
    RoomArea('C1.1.141', 'Аудитория 141', 'C1', '1.1', 1, false, Rect.fromLTWH(0.260, 0.14, 0.055, 0.09)),
    RoomArea('C1.1.142', 'Аудитория 142', 'C1', '1.1', 1, false, Rect.fromLTWH(0.260, 0.25, 0.055, 0.09)),
    // C1.1 lower
    RoomArea('C1.1.168', 'Аудитория 168', 'C1', '1.1', 1, false, Rect.fromLTWH(0.240, 0.45, 0.075, 0.10)),
    RoomArea('C1.1.165', 'Аудитория 165', 'C1', '1.1', 1, false, Rect.fromLTWH(0.255, 0.58, 0.035, 0.06)),
    RoomArea('C1.1.164', 'Аудитория 164', 'C1', '1.1', 1, false, Rect.fromLTWH(0.295, 0.56, 0.025, 0.05)),
    RoomArea('C1.1.156', 'Аудитория 156', 'C1', '1.1', 1, false, Rect.fromLTWH(0.295, 0.62, 0.020, 0.04)),
    RoomArea('C1.1.163', 'Аудитория 163', 'C1', '1.1', 1, false, Rect.fromLTWH(0.315, 0.60, 0.020, 0.04)),
    RoomArea('C1.1.155', 'Аудитория 155', 'C1', '1.1', 1, false, Rect.fromLTWH(0.300, 0.70, 0.055, 0.07)),
    // C1.2 left corridor
    RoomArea('C1.2.124K', 'Кабинет 124К', 'C1', '1.2', 1, false, Rect.fromLTWH(0.345, 0.38, 0.045, 0.06)),
    RoomArea('C1.2.123K', 'Кабинет 123К', 'C1', '1.2', 1, false, Rect.fromLTWH(0.345, 0.46, 0.045, 0.06)),
    RoomArea('C1.2.122K', 'Кабинет 122К', 'C1', '1.2', 1, false, Rect.fromLTWH(0.345, 0.55, 0.045, 0.06)),
    RoomArea('C1.2.121K', 'Кабинет 121К', 'C1', '1.2', 1, false, Rect.fromLTWH(0.345, 0.65, 0.050, 0.07)),
    RoomArea('C1.2.129', 'Аудитория 129', 'C1', '1.2', 1, false, Rect.fromLTWH(0.395, 0.36, 0.025, 0.30)),
    // C1.2 right of atrium
    RoomArea('C1.2.133', 'Аудитория 133', 'C1', '1.2', 1, false, Rect.fromLTWH(0.530, 0.60, 0.035, 0.05)),
    RoomArea('C1.2.136', 'Аудитория 136', 'C1', '1.2', 1, false, Rect.fromLTWH(0.585, 0.66, 0.035, 0.06)),
    RoomArea('C1.2.135', 'Аудитория 135', 'C1', '1.2', 1, false, Rect.fromLTWH(0.585, 0.74, 0.035, 0.06)),
    RoomArea('C1.2.139', 'Аудитория 139', 'C1', '1.2', 1, false, Rect.fromLTWH(0.590, 0.38, 0.060, 0.09)),
    RoomArea('C1.2.138L', 'Лаборатория 138Л', 'C1', '1.2', 1, false, Rect.fromLTWH(0.590, 0.49, 0.060, 0.07)),
    RoomArea('C1.2.137P', 'Практическая 137П', 'C1', '1.2', 1, false, Rect.fromLTWH(0.590, 0.58, 0.050, 0.06)),
    // C1.3 upper
    RoomArea('C1.3.126', 'Аудитория 126', 'C1', '1.3', 1, false, Rect.fromLTWH(0.690, 0.09, 0.035, 0.06)),
    RoomArea('C1.3.125', 'Аудитория 125', 'C1', '1.3', 1, false, Rect.fromLTWH(0.740, 0.09, 0.040, 0.06)),
    RoomArea('C1.3.129', 'Аудитория 129', 'C1', '1.3', 1, false, Rect.fromLTWH(0.790, 0.08, 0.020, 0.04)),
    RoomArea('C1.3.130', 'Аудитория 130', 'C1', '1.3', 1, false, Rect.fromLTWH(0.810, 0.08, 0.020, 0.04)),
    RoomArea('C1.3.128', 'Аудитория 128', 'C1', '1.3', 1, false, Rect.fromLTWH(0.750, 0.17, 0.040, 0.06)),
    RoomArea('C1.3.121', 'Аудитория 121', 'C1', '1.3', 1, false, Rect.fromLTWH(0.710, 0.24, 0.070, 0.10)),
    // C1.3 lower
    RoomArea('C1.3.188', 'Аудитория 188', 'C1', '1.3', 1, false, Rect.fromLTWH(0.680, 0.43, 0.050, 0.06)),
    RoomArea('C1.3.187', 'Аудитория 187', 'C1', '1.3', 1, false, Rect.fromLTWH(0.720, 0.50, 0.040, 0.06)),
    RoomArea('C1.3.166', 'Аудитория 166', 'C1', '1.3', 1, false, Rect.fromLTWH(0.830, 0.42, 0.025, 0.06)),
  ];

  // ═══ FLOOR 2 ═══════════════════════════════════════
  // Coordinates read from второй.png (1567×783 px)
  static const _f2 = <RoomArea>[
    RoomArea('C1.ASSEMBLY_HALL_2', 'Актовый зал (2 этаж)', 'C1', '1.3', 2, true, Rect.fromLTWH(0.145, 0.50, 0.120, 0.24)),
    // C1.1 left column (bottom to top)
    RoomArea('C1.1.261', 'Аудитория 261', 'C1', '1.1', 2, false, Rect.fromLTWH(0.110, 0.90, 0.040, 0.04)),
    RoomArea('C1.1.262', 'Аудитория 262', 'C1', '1.1', 2, false, Rect.fromLTWH(0.085, 0.85, 0.030, 0.04)),
    RoomArea('C1.1.263', 'Аудитория 263', 'C1', '1.1', 2, false, Rect.fromLTWH(0.075, 0.80, 0.030, 0.04)),
    RoomArea('C1.1.264', 'Аудитория 264', 'C1', '1.1', 2, false, Rect.fromLTWH(0.065, 0.75, 0.030, 0.04)),
    RoomArea('C1.1.265', 'Аудитория 265', 'C1', '1.1', 2, false, Rect.fromLTWH(0.055, 0.70, 0.030, 0.04)),
    RoomArea('C1.1.266', 'Аудитория 266', 'C1', '1.1', 2, false, Rect.fromLTWH(0.048, 0.65, 0.025, 0.04)),
    RoomArea('C1.1.267', 'Аудитория 267', 'C1', '1.1', 2, false, Rect.fromLTWH(0.040, 0.60, 0.025, 0.04)),
    RoomArea('C1.1.268', 'Аудитория 268', 'C1', '1.1', 2, false, Rect.fromLTWH(0.035, 0.55, 0.025, 0.04)),
    RoomArea('C1.1.269', 'Аудитория 269', 'C1', '1.1', 2, false, Rect.fromLTWH(0.030, 0.50, 0.025, 0.04)),
    RoomArea('C1.1.270', 'Аудитория 270', 'C1', '1.1', 2, false, Rect.fromLTWH(0.025, 0.46, 0.025, 0.04)),
    RoomArea('C1.1.271', 'Аудитория 271', 'C1', '1.1', 2, false, Rect.fromLTWH(0.020, 0.42, 0.025, 0.04)),
    RoomArea('C1.1.272', 'Аудитория 272', 'C1', '1.1', 2, false, Rect.fromLTWH(0.015, 0.38, 0.030, 0.04)),
    RoomArea('C1.1.273', 'Аудитория 273', 'C1', '1.1', 2, false, Rect.fromLTWH(0.010, 0.34, 0.030, 0.04)),
    // C1.1 inner
    RoomArea('C1.1.260P', 'Практическая 260П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.135, 0.82, 0.035, 0.04)),
    RoomArea('C1.1.256P', 'Практическая 256П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.100, 0.66, 0.035, 0.04)),
    RoomArea('C1.1.255P', 'Практическая 255П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.100, 0.60, 0.035, 0.04)),
    RoomArea('C1.1.254L', 'Лаборатория 254Л', 'C1', '1.1', 2, false, Rect.fromLTWH(0.085, 0.54, 0.040, 0.05)),
    RoomArea('C1.1.253L', 'Лаборатория 253Л', 'C1', '1.1', 2, false, Rect.fromLTWH(0.095, 0.48, 0.040, 0.05)),
    RoomArea('C1.1.252L', 'Лаборатория 252Л', 'C1', '1.1', 2, false, Rect.fromLTWH(0.068, 0.38, 0.050, 0.05)),
    RoomArea('C1.1.251L', 'Лаборатория 251Л', 'C1', '1.1', 2, false, Rect.fromLTWH(0.105, 0.33, 0.050, 0.05)),
    RoomArea('C1.1.250', 'Аудитория 250', 'C1', '1.1', 2, false, Rect.fromLTWH(0.155, 0.42, 0.020, 0.03)),
    // C1.1 upper arc
    RoomArea('C1.1.234P', 'Практическая 234П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.155, 0.23, 0.040, 0.04)),
    RoomArea('C1.1.233P', 'Практическая 233П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.245, 0.20, 0.040, 0.06)),
    RoomArea('C1.1.232P', 'Практическая 232П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.275, 0.06, 0.040, 0.06)),
    RoomArea('C1.1.231P', 'Аудитория 231П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.215, 0.06, 0.025, 0.04)),
    RoomArea('C1.1.230P', 'Практическая 230П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.195, 0.06, 0.020, 0.04)),
    RoomArea('C1.1.229P', 'Практическая 229П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.168, 0.08, 0.020, 0.04)),
    RoomArea('C1.1.228P', 'Практическая 228П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.148, 0.10, 0.020, 0.04)),
    RoomArea('C1.1.227P', 'Практическая 227П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.128, 0.10, 0.020, 0.04)),
    RoomArea('C1.1.225P', 'Практическая 225П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.108, 0.12, 0.020, 0.04)),
    RoomArea('C1.1.224P', 'Практическая 224П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.085, 0.14, 0.020, 0.04)),
    RoomArea('C1.1.223P', 'Практическая 223П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.060, 0.16, 0.020, 0.04)),
    RoomArea('C1.1.222P', 'Практическая 222П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.040, 0.18, 0.020, 0.04)),
    RoomArea('C1.1.221P', 'Практическая 221П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.015, 0.22, 0.025, 0.04)),
    RoomArea('C1.1.235P', 'Практическая 235П', 'C1', '1.1', 2, false, Rect.fromLTWH(0.265, 0.26, 0.040, 0.04)),
    // C1.2 upper arc
    RoomArea('C1.2.221P', 'Практическая 221П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.305, 0.06, 0.030, 0.05)),
    RoomArea('C1.2.222P', 'Практическая 222П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.340, 0.05, 0.030, 0.05)),
    RoomArea('C1.2.223K', 'Кабинет 223К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.375, 0.05, 0.030, 0.04)),
    RoomArea('C1.2.224P', 'Практическая 224П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.408, 0.05, 0.030, 0.04)),
    RoomArea('C1.2.225P', 'Практическая 225П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.440, 0.05, 0.030, 0.04)),
    RoomArea('C1.2.226P', 'Практическая 226П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.472, 0.05, 0.030, 0.04)),
    RoomArea('C1.2.227P', 'Практическая 227П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.505, 0.05, 0.030, 0.04)),
    RoomArea('C1.2.228P', 'Практическая 228П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.538, 0.05, 0.030, 0.04)),
    RoomArea('C1.2.229P', 'Практическая 229П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.572, 0.05, 0.030, 0.04)),
    RoomArea('C1.2.230P', 'Практическая 230П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.606, 0.05, 0.030, 0.04)),
    RoomArea('C1.2.231K', 'Кабинет 231К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.640, 0.05, 0.030, 0.04)),
    RoomArea('C1.2.232P', 'Практическая 232П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.672, 0.05, 0.030, 0.05)),
    // C1.2 middle
    RoomArea('C1.2.237L', 'Лаборатория 237Л', 'C1', '1.2', 2, false, Rect.fromLTWH(0.385, 0.18, 0.075, 0.08)),
    RoomArea('C1.2.233L', 'Лаборатория 233Л', 'C1', '1.2', 2, false, Rect.fromLTWH(0.530, 0.18, 0.050, 0.06)),
    RoomArea('C1.2.234K', 'Кабинет 234К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.585, 0.18, 0.045, 0.06)),
    RoomArea('C1.2.237P', 'Практическая 237П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.660, 0.24, 0.025, 0.04)),
    RoomArea('C1.2.235L', 'Лаборатория 235Л', 'C1', '1.2', 2, false, Rect.fromLTWH(0.690, 0.20, 0.040, 0.06)),
    RoomArea('C1.2.236', 'Аудитория 236', 'C1', '1.2', 2, false, Rect.fromLTWH(0.680, 0.14, 0.025, 0.04)),
    // C1.2 center rooms
    RoomArea('C1.2.246', 'Аудитория 246', 'C1', '1.2', 2, false, Rect.fromLTWH(0.235, 0.40, 0.020, 0.04)),
    RoomArea('C1.2.238K', 'Кабинет 238К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.198, 0.42, 0.030, 0.04)),
    RoomArea('C1.2.239K', 'Кабинет 239К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.345, 0.40, 0.040, 0.06)),
    RoomArea('C1.2.240K', 'Кабинет 240К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.430, 0.38, 0.055, 0.06)),
    RoomArea('C1.2.241K', 'Кабинет 241К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.300, 0.44, 0.040, 0.06)),
    RoomArea('C1.2.241K', 'Кабинет 241К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.365, 0.48, 0.040, 0.05)),
    RoomArea('C1.2.242K', 'Кабинет 242К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.300, 0.52, 0.050, 0.06)),
    RoomArea('C1.2.242K', 'Кабинет 242К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.430, 0.44, 0.055, 0.06)),
    RoomArea('C1.2.243K', 'Кабинет 243К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.430, 0.52, 0.055, 0.06)),
    RoomArea('C1.2.240K', 'Кабинет 240К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.260, 0.56, 0.035, 0.04)),
    RoomArea('C1.2.248L', 'Лаборатория 248Л', 'C1', '1.2', 2, false, Rect.fromLTWH(0.530, 0.38, 0.055, 0.06)),
    RoomArea('C1.2.249L', 'Лаборатория 249Л', 'C1', '1.2', 2, false, Rect.fromLTWH(0.590, 0.40, 0.050, 0.06)),
    RoomArea('C1.2.250L', 'Лаборатория 250Л', 'C1', '1.2', 2, false, Rect.fromLTWH(0.530, 0.46, 0.055, 0.06)),
    RoomArea('C1.2.252K', 'Кабинет 252К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.530, 0.54, 0.055, 0.06)),
    RoomArea('C1.2.251L', 'Лаборатория 251Л', 'C1', '1.2', 2, false, Rect.fromLTWH(0.590, 0.48, 0.050, 0.06)),
    RoomArea('C1.2.243P', 'Практическая 243П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.640, 0.50, 0.050, 0.06)),
    RoomArea('C1.2.240P', 'Практическая 240П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.640, 0.38, 0.050, 0.06)),
    RoomArea('C1.2.241P', 'Практическая 241П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.640, 0.44, 0.050, 0.06)),
    RoomArea('C1.2.244P', 'Практическая 244П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.640, 0.56, 0.050, 0.06)),
    // C1.2 bottom
    RoomArea('C1.2.244K', 'Кабинет 244К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.310, 0.70, 0.030, 0.04)),
    RoomArea('C1.2.245K', 'Кабинет 245К', 'C1', '1.2', 2, false, Rect.fromLTWH(0.345, 0.70, 0.030, 0.04)),
    RoomArea('C1.2.245', 'Аудитория 245', 'C1', '1.2', 2, false, Rect.fromLTWH(0.410, 0.64, 0.070, 0.08)),
    RoomArea('C1.2.246', 'Аудитория 246', 'C1', '1.2', 2, false, Rect.fromLTWH(0.370, 0.66, 0.030, 0.06)),
    RoomArea('C1.2.254', 'Аудитория 254', 'C1', '1.2', 2, false, Rect.fromLTWH(0.540, 0.66, 0.060, 0.07)),
    RoomArea('C1.2.255', 'Аудитория 255', 'C1', '1.2', 2, false, Rect.fromLTWH(0.610, 0.66, 0.050, 0.06)),
    RoomArea('C1.2.247P', 'Практическая 247П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.665, 0.70, 0.030, 0.04)),
    RoomArea('C1.2.246P', 'Практическая 246П', 'C1', '1.2', 2, false, Rect.fromLTWH(0.700, 0.72, 0.030, 0.04)),
    // C1.3 upper arc
    RoomArea('C1.3.221K', 'Кабинет 221К', 'C1', '1.3', 2, false, Rect.fromLTWH(0.720, 0.06, 0.025, 0.04)),
    RoomArea('C1.3.222P', 'Практическая 222П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.750, 0.07, 0.025, 0.04)),
    RoomArea('C1.3.223P', 'Практическая 223П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.780, 0.07, 0.025, 0.04)),
    RoomArea('C1.3.224P', 'Практическая 224П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.810, 0.08, 0.020, 0.04)),
    RoomArea('C1.3.226P', 'Практическая 226П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.855, 0.10, 0.020, 0.04)),
    RoomArea('C1.3.227P', 'Практическая 227П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.880, 0.12, 0.020, 0.04)),
    RoomArea('C1.3.228P', 'Практическая 228П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.900, 0.14, 0.020, 0.04)),
    RoomArea('C1.3.229P', 'Практическая 229П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.920, 0.16, 0.020, 0.04)),
    RoomArea('C1.3.230P', 'Практическая 230П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.935, 0.20, 0.020, 0.04)),
    RoomArea('C1.3.231P', 'Практическая 231П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.945, 0.24, 0.020, 0.04)),
    RoomArea('C1.3.232P', 'Практическая 232П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.955, 0.30, 0.025, 0.04)),
    // C1.3 right column
    RoomArea('C1.3.234K', 'Кабинет 234К', 'C1', '1.3', 2, false, Rect.fromLTWH(0.905, 0.36, 0.035, 0.04)),
    RoomArea('C1.3.233P', 'Практическая 233П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.905, 0.40, 0.035, 0.04)),
    RoomArea('C1.3.249K', 'Кабинет 249К', 'C1', '1.3', 2, false, Rect.fromLTWH(0.940, 0.34, 0.025, 0.04)),
    RoomArea('C1.3.248P', 'Практическая 248П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.940, 0.38, 0.025, 0.04)),
    RoomArea('C1.3.250K', 'Кабинет 250К', 'C1', '1.3', 2, false, Rect.fromLTWH(0.940, 0.42, 0.025, 0.04)),
    RoomArea('C1.3.251K', 'Кабинет 251К', 'C1', '1.3', 2, false, Rect.fromLTWH(0.940, 0.46, 0.025, 0.04)),
    RoomArea('C1.3.252K', 'Кабинет 252К', 'C1', '1.3', 2, false, Rect.fromLTWH(0.940, 0.50, 0.025, 0.04)),
    RoomArea('C1.3.253K', 'Кабинет 253К', 'C1', '1.3', 2, false, Rect.fromLTWH(0.940, 0.54, 0.025, 0.04)),
    RoomArea('C1.3.254L', 'Лаборатория 254Л', 'C1', '1.3', 2, false, Rect.fromLTWH(0.900, 0.48, 0.030, 0.04)),
    RoomArea('C1.3.255L', 'Лаборатория 255Л', 'C1', '1.3', 2, false, Rect.fromLTWH(0.890, 0.52, 0.030, 0.04)),
    RoomArea('C1.3.257P', 'Практическая 257П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.920, 0.56, 0.025, 0.04)),
    RoomArea('C1.3.258P', 'Практическая 258П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.910, 0.60, 0.025, 0.04)),
    RoomArea('C1.3.259P', 'Практическая 259П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.895, 0.64, 0.025, 0.04)),
    RoomArea('C1.3.266P', 'Практическая 266П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.870, 0.58, 0.025, 0.03)),
    RoomArea('C1.3.267P', 'Практическая 267П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.860, 0.62, 0.025, 0.03)),
    RoomArea('C1.3.260P', 'Практическая 260П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.895, 0.75, 0.025, 0.04)),
    RoomArea('C1.3.261P', 'Практическая 261П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.895, 0.80, 0.025, 0.04)),
    RoomArea('C1.3.262P', 'Практическая 262П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.870, 0.84, 0.030, 0.04)),
    RoomArea('C1.3.263P', 'Практическая 263П', 'C1', '1.3', 2, false, Rect.fromLTWH(0.830, 0.88, 0.040, 0.04)),
    RoomArea('C1.3.264L', 'Лаборатория 264Л', 'C1', '1.3', 2, false, Rect.fromLTWH(0.810, 0.80, 0.050, 0.05)),
    RoomArea('C1.3.365L', 'Лаборатория 365Л', 'C1', '1.3', 2, false, Rect.fromLTWH(0.830, 0.55, 0.040, 0.04)),
  ];

  // ═══ FLOOR 3 ═══════════════════════════════════════
  // Coordinates read from третий.png (1567×783 px)
  static const _f3 = <RoomArea>[
    RoomArea('C1.OPEN_SPACE', 'Open Space', 'C1', '1.3', 3, true, Rect.fromLTWH(0.125, 0.46, 0.125, 0.24)),
    // C1.1 left column (bottom to top)
    RoomArea('C1.1.320', 'Аудитория 320', 'C1', '1.1', 3, false, Rect.fromLTWH(0.120, 0.90, 0.040, 0.04)),
    RoomArea('C1.1.321', 'Аудитория 321', 'C1', '1.1', 3, false, Rect.fromLTWH(0.100, 0.85, 0.035, 0.04)),
    RoomArea('C1.1.322', 'Аудитория 322', 'C1', '1.1', 3, false, Rect.fromLTWH(0.080, 0.80, 0.030, 0.04)),
    RoomArea('C1.1.323', 'Аудитория 323', 'C1', '1.1', 3, false, Rect.fromLTWH(0.068, 0.74, 0.030, 0.04)),
    RoomArea('C1.1.323', 'Аудитория 323', 'C1', '1.1', 3, false, Rect.fromLTWH(0.058, 0.70, 0.030, 0.04)),
    RoomArea('C1.1.325', 'Аудитория 325', 'C1', '1.1', 3, false, Rect.fromLTWH(0.050, 0.64, 0.030, 0.04)),
    RoomArea('C1.1.327', 'Аудитория 327', 'C1', '1.1', 3, false, Rect.fromLTWH(0.042, 0.58, 0.030, 0.04)),
    RoomArea('C1.1.329', 'Аудитория 329', 'C1', '1.1', 3, false, Rect.fromLTWH(0.035, 0.52, 0.030, 0.04)),
    RoomArea('C1.1.330', 'Аудитория 330', 'C1', '1.1', 3, false, Rect.fromLTWH(0.030, 0.47, 0.030, 0.04)),
    RoomArea('C1.1.332', 'Аудитория 332', 'C1', '1.1', 3, false, Rect.fromLTWH(0.025, 0.42, 0.030, 0.04)),
    RoomArea('C1.1.333', 'Аудитория 333', 'C1', '1.1', 3, false, Rect.fromLTWH(0.023, 0.38, 0.030, 0.04)),
    RoomArea('C1.1.335', 'Аудитория 335', 'C1', '1.1', 3, false, Rect.fromLTWH(0.020, 0.33, 0.030, 0.04)),
    RoomArea('C1.1.336', 'Аудитория 336', 'C1', '1.1', 3, false, Rect.fromLTWH(0.015, 0.28, 0.030, 0.05)),
    RoomArea('C1.1.337', 'Аудитория 337', 'C1', '1.1', 3, false, Rect.fromLTWH(0.012, 0.22, 0.030, 0.05)),
    RoomArea('C1.1.338', 'Аудитория 338', 'C1', '1.1', 3, false, Rect.fromLTWH(0.010, 0.16, 0.035, 0.05)),
    // C1.1 inner
    RoomArea('C1.1.318K', 'Кабинет 318К', 'C1', '1.1', 3, false, Rect.fromLTWH(0.160, 0.85, 0.035, 0.04)),
    RoomArea('C1.1.324L', 'Лаборатория 324Л', 'C1', '1.1', 3, false, Rect.fromLTWH(0.105, 0.62, 0.045, 0.05)),
    RoomArea('C1.1.326L', 'Лаборатория 326Л', 'C1', '1.1', 3, false, Rect.fromLTWH(0.105, 0.56, 0.045, 0.05)),
    RoomArea('C1.1.328L', 'Лаборатория 328Л', 'C1', '1.1', 3, false, Rect.fromLTWH(0.105, 0.48, 0.055, 0.06)),
    RoomArea('C1.1.334L', 'Лаборатория 334Л', 'C1', '1.1', 3, false, Rect.fromLTWH(0.100, 0.30, 0.060, 0.08)),
    // C1.1 upper arc
    RoomArea('C1.1.341P', 'Практическая 341П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.060, 0.14, 0.030, 0.05)),
    RoomArea('C1.1.343P', 'Практическая 343П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.065, 0.10, 0.030, 0.04)),
    RoomArea('C1.1.344P', 'Практическая 344П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.095, 0.08, 0.025, 0.04)),
    RoomArea('C1.1.346P', 'Практическая 346П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.115, 0.06, 0.025, 0.04)),
    RoomArea('C1.1.347P', 'Практическая 347П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.140, 0.06, 0.025, 0.04)),
    RoomArea('C1.1.348K', 'Кабинет 348К', 'C1', '1.1', 3, false, Rect.fromLTWH(0.170, 0.05, 0.025, 0.04)),
    RoomArea('C1.1.349P', 'Практическая 349П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.195, 0.04, 0.025, 0.04)),
    RoomArea('C1.1.350P', 'Практическая 350П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.230, 0.04, 0.035, 0.04)),
    RoomArea('C1.1.352K', 'Кабинет 352К', 'C1', '1.1', 3, false, Rect.fromLTWH(0.210, 0.12, 0.035, 0.05)),
    RoomArea('C1.1.354K', 'Кабинет 354К', 'C1', '1.1', 3, false, Rect.fromLTWH(0.255, 0.10, 0.035, 0.05)),
    RoomArea('C1.1.353P', 'Практическая 353П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.195, 0.22, 0.035, 0.05)),
    RoomArea('C1.1.355P', 'Практическая 355П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.270, 0.22, 0.040, 0.05)),
    RoomArea('C1.1.357K', 'Кабинет 357К', 'C1', '1.1', 3, false, Rect.fromLTWH(0.255, 0.40, 0.040, 0.05)),
    RoomArea('C1.1.358K', 'Кабинет 358К', 'C1', '1.1', 3, false, Rect.fromLTWH(0.255, 0.47, 0.040, 0.05)),
    RoomArea('C1.1.360K', 'Кабинет 360К', 'C1', '1.1', 3, false, Rect.fromLTWH(0.305, 0.40, 0.035, 0.05)),
    RoomArea('C1.1.361K', 'Кабинет 361К', 'C1', '1.1', 3, false, Rect.fromLTWH(0.305, 0.47, 0.035, 0.05)),
    RoomArea('C1.1.365P', 'Практическая 365П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.265, 0.66, 0.030, 0.04)),
    RoomArea('C1.1.366P', 'Практическая 366П', 'C1', '1.1', 3, false, Rect.fromLTWH(0.300, 0.66, 0.030, 0.04)),
    // C1.2 upper
    RoomArea('C1.2.340', 'Аудитория 340', 'C1', '1.2', 3, false, Rect.fromLTWH(0.310, 0.06, 0.050, 0.07)),
    RoomArea('C1.2.339', 'Аудитория 339', 'C1', '1.2', 3, false, Rect.fromLTWH(0.340, 0.14, 0.040, 0.06)),
    RoomArea('C1.2.337', 'Аудитория 337', 'C1', '1.2', 3, false, Rect.fromLTWH(0.340, 0.22, 0.040, 0.06)),
    RoomArea('C1.2.336', 'Аудитория 336', 'C1', '1.2', 3, false, Rect.fromLTWH(0.355, 0.30, 0.035, 0.05)),
    RoomArea('C1.2.338', 'Аудитория 338', 'C1', '1.2', 3, false, Rect.fromLTWH(0.415, 0.12, 0.050, 0.06)),
    RoomArea('C1.2.335', 'Аудитория 335', 'C1', '1.2', 3, false, Rect.fromLTWH(0.395, 0.20, 0.045, 0.06)),
    RoomArea('C1.2.334', 'Аудитория 334', 'C1', '1.2', 3, false, Rect.fromLTWH(0.400, 0.28, 0.040, 0.06)),
    RoomArea('C1.2.344', 'Аудитория 344', 'C1', '1.2', 3, false, Rect.fromLTWH(0.395, 0.04, 0.065, 0.06)),
    RoomArea('C1.2.346', 'Аудитория 346', 'C1', '1.2', 3, false, Rect.fromLTWH(0.470, 0.04, 0.060, 0.06)),
    RoomArea('C1.2.352', 'Аудитория 352', 'C1', '1.2', 3, false, Rect.fromLTWH(0.540, 0.04, 0.060, 0.06)),
    RoomArea('C1.2.354', 'Аудитория 354', 'C1', '1.2', 3, false, Rect.fromLTWH(0.610, 0.06, 0.060, 0.06)),
    RoomArea('C1.2.359', 'Аудитория 359', 'C1', '1.2', 3, false, Rect.fromLTWH(0.550, 0.14, 0.060, 0.07)),
    RoomArea('C1.2.360', 'Аудитория 360', 'C1', '1.2', 3, false, Rect.fromLTWH(0.525, 0.22, 0.050, 0.06)),
    RoomArea('C1.2.358', 'Аудитория 358', 'C1', '1.2', 3, false, Rect.fromLTWH(0.590, 0.24, 0.050, 0.06)),
    // C1.2 center rooms
    RoomArea('C1.2.331', 'Аудитория 331', 'C1', '1.2', 3, false, Rect.fromLTWH(0.340, 0.36, 0.035, 0.05)),
    RoomArea('C1.2.329', 'Аудитория 329', 'C1', '1.2', 3, false, Rect.fromLTWH(0.360, 0.42, 0.035, 0.05)),
    RoomArea('C1.2.327', 'Аудитория 327', 'C1', '1.2', 3, false, Rect.fromLTWH(0.360, 0.48, 0.035, 0.05)),
    RoomArea('C1.2.325', 'Аудитория 325', 'C1', '1.2', 3, false, Rect.fromLTWH(0.360, 0.54, 0.035, 0.05)),
    RoomArea('C1.2.323', 'Аудитория 323', 'C1', '1.2', 3, false, Rect.fromLTWH(0.360, 0.60, 0.035, 0.05)),
    RoomArea('C1.2.332', 'Аудитория 332', 'C1', '1.2', 3, false, Rect.fromLTWH(0.405, 0.36, 0.035, 0.05)),
    RoomArea('C1.2.330', 'Аудитория 330', 'C1', '1.2', 3, false, Rect.fromLTWH(0.405, 0.42, 0.035, 0.05)),
    RoomArea('C1.2.328', 'Аудитория 328', 'C1', '1.2', 3, false, Rect.fromLTWH(0.405, 0.48, 0.035, 0.05)),
    RoomArea('C1.2.326', 'Аудитория 326', 'C1', '1.2', 3, false, Rect.fromLTWH(0.405, 0.54, 0.035, 0.05)),
    RoomArea('C1.2.324', 'Аудитория 324', 'C1', '1.2', 3, false, Rect.fromLTWH(0.405, 0.60, 0.035, 0.05)),
    RoomArea('C1.2.362', 'Аудитория 362', 'C1', '1.2', 3, false, Rect.fromLTWH(0.470, 0.36, 0.035, 0.04)),
    RoomArea('C1.2.363', 'Аудитория 363', 'C1', '1.2', 3, false, Rect.fromLTWH(0.510, 0.36, 0.035, 0.04)),
    RoomArea('C1.2.364', 'Аудитория 364', 'C1', '1.2', 3, false, Rect.fromLTWH(0.510, 0.41, 0.035, 0.04)),
    RoomArea('C1.2.365', 'Аудитория 365', 'C1', '1.2', 3, false, Rect.fromLTWH(0.510, 0.46, 0.035, 0.04)),
    RoomArea('C1.2.366', 'Аудитория 366', 'C1', '1.2', 3, false, Rect.fromLTWH(0.510, 0.50, 0.035, 0.04)),
    RoomArea('C1.2.367', 'Аудитория 367', 'C1', '1.2', 3, false, Rect.fromLTWH(0.510, 0.55, 0.035, 0.04)),
    RoomArea('C1.2.368', 'Аудитория 368', 'C1', '1.2', 3, false, Rect.fromLTWH(0.510, 0.60, 0.035, 0.04)),
    RoomArea('C1.2.369', 'Аудитория 369', 'C1', '1.2', 3, false, Rect.fromLTWH(0.545, 0.55, 0.035, 0.04)),
    RoomArea('C1.2.370', 'Аудитория 370', 'C1', '1.2', 3, false, Rect.fromLTWH(0.480, 0.60, 0.030, 0.04)),
    RoomArea('C1.2.371', 'Аудитория 371', 'C1', '1.2', 3, false, Rect.fromLTWH(0.545, 0.60, 0.035, 0.04)),
    // C1.2 bottom
    RoomArea('C1.2.319', 'Аудитория 319', 'C1', '1.2', 3, false, Rect.fromLTWH(0.355, 0.68, 0.025, 0.10)),
    RoomArea('C1.2.321', 'Аудитория 321', 'C1', '1.2', 3, false, Rect.fromLTWH(0.330, 0.68, 0.025, 0.06)),
    RoomArea('C1.2.320', 'Аудитория 320', 'C1', '1.2', 3, false, Rect.fromLTWH(0.380, 0.68, 0.025, 0.08)),
    RoomArea('C1.2.374', 'Аудитория 374', 'C1', '1.2', 3, false, Rect.fromLTWH(0.510, 0.68, 0.035, 0.06)),
    RoomArea('C1.2.375', 'Аудитория 375', 'C1', '1.2', 3, false, Rect.fromLTWH(0.550, 0.68, 0.035, 0.06)),
    RoomArea('C1.2.376', 'Аудитория 376', 'C1', '1.2', 3, false, Rect.fromLTWH(0.590, 0.70, 0.035, 0.05)),
    RoomArea('C1.2.319P', 'Практическая 319П', 'C1', '1.2', 3, false, Rect.fromLTWH(0.635, 0.74, 0.035, 0.04)),
    RoomArea('C1.2.318P', 'Практическая 318П', 'C1', '1.2', 3, false, Rect.fromLTWH(0.675, 0.74, 0.035, 0.04)),
    // C1.2 right side
    RoomArea('C1.2.327K', 'Кабинет 327К', 'C1', '1.2', 3, false, Rect.fromLTWH(0.605, 0.28, 0.035, 0.04)),
    RoomArea('C1.2.324K', 'Кабинет 324К', 'C1', '1.2', 3, false, Rect.fromLTWH(0.555, 0.37, 0.030, 0.04)),
    RoomArea('C1.2.323K', 'Кабинет 323К', 'C1', '1.2', 3, false, Rect.fromLTWH(0.590, 0.38, 0.030, 0.04)),
    RoomArea('C1.2.322P', 'Практическая 322П', 'C1', '1.2', 3, false, Rect.fromLTWH(0.570, 0.44, 0.030, 0.04)),
    RoomArea('C1.2.321P', 'Практическая 321П', 'C1', '1.2', 3, false, Rect.fromLTWH(0.600, 0.50, 0.030, 0.04)),
    RoomArea('C1.2.331P', 'Практическая 331П', 'C1', '1.2', 3, false, Rect.fromLTWH(0.660, 0.22, 0.025, 0.04)),
    // C1.3 upper arc
    RoomArea('C1.3.337', 'Аудитория 337', 'C1', '1.3', 3, false, Rect.fromLTWH(0.685, 0.08, 0.030, 0.04)),
    RoomArea('C1.3.338', 'Аудитория 338', 'C1', '1.3', 3, false, Rect.fromLTWH(0.720, 0.10, 0.025, 0.04)),
    RoomArea('C1.3.339', 'Аудитория 339', 'C1', '1.3', 3, false, Rect.fromLTWH(0.748, 0.10, 0.025, 0.04)),
    RoomArea('C1.3.340', 'Аудитория 340', 'C1', '1.3', 3, false, Rect.fromLTWH(0.780, 0.10, 0.025, 0.04)),
    RoomArea('C1.3.341', 'Аудитория 341', 'C1', '1.3', 3, false, Rect.fromLTWH(0.808, 0.12, 0.025, 0.04)),
    RoomArea('C1.3.342', 'Аудитория 342', 'C1', '1.3', 3, false, Rect.fromLTWH(0.835, 0.14, 0.025, 0.04)),
    RoomArea('C1.3.343', 'Аудитория 343', 'C1', '1.3', 3, false, Rect.fromLTWH(0.860, 0.17, 0.025, 0.04)),
    RoomArea('C1.3.344', 'Аудитория 344', 'C1', '1.3', 3, false, Rect.fromLTWH(0.880, 0.20, 0.025, 0.04)),
    RoomArea('C1.3.345', 'Аудитория 345', 'C1', '1.3', 3, false, Rect.fromLTWH(0.900, 0.24, 0.025, 0.04)),
    RoomArea('C1.3.346', 'Аудитория 346', 'C1', '1.3', 3, false, Rect.fromLTWH(0.915, 0.30, 0.030, 0.04)),
    RoomArea('C1.3.328', 'Аудитория 328', 'C1', '1.3', 3, false, Rect.fromLTWH(0.700, 0.22, 0.055, 0.08)),
    // C1.3 right column
    RoomArea('C1.3.370L', 'Лаборатория 370Л', 'C1', '1.3', 3, false, Rect.fromLTWH(0.765, 0.36, 0.060, 0.06)),
    RoomArea('C1.3.367K', 'Кабинет 367К', 'C1', '1.3', 3, false, Rect.fromLTWH(0.835, 0.36, 0.040, 0.05)),
    RoomArea('C1.3.366L', 'Лаборатория 366Л', 'C1', '1.3', 3, false, Rect.fromLTWH(0.835, 0.48, 0.040, 0.04)),
    RoomArea('C1.3.365L', 'Лаборатория 365Л', 'C1', '1.3', 3, false, Rect.fromLTWH(0.840, 0.55, 0.040, 0.04)),
    RoomArea('C1.3.352', 'Аудитория 352', 'C1', '1.3', 3, false, Rect.fromLTWH(0.920, 0.34, 0.030, 0.04)),
    RoomArea('C1.3.353', 'Аудитория 353', 'C1', '1.3', 3, false, Rect.fromLTWH(0.920, 0.38, 0.030, 0.04)),
    RoomArea('C1.3.354', 'Аудитория 354', 'C1', '1.3', 3, false, Rect.fromLTWH(0.920, 0.42, 0.030, 0.04)),
    RoomArea('C1.3.355', 'Аудитория 355', 'C1', '1.3', 3, false, Rect.fromLTWH(0.920, 0.46, 0.030, 0.04)),
    RoomArea('C1.3.356', 'Аудитория 356', 'C1', '1.3', 3, false, Rect.fromLTWH(0.910, 0.50, 0.030, 0.04)),
    RoomArea('C1.3.357P', 'Практическая 357П', 'C1', '1.3', 3, false, Rect.fromLTWH(0.895, 0.54, 0.030, 0.04)),
    RoomArea('C1.3.358P', 'Практическая 358П', 'C1', '1.3', 3, false, Rect.fromLTWH(0.885, 0.58, 0.030, 0.04)),
    RoomArea('C1.3.359P', 'Практическая 359П', 'C1', '1.3', 3, false, Rect.fromLTWH(0.875, 0.62, 0.030, 0.04)),
    RoomArea('C1.3.360K', 'Кабинет 360К', 'C1', '1.3', 3, false, Rect.fromLTWH(0.870, 0.72, 0.030, 0.04)),
    RoomArea('C1.3.361', 'Аудитория 361', 'C1', '1.3', 3, false, Rect.fromLTWH(0.850, 0.80, 0.035, 0.04)),
    RoomArea('C1.3.362P', 'Практическая 362П', 'C1', '1.3', 3, false, Rect.fromLTWH(0.830, 0.76, 0.035, 0.04)),
  ];

  static List<RoomArea> get all => [..._f1, ..._f2, ..._f3];
}