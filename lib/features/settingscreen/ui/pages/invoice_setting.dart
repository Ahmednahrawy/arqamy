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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsProvider = context.read<InvoiceSettingsProvider>();
    // Populate controllers with current provider values
    _managerNameController.text = settingsProvider.managerName;
    _managerPhoneController.text = settingsProvider.managerPhone;
    _companyNameController.text = settingsProvider.companyName;
    _companyDescController.text = settingsProvider.companyDescription;
    _qrDataController.text = settingsProvider.qrData;
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
    await settingsProvider.updateSettings(logoPath: 'assets/images/arqamy.png');
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
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _managerNameController,
              decoration: InputDecoration(labelText: strings.manager_name),
              validator: (val) => val == null || val.isEmpty
                  ? strings.enter_manager_name
                  : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _managerPhoneController,
              decoration: InputDecoration(labelText: strings.manager_phone),
              keyboardType: TextInputType.phone,
              validator: (val) => val == null || val.isEmpty
                  ? strings.enter_phone
                  : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _companyNameController,
              decoration: InputDecoration(labelText: strings.company_name),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _companyDescController,
              decoration:
                  InputDecoration(labelText: strings.company_description),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _qrDataController,
              decoration: InputDecoration(labelText: strings.qr_data),
            ),
            const SizedBox(height: 24),

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
