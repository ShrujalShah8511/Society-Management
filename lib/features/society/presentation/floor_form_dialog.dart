import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/floor.dart';
import '../domain/tower.dart';

class FloorFormDialog extends StatefulWidget {
  final Floor? floor;
  final String towerName;

  const FloorFormDialog({super.key, this.floor, required this.towerName});

  static Future<Floor?> show(BuildContext context, {Floor? floor, required String towerName}) {
    return showDialog<Floor>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FloorFormDialog(floor: floor, towerName: towerName),
    );
  }

  @override
  State<FloorFormDialog> createState() => _FloorFormDialogState();
}

class _FloorFormDialogState extends State<FloorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberController;
  late TextEditingController _nameController;
  late TowerStatus _status;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(
        text: widget.floor != null ? widget.floor!.floorNumber.toString() : '');
    _nameController = TextEditingController(text: widget.floor?.displayName ?? '');
    _status = widget.floor?.status ?? TowerStatus.active;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final floorNum = int.parse(_numberController.text.trim());
    if (widget.floor != null) {
      final updated = widget.floor!.copyWith(
        floorNumber: floorNum,
        displayName: _nameController.text.trim(),
        status: _status,
      );
      Navigator.of(context).pop(updated);
    } else {
      final created = Floor(
        id: '',
        societyId: '',
        towerId: '',
        floorNumber: floorNum,
        displayName: _nameController.text.trim(),
        status: _status,
        createdAt: DateTime.now(),
      );
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.floor != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Floor' : 'Add Floor to ${widget.towerName}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  key: const Key('floor_number_field'),
                  controller: _numberController,
                  label: 'Floor Number',
                  hint: 'e.g. 1, 2, 3...',
                  keyboardType: TextInputType.number,
                  validator: (val) => Validators.positiveInt(val, 'Floor number'),
                  onChanged: (val) {
                    if (!isEditing && _nameController.text.isEmpty && val.isNotEmpty) {
                      _nameController.text = 'Floor $val';
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  key: const Key('floor_display_name_field'),
                  controller: _nameController,
                  label: 'Display Name',
                  hint: 'e.g. Floor 1 or Ground Floor',
                  validator: Validators.required,
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
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
          key: const Key('floor_submit_button'),
          text: isEditing ? 'Save Changes' : 'Create Floor',
          onPressed: _submit,
        ),
      ],
    );
  }
}
