import 'dart:io';

void main() {
  final file = File('lib/features/map/presentation/screens/map_page.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('MapRoomZone', 'RoomArea');
  content = content.replaceAll(
    'rx >= z.x && rx <= z.x + z.w && ry >= z.y && ry <= z.y + z.h',
    'rx >= z.rect.left && rx <= z.rect.right && ry >= z.rect.top && ry <= z.rect.bottom'
  );
  file.writeAsStringSync(content);
}
