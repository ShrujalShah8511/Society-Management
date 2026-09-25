import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_picker_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/society_logo_widget.dart';
import '../../../core/widgets/state_views.dart';
import '../../authentication/presentation/auth_notifier.dart';
import '../../role/domain/role.dart';
import '../domain/society.dart';
import 'active_society_provider.dart';
import 'society_profile_notifier.dart';

class SocietyProfileScreen extends ConsumerStatefulWidget {
  const SocietyProfileScreen({super.key});

  @override
  ConsumerState<SocietyProfileScreen> createState() => _SocietyProfileScreenState();
}

class _SocietyProfileScreenState extends ConsumerState<SocietyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _pinCodeController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _regNumberController;
  late TextEditingController _websiteController;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers([Society? society]) {
    _nameController = TextEditingController(text: society?.name ?? '');
    _addressController = TextEditingController(text: society?.address ?? '');
    _cityController = TextEditingController(text: society?.city ?? '');
    _stateController = TextEditingController(text: society?.state ?? '');
    _countryController = TextEditingController(text: society?.country ?? 'India');
    _pinCodeController = TextEditingController(text: society?.pinCode ?? '');
    _contactController = TextEditingController(text: society?.contactNumber ?? '');
    _emailController = TextEditingController(text: society?.email ?? '');
    _regNumberController = TextEditingController(text: society?.registrationNumber ?? '');
    _websiteController = TextEditingController(text: society?.website ?? '');
    _logoUrl = society?.logoUrl;
  }

  void _populateFromSociety(Society society) {
    _nameController.text = society.name;
    _addressController.text = society.address;
    _cityController.text = society.city;
    _stateController.text = society.state;
    _countryController.text = society.country;
    _pinCodeController.text = society.pinCode;
    _contactController.text = society.contactNumber;
    _emailController.text = society.email;
    _regNumberController.text = society.registrationNumber;
    _websiteController.text = society.website ?? '';
    _logoUrl = society.logoUrl;
  }

  String? _lastSyncedKey;

  void _syncControllersWithSociety(Society society) {
    final key = '${society.id}_${society.updatedAt.millisecondsSinceEpoch}_$_isEditing';
    if (!_isEditing && _lastSyncedKey != key) {
      _populateFromSociety(society);
      _lastSyncedKey = key;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pinCodeController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _regNumberController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(Society current) async {
    if (!_formKey.currentState!.validate()) return;

    final updated = current.copyWith(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      pinCode: _pinCodeController.text.trim(),
      contactNumber: _contactController.text.trim(),
      email: _emailController.text.trim(),
      registrationNumber: _regNumberController.text.trim(),
      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      logoUrl: _logoUrl,
    );

    final success = await ref
        .read(societyProfileNotifierProvider.notifier)
        .updateProfile(updated);

    if (success && mounted) {
      await ref.read(activeSocietyProvider.notifier).loadSocieties(preferredActiveId: updated.id);
      if (!mounted) return;
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Society profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _pickAndUploadLogo() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Society Logo Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.upload_file_rounded, color: AppColors.primary),
                title: const Text('Upload Image from Device'),
                subtitle: const Text('Select a PNG, JPG, or SVG from your device'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  try {
                    final picked = await FilePickerService.pickImage();
                    if (picked != null) {
                      setState(() {
                        _logoUrl = picked.dataUrl;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Logo "${picked.name}" selected! Click Save to apply.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error picking logo: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.link_rounded, color: AppColors.primary),
                title: const Text('Enter Image URL'),
                subtitle: const Text('Paste an image web URL or Data URI'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showLogoUrlInputDialog();
                },
              ),
              if (_logoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  title: const Text('Remove Logo', style: TextStyle(color: AppColors.error)),
                  subtitle: const Text('Reset to default platform monogram / icon'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _logoUrl = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logo removed. Click Save to apply.'),
                        backgroundColor: AppColors.slate700,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoUrlInputDialog() {
    final textController = TextEditingController(
      text: (_logoUrl != null && !_logoUrl!.startsWith('data:')) ? _logoUrl : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Logo Image URL'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/logo.png',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              setState(() {
                _logoUrl = text.isNotEmpty ? text : null;
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(societyProfileNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final userRole = authState.role;
    final canEdit = RolePermissions.canManageSociety(userRole);
    final isSuperAdmin = RolePermissions.canDeleteSociety(userRole);

    ref.listen<SocietyProfileState>(societyProfileNotifierProvider, (previous, next) {
      if (next.society != null && !_isEditing) {
        _syncControllersWithSociety(next.society!);
      }
    });

    if (state.isLoading && state.society == null) {
      return const LoadingView(message: 'Loading society profile...');
    }

    if (state.errorMessage != null && state.society == null) {
      return ErrorRetryView(
        message: state.errorMessage!,
        onRetry: () {
          final active = ref.read(activeSocietyProvider).activeSociety;
          ref.read(societyProfileNotifierProvider.notifier).loadProfile(active?.id);
        },
      );
    }

    final society = state.society;
    if (society == null) {
      return const EmptyStateView(
        title: 'No Society Found',
        message: 'No registered society profile exists.',
      );
    }

    _syncControllersWithSociety(society);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Society Profile'),
        actions: [
          if (canEdit && !_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: isMobile
                  ? IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Profile',
                      onPressed: () {
                        _populateFromSociety(society);
                        setState(() {
                          _isEditing = true;
                        });
                      },
                    )
                  : AppButton(
                      text: 'Edit Profile',
                      icon: Icons.edit_outlined,
                      variant: AppButtonVariant.outlined,
                      height: 38,
                      onPressed: () {
                        _populateFromSociety(society);
                        setState(() {
                          _isEditing = true;
                        });
                      },
                    ),
            ),
          if (_isEditing) ...[
            AppButton(
              text: 'Cancel',
              variant: AppButtonVariant.text,
              height: 38,
              onPressed: () {
                _populateFromSociety(society);
                setState(() {
                  _isEditing = false;
                });
              },
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: AppButton(
                text: 'Save',
                icon: Icons.save_outlined,
                height: 38,
                isLoading: state.isSaving,
                onPressed: () => _handleSave(society),
              ),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SocietyLogoWidget(
                            logoUrl: _logoUrl,
                            societyName: _nameController.text.isNotEmpty
                                ? _nameController.text
                                : society.name,
                            size: isMobile ? 64 : 80,
                            borderRadius: 16,
                            onTap: _isEditing ? _pickAndUploadLogo : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickAndUploadLogo,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      size: 14, color: AppColors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              society.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isMobile ? 18 : null,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RERA / Reg: ${society.registrationNumber}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.slate500,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Last Updated: ${Formatters.formatDateTime(society.updatedAt)}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.slate400,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Details Form Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'General & Legal Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 650;
                          return Column(
                            children: [
                              _buildRow(
                                isWide: isWide,
                                first: AppTextField(
                                  controller: _nameController,
                                  label: 'Society Name',
                                  readOnly: !_isEditing,
                                  validator: Validators.required,
                                ),
                                second: AppTextField(
                                  controller: _regNumberController,
                                  label: 'RERA / Registration Number',
                                  readOnly: !_isEditing,
                                  validator: Validators.required,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildRow(
                                isWide: isWide,
                                first: AppTextField(
                                  controller: _emailController,
                                  label: 'Official Email',
                                  keyboardType: TextInputType.emailAddress,
                                  readOnly: !_isEditing,
                                  validator: Validators.email,
                                ),
                                second: AppTextField(
                                  controller: _contactController,
                                  label: 'Contact Number',
                                  keyboardType: TextInputType.phone,
                                  readOnly: !_isEditing,
                                  validator: Validators.phone,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildRow(
                                isWide: isWide,
                                first: AppTextField(
                                  controller: _websiteController,
                                  label: 'Website (Optional)',
                                  readOnly: !_isEditing,
                                ),
                                second: AppTextField(
                                  controller: _addressController,
                                  label: 'Street Address',
                                  readOnly: !_isEditing,
                                  validator: Validators.required,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildRow(
                                isWide: isWide,
                                first: AppTextField(
                                  controller: _cityController,
                                  label: 'City',
                                  readOnly: !_isEditing,
                                  validator: Validators.required,
                                ),
                                second: AppTextField(
                                  controller: _stateController,
                                  label: 'State',
                                  readOnly: !_isEditing,
                                  validator: Validators.required,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildRow(
                                isWide: isWide,
                                first: AppTextField(
                                  controller: _countryController,
                                  label: 'Country',
                                  readOnly: !_isEditing,
                                  validator: Validators.required,
                                ),
                                second: AppTextField(
                                  controller: _pinCodeController,
                                  label: 'PIN Code',
                                  keyboardType: TextInputType.number,
                                  readOnly: !_isEditing,
                                  validator: Validators.pinCode,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Danger Zone: Super Admin Tenant Governance
              if (isSuperAdmin) ...[
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.35)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: AppColors.errorDark, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Danger Zone: Decommission Society Tenant',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.errorDark,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Permanently remove this society tenant, including all its towers, floors, and flats.',
                                    style: TextStyle(fontSize: 12, color: AppColors.slate500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: isMobile ? double.infinity : null,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.delete_forever_rounded, size: 18),
                            label: const Text('Delete Society Tenant Permanently', style: TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: () => _handleDeleteSociety(context, society),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteSociety(BuildContext context, Society society) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text('Decommission Society'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to permanently delete "${society.name}"?',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'All associated towers, floors, flat inventory, and tenant associations will be permanently purged. This action cannot be undone.',
                style: TextStyle(fontSize: 13, color: AppColors.slate500),
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(activeSocietyProvider.notifier).deleteSociety(society.id);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Society "${society.name}" has been decommissioned.'),
              backgroundColor: AppColors.error,
            ),
          );
          context.go(RouteConstants.societiesPath);
        } else {
          final err = ref.read(activeSocietyProvider).errorMessage ?? 'Failed to delete society';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Widget _buildRow({
    required bool isWide,
    required Widget first,
    required Widget second,
  }) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 16),
          Expanded(child: second),
        ],
      );
    }
    return Column(
      children: [
        first,
        const SizedBox(height: 16),
        second,
      ],
    );
  }
}
