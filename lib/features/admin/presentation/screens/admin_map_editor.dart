import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/timely_button.dart';
import '../../../../core/widgets/timely_input.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/utils/room_utils.dart';
import '../../../map/domain/entities/room.dart';
import '../providers/admin_provider.dart';

class AdminMapEditor extends ConsumerStatefulWidget {
  final Room? room; // Null if creating new

  const AdminMapEditor({super.key, this.room});

  @override
  ConsumerState<AdminMapEditor> createState() => _AdminMapEditorState();
}

class _AdminMapEditorState extends ConsumerState<AdminMapEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _descController;
  
  double _lat = 0.0;
  double _lng = 0.0;
  String _selectedBuilding = 'C1';
  int _selectedFloor = 1;
  String _selectedSector = 'C1.1'; // C1.1, C1.2, C1.3, OTHER

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.room?.shortCode ?? widget.room?.code ?? '');
    _descController = TextEditingController(text: widget.room?.description ?? '');
    _lat = widget.room?.lat ?? 0.5; // Default center
    _lng = widget.room?.lng ?? 0.5;
    _selectedBuilding = widget.room?.building ?? 'C1';
    _selectedFloor = widget.room?.floor ?? 1;
    _selectedSector = widget.room?.sector != null && widget.room!.sector.isNotEmpty ? widget.room!.sector : 'C1.1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.room == null ? 'Добавить аудиторию' : 'Редактировать аудиторию')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                   Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSector,
                      items: [
                        const DropdownMenuItem(value: 'C1.1', child: Text('C1.1 (Лево)')),
                        const DropdownMenuItem(value: 'C1.2', child: Text('C1.2 (Центр)')),
                        const DropdownMenuItem(value: 'C1.3', child: Text('C1.3 (Право)')),
                        const DropdownMenuItem(value: 'OTHER', child: Text('Другое')),
                      ],
                      onChanged: (v) => setState(() => _selectedSector = v!),
                      decoration: const InputDecoration(labelText: 'Сектор', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: TimelyInput(controller: _codeController, label: 'Номер (Код)'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TimelyInput(controller: _descController, label: 'Описание'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBuilding,
                      items: ['C1', 'C2'].map((e) => DropdownMenuItem(value: e, child: Text('Корпус $e'))).toList(),
                      onChanged: (v) => setState(() => _selectedBuilding = v!),
                      decoration: const InputDecoration(labelText: 'Корпус', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedFloor,
                      items: [1, 2, 3].map((e) => DropdownMenuItem(value: e, child: Text('$e этаж'))).toList(),
                      onChanged: (v) => setState(() {
                        _selectedFloor = v!;
                      }),
                      decoration: const InputDecoration(labelText: 'Этаж', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Укажите расположение на карте:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // Map Picker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: AspectRatio(
                  aspectRatio: 16/10,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      String assetPath = _selectedFloor == 1
                          ? 'lib/assets/первый.png'
                          : _selectedFloor == 2
                              ? 'lib/assets/второй.png'
                              : 'lib/assets/третий.png';
                      return GestureDetector(
                        onTapDown: (details) {
                          setState(() {
                            _lat = details.localPosition.dx / constraints.maxWidth;
                            _lng = details.localPosition.dy / constraints.maxHeight;
                          });
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              assetPath,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                            // Marker
                            Align(
                              alignment: FractionalOffset(_lat.clamp(0.0, 1.0), _lng.clamp(0.0, 1.0)),
                              child: Transform.translate(
                                offset: const Offset(-15, -30),
                                child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Lat: ${_lat.toStringAsFixed(2)}, Lng: ${_lng.toStringAsFixed(2)}'),
              
              const SizedBox(height: 32),
              TimelyButton(
                title: 'Сохранить',
                onPressed: _saveRoom,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveRoom() {
    if (_formKey.currentState!.validate()) {
      final codeRaw = _codeController.text.trim();
      if (codeRaw.isEmpty) {
        AppToast.error(context, 'Укажите номер аудитории');
        return;
      }
      
      final sector = _selectedSector == 'OTHER' ? '' : _selectedSector;
      final fullCode = RoomCodeNormalizer.toFullCode(codeRaw, requiredSector: sector);
      final shortCode = RoomCodeNormalizer.extractShortCode(fullCode);

      final data = {
        'code': fullCode, // backend currently maps `code` basically
        'fullCode': fullCode,
        'shortCode': shortCode,
        'sector': sector,
        'description': _descController.text.trim(),
        'building': _selectedBuilding,
        'floor': _selectedFloor,
        'positionX': _lat,
        'positionY': _lng,
      };

      if (widget.room == null) {
        ref.read(adminRoomsProvider.notifier).create(data);
      } else {
        ref.read(adminRoomsProvider.notifier).update(widget.room!.id, data);
      }
      
      Navigator.pop(context);
    }
  }
}
