import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/entities/subject.dart';
import '../providers/admin_provider.dart';

class AdminTeachersList extends ConsumerWidget {
  const AdminTeachersList({super.key});

  void _showTeacherDialog(BuildContext context, WidgetRef ref, {Teacher? teacher, required List<Subject> allSubjects}) {
    final nameCtrl = TextEditingController(text: teacher?.fullName);
    final phoneCtrl = TextEditingController(text: teacher?.phone);
    bool isActive = teacher?.isActive ?? true;
    List<String> selectedSubjects = List.from(teacher?.subjects ?? []);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(teacher == null ? 'Новый преподаватель' : 'Редактировать'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'ФИО *'),
                    validator: (v) => v!.isEmpty ? 'Обязательно' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Телефон'),
                  ),
                  const SizedBox(height: 16),
                  const Align(alignment: Alignment.centerLeft, child: Text('Предметы:', style: TextStyle(fontWeight: FontWeight.bold))),
                  if (allSubjects.isEmpty)
                    const Text('Нет доступных предметов. Создайте предметы сначала.')
                  else
                    Wrap(
                      spacing: 8,
                      children: allSubjects.map((s) {
                        final isSelected = selectedSubjects.contains(s.id);
                        return FilterChip(
                          label: Text(s.name, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedSubjects.add(s.id!);
                              } else {
                                selectedSubjects.remove(s.id!);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Активен'),
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'fullName': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'subjects': selectedSubjects,
                    'isActive': isActive,
                  };
                  if (teacher == null) {
                    ref.read(adminTeachersProvider.notifier).create(data);
                  } else {
                    ref.read(adminTeachersProvider.notifier).update(teacher.id!, data);
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

  void _deleteTeacher(BuildContext context, WidgetRef ref, Teacher teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить?'),
        content: Text('Вы уверены, что хотите удалить ${teacher.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              ref.read(adminTeachersProvider.notifier).delete(teacher.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(adminTeachersProvider);
    final subjectsAsync = ref.watch(adminSubjectsProvider);
    final allSubjects = subjectsAsync.valueOrNull ?? [];

    return Scaffold(
      body: teachersAsync.when(
        data: (teachers) {
          if (teachers.isEmpty) return const Center(child: Text('Нет преподавателей'));
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (ctx, i) {
              final t = teachers[i];
              // Map subject IDs to Names for display
              final tSubjectNames = t.subjects.map((sid) {
                final match = allSubjects.where((s) => s.id == sid).firstOrNull;
                return match?.name ?? 'Неизвестно';
              }).join(', ');

              return ListTile(
                title: Text(t.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (t.phone != null && t.phone!.isNotEmpty) Text(t.phone!),
                    Text(tSubjectNames.isEmpty ? 'Нет предметов' : tSubjectNames, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(t.isActive ? 'Активен' : 'Неактивен', style: TextStyle(color: t.isActive ? AppTheme.successColor : AppTheme.errorColor, fontSize: 12)),
                  ],
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: AppTheme.accent), onPressed: () => _showTeacherDialog(context, ref, teacher: t, allSubjects: allSubjects)),
                    IconButton(icon: const Icon(Icons.delete, color: AppTheme.errorColor), onPressed: () => _deleteTeacher(context, ref, t)),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_teachers',
        onPressed: () => _showTeacherDialog(context, ref, allSubjects: allSubjects),
        child: const Icon(Icons.add),
      ),
    );
  }
}
