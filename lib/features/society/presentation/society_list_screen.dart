import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_picker_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/society_logo_widget.dart';
import '../../../core/widgets/state_views.dart';
import '../../authentication/presentation/auth_notifier.dart';
import '../../role/domain/role.dart';
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

    final isScreenMobile = MediaQuery.of(context).size.width < 620;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isScreenMobile ? 14.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;
                final titleColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Societies Management',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            fontSize: isMobile ? 22 : null,
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
                );

                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleColumn,
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Register New Society',
                          icon: Icons.add_business_rounded,
                          height: 42,
                          onPressed: () => _showCreateSocietyDialog(context),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 16),
                    AppButton(
                      text: 'Register New Society',
                      icon: Icons.add_business_rounded,
                      height: 42,
                      onPressed: () => _showCreateSocietyDialog(context),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Active Society Banner
            if (activeState.activeSociety != null)
              _buildActiveSocietyBanner(context, activeState.activeSociety!, isDark),
            const SizedBox(height: 28),

            // Search Bar & Count Row
            LayoutBuilder(
              builder: (context, searchConstraints) {
                final isNarrow = searchConstraints.maxWidth < 480;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
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
                            hintText: 'Search societies...',
                            prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.slate400),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            '${filteredSocieties.length} Societies',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
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
                );
              },
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 650;

          final logoWidget = SocietyLogoWidget(
            logoUrl: society.logoUrl,
            societyName: society.name,
            size: isMobile ? 48 : 60,
            borderRadius: 16,
          );

          final titleContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    society.name,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    logoWidget,
                    const SizedBox(width: 14),
                    Expanded(child: titleContent),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Go to Dashboard',
                    icon: Icons.dashboard_rounded,
                    height: 38,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.go(RouteConstants.dashboardPath),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              logoWidget,
              const SizedBox(width: 20),
              Expanded(child: titleContent),
              const SizedBox(width: 16),
              AppButton(
                text: 'Go to Dashboard',
                icon: Icons.dashboard_rounded,
                height: 38,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go(RouteConstants.dashboardPath),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSocietyCard(BuildContext context, Society society, bool isActive, bool isDark) {
    final authState = ref.watch(authNotifierProvider);
    final isSuperAdmin = RolePermissions.canDeleteSociety(authState.role);

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
              SocietyLogoWidget(
                logoUrl: society.logoUrl,
                societyName: society.name,
                size: 48,
                borderRadius: 12,
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
              if (isSuperAdmin) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                  tooltip: 'Delete Society',
                  onPressed: () => _showDeleteSocietyDialog(context, society),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteSocietyDialog(BuildContext context, Society society) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DeleteSocietyDialog(society: society),
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
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _regController = TextEditingController();
  String? _logoUrl;
  String? _logoFileName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
  }

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

  Future<void> _pickLogoFile() async {
    try {
      final picked = await FilePickerService.pickImage();
      if (picked != null) {
        setState(() {
          _logoUrl = picked.dataUrl;
          _logoFileName = picked.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick logo image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showUrlDialog() {
    final textController = TextEditingController(
      text: (_logoUrl != null && !_logoUrl!.startsWith('data:')) ? _logoUrl : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Logo Image URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a direct image URL (PNG, JPG, SVG, WebP) or Data URL:',
              style: TextStyle(fontSize: 12, color: AppColors.slate500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/logo.png',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
          ],
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
                _logoFileName = text.isNotEmpty ? 'Custom URL' : null;
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final id = 'soc-${DateTime.now().millisecondsSinceEpoch}';
    final rawCity = _cityController.text.trim();
    final cityCode = rawCity.length >= 3 ? rawCity.toUpperCase().substring(0, 3) : 'SOC';
    final regNum = _regController.text.trim().isEmpty
        ? 'REG/$cityCode/2026/${DateTime.now().millisecond}'
        : _regController.text.trim();

    final newSociety = Society(
      id: id,
      name: _nameController.text.trim(),
      logoUrl: _logoUrl,
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

                  // Society Logo Section (Optional)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDarkCard
                          : AppColors.slate50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SocietyLogoWidget(
                          logoUrl: _logoUrl,
                          societyName: _nameController.text.trim().isNotEmpty
                              ? _nameController.text.trim()
                              : 'New',
                          size: 56,
                          borderRadius: 14,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Society Logo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Optional',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _logoUrl != null
                                    ? (_logoFileName ?? 'Custom Logo Set')
                                    : 'Upload a logo to display in the browser tab and app navigation.',
                                style: const TextStyle(
                                  color: AppColors.slate500,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _pickLogoFile,
                                    icon: const Icon(Icons.upload_file_rounded, size: 15),
                                    label: Text(
                                      _logoUrl != null ? 'Change Image' : 'Upload Logo',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      minimumSize: const Size(0, 32),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _showUrlDialog,
                                    icon: const Icon(Icons.link_rounded, size: 15),
                                    label: const Text('Enter URL', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      minimumSize: const Size(0, 32),
                                    ),
                                  ),
                                  if (_logoUrl != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _logoUrl = null;
                                          _logoFileName = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.error),
                                      label: const Text(
                                        'Remove',
                                        style: TextStyle(fontSize: 12, color: AppColors.error),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        minimumSize: const Size(0, 32),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  AppTextField(
                    label: 'Society Name',
                    controller: _nameController,
                    prefixIcon: Icons.apartment_rounded,
                    validator: (v) => Validators.required(v, 'Society Name'),
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Society Address / Location',
                    controller: _addressController,
                    prefixIcon: Icons.location_on_outlined,
                    validator: (v) => Validators.required(v, 'Address'),
                  ),
                  const SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, fieldConstraints) {
                      final isCompact = fieldConstraints.maxWidth < 450;
                      if (isCompact) {
                        return Column(
                          children: [
                            AppTextField(
                              label: 'City',
                              controller: _cityController,
                              validator: (v) => Validators.required(v, 'City'),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'State',
                              controller: _stateController,
                              validator: (v) => Validators.required(v, 'State'),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Pincode',
                              controller: _pincodeController,
                              validator: (v) => Validators.required(v, 'Pincode'),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'City',
                              controller: _cityController,
                              validator: (v) => Validators.required(v, 'City'),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AppTextField(
                              label: 'State',
                              controller: _stateController,
                              validator: (v) => Validators.required(v, 'State'),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AppTextField(
                              label: 'Pincode',
                              controller: _pincodeController,
                              validator: (v) => Validators.required(v, 'Pincode'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, fieldConstraints) {
                      final isCompact = fieldConstraints.maxWidth < 450;
                      if (isCompact) {
                        return Column(
                          children: [
                            AppTextField(
                              label: 'Contact Phone',
                              controller: _contactController,
                              prefixIcon: Icons.phone_outlined,
                              validator: (v) => Validators.phone(v),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Official Email',
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              validator: (v) => Validators.email(v),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Contact Phone',
                              controller: _contactController,
                              prefixIcon: Icons.phone_outlined,
                              validator: (v) => Validators.phone(v),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AppTextField(
                              label: 'Official Email',
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              validator: (v) => Validators.email(v),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'RERA / Registration Number (Optional)',
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

class _DeleteSocietyDialog extends ConsumerStatefulWidget {
  final Society society;

  const _DeleteSocietyDialog({required this.society});

  @override
  ConsumerState<_DeleteSocietyDialog> createState() => _DeleteSocietyDialogState();
}

class _DeleteSocietyDialogState extends ConsumerState<_DeleteSocietyDialog> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    final success = await ref.read(activeSocietyProvider.notifier).deleteSociety(widget.society.id);
    setState(() => _isDeleting = false);

    if (mounted) {
      Navigator.of(context).pop();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Society "${widget.society.name}" and all associated units have been removed.'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        final err = ref.read(activeSocietyProvider).errorMessage ?? 'Failed to delete society';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSociety = ref.watch(activeSocietyProvider).activeSociety;
    final isCurrentActive = activeSociety?.id == widget.society.id;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppColors.errorDark, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Decommission Society',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Super Admin Multi-Tenant Governance',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Are you sure you want to permanently delete "${widget.society.name}"?',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.delete_forever_rounded, color: AppColors.errorDark, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This action is irreversible. All towers, floors, flat inventory, and tenant associations belonging to ${widget.society.name} will be permanently purged.',
                        style: const TextStyle(fontSize: 12, color: AppColors.errorDark, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentActive) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDarkHigher : AppColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is currently your active society. Deletion will automatically switch the active platform context to Shyam Heights.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.text,
                    onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : const Icon(Icons.delete_forever_rounded, size: 18),
                    label: Text(_isDeleting ? 'Deleting...' : 'Delete Society Permanently'),
                    onPressed: _isDeleting ? null : _handleDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
