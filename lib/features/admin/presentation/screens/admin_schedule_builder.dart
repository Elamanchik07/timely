import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/teacher.dart';
import '../providers/admin_provider.dart';
import '../../../schedule/domain/entities/schedule_item.dart';
import '../../../map/domain/entities/room.dart';
import '../../../../core/utils/room_utils.dart';

const List<Map<String, String>> shift1Times = [
  {'start': '08:00', 'end': '09:35'},
  {'start': '09:45', 'end': '11:20'},
  {'start': '11:40', 'end': '13:15'},
];

const List<Map<String, String>> shift2Times = [
  {'start': '13:30', 'end': '15:00'},
  {'start': '15:20', 'end': '16:50'},
  {'start': '17:00', 'end': '18:30'},
];

const List<String> daysOfWeek = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'];

class AdminScheduleBuilder extends ConsumerStatefulWidget {
  const AdminScheduleBuilder({super.key});

  @override
  ConsumerState<AdminScheduleBuilder> createState() => _AdminScheduleBuilderState();
}

class _AdminScheduleBuilderState extends ConsumerState<AdminScheduleBuilder> {
  Group? _selectedGroup;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminGroupsProvider.notifier).fetchGroups();
      ref.read(adminSubjectsProvider.notifier).fetchSubjects();
      ref.read(adminRoomsProvider.notifier).fetchRooms();
      ref.read(adminTeachersProvider.notifier).fetchTeachers();
    });
  }

  void _onGroupSelected(Group? group) {
    setState(() => _selectedGroup = group);
    if (group != null) {
      ref.read(adminScheduleListProvider.notifier).fetchByGroup(group.groupCode);
    }
  }

  void _copySchedule() {
    // Show dialog to copy TO selected group FROM another group
    if (_selectedGroup == null) return;
    String? fromGroup;
    final groups = ref.read(adminGroupsProvider).value ?? [];
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Копировать расписание'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Откуда'),
            items: groups
                .where((g) => g.groupCode != _selectedGroup!.groupCode)
                .map((g) => DropdownMenuItem(value: g.groupCode, child: Text(g.groupCode)))
                .toList(),
            onChanged: (v) => setDialogState(() => fromGroup = v),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (fromGroup != null) {
                  try {
                    await ref.read(adminScheduleListProvider.notifier).copySchedule(fromGroup!, _selectedGroup!.groupCode);
                    if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Расписание скопировано')));
                       Navigator.pop(ctx);
                    }
                  } catch (e) {
                    if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: AppTheme.errorColor));
                    }
                  }
                }
              },
              child: const Text('Копировать'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSchedule() {
     if (_selectedGroup == null) return;
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить расписание?'),
        content: const Text('Вы уверены? Это удалит все занятия этой группы.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () async {
               try {
                  await ref.read(adminScheduleListProvider.notifier).clearSchedule(_selectedGroup!.groupCode);
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Расписание очищено')));
                     Navigator.pop(ctx);
                  }
               } catch (e) {
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: AppTheme.errorColor));
                  }
               }
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(adminGroupsProvider);
    final subjectsAsync = ref.watch(adminSubjectsProvider);
    final scheduleAsync = ref.watch(adminScheduleListProvider);
    final roomsAsync = ref.watch(adminRoomsProvider);
    final teachersAsync = ref.watch(adminTeachersProvider);

    return Column(
      children: [
        // Controls Header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.surfaceColor,
          child: Row(
            children: [
              Expanded(
                child: groupsAsync.when(
                  data: (groups) => DropdownButtonFormField<Group>(
                    value: _selectedGroup,
                    decoration: const InputDecoration(
                      labelText: 'Выберите группу',
                      prefixIcon: Icon(Icons.group),
                    ),
                    items: groups.map((g) => DropdownMenuItem(
                      value: g,
                      child: Text('${g.groupCode} (${g.shift} смена)'),
                    )).toList(),
                    onChanged: _onGroupSelected,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => const Text('Ошбика загрузки групп'),
                ),
              ),
              const SizedBox(width: 16),
              if (_selectedGroup != null) ...[
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Копировать',
                  onPressed: _copySchedule,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: AppTheme.errorColor),
                  tooltip: 'Очистить всё',
                  onPressed: _clearSchedule,
                ),
              ]
            ],
          ),
        ),
        
        // Builder Grid
        Expanded(
          child: _selectedGroup == null
            ? const Center(child: Text('Выберите группу для редактирования расписания'))
            : scheduleAsync.when(
                data: (items) => _ScheduleGrid(
                  group: _selectedGroup!,
                  scheduleItems: items,
                  subjects: subjectsAsync.value ?? [],
                  rooms: roomsAsync.valueOrNull ?? [],
                  teachers: teachersAsync.valueOrNull ?? [],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Ошибка: $e')),
            ),
        ),
      ],
    );
  }
}

class _ScheduleGrid extends ConsumerWidget {
  final Group group;
  final List<ScheduleItem> scheduleItems;
  final List<Subject> subjects;
  final List<Room> rooms;
  final List<Teacher> teachers;

  const _ScheduleGrid({required this.group, required this.scheduleItems, required this.subjects, required this.rooms, required this.teachers});

  void _showItemDialog(BuildContext context, WidgetRef ref, int dayOfWeek, int pairNumber, {ScheduleItem? existingItem}) {
    final List<Map<String, String>> times = group.shift == 1 ? shift1Times : shift2Times;
    final timeStart = times[pairNumber - 1]['start']!;
    final timeEnd = times[pairNumber - 1]['end']!;

    String? subjectName = existingItem?.subject;
    String? selectedTeacherName = existingItem?.teacher;
    String? selectedRoomCode = existingItem?.room;
    
    final activeRooms = rooms.where((r) => r.isActive).toList();
    if (selectedRoomCode != null) {
      final match = activeRooms.where((r) => r.fullCode == selectedRoomCode || r.code == selectedRoomCode).firstOrNull;
      if (match != null) {
        selectedRoomCode = match.fullCode;
      } else {
        final normalized = RoomCodeNormalizer.toFullCode(selectedRoomCode);
        final normMatch = activeRooms.where((r) => r.fullCode == normalized).firstOrNull;
        if (normMatch != null) {
           selectedRoomCode = normMatch.fullCode;
        } else {
           selectedRoomCode = null; // Prevent crash if room was deleted/inactive
        }
      }
    }

    String type = existingItem?.type ?? 'lecture';
    String weekType = existingItem?.weekType ?? 'ALL';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('${daysOfWeek[dayOfWeek - 1]}, Пара $pairNumber\n$timeStart - $timeEnd'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: subjectName,
                    decoration: const InputDecoration(labelText: 'Предмет *'),
                    items: subjects.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                    onChanged: (v) {
                       setState(() {
                         subjectName = v;
                         selectedTeacherName = null; // reset teacher when subject changes
                       });
                    },
                    validator: (v) => v == null ? 'Обязательно' : null,
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                       final activeTeachers = teachers.where((t) => t.isActive).toList();
                       
                       // Filter teachers if subject is selected
                       List<Teacher> availableTeachers = activeTeachers;
                       if (subjectName != null && subjectName!.isNotEmpty) {
                          final matchingSubject = subjects.where((s) => s.name == subjectName).firstOrNull;
                          if (matchingSubject != null) {
                             availableTeachers = activeTeachers.where((t) => t.subjects.contains(matchingSubject.id)).toList();
                          }
                       }

                       if (selectedTeacherName != null && !availableTeachers.any((t) => t.fullName == selectedTeacherName)) {
                          // Allow keeping existing teacher even if filter fails (graceful degradation)
                          // if the teacher is completely inactive/missing, we could nullify, but let's just nullify if not in active list
                          if (!activeTeachers.any((t) => t.fullName == selectedTeacherName)) {
                             selectedTeacherName = null;
                          } else {
                             // Temporarily add to available so dropdown doesn't crash
                             final missingTeacher = activeTeachers.firstWhere((t) => t.fullName == selectedTeacherName);
                             if (!availableTeachers.contains(missingTeacher)) availableTeachers.add(missingTeacher);
                          }
                       }

                       if (availableTeachers.isEmpty) {
                         return const Text('Нет преподавателей для этого предмета', style: TextStyle(color: AppTheme.errorColor));
                       }

                       return DropdownButtonFormField<String>(
                         value: selectedTeacherName,
                         decoration: const InputDecoration(labelText: 'Преподаватель *'),
                         items: availableTeachers.map((t) => DropdownMenuItem(value: t.fullName, child: Text(t.fullName))).toList(),
                         onChanged: (v) => setState(() => selectedTeacherName = v),
                         validator: (v) => v == null ? 'Обязательно' : null,
                       );
                    }
                  ),
                  const SizedBox(height: 8),
                  if (activeRooms.isEmpty)
                    const Text('Внимание: Нет доступных аудиторий. Расписание сохранить невозможно.', style: TextStyle(color: AppTheme.errorColor))
                  else
                    InkWell(
                      onTap: () async {
                         final selected = await showModalBottomSheet<Room>(
                           context: context,
                           isScrollControlled: true,
                           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                           builder: (ctx) => _RoomPickerSheet(rooms: activeRooms, selectedRoomCode: selectedRoomCode),
                         );
                         if (selected != null) {
                           setState(() => selectedRoomCode = selected.fullCode);
                         }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Аудитория *',
                          errorText: selectedRoomCode == null && formKey.currentState?.validate() == false ? 'Обязательно' : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedRoomCode ?? 'Выбрать...'),
                            const Icon(Icons.arrow_drop_down),
                          ]
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Тип занятия'),
                    items: const [
                       DropdownMenuItem(value: 'lecture', child: Text('Лекция')),
                       DropdownMenuItem(value: 'practice', child: Text('Практика')),
                       DropdownMenuItem(value: 'lab', child: Text('Лабораторная')),
                    ],
                    onChanged: (v) => setState(() => type = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (existingItem != null)
              TextButton(
                onPressed: () {
                   ref.read(adminScheduleListProvider.notifier).delete(existingItem.id);
                   Navigator.pop(ctx);
                },
                child: const Text('Удалить', style: TextStyle(color: AppTheme.errorColor)),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'groupCode': group.groupCode,
                    'dayOfWeek': dayOfWeek,
                    'pairNumber': pairNumber,
                    'startTime': timeStart,
                    'endTime': timeEnd,
                    'subject': subjectName,
                    'subjectId': subjectName != null ? subjects.where((s) => s.name == subjectName!).firstOrNull?.id : null,
                    'teacher': selectedTeacherName,
                    'teacherId': selectedTeacherName != null ? teachers.where((t) => t.fullName == selectedTeacherName!).firstOrNull?.id : null,
                    'room': selectedRoomCode,
                    'roomId': selectedRoomCode != null ? rooms.where((r) => r.fullCode == selectedRoomCode).firstOrNull?.id : null,
                    'type': type,
                    'weekType': weekType,
                  };
                  if (existingItem == null) {
                    ref.read(adminScheduleListProvider.notifier).create(data);
                  } else {
                    ref.read(adminScheduleListProvider.notifier).updateItem(existingItem.id, data);
                  }
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6, // Mon to Sat
      itemBuilder: (ctx, dayIdx) {
        final day = dayIdx + 1; // 1-6
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Text(
                  daysOfWeek[dayIdx],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accent),
                ),
              ),
              ...List.generate(3, (pairIdx) { // 3 slots per shift
                final pair = pairIdx + 1;
                final items = scheduleItems.where((i) => i.dayOfWeek == day && i.pairNumber == pair).toList();
                
                final times = group.shift == 1 ? shift1Times : shift2Times;

                if (items.isEmpty) {
                  return ListTile(
                    title: const Text('Пусто', style: TextStyle(color: Colors.grey)),
                    subtitle: Text('${times[pairIdx]['start']} - ${times[pairIdx]['end']}'),
                    trailing: const Icon(Icons.add, color: AppTheme.accent),
                    onTap: () => _showItemDialog(context, ref, day, pair),
                  );
                }

                final item = items.first; // Note: weekType A/B logic should be handled properly to display multiple. But simplified here.
                return ListTile(
                  title: Text('${item.subject} (${item.type})', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${item.teacher} • Ауд: ${item.room}'),
                  leading: Text('${times[pairIdx]['start']}\n${times[pairIdx]['end']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppTheme.accent)),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () => _showItemDialog(context, ref, day, pair, existingItem: item),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _RoomPickerSheet extends StatefulWidget {
  final List<Room> rooms;
  final String? selectedRoomCode;

  const _RoomPickerSheet({required this.rooms, this.selectedRoomCode});

  @override
  State<_RoomPickerSheet> createState() => _RoomPickerSheetState();
}

class _RoomPickerSheetState extends State<_RoomPickerSheet> {
  String _searchQuery = '';
  late List<Room> _filteredRooms;

  @override
  void initState() {
    super.initState();
    _filterRooms('');
  }

  void _filterRooms(String query) {
    if (query.isEmpty) {
      _filteredRooms = List.from(widget.rooms);
    } else {
      final q = RoomCodeNormalizer.toFullCode(query);
      final rawQ = query.trim().toUpperCase();
      _filteredRooms = widget.rooms.where((r) {
        final code = r.fullCode;
        final shortCode = r.shortCode;
        return code == q || code.startsWith(q) || code.contains(rawQ) || shortCode.startsWith(rawQ);
      }).toList();
      _filteredRooms.sort((a, b) => a.fullCode.compareTo(b.fullCode));
    }
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    // group by sector
    final Map<String, List<Room>> groups = {};
    for (final r in _filteredRooms) {
       final sector = r.sector.isNotEmpty ? r.sector : 'Прочие';
       groups.putIfAbsent(sector, () => []).add(r);
    }
    
    final sortedSectors = groups.keys.toList()..sort();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 16, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Поиск (например, C1.2.235)',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            onChanged: _filterRooms,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sortedSectors.length,
              itemBuilder: (ctx, idx) {
                final sector = sortedSectors[idx];
                final sectorRooms = groups[sector]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Сектор $sector', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
                    ),
                    ...sectorRooms.map((r) => ListTile(
                      title: Text(r.fullCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: r.title != null && r.title != r.code ? Text(r.title!) : null,
                      trailing: widget.selectedRoomCode == r.fullCode ? const Icon(Icons.check, color: AppTheme.successColor) : null,
                      onTap: () => Navigator.pop(context, r),
                    )).toList(),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
