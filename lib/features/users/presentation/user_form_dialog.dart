import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../authentication/domain/user.dart';
import '../../role/domain/role.dart';
import '../../society/domain/flat.dart';
import '../../society/domain/society.dart';

class UserFormData {
  final User user;
  final String temporaryPassword;

  const UserFormData({
    required this.user,
    required this.temporaryPassword,
  });
}

class UserFormDialog extends StatefulWidget {
  final bool isSuperAdmin;
  final List<Society> societies;
  final Society? currentSociety;
  final List<Flat> availableFlats;
  final List<User> existingUsers;
  final String Function(String city) generateUserId;

  const UserFormDialog({
    super.key,
    required this.isSuperAdmin,
    required this.societies,
    required this.currentSociety,
    required this.availableFlats,
    required this.existingUsers,
    required this.generateUserId,
  });

  static Future<UserFormData?> show(
    BuildContext context, {
    required bool isSuperAdmin,
    required List<Society> societies,
    required Society? currentSociety,
    required List<Flat> availableFlats,
    required List<User> existingUsers,
    required String Function(String city) generateUserId,
  }) {
    return showDialog<UserFormData>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UserFormDialog(
        isSuperAdmin: isSuperAdmin,
        societies: societies,
        currentSociety: currentSociety,
        availableFlats: availableFlats,
        existingUsers: existingUsers,
        generateUserId: generateUserId,
      ),
    );
  }

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  late Role _selectedRole;
  late Society? _selectedSociety;
  String? _selectedFlatId;
  String? _generatedUserId;

  @override
  void initState() {
    super.initState();
    _selectedSociety = widget.currentSociety ??
        (widget.societies.isNotEmpty ? widget.societies.first : null);

    _selectedRole = widget.isSuperAdmin ? Role.societyAdmin : Role.resident;

    _updateGeneratedUserId();
    _mobileController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  void _updateGeneratedUserId() {
    final city = _selectedSociety?.city ?? 'SOC';
    _generatedUserId = widget.generateUserId(city);
  }

  @override
  void dispose() {
    _mobileController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  List<Role> get _allowedRoles {
    if (widget.isSuperAdmin) {
      return [
        Role.societyAdmin,
        Role.committeeMember,
        Role.resident,
        Role.security,
        Role.staff,
      ];
    }
    return [
      Role.resident,
      Role.committeeMember,
      Role.security,
      Role.staff,
    ];
  }

  List<Flat> get _unassignedFlats {
    if (_selectedSociety == null) return [];
    final assignedFlatIds = widget.existingUsers
        .where((u) => u.societyId == _selectedSociety!.id && u.flatId != null)
        .map((u) => u.flatId!)
        .toSet();

    return widget.availableFlats
        .where((f) => f.societyId == _selectedSociety!.id && !assignedFlatIds.contains(f.id))
        .toList();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSociety == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a society for this user')),
      );
      return;
    }

    final mobile = _mobileController.text.trim();
    // Validate unique mobile number among existing users
    final duplicate = widget.existingUsers.any((u) => u.mobile == mobile);
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A user with this mobile number (username) already exists.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Flat? assignedFlat;
    if (_selectedRole == Role.resident && _selectedFlatId != null) {
      final matches = widget.availableFlats.where((f) => f.id == _selectedFlatId);
      if (matches.isNotEmpty) assignedFlat = matches.first;
    }

    final tempPassword = 'Welcome@$mobile';

    final newUser = User(
      id: _generatedUserId ?? 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      mobile: mobile,
      email: _emailController.text.trim(),
      role: _selectedRole,
      societyId: _selectedSociety!.id,
      societyName: _selectedSociety!.name,
      flatId: assignedFlat?.id,
      flatNumber: assignedFlat?.flatNumber,
      mustChangePassword: true,
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop(UserFormData(
      user: newUser,
      temporaryPassword: tempPassword,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogWidth = (MediaQuery.sizeOf(context).width - 48).clamp(320.0, 520.0);
    final mobileText = _mobileController.text.trim();
    final tempPasswordPreview = mobileText.isNotEmpty ? 'Welcome@$mobileText' : 'Welcome@<mobile>';

    return AlertDialog(
      title: Text(widget.isSuperAdmin ? 'Provision User / Admin' : 'Add Society Member'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informational credential preview box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.key_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Auto-Generated Credentials',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Change on 1st Login: YES',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('User ID: ${_generatedUserId ?? "Generating..."}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text('Username: ${mobileText.isNotEmpty ? mobileText : "(Mobile number)"}', style: const TextStyle(fontSize: 11)),
                      Text('Temporary Password: $tempPasswordPreview', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Society Selector
                if (widget.isSuperAdmin) ...[
                  Text('Assign to Society', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedSociety?.id,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    items: widget.societies.map((s) {
                      return DropdownMenuItem(value: s.id, child: Text(s.name));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        final found = widget.societies.where((s) => s.id == val);
                        if (found.isNotEmpty) {
                          _selectedSociety = found.first;
                          _selectedFlatId = null;
                          _updateGeneratedUserId();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDarkHigher : AppColors.slate100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.apartment_rounded, size: 16, color: AppColors.slate500),
                        const SizedBox(width: 8),
                        Text('Society: ${_selectedSociety?.name ?? "Current Society"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Role Selector
                Text('User Role', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<Role>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  items: _allowedRoles.map((r) {
                    return DropdownMenuItem(value: r, child: Text(r.displayName));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRole = val;
                        if (_selectedRole != Role.resident) _selectedFlatId = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Flat Assignment (Conditional for Residents)
                if (_selectedRole == Role.resident) ...[
                  Text('Assign Flat (Exclusive)', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedFlatId,
                    decoration: const InputDecoration(
                      hintText: 'Select unallocated flat',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    items: _unassignedFlats.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text('${f.flatNumber} (${f.flatType.displayName})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedFlatId = val),
                    validator: (val) {
                      if (_selectedRole == Role.resident && (val == null || val.isEmpty)) {
                        return 'Please allocate a flat to this resident';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _unassignedFlats.isEmpty
                        ? 'Notice: No vacant/unassigned flats available in this society.'
                        : '${_unassignedFlats.length} unassigned flat(s) available for allocation.',
                    style: TextStyle(
                      fontSize: 11,
                      color: _unassignedFlats.isEmpty ? AppColors.error : AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Full Name
                AppTextField(
                  key: const Key('user_name_field'),
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'e.g. Rajesh Sharma',
                  prefixIcon: Icons.badge_outlined,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),

                // Mobile Number (Username)
                AppTextField(
                  key: const Key('user_mobile_field'),
                  controller: _mobileController,
                  label: 'Mobile Number (Primary Username)',
                  hint: 'e.g. 9876543210',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android_rounded,
                  validator: (v) => Validators.phone(v, 'Mobile number'),
                ),
                const SizedBox(height: 16),

                // Email Address
                AppTextField(
                  key: const Key('user_email_field'),
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'e.g. rajesh@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
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
          key: const Key('user_submit_button'),
          text: 'Provision User',
          onPressed: _submit,
        ),
      ],
    );
  }
}

class UserCreatedSuccessDialog extends StatelessWidget {
  final User user;
  final String temporaryPassword;

  const UserCreatedSuccessDialog({
    super.key,
    required this.user,
    required this.temporaryPassword,
  });

  static Future<void> show(
    BuildContext context, {
    required User user,
    required String temporaryPassword,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UserCreatedSuccessDialog(
        user: user,
        temporaryPassword: temporaryPassword,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 10),
          const Text('User Provisioned!'),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Account provisioned successfully with mandatory password change enabled upon first login.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDarkCard : AppColors.slate100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('User ID', user.id),
                  _infoRow('Full Name', user.name),
                  _infoRow('Username (Mobile)', user.mobile),
                  _infoRow('Email', user.email),
                  _infoRow('Role', user.role.displayName),
                  _infoRow('Society', user.societyName),
                  if (user.flatNumber != null) _infoRow('Allocated Flat', user.flatNumber!),
                  const Divider(height: 16),
                  _infoRow('Temporary Password', temporaryPassword, isBold: true, color: AppColors.primary),
                  _infoRow('Must Change Password', 'YES (Mandatory on 1st login)', color: AppColors.goldDark),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      actions: [
        AppButton(
          text: 'Copy Credentials',
          variant: AppButtonVariant.secondary,
          icon: Icons.copy_rounded,
          onPressed: () {
            Clipboard.setData(ClipboardData(
              text: 'Society: ${user.societyName}\nUser ID: ${user.id}\nUsername: ${user.mobile}\nPassword: $temporaryPassword\nLogin URL: http://localhost:8080',
            ));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Credentials copied to clipboard!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
        AppButton(
          text: 'Done',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
