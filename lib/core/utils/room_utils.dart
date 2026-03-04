import 'package:flutter/foundation.dart';
import 'package:mobile_project_app/features/map/domain/map_room_data.dart';

/// Single source of truth for normalizing room codes across the app.
class RoomCodeNormalizer {
  RoomCodeNormalizer._();

  /// Converts any raw string like "245", "235P", "C1.1.245" into a FULL code (C1.x.y)
  /// Returns the exact full code if found in MapRoomData.
  static String toFullCode(String rawCode, {int? floor, String? block, String? requiredSector}) {
    if (rawCode.trim().isEmpty) return '';

    String c = rawCode.trim().toUpperCase();
    c = c.replaceAll(RegExp(r'\s+'), '');
    c = c.replaceAll(',', '.').replaceAll('-', '.').replaceAll('_', '.');
    
    // Normalize Cyrillic 'C' to Latin 'C' etc.
    const cyrToLat = {
      'С': 'C', 'А': 'A', 'Е': 'E', 'О': 'O', 'Р': 'P',
      'М': 'M', 'Т': 'T', 'Х': 'X', 'К': 'K', 'Л': 'L',
      'П': 'P', 'В': 'B', 'У': 'Y', 'Н': 'H'
    };
    cyrToLat.forEach((cyr, lat) => c = c.replaceAll(cyr, lat));
    c = c.replaceAll(RegExp(r'\.{2,}'), '.');
    if (c.startsWith('.')) c = c.substring(1);
    if (c.endsWith('.')) c = c.substring(0, c.length - 1);

    // Non-room areas mapping
    final nonRoomTypes = ['LIBRARY', 'ASSEMBLY', 'COWORKING', 'ATRIUM', 'DINING', 'OPEN'];
    if (nonRoomTypes.any((nr) => c.contains(nr))) {
      final mapped = MapRoomData.findByCode(c);
      if (mapped != null) return mapped.fullCode;
      if (c.startsWith('C1.')) return c;
      return 'C1.$c';
    }

    // Attempt smart search in static MapRoomData
    final mapped = MapRoomData.findByCode(c, floor: floor, block: block);
    if (mapped != null) return mapped.fullCode;

    // Handle 2-part codes like "C1.201" → try just "201"
    if (c.startsWith('C1.') && c.split('.').length == 2) {
      final shortPart = c.substring(3);
      final mapped2 = MapRoomData.findByCode(shortPart, floor: floor, block: block);
      if (mapped2 != null) return mapped2.fullCode;
    }

    // Direct mapping failed, but maybe we have context?
    if (requiredSector != null && requiredSector.isNotEmpty) {
       String short = c;
       if (short.startsWith('$requiredSector.')) short = short.substring(requiredSector.length + 1);
       if (short.startsWith('C1.')) short = short.substring(3);
       return '$requiredSector.$short';
    }

    // Default return
    return c.startsWith('C1.') ? c : c;
  }

  static String extractShortCode(String fullCode) {
    if (fullCode.isEmpty) return fullCode;
    final parts = fullCode.split('.');
    return parts.last;
  }

  static String extractSector(String fullCode) {
    if (fullCode.isEmpty) return 'C1.1'; // Default
    final parts = fullCode.split('.');
    if (parts.length >= 2 && parts[0] == 'C1' && (parts[1]=='1' || parts[1]=='2' || parts[1]=='3')) {
      return '${parts[0]}.${parts[1]}';
    }
    return ''; // Non-room sectors
  }
}

class RoomUtils {
  RoomUtils._();

  static String? normalizeRoomCode(String raw) {
    final res = RoomCodeNormalizer.toFullCode(raw);
    return res.isEmpty ? null : res;
  }

  static String formatShortCode(String raw) {
     return RoomCodeNormalizer.extractShortCode(RoomCodeNormalizer.toFullCode(raw));
  }

  static String displayCode(String raw) {
    if (raw.trim().isEmpty) return '—';
    return RoomCodeNormalizer.toFullCode(raw);
  }

  /// Generates a diagnostic report
  static Map<String, dynamic> generateReport(List<String> rawCodes) {
    final unique = rawCodes.toSet().where((r) => r.trim().isNotEmpty).toList();
    final mapping = <String, String>{};
    final unresolved = <String>[];

    for (final raw in unique) {
      final normalized = normalizeRoomCode(raw);
      if (normalized != null) {
        mapping[raw] = normalized;
      } else {
        unresolved.add(raw);
      }
    }

    return {
      'total': unique.length,
      'resolved': mapping.length,
      'unresolved': unresolved,
      'mapping': mapping,
    };
  }
}
