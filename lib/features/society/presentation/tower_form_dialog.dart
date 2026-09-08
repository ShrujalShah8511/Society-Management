import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/tower.dart';

class TowerFormDialog extends StatefulWidget {
  final Tower? tower;

  const TowerFormDialog({super.key, this.tower});

  static Future<Tower?> show(BuildContext context, {Tower? tower}) {
    return showDialog<Tower>(
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
  late TowerStatus _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tower?.name ?? '');
    _descController = TextEditingController(text: widget.tower?.description ?? '');
    _floorsController = TextEditingController(
        text: widget.tower != null ? widget.tower!.floorCount.toString() : '1');
    _status = widget.tower?.status ?? TowerStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _floorsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final floorCount = int.parse(_floorsController.text.trim());
    if (widget.tower != null) {
      final updated = widget.tower!.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        floorCount: floorCount,
        status: _status,
      );
      Navigator.of(context).pop(updated);
    } else {
      final created = Tower(
        id: '', // Will be assigned by repository
        societyId: '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        floorCount: floorCount,
        status: _status,
        createdAt: DateTime.now(),
      );
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tower != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Tower' : 'Add New Tower'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
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
                  hint: 'e.g. Tower A or Aster',
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
                AppTextField(
                  key: const Key('tower_floors_field'),
                  controller: _floorsController,
                  label: 'Number of Floors',
                  hint: 'e.g. 10',
                  keyboardType: TextInputType.number,
                  validator: (val) => Validators.positiveInt(val, 'Number of floors'),
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
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
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
          key: const Key('tower_submit_button'),
          text: isEditing ? 'Save Changes' : 'Create Tower',
          onPressed: _submit,
        ),
      ],
    );
  }
}
