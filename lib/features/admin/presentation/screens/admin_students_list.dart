import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';
import '../providers/admin_provider.dart';

class AdminStudentsList extends ConsumerWidget {
  final String? status;
  final bool showActions;

  const AdminStudentsList({
    super.key,
    this.status,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(adminStudentsProvider(status));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text('Пользователи не найдены', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return _StudentCard(student: student, showActions: showActions, filterStatus: status);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Ошибка: $e', style: const TextStyle(color: AppTheme.errorColor))),
    );
  }
}

class _StudentCard extends ConsumerWidget {
  final User student;
  final bool showActions;
  final String? filterStatus;

  const _StudentCard({required this.student, required this.showActions, required this.filterStatus});

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отклонить заявку'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Причина (опционально)',
            hintText: 'Напр: Неверные данные',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              ref.read(adminStudentsProvider(filterStatus).notifier).reject(student.id, reason: controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Отклонить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: Text('Вы уверены, что хотите удалить ${student.fullName}? Это действие необратимо.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              ref.read(adminStudentsProvider(filterStatus).notifier).delete(student.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: student.fullName);
    final emailCtrl = TextEditingController(text: student.email);
    final phoneCtrl = TextEditingController(text: student.phone ?? '');
    final courseCtrl = TextEditingController(text: student.course?.toString() ?? '');
    final groupCtrl = TextEditingController(text: student.groupCode ?? '');
    final universityCtrl = TextEditingController(text: student.university ?? '');
    final facultyCtrl = TextEditingController(text: student.faculty ?? '');
    final specialtyCtrl = TextEditingController(text: student.specialty ?? '');
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Редактировать данные'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'ФИО'),
                        validator: (v) => v!.isEmpty ? 'Обязательное поле' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => v!.isEmpty || !v.contains('@') ? 'Неверный email' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Телефон'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: courseCtrl,
                        decoration: const InputDecoration(labelText: 'Курс (число)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: groupCtrl,
                        decoration: const InputDecoration(labelText: 'Группа (код)'),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.school_rounded, size: 16, color: AppTheme.accent),
                            SizedBox(width: 8),
                            Text('Академические данные', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: universityCtrl,
                        decoration: const InputDecoration(labelText: 'Учебное заведение'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: facultyCtrl,
                        decoration: const InputDecoration(labelText: 'Факультет'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: specialtyCtrl,
                        decoration: const InputDecoration(labelText: 'Специальность'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    setState(() => isLoading = true);
                    try {
                      await ref.read(adminStudentsProvider(filterStatus).notifier).updateStudent(student.id, {
                        'fullName': nameCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'course': int.tryParse(courseCtrl.text.trim()),
                        'groupCode': groupCtrl.text.trim(),
                        'university': universityCtrl.text.trim(),
                        'faculty': facultyCtrl.text.trim(),
                        'specialty': specialtyCtrl.text.trim(),
                      });
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные успешно обновлены', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.successColor));
                      }
                    } catch (e) {
                      setState(() => isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppTheme.errorColor));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                  child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Сохранить', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = student.status == 'PENDING';

    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
          child: Text(student.fullName[0].toUpperCase(), style: const TextStyle(color: AppTheme.accent)),
        ),
        title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${student.groupCode} • ${student.course} курс', style: const TextStyle(fontSize: 12)),
        trailing: _StatusBadge(status: student.status, isBlocked: student.isBlocked),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.email_outlined, label: 'Email', value: student.email),
                _InfoRow(icon: Icons.phone_outlined, label: 'Телефон', value: student.phone ?? 'Не указан'),
                if (student.status == 'REJECTED' && student.rejectReason != null)
                  _InfoRow(icon: Icons.warning_amber_rounded, label: 'Причина отказа', value: student.rejectReason!, color: AppTheme.errorColor),
                
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending) ...[
                      OutlinedButton(
                        onPressed: () => _showRejectDialog(context, ref),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor, side: const BorderSide(color: AppTheme.errorColor)),
                        child: const Text('Отклонить'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => ref.read(adminStudentsProvider(filterStatus).notifier).approve(student.id),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                        child: const Text('Одобрить'),
                      ),
                    ] else ...[
                      IconButton(
                        onPressed: () => _showEditDialog(context, ref),
                        icon: const Icon(Icons.edit_outlined, color: AppTheme.accent),
                        tooltip: 'Редактировать инфо',
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirm(context, ref),
                        icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                        tooltip: 'Удалить',
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => ref.read(adminStudentsProvider(filterStatus).notifier).toggleBlock(student.id, student.isBlocked),
                        icon: Icon(student.isBlocked ? Icons.lock_open_rounded : Icons.block_flipped),
                        label: Text(student.isBlocked ? 'Разблокировать' : 'Заблокировать'),
                        style: TextButton.styleFrom(foregroundColor: student.isBlocked ? AppTheme.successColor : AppTheme.warningColor),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isBlocked;

  const _StatusBadge({required this.status, required this.isBlocked});

  @override
  Widget build(BuildContext context) {
    if (isBlocked) {
      return _Badge(text: 'БАН', color: Colors.black, textColor: Colors.white);
    }
    switch (status) {
      case 'APPROVED': return const _Badge(text: 'ОДОБРЕНО', color: AppTheme.successColor);
      case 'REJECTED': return const _Badge(text: 'ОТКЛОНЕНО', color: AppTheme.errorColor);
      default: return const _Badge(text: 'ОЖИДАЕТ', color: AppTheme.warningColor);
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  const _Badge({required this.text, required this.color, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({required this.icon, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: color?.withOpacity(0.7) ?? AppTheme.textSecondary)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color))),
        ],
      ),
    );
  }
}
