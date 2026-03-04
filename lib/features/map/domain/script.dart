import 'dart:io';

void main() {
  final file = File('lib/features/map/domain/map_room_data.dart');
  final lines = file.readAsLinesSync();
  final newLines = <String>[];
  
  String currentBlock = '1';
  
  for (final line in lines) {
    if (line.contains('// C1.')) {
      final match = RegExp(r'C1\.(\d+)').firstMatch(line);
      if (match != null) {
        currentBlock = '1.${match.group(1)}';
      }
    }
    
    if (line.contains('MapRoomZone(')) {
      final group = RegExp(r"MapRoomZone\('([^']+)',\s*'([^']+)',\s*(\d),\s*'([^']+)',\s*([^,]+),\s*([^,]+),\s*([^,]+),\s*([^)]+)\)").firstMatch(line);
      if (group != null) {
        final code = group.group(1)!;
        final label = group.group(2)!;
        final floor = group.group(3)!;
        final type = group.group(4)!;
        final x = group.group(5)!;
        final y = group.group(6)!;
        final w = group.group(7)!;
        final h = group.group(8)!;
        
        final cleanCode = code.replaceAll('_c', '').replaceAll('_r', '').replaceAll('_b', '');
        
        String fullCode;
        if (['LIBRARY', 'ASSEMBLY_HALL_1', 'COWORKING', 'ATRIUM', 'DINING_HALL', 'ASSEMBLY_HALL_2', 'OPEN_SPACE'].contains(cleanCode)) {
          fullCode = 'C1.$cleanCode';
        } else {
          fullCode = 'C1.$currentBlock.$cleanCode';
        }
        
        final isArea = type == 'area' ? 'true' : 'false';
        
        newLines.add("    RoomArea('$fullCode', '$label', 'C1', '$currentBlock', $floor, $isArea, Rect.fromLTWH(${x.trim()}, ${y.trim()}, ${w.trim()}, ${h.trim()})),");
        continue;
      }
    }
    
    if (line.contains('class MapRoomZone')) {
      newLines.add("import 'dart:ui';");
      newLines.add("");
      newLines.add("class RoomArea {");
      newLines.add("  final String fullCode;");
      newLines.add("  final String label;");
      newLines.add("  final String building;");
      newLines.add("  final String block;");
      newLines.add("  final int floor;");
      newLines.add("  final bool isArea;");
      newLines.add("  final Rect rect;");
      newLines.add("");
      newLines.add("  const RoomArea(this.fullCode, this.label, this.building, this.block, this.floor, this.isArea, this.rect);");
      newLines.add("");
      newLines.add("  double get cx => rect.center.dx;");
      newLines.add("  double get cy => rect.center.dy;");
      newLines.add("  String get code => fullCode;");
      newLines.add("}");
      continue;
    }
    
    if (line.contains('final String code;') || 
        line.contains('final String label;') || 
        line.contains('final int floor;') || 
        line.contains('final String type;') || 
        line.contains('final double x, y, w, h;') || 
        line.contains('const MapRoomZone') || 
        line.contains('double get cx') || 
        line.contains('double get cy') || 
        line.contains('bool get isArea')) {
      continue;
    }
    
    if (line.trim() == '}' && newLines.length > 10 && newLines[newLines.length - 2].contains('code => fullCode')) {
      continue;
    }
    
    var l = line.replaceAll('MapRoomZone', 'RoomArea');
    newLines.add(l);
  }
  
  file.writeAsStringSync(newLines.join('\n'));
}
