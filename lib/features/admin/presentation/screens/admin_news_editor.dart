import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/timely_button.dart';
import '../../../../core/widgets/timely_input.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../notification_service.dart';
import '../../../news/domain/entities/news_item.dart';
import '../../../news/data/news_repository.dart';
import '../../../news/presentation/providers/news_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';

import '../../../../core/widgets/app_toast.dart';

class AdminNewsEditor extends ConsumerStatefulWidget {
  final NewsItem? news;

  const AdminNewsEditor({super.key, this.news});

  @override
  ConsumerState<AdminNewsEditor> createState() => _AdminNewsEditorState();
}

class _AdminNewsEditorState extends ConsumerState<AdminNewsEditor> {
  late TextEditingController _textController;
  bool _isPinned = false;
  String _category = 'Announcements';
  final List<String> _categories = ['Academic', 'Announcements', 'Events', 'Urgent'];
  XFile? _mediaFile;
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0;
  bool _removeMedia = false;
  bool _showPreview = false;

  // Push notification settings
  bool _sendPush = false;
  bool _pushImmediate = true;
  DateTime? _scheduledPushTime;

  @override
  void initState() {
    super.initState();
    final initialText = widget.news != null 
        ? (widget.news!.title.isNotEmpty ? '${widget.news!.title}\n\n${widget.news!.content}' : widget.news!.content)
        : '';
    _textController = TextEditingController(text: initialText);
    _isPinned = widget.news?.isPinned ?? false;
    _category = widget.news?.category ?? 'Announcements';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile;
    try {
      pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Не удалось открыть галерею');
      }
      return;
    }

    if (pickedFile == null) return;

    // Validate file size (50 MB max)
    final fileSizeMB = await pickedFile.length() / (1024 * 1024);
    if (fileSizeMB > 50) {
      if (mounted) {
        AppToast.error(context, 'Файл слишком большой (${fileSizeMB.toStringAsFixed(1)} МБ).\nМаксимум: 50 МБ');
      }
      return;
    }

    setState(() {
      _mediaFile = pickedFile;
      _removeMedia = false;
    });
  }

  Future<void> _selectScheduledTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time == null) return;

    setState(() {
      _scheduledPushTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  ({String title, String content}) _formatNews(String rawText) {
    if (rawText.trim().isEmpty) return (title: '', content: '');
    final lines = rawText.split('\n');
    final firstLine = lines.first.trim();
    if (firstLine.length <= 60 && lines.length > 1) {
      return (title: firstLine, content: lines.sublist(1).join('\n').trim());
    }
    
    final sentenceEnd = rawText.indexOf('. ');
    if (sentenceEnd != -1 && sentenceEnd <= 60) {
      return (
        title: rawText.substring(0, sentenceEnd + 1).trim(),
        content: rawText.substring(sentenceEnd + 1).trim()
      );
    }
    return (title: firstLine.length <= 60 ? firstLine : '${firstLine.substring(0, 57)}...', content: rawText.trim());
  }

  Future<void> _save(bool publish) async {
    final formatted = _formatNews(_textController.text);
    if (formatted.title.isEmpty && formatted.content.isEmpty) {
      AppToast.error(context, 'Введите текст новости');
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploading = _mediaFile != null;
      _uploadProgress = 0;
    });

    try {
      final repository = ref.read(newsRepositoryProvider);
      final l10n = ref.read(l10nProvider);

      void onProgress(int sent, int total) {
        if (total > 0 && mounted) {
          setState(() {
            _uploadProgress = sent / total;
            if (_uploadProgress >= 1.0) _isUploading = false;
          });
        }
      }

      if (widget.news == null) {
        await repository.createNews(
          title: formatted.title,
          content: formatted.content,
          isPublished: publish,
          category: _category,
          isPinned: _isPinned,
          media: _mediaFile,
          onProgress: onProgress,
        );
      } else {
        await repository.updateNews(
          widget.news!.id,
          title: formatted.title,
          content: formatted.content,
          isPublished: publish,
          category: _category,
          isPinned: _isPinned,
          media: _mediaFile,
          removeMedia: _removeMedia,
          onProgress: onProgress,
        );
      }

      // Handle push notification
      if (_sendPush && publish) {
        if (_pushImmediate) {
          await NotificationService().showNewsNotification(
            title: formatted.title,
            body: formatted.content.length > 100
                ? '${formatted.content.substring(0, 100)}...'
                : formatted.content,
            l10n: l10n,
          );
        } else if (_scheduledPushTime != null) {
          await NotificationService().scheduleNewsNotification(
            title: formatted.title,
            body: formatted.content.length > 100
                ? '${formatted.content.substring(0, 100)}...'
                : formatted.content,
            scheduledTime: _scheduledPushTime!,
            l10n: l10n,
          );
        }
      }

      ref.invalidate(adminNewsProvider);
      ref.invalidate(newsFeedProvider);

      if (mounted) {
        AppToast.success(context, widget.news == null ? 'Новость сохранена!' : 'Новость обновлена!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Ошибка: $e', onRetry: () => _save(publish));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showPreview) {
      return _buildPreview();
    }
    return _buildEditor();
  }

  Widget _buildEditor() {
    final baseUrl = AppConstants.baseUrl.replaceAll('/api', '');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.news == null ? 'Новая новость' : 'Редактирование',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton.icon(
            onPressed: _textController.text.isEmpty
                ? null
                : () => setState(() => _showPreview = true),
            icon: const Icon(Icons.preview_outlined, size: 18),
            label: const Text('Превью'),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content
                TimelyInput(
                  controller: _textController,
                  label: 'Текст новости',
                  hint: 'Первая короткая строка автоматически станет заголовком...',
                  prefixIcon: Icons.article_outlined,
                  maxLines: 15,
                ),
                const SizedBox(height: 24),

                // Publish & Metadata card
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.dividerColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Закрепить новость',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text(
                          'Новость будет всегда наверху ленты',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _isPinned,
                        onChanged: (v) => setState(() => _isPinned = v),
                        activeColor: AppTheme.accent,
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Text('Категория:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _category,
                                  isExpanded: true,
                                  items: _categories.map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat, style: const TextStyle(fontSize: 15)),
                                  )).toList(),
                                  onChanged: (v) {
                                    if (v != null) setState(() => _category = v);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Push notification settings
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.dividerColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Отправить уведомление',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          'Push-уведомление студентам',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        value: _sendPush,
                        onChanged: (v) => setState(() => _sendPush = v),
                        activeColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      if (_sendPush) ...[
                        const Divider(height: 1),
                        RadioListTile<bool>(
                          title: const Text('Отправить сразу'),
                          value: true,
                          groupValue: _pushImmediate,
                          onChanged: (v) =>
                              setState(() => _pushImmediate = v ?? true),
                          activeColor: AppTheme.accent,
                          dense: true,
                        ),
                        RadioListTile<bool>(
                          title: const Text('По расписанию'),
                          subtitle: _scheduledPushTime != null
                              ? Text(
                                  DateFormat('dd.MM.yyyy HH:mm')
                                      .format(_scheduledPushTime!),
                                  style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w600),
                                )
                              : null,
                          value: false,
                          groupValue: _pushImmediate,
                          onChanged: (v) async {
                            setState(() => _pushImmediate = false);
                            await _selectScheduledTime();
                          },
                          activeColor: AppTheme.accent,
                          dense: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Media section
                Text(
                  'МЕДИА',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                if (_mediaFile != null)
                  _MediaPreviewCard(
                    file: _mediaFile!,
                    onRemove: () => setState(() => _mediaFile = null),
                  )
                else if (widget.news?.mediaPath != null && !_removeMedia)
                  _MediaPreviewCard(
                    url: '$baseUrl${widget.news!.mediaPath!}',
                    onRemove: () => setState(() => _removeMedia = true),
                  )
                else
                  _AddMediaButton(onTap: _pickImage),

                // Upload progress
                if (_isUploading) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Загрузка... ${(_uploadProgress * 100).toInt()}%',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _uploadProgress,
                            backgroundColor:
                                AppTheme.dividerColor.withOpacity(0.3),
                            color: AppTheme.accent,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // Save buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: (_isLoading || _isUploading) ? null : () => _save(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: AppTheme.accent.withOpacity(0.5)),
                          ),
                        ),
                        child: const Text('В черновики', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accent)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TimelyButton(
                        title: widget.news == null
                            ? 'Опубликовать'
                            : 'Опубликовать правки',
                        isLoading: _isLoading,
                        onPressed: (_isLoading || _isUploading) ? null : () => _save(true),
                        icon: Icons.publish_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => setState(() => _showPreview = false),
        ),
        title: const Text('Предпросмотр',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton.icon(
            onPressed: () => _save(false),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('В черновики'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
          ),
          TextButton.icon(
            onPressed: () => _save(true),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Опубликовать'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.successColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status chips
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Предпросмотр',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (_sendPush)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_active_outlined,
                            size: 12, color: AppTheme.accent),
                        const SizedBox(width: 4),
                        Text(
                          _pushImmediate ? 'Пуш сразу' : 'Пуш по времени',
                          style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Author row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.accent, Color(0xFF7C3AED)],
                    ),
                  ),
                  child: const Center(
                    child: Text('A',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Администратор',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('Сейчас',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _formatNews(_textController.text).title.isEmpty
                  ? 'Заголовок...'
                  : _formatNews(_textController.text).title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _formatNews(_textController.text).title.isEmpty
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Text(
              _formatNews(_textController.text).content.isEmpty
                  ? 'Содержание...'
                  : _formatNews(_textController.text).content,
              style: TextStyle(
                fontSize: 15,
                color: _formatNews(_textController.text).content.isEmpty
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary.withOpacity(0.9),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),

            // Image preview
            if (_mediaFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: kIsWeb
                    ? Image.network(_mediaFile!.path,
                        fit: BoxFit.cover, width: double.infinity)
                    : Image.file(File(_mediaFile!.path),
                        fit: BoxFit.cover, width: double.infinity),
              )
            else if (widget.news?.mediaPath != null && !_removeMedia)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  '${AppConstants.baseUrl.replaceAll('/api', '')}${widget.news!.mediaPath!}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MediaPreviewCard extends StatelessWidget {
  final XFile? file;
  final String? url;
  final VoidCallback onRemove;

  const _MediaPreviewCard({this.file, this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.surfaceColor,
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
          ),
          clipBehavior: Clip.antiAlias,
          child: file != null
              ? (kIsWeb
                  ? Image.network(file!.path, fit: BoxFit.cover)
                  : Image.file(File(file!.path), fit: BoxFit.cover))
              : Image.network(url!, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
            child: IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 20),
              onPressed: onRemove,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddMediaButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMediaButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accent.withOpacity(0.3),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            color: AppTheme.accent.withOpacity(0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_a_photo_outlined,
                    color: AppTheme.accent, size: 24),
              ),
              const SizedBox(height: 12),
              const Text(
                'Добавить изображение',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'JPG, PNG, GIF, WEBP • до 50 МБ',
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
