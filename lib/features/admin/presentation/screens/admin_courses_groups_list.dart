import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/group.dart';
import '../providers/admin_provider.dart';

class AdminCoursesGroupsList extends ConsumerStatefulWidget {
  const AdminCoursesGroupsList({super.key});

  @override
  ConsumerState<AdminCoursesGroupsList> createState() => _AdminCoursesGroupsListState();
}

class _AdminCoursesGroupsListState extends ConsumerState<AdminCoursesGroupsList> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(text: 'Группы'),
            Tab(text: 'Курсы'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _GroupsTab(),
              _CoursesTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Groups Tab ─────────────────────────────────────────────────────────────

class _GroupsTab extends ConsumerWidget {
  const _GroupsTab();

  void _showGroupDialog(BuildContext context, WidgetRef ref, {Group? group}) {
    final codeCtrl = TextEditingController(text: group?.groupCode);
    final titleCtrl = TextEditingController(text: group?.title);
    final descCtrl = TextEditingController(text: group?.description);
    String? selectedCourseId = group?.courseId;
    int selectedShift = group?.shift ?? 1;
    bool isActive = group?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    // Load active courses directly from provider state
    final coursesList = ref.read(adminCoursesProvider).valueOrNull ?? [];
    final activeCourses = coursesList.where((c) => c.isActive).toList();

    // If we have an existing selectedCourseId but it's not in the active list, we might want to include it or just clear it.
    // For simplicity, let's just make sure it's valid:
    if (selectedCourseId != null && !activeCourses.any((c) => c.id == selectedCourseId)) {
       selectedCourseId = null;
    }
    // Auto-select first if empty and active courses exist
    if (selectedCourseId == null && activeCourses.isNotEmpty) {
       selectedCourseId = activeCourses.first.id;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(group == null ? 'Новая группа' : 'Редактировать группу'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Код группы * (Пр: CS-21)'),
                    validator: (v) => v!.isEmpty ? 'Обязательно' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Название (опц)'),
                  ),
                  const SizedBox(height: 8),
                  if (activeCourses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Нет активных курсов. Сначала создайте курс.', style: TextStyle(color: AppTheme.errorColor)),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedCourseId,
                      decoration: const InputDecoration(labelText: 'Курс *'),
                      items: activeCourses.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.number} курс ${c.title ?? ""}'.trim()))).toList(),
                      onChanged: (v) => setState(() => selectedCourseId = v),
                      validator: (v) => v == null ? 'Обязательно' : null,
                    ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedShift,
                    decoration: const InputDecoration(labelText: 'Смена'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 Смена')),
                      DropdownMenuItem(value: 2, child: Text('2 Смена')),
                    ],
                    onChanged: (v) => setState(() => selectedShift = v!),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Активна'),
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
                    'groupCode': codeCtrl.text.trim(),
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'courseId': selectedCourseId,
                    // If we have courseId, we can also send course number just in case the backend needs backward compat
                    'course': activeCourses.firstWhere((c) => c.id == selectedCourseId, orElse: () => activeCourses.first).number,
                    'shift': selectedShift,
                    'isActive': isActive,
                  };
                  if (group == null) {
                    ref.read(adminGroupsProvider.notifier).create(data);
                  } else {
                    ref.read(adminGroupsProvider.notifier).update(group.id!, data);
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

  void _deleteGroup(BuildContext context, WidgetRef ref, Group group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить группу?'),
        content: Text('Удалить ${group.groupCode}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              ref.read(adminGroupsProvider.notifier).delete(group.id!);
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
    final groupsAsync = ref.watch(adminGroupsProvider);

    return Scaffold(
      body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) return const Center(child: Text('Нет групп'));
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (ctx, i) {
              final g = groups[i];
              return ListTile(
                title: Text(g.groupCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${g.course} курс • ${g.shift} смена • ${g.isActive ? "Активна" : "Неактивна"}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: AppTheme.accent), onPressed: () => _showGroupDialog(context, ref, group: g)),
                    IconButton(icon: const Icon(Icons.delete, color: AppTheme.errorColor), onPressed: () => _deleteGroup(context, ref, g)),
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
        heroTag: 'fab_groups',
        onPressed: () => _showGroupDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Courses Tab ────────────────────────────────────────────────────────────

class _CoursesTab extends ConsumerWidget {
  const _CoursesTab();

  void _showCourseDialog(BuildContext context, WidgetRef ref, {Course? course}) {
    final numberCtrl = TextEditingController(text: course?.number.toString());
    final titleCtrl = TextEditingController(text: course?.title);
    bool isActive = course?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(course == null ? 'Новый курс' : 'Редактировать курс'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: numberCtrl,
                  decoration: const InputDecoration(labelText: 'Номер курса *(1-4)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Обязательно';
                    final n = int.tryParse(v);
                    if (n == null || n < 1 || n > 6) return 'От 1 до 6';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Название опционально'),
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
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'number': int.parse(numberCtrl.text.trim()),
                    'title': titleCtrl.text.trim(),
                    'isActive': isActive,
                  };
                  if (course == null) {
                    ref.read(adminCoursesProvider.notifier).create(data);
                  } else {
                    ref.read(adminCoursesProvider.notifier).update(course.id!, data);
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

  void _deleteCourse(BuildContext context, WidgetRef ref, Course course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить курс?'),
        content: Text('Удалить курс ${course.number}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              ref.read(adminCoursesProvider.notifier).delete(course.id!);
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
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Scaffold(
      body: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) return const Center(child: Text('Нет курсов'));
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (ctx, i) {
              final c = courses[i];
              return ListTile(
                title: Text('${c.number} Курс', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.isActive ? 'Активен' : 'Неактивен'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: AppTheme.accent), onPressed: () => _showCourseDialog(context, ref, course: c)),
                    IconButton(icon: const Icon(Icons.delete, color: AppTheme.errorColor), onPressed: () => _deleteCourse(context, ref, c)),
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
        heroTag: 'fab_courses',
        onPressed: () => _showCourseDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
