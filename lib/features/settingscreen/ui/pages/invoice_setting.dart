import 'dart:io';

import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class InvoiceSettingsScreen extends StatefulWidget {
  const InvoiceSettingsScreen({super.key});

  @override
  State<InvoiceSettingsScreen> createState() => _InvoiceSettingsScreenState();
}

class _InvoiceSettingsScreenState extends State<InvoiceSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _managerNameController = TextEditingController();
  final _managerPhoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyDescController = TextEditingController();
  final _qrDataController = TextEditingController();
  final _defaultPackageWeightController = TextEditingController();
  final _defaultPackageNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  static String _formatDefaultNumber(double value) =>
      value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  Future<void> _loadSettings() async {
    final settingsProvider = context.read<InvoiceSettingsProvider>();
    // Populate controllers with current provider values
    _managerNameController.text = settingsProvider.managerName;
    _managerPhoneController.text = settingsProvider.managerPhone;
    _companyNameController.text = settingsProvider.companyName;
    _companyDescController.text = settingsProvider.companyDescription;
    _qrDataController.text = settingsProvider.qrData;
    _defaultPackageWeightController.text = _formatDefaultNumber(
      settingsProvider.defaultPackageWeight,
    );
    _defaultPackageNumberController.text = settingsProvider.defaultPackageNumber
        .toString();
    if (mounted) setState(() {});
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState?.validate() ?? false) {
      final settingsProvider = context.read<InvoiceSettingsProvider>();
      try {
        await settingsProvider.updateSettings(
          managerName: _managerNameController.text,
          managerPhone: _managerPhoneController.text,
          companyName: _companyNameController.text,
          companyDescription: _companyDescController.text,
          qrData: _qrDataController.text,
          defaultPackageWeight: double.tryParse(
            _defaultPackageWeightController.text,
          ),
          defaultPackageNumber: int.tryParse(
            _defaultPackageNumberController.text,
          ),
        );

        if (!mounted) return;
        showAppSnackBar(context, S.of(context).invoice_settings_saved);
      } catch (error) {
        if (!mounted) return;
        showAppSnackBar(
          context,
          '${S.of(context).could_not_save_settings}: $error',
          isError: true,
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    final strings = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.reset_to_defaults),
        content: Text(strings.reset_defaults_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.reset_action),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<InvoiceSettingsProvider>().resetToDefaults();
    await _loadSettings();
    if (!mounted) return;
    showAppSnackBar(context, strings.invoice_settings_saved);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (!mounted) return;
      final settingsProvider = context.read<InvoiceSettingsProvider>();
      await settingsProvider.updateSettings(logoPath: picked.path);
    }
  }

  Future<void> _removeLogo() async {
    final settingsProvider = context.read<InvoiceSettingsProvider>();
    await settingsProvider.updateSettings(
      logoPath: InvoiceSettingsProvider.defaultLogoPath,
    );
  }

  Widget? _clearIcon(TextEditingController controller) {
    if (controller.text.isEmpty) return null;
    return IconButton(
      tooltip: S.of(context).clear_text,
      icon: const Icon(Icons.close, size: 18),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      onPressed: () => setState(controller.clear),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: _clearIcon(controller),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      validator: validator,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  void dispose() {
    _managerNameController.dispose();
    _managerPhoneController.dispose();
    _companyNameController.dispose();
    _companyDescController.dispose();
    _qrDataController.dispose();
    _defaultPackageWeightController.dispose();
    _defaultPackageNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final colors = Theme.of(context).colorScheme;
    final strings = S.of(context);
    final settingsProvider = context.watch<InvoiceSettingsProvider>();
    // Check if the path is a file path (not starting with 'assets/')
    final isFilePath = !settingsProvider.logoPath.startsWith('assets/');
    final hasCustomLogo = isFilePath && settingsProvider.logoPath.isNotEmpty;
    Widget logoWidget;

    if (hasCustomLogo) {
      // It's a file path, attempt to load the file
      final file = File(settingsProvider.logoPath);
      if (file.existsSync()) {
        logoWidget = Image.file(
          file,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      } else {
        // Fallback if the saved permanent file is somehow missing
        logoWidget = Icon(
          Icons.broken_image,
          size: 60,
          color: colors.error,
        );
      }
    } else {
      // It's either the default asset path or an empty path
      logoWidget = settingsProvider.logoPath.startsWith('assets/')
          ? Image.asset(
              settingsProvider.logoPath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            )
          : Icon(
              // Fallback for a blank path or other issue
              Icons.image,
              size: 60,
              color: colors.onSurfaceVariant,
            );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.invoice_settings)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle(strings.invoice_template),
            // Logo
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: logoWidget,
                      ),
                      if (hasCustomLogo)
                        GestureDetector(
                          onTap: _removeLogo,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: colors.onError,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(strings.choose_logo),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _field(
              _managerNameController,
              strings.manager_name,
              validator: (val) => val == null || val.isEmpty
                  ? strings.enter_manager_name
                  : null,
            ),
            const SizedBox(height: 12),

            _field(
              _managerPhoneController,
              strings.manager_phone,
              keyboardType: TextInputType.phone,
              validator: (val) => val == null || val.isEmpty
                  ? strings.enter_phone
                  : null,
            ),
            const SizedBox(height: 12),

            _field(_companyNameController, strings.company_name),
            const SizedBox(height: 12),

            _field(
              _companyDescController,
              strings.company_description,
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            _field(_qrDataController, strings.qr_data),
            const SizedBox(height: 24),

            _sectionTitle(strings.order_defaults),
            _field(
              _defaultPackageWeightController,
              strings.default_package_weight,
              hint: strings.kilograms,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                if (parsed == null || !parsed.isFinite || parsed < 0) {
                  return strings.invalid_default_package_weight;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            _field(
              _defaultPackageNumberController,
              strings.default_package_count,
              keyboardType: TextInputType.number,
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed == null || parsed < 0) {
                  return strings.invalid_default_package_count;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.show_package_weight),
              value: settingsProvider.showPackageWeight,
              onChanged: (value) => settingsProvider.updateSettings(
                showPackageWeight: value,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.show_package_number),
              value: settingsProvider.showPackageNumber,
              onChanged: (value) => settingsProvider.updateSettings(
                showPackageNumber: value,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: size.width,
              child: OutlinedButton(
                onPressed: _resetSettings,
                child: Text(strings.reset_to_defaults),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: size.width,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text(strings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
