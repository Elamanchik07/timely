import 'package:flutter_riverpod/flutter_riverpod.dart';

// Represents a command to navigate to the map and focus on a specific room.
// The string is the room code. Null means no pending command.
final mapFocusProvider = StateProvider<String?>((ref) => null);

// We can also have a provider for changing bottom nav index
final homeTabProvider = StateProvider<int>((ref) => 0);
