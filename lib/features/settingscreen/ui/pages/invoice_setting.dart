import 'dart:io';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter/material.dart';
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
        showAppSnackBar(context, 'تم حفظ إعدادات الفاتورة');
      } catch (error) {
        if (!mounted) return;
        showAppSnackBar(
          context,
          'تعذر حفظ إعدادات الفاتورة: $error',
          isError: true,
        );
      }
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
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
      appBar: AppBar(title: const Text("إعدادات الفاتورة")),
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
                    alignment: Alignment.topRight,
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
                    label: const Text("اختر الشعار"),
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
              decoration: const InputDecoration(labelText: "اسم المدير"),
              validator: (val) =>
                  val == null || val.isEmpty ? "ادخل اسم المدير" : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _managerPhoneController,
              decoration: const InputDecoration(labelText: "رقم المدير"),
              keyboardType: TextInputType.phone,
              validator: (val) =>
                  val == null || val.isEmpty ? "ادخل رقم الهاتف" : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(labelText: "اسم الشركة"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _companyDescController,
              decoration: const InputDecoration(labelText: "وصف الشركة"),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _qrDataController,
              decoration: const InputDecoration(labelText: "بيانات QR"),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: size.width,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text("حفظ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
