import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/society.dart';
import 'active_society_provider.dart';

class SocietyListScreen extends ConsumerStatefulWidget {
  const SocietyListScreen({super.key});

  @override
  ConsumerState<SocietyListScreen> createState() => _SocietyListScreenState();
}

class _SocietyListScreenState extends ConsumerState<SocietyListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeSocietyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredSocieties = activeState.allSocieties.where((s) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.city.toLowerCase().contains(q) ||
          s.registrationNumber.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Societies Management',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Super Admin Multi-Tenant Hub • Manage and switch between residential societies',
                      style: TextStyle(
                        color: AppColors.slate500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                AppButton(
                  text: 'Register New Society',
                  icon: Icons.add_business_rounded,
                  height: 42,
                  onPressed: () => _showCreateSocietyDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Active Society Banner
            if (activeState.activeSociety != null)
              _buildActiveSocietyBanner(context, activeState.activeSociety!, isDark),
            const SizedBox(height: 28),

            // Search Bar & Count Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: 'Search societies by name, city, or registration number...',
                        prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.slate400),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    '${filteredSocieties.length} Societies',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Societies Grid
            if (activeState.isLoading)
              const LoadingView(message: 'Loading societies...')
            else if (filteredSocieties.isEmpty)
              const EmptyStateView(
                title: 'No Societies Found',
                message: 'No societies match your search criteria. Click "+ Register New Society" to add one.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final crossAxisCount = isWide ? 2 : 1;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 210,
                    ),
                    itemCount: filteredSocieties.length,
                    itemBuilder: (context, index) {
                      final society = filteredSocieties[index];
                      final isActive = activeState.activeSociety?.id == society.id;
                      return _buildSocietyCard(context, society, isActive, isDark);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSocietyBanner(BuildContext context, Society society, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: society.logoUrl != null
                  ? Image.asset(
                      society.logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 32),
                    )
                  : const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 32),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      society.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PulsingStatusDot(color: AppColors.mintNeon, size: 6),
                          SizedBox(width: 6),
                          Text(
                            'CURRENTLY ACTIVE',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${society.address}, ${society.city}, ${society.state} - ${society.pinCode}',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            text: 'Go to Dashboard',
            icon: Icons.dashboard_rounded,
            height: 38,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(RouteConstants.dashboardPath),
          ),
        ],
      ),
    );
  }

  Widget _buildSocietyCard(BuildContext context, Society society, bool isActive, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? AppColors.primary
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: society.logoUrl != null
                      ? Image.asset(
                          society.logoUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 24),
                        )
                      : const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      society.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${society.city}, ${society.state} • ${society.pinCode}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.slate50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'RERA: ${society.registrationNumber}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  society.contactNumber,
                  style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: isActive ? 'Currently Selected' : 'Switch to Society',
                  icon: isActive ? Icons.check_circle_rounded : Icons.swap_horiz_rounded,
                  height: 36,
                  variant: isActive ? AppButtonVariant.outlined : AppButtonVariant.primary,
                  onPressed: isActive
                      ? () => context.go(RouteConstants.dashboardPath)
                      : () async {
                          await ref.read(activeSocietyProvider.notifier).selectSociety(society.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Switched active society to ${society.name}'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            context.go(RouteConstants.dashboardPath);
                          }
                        },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, size: 20),
                tooltip: 'View Society Profile',
                onPressed: () async {
                  await ref.read(activeSocietyProvider.notifier).selectSociety(society.id);
                  if (context.mounted) {
                    context.go(RouteConstants.societyProfilePath);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateSocietyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateSocietyDialog(),
    );
  }
}

class _CreateSocietyDialog extends ConsumerStatefulWidget {
  const _CreateSocietyDialog();

  @override
  ConsumerState<_CreateSocietyDialog> createState() => _CreateSocietyDialogState();
}

class _CreateSocietyDialogState extends ConsumerState<_CreateSocietyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Gandhinagar');
  final _stateController = TextEditingController(text: 'Gujarat');
  final _pincodeController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _regController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _regController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final id = 'soc-${DateTime.now().millisecondsSinceEpoch}';
    final regNum = _regController.text.trim().isEmpty
        ? 'GUJ/${_cityController.text.trim().toUpperCase().substring(0, 3)}/2026/${DateTime.now().millisecond}'
        : _regController.text.trim();

    final newSociety = Society(
      id: id,
      name: _nameController.text.trim(),
      logoUrl: null,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: 'India',
      pinCode: _pincodeController.text.trim(),
      contactNumber: _contactController.text.trim(),
      email: _emailController.text.trim(),
      registrationNumber: regNum,
      updatedAt: DateTime.now(),
    );

    final created = await ref.read(activeSocietyProvider.notifier).createSociety(newSociety);
    setState(() => _isSaving = false);

    if (created != null && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Society "${created.name}" registered and set as active!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Register New Society',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Add a new residential housing society under platform administration.',
                    style: TextStyle(color: AppColors.slate500, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    label: 'Society Name',
                    hint: 'e.g. Royal Orchid Enclave',
                    controller: _nameController,
                    prefixIcon: Icons.apartment_rounded,
                    validator: (v) => Validators.required(v, 'Society Name'),
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Society Address / Location',
                    hint: 'e.g. Near Infocity Circle, Kudasan',
                    controller: _addressController,
                    prefixIcon: Icons.location_on_outlined,
                    validator: (v) => Validators.required(v, 'Address'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'City',
                          hint: 'City',
                          controller: _cityController,
                          validator: (v) => Validators.required(v, 'City'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          label: 'State',
                          hint: 'State',
                          controller: _stateController,
                          validator: (v) => Validators.required(v, 'State'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          label: 'Pincode',
                          hint: '382421',
                          controller: _pincodeController,
                          validator: (v) => Validators.required(v, 'Pincode'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Contact Phone',
                          hint: '+91 9876543210',
                          controller: _contactController,
                          prefixIcon: Icons.phone_outlined,
                          validator: (v) => Validators.phone(v),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          label: 'Official Email',
                          hint: 'contact@society.in',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          validator: (v) => Validators.email(v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'RERA / Registration Number (Optional)',
                    hint: 'e.g. PR/GJ/GANDHINAGAR/...',
                    controller: _regController,
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        text: 'Cancel',
                        variant: AppButtonVariant.text,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        text: 'Register Society',
                        icon: Icons.check_rounded,
                        isLoading: _isSaving,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
