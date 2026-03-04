import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/subject.dart';
import '../providers/admin_provider.dart';

class AdminSubjectsList extends ConsumerWidget {
  const AdminSubjectsList({super.key});

  void _showSubjectDialog(BuildContext context, WidgetRef ref, {Subject? subject}) {
    final nameCtrl = TextEditingController(text: subject?.name);
    final shortCtrl = TextEditingController(text: subject?.shortName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(subject == null ? 'Новый предмет' : 'Редактировать предмет'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Название *'),
                validator: (v) => v!.isEmpty ? 'Обязательно' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: shortCtrl,
                decoration: const InputDecoration(labelText: 'Сокращение (опц)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final data = {
                  'name': nameCtrl.text.trim(),
                  'shortName': shortCtrl.text.trim(),
                };
                if (subject == null) {
                  ref.read(adminSubjectsProvider.notifier).create(data);
                } else {
                  ref.read(adminSubjectsProvider.notifier).update(subject.id!, data);
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _deleteSubject(BuildContext context, WidgetRef ref, Subject subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить предмет?'),
        content: Text('Удалить ${subject.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              ref.read(adminSubjectsProvider.notifier).delete(subject.id!);
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
    final subjectsAsync = ref.watch(adminSubjectsProvider);

    return Scaffold(
      body: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) return const Center(child: Text('Нет предметов'));
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (ctx, i) {
              final s = subjects[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.surfaceColor,
                    child: Icon(Icons.book, color: AppTheme.accent),
                  ),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(s.shortName ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: AppTheme.accent), onPressed: () => _showSubjectDialog(context, ref, subject: s)),
                      IconButton(icon: const Icon(Icons.delete, color: AppTheme.errorColor), onPressed: () => _deleteSubject(context, ref, s)),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_subjects',
        onPressed: () => _showSubjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
