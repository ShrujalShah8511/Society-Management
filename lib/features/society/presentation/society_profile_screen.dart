import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
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
    // Demonstration upload using FileStorageService abstraction
    final notifier = ref.read(societyProfileNotifierProvider.notifier);
    final dummyBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]); // PNG header mock
    final newUrl = await notifier.fileStorageService.uploadFile(
      fileName: 'society_logo.png',
      bytes: dummyBytes,
      mimeType: 'image/png',
    );
    setState(() {
      _logoUrl = newUrl;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Society logo updated via FileStorageService')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(societyProfileNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final userRole = authState.role;
    final canEdit = RolePermissions.canManageSociety(userRole);

    if (state.isLoading) {
      return const LoadingView(message: 'Loading society profile...');
    }

    if (state.errorMessage != null && state.society == null) {
      return ErrorRetryView(
        message: state.errorMessage!,
        onRetry: () => ref.read(societyProfileNotifierProvider.notifier).loadProfile(),
      );
    }

    final society = state.society;
    if (society == null) {
      return const EmptyStateView(
        title: 'No Society Found',
        message: 'No registered society profile exists.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Society Profile'),
        actions: [
          if (canEdit && !_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: AppButton(
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
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: _logoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      _logoUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.apartment_rounded,
                                        size: 44,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.apartment_rounded,
                                    size: 44, color: AppColors.primary),
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
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              society.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
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
                                  hint: 'https://society.example.com',
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
            ],
          ),
        ),
      ),
    );
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
