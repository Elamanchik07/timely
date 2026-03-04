import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../../core/theme/app_theme.dart';
import '../../../map/domain/entities/room.dart';
import '../../data/admin_repository.dart';
import 'admin_map_editor.dart';
import '../providers/admin_provider.dart';

class AdminRoomsList extends ConsumerWidget {
  const AdminRoomsList({super.key});

  void _openMapEditor(BuildContext context, WidgetRef ref, {Room? room}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminMapEditor(room: room),
      ),
    );
  }

  void _deleteRoom(BuildContext context, WidgetRef ref, Room room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить?'),
        content: Text('Удалить аудиторию ${room.code}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              ref.read(adminRoomsProvider.notifier).delete(room.id);
              Navigator.pop(ctx);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Future<void> _importRoomsFromSeed(BuildContext context, WidgetRef ref) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Импорт аудиторий из карты...'),
          ],
        ),
      ),
    );

    try {
      final jsonString = await rootBundle.loadString('assets/data/rooms_seed.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Call bulk import API
      final repo = ref.read(adminRepositoryProvider);
      final response = await repo.bulkImportRooms(jsonList);

      if (context.mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Импортировано: $response')),
        );
        ref.read(adminRoomsProvider.notifier).fetchRooms();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка импорта: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(adminRoomsProvider);

    return Scaffold(
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.door_front_door_outlined, size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Нет аудиторий', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _importRoomsFromSeed(context, ref),
                    icon: const Icon(Icons.download),
                    label: const Text('Импорт аудиторий из карты'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          // Group by floor
          final floor1 = rooms.where((r) => r.floor == 1).toList();
          final floor2 = rooms.where((r) => r.floor == 2).toList();
          final floor3 = rooms.where((r) => r.floor == 3).toList();

          return Column(
            children: [
              // Import button at top
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Всего: ${rooms.length} аудиторий', style: const TextStyle(color: AppTheme.textSecondary)),
                    TextButton.icon(
                      onPressed: () => _importRoomsFromSeed(context, ref),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Импорт из карты'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (floor1.isNotEmpty) ...[
                      _buildFloorHeader('1 этаж', floor1.length),
                      ...floor1.map((r) => _buildRoomTile(context, ref, r)),
                    ],
                    if (floor2.isNotEmpty) ...[
                      _buildFloorHeader('2 этаж', floor2.length),
                      ...floor2.map((r) => _buildRoomTile(context, ref, r)),
                    ],
                    if (floor3.isNotEmpty) ...[
                      _buildFloorHeader('3 этаж', floor3.length),
                      ...floor3.map((r) => _buildRoomTile(context, ref, r)),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_rooms',
        onPressed: () => _openMapEditor(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFloorHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.primaryMid,
      child: Row(
        children: [
          const Icon(Icons.layers, size: 18, color: AppTheme.accent),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
          const SizedBox(width: 8),
          Text('($count)', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, WidgetRef ref, Room room) {
    return ListTile(
      dense: true,
      title: Text(room.fullCode, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        room.description ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: room.isActive ? AppTheme.successColor.withValues(alpha: 0.15) : AppTheme.errorColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              room.isActive ? 'Активна' : 'Неактивна',
              style: TextStyle(fontSize: 10, color: room.isActive ? AppTheme.successColor : AppTheme.errorColor),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.edit, size: 18, color: AppTheme.accent),
            onPressed: () => _openMapEditor(context, ref, room: room),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
            onPressed: () => _deleteRoom(context, ref, room),
          ),
        ],
      ),
    );
  }
}
