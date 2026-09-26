import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/flat.dart';
import '../domain/floor.dart';
import '../domain/tower.dart';

class FlatFormDialog extends StatefulWidget {
  final Flat? flat;
  final List<Tower> towers;
  final List<Floor> floors;

  const FlatFormDialog({
    super.key,
    this.flat,
    required this.towers,
    required this.floors,
  });

  static Future<Flat?> show(
    BuildContext context, {
    Flat? flat,
    required List<Tower> towers,
    required List<Floor> floors,
  }) {
    return showDialog<Flat>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FlatFormDialog(
        flat: flat,
        towers: towers,
        floors: floors,
      ),
    );
  }

  @override
  State<FlatFormDialog> createState() => _FlatFormDialogState();
}

class _FlatFormDialogState extends State<FlatFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedTowerId;
  late String? _selectedFloorId;
  late TextEditingController _numberController;
  late TextEditingController _areaController;
  late FlatType _flatType;
  late OccupancyStatus _occupancyStatus;

  @override
  void initState() {
    super.initState();
    _selectedTowerId = widget.flat?.towerId ??
        (widget.towers.isNotEmpty ? widget.towers.first.id : null);

    final availableFloors = _getFloorsForTower(_selectedTowerId);
    _selectedFloorId = widget.flat?.floorId ??
        (availableFloors.isNotEmpty ? availableFloors.first.id : null);

    _numberController = TextEditingController(text: widget.flat?.flatNumber ?? '');
    _areaController = TextEditingController(
        text: widget.flat != null ? widget.flat!.areaSqFt.toStringAsFixed(0) : '1000');
    _flatType = widget.flat?.flatType ?? FlatType.twoBhk;
    _occupancyStatus = widget.flat?.occupancyStatus ?? OccupancyStatus.vacant;
  }

  List<Floor> _getFloorsForTower(String? towerId) {
    if (towerId == null) return [];
    return widget.floors.where((f) => f.towerId == towerId).toList();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTowerId == null || _selectedFloorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid tower and floor')),
      );
      return;
    }

    final area = double.tryParse(_areaController.text.trim()) ?? 1000.0;
    if (widget.flat != null) {
      final updated = widget.flat!.copyWith(
        towerId: _selectedTowerId!,
        floorId: _selectedFloorId!,
        flatNumber: _numberController.text.trim(),
        flatType: _flatType,
        areaSqFt: area,
        occupancyStatus: _occupancyStatus,
      );
      Navigator.of(context).pop(updated);
    } else {
      final created = Flat(
        id: 'flt-${DateTime.now().millisecondsSinceEpoch}',
        societyId: AppConstants.defaultSocietyId,
        towerId: _selectedTowerId!,
        floorId: _selectedFloorId!,
        flatNumber: _numberController.text.trim(),
        flatType: _flatType,
        areaSqFt: area,
        occupancyStatus: _occupancyStatus,
        createdAt: DateTime.now(),
      );
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.flat != null;
    final availableFloors = _getFloorsForTower(_selectedTowerId);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Flat' : 'Add New Flat'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tower & Floor Pickers
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 380;
                    final towerField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tower', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedTowerId,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          items: widget.towers.map((t) {
                            return DropdownMenuItem(value: t.id, child: Text(t.name));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedTowerId = val;
                              final newFloors = _getFloorsForTower(val);
                              _selectedFloorId = newFloors.isNotEmpty ? newFloors.first.id : null;
                            });
                          },
                        ),
                      ],
                    );

                    final floorField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Floor', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedFloorId,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          items: availableFloors.map((f) {
                            return DropdownMenuItem(value: f.id, child: Text(f.displayName));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedFloorId = val;
                            });
                          },
                        ),
                      ],
                    );

                    if (isCompact) {
                      return Column(
                        children: [
                          towerField,
                          const SizedBox(height: 14),
                          floorField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: towerField),
                        const SizedBox(width: 14),
                        Expanded(child: floorField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Flat Number
                AppTextField(
                  key: const Key('flat_number_field'),
                  controller: _numberController,
                  label: 'Flat Number',
                  hint: 'e.g. A-101, B-402',
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),

                // Flat Type & Area
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 380;
                    final flatTypeField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Flat Type', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<FlatType>(
                          value: _flatType,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          items: FlatType.values.map((t) {
                            return DropdownMenuItem(value: t, child: Text(t.displayName));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _flatType = val);
                          },
                        ),
                      ],
                    );

                    final areaField = AppTextField(
                      key: const Key('flat_area_field'),
                      controller: _areaController,
                      label: 'Area (sq. ft.)',
                      hint: 'e.g. 1150',
                      keyboardType: TextInputType.number,
                      validator: (val) => Validators.positiveDouble(val, 'Area'),
                    );

                    if (isCompact) {
                      return Column(
                        children: [
                          flatTypeField,
                          const SizedBox(height: 14),
                          areaField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: flatTypeField),
                        const SizedBox(width: 14),
                        Expanded(child: areaField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Occupancy Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Occupancy Status', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<OccupancyStatus>(
                      value: _occupancyStatus,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      items: OccupancyStatus.values.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.displayName));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _occupancyStatus = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      actions: [
        AppButton(
          text: 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          key: const Key('flat_submit_button'),
          text: isEditing ? 'Save Changes' : 'Create Flat',
          onPressed: _submit,
        ),
      ],
    );
  }
}
