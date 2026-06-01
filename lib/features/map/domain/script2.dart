import 'dart:io';

void main() {
  final file = File('lib/features/map/domain/map_room_data.dart');
  final lines = file.readAsLinesSync();
  final newLines = <String>[];
  
  for (final line in lines) {
    if (line.contains('RoomArea(')) {
      var l = line.replaceAll('C1.1.1.', 'C1.1.').replaceAll('C1.1.2.', 'C1.2.').replaceAll('C1.1.3.', 'C1.3.');
      newLines.add(l);
    } else {
      newLines.add(line);
    }
  }
  
  file.writeAsStringSync(newLines.join('\n'));
}
