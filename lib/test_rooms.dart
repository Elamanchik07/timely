import 'package:mobile_project_app/core/utils/room_utils.dart';
import 'package:mobile_project_app/features/map/domain/map_room_data.dart';

void main() {
  final testCases = [
    '232P', '232', '340', '1.225', '225', '261', '121K', 'LIBRARY', '1.1.250', '260P', '1.2'
  ];
  
  for (final t in testCases) {
    print('Raw: $t => Normalized: ${RoomUtils.normalizeRoomCode(t)} => Display: ${RoomUtils.displayCode(t)}');
  }
}
