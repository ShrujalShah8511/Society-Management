import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/flat.dart';
import '../domain/tower.dart';

class TowerFormData {
  final Tower tower;
  final bool autogenerateFlats;
  final int flatsPerFloor;
  final FlatType flatType;
  final String flatPrefix;
  final double areaSqFt;

  const TowerFormData({
    required this.tower,
    this.autogenerateFlats = false,
    this.flatsPerFloor = 3,
    this.flatType = FlatType.twoBhk,
    this.flatPrefix = '',
    this.areaSqFt = 0.0,
  });
}

class TowerFormDialog extends StatefulWidget {
  final Tower? tower;

  const TowerFormDialog({super.key, this.tower});

  static Future<TowerFormData?> show(BuildContext context, {Tower? tower}) {
    return showDialog<TowerFormData>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TowerFormDialog(tower: tower),
    );
  }

  @override
  State<TowerFormDialog> createState() => _TowerFormDialogState();
}

class _TowerFormDialogState extends State<TowerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _floorsController;
  late TextEditingController _flatsPerFloorController;
  late TextEditingController _flatPrefixController;
  late TextEditingController _areaController;
  late TowerStatus _status;
  bool _autogenerateFlats = true;
  FlatType _defaultFlatType = FlatType.twoBhk;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.tower != null;
    _nameController = TextEditingController(text: widget.tower?.name ?? '');
    _descController = TextEditingController(text: widget.tower?.displayDescription ?? '');
    _floorsController = TextEditingController(
        text: isEditing ? widget.tower!.floorCount.toString() : '5');
    _flatsPerFloorController = TextEditingController(
        text: isEditing ? widget.tower!.flatsPerFloor.toString() : '3');
    _flatPrefixController = TextEditingController();
    _areaController = TextEditingController();
    _status = widget.tower?.status ?? TowerStatus.active;

    _nameController.addListener(_onNameChanged);
    _floorsController.addListener(_onFieldChanged);
    _flatsPerFloorController.addListener(_onFieldChanged);
    _flatPrefixController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  void _onNameChanged() {
    if (widget.tower == null) {
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        final parts = name.split(RegExp(r'\s+'));
        final last = parts.last;
        if (last.length <= 2) {
          _flatPrefixController.text = '${last.toUpperCase()}-';
        } else {
          _flatPrefixController.text = '${name[0].toUpperCase()}-';
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _floorsController.removeListener(_onFieldChanged);
    _flatsPerFloorController.removeListener(_onFieldChanged);
    _flatPrefixController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _descController.dispose();
    _floorsController.dispose();
    _flatsPerFloorController.dispose();
    _flatPrefixController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  List<String> _getPreviewFlatNumbers() {
    final floorCount = int.tryParse(_floorsController.text.trim()) ?? 0;
    final flatsPerFloor = int.tryParse(_flatsPerFloorController.text.trim()) ?? 0;
    if (floorCount <= 0 || flatsPerFloor <= 0) return [];

    final prefix = _flatPrefixController.text.trim();
    final list = <String>[];
    for (int f = 1; f <= floorCount; f++) {
      for (int i = 1; i <= flatsPerFloor; i++) {
        list.add('$prefix${f * 100 + i}');
      }
    }
    return list;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final floorCount = int.tryParse(_floorsController.text.trim()) ?? 1;
    final flatsPerFloor = int.tryParse(_flatsPerFloorController.text.trim()) ?? 3;
    final flatPrefix = _flatPrefixController.text.trim();
    final areaText = _areaController.text.trim();
    final area = areaText.isNotEmpty ? (double.tryParse(areaText) ?? 0.0) : 0.0;

    final tower = widget.tower != null
        ? widget.tower!.copyWith(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            floorCount: floorCount,
            flatsPerFloor: flatsPerFloor,
            status: _status,
          )
        : Tower(
            id: '',
            societyId: '',
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            floorCount: floorCount,
            flatsPerFloor: flatsPerFloor,
            status: _status,
            createdAt: DateTime.now(),
          );

    Navigator.of(context).pop(TowerFormData(
      tower: tower,
      autogenerateFlats: widget.tower == null && _autogenerateFlats,
      flatsPerFloor: flatsPerFloor,
      flatType: _defaultFlatType,
      flatPrefix: flatPrefix,
      areaSqFt: area,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tower != null;
    final dialogWidth = (MediaQuery.sizeOf(context).width - 48).clamp(320.0, 480.0);
    final previewList = _getPreviewFlatNumbers();
    final totalToGenerate = previewList.length;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Tower' : 'Add New Tower'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  key: const Key('tower_name_field'),
                  controller: _nameController,
                  label: 'Tower Name / Number',
                  hint: 'e.g. Block A or Aster',
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  key: const Key('tower_description_field'),
                  controller: _descController,
                  label: 'Description',
                  hint: 'e.g. Main residential wing',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        key: const Key('tower_floors_field'),
                        controller: _floorsController,
                        label: 'Number of Floors',
                        hint: 'e.g. 10',
                        keyboardType: TextInputType.number,
                        validator: (val) => Validators.positiveInt(val, 'Floors count'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        key: const Key('tower_flats_per_floor_field'),
                        controller: _flatsPerFloorController,
                        label: 'Flats Per Floor',
                        hint: 'e.g. 3',
                        keyboardType: TextInputType.number,
                        validator: (val) => Validators.positiveInt(val, 'Flats per floor'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<TowerStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: TowerStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _status = val;
                      });
                    }
                  },
                ),

                // Autogenerate Flats Section (only for new towers)
                if (!isEditing) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Auto-generate Flats on Creation',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            Switch.adaptive(
                              value: _autogenerateFlats,
                              onChanged: (val) => setState(() => _autogenerateFlats = val),
                            ),
                          ],
                        ),
                        if (_autogenerateFlats) ...[
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Flat Type', style: Theme.of(context).textTheme.labelMedium),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<FlatType>(
                                value: _defaultFlatType,
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                                items: FlatType.values.map((t) {
                                  return DropdownMenuItem(value: t, child: Text(t.displayName));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _defaultFlatType = val);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppTextField(
                                  key: const Key('flat_prefix_field'),
                                  controller: _flatPrefixController,
                                  label: 'Prefix (Optional)',
                                  hint: 'e.g. A-',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  key: const Key('tower_flat_area_field'),
                                  controller: _areaController,
                                  label: 'Area (Optional)',
                                  hint: 'e.g. 1150',
                                  keyboardType: TextInputType.number,
                                  validator: (val) {
                                    if (!_autogenerateFlats) return null;
                                    return Validators.optionalPositiveDouble(val, 'Area');
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Example: Prefix "A-" with 3 flats on Floor 1 generates A-101, A-102, A-103',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                          ),
                          const SizedBox(height: 12),
                          // Live Summary Preview Banner
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Summary Preview',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$totalToGenerate Flats Total',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (previewList.isEmpty)
                                  Text(
                                    'Configure floors and flats per floor to preview generation.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  )
                                else ...[
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      ...previewList.take(8).map((flatNo) => Chip(
                                            label: Text(flatNo, style: const TextStyle(fontSize: 11)),
                                            visualDensity: VisualDensity.compact,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            padding: EdgeInsets.zero,
                                          )),
                                      if (previewList.length > 8)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            '+${previewList.length - 8} more',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
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
          key: const Key('tower_submit_button'),
          text: isEditing
              ? 'Save Changes'
              : (_autogenerateFlats && totalToGenerate > 0
                  ? '✨ Create Tower & Generate $totalToGenerate Flats'
                  : 'Create Tower'),
          onPressed: _submit,
        ),
      ],
    );
  }
}
