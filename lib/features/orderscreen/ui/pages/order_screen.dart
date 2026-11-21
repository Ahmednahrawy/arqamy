import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/core/services/invoice_service.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/invoice_summary_bottomsheet.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/product_input_form.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';

import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/config/theme/styles.dart';
import 'package:arqamy/core/helpers/formatters.dart';
import 'package:arqamy/core/helpers/helper_date_price.dart';
import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/core/helpers/money.dart';
import 'package:arqamy/core/widgets/text_button.dart';
import 'package:arqamy/core/widgets/text_form_field.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/drawer/ui/side_nav.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/customer_name.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/my_data_table.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

enum _InvoiceShareTarget { allApps, whatsapp }

class Orderscreen extends StatefulWidget {
  const Orderscreen({super.key});
  // This widget is the main screen for issuing invoices.
  //   It allows users to create, manage, and send invoices for products with various actions like buying, selling, or storing. @override
  @override
  State<Orderscreen> createState() => _OrderscreenState();
}

class _OrderscreenState extends State<Orderscreen>
    with SingleTickerProviderStateMixin {
  // Variables for user inputs and calculations
  String? formattedDate;
  String? formattedTime;
  final DateTime selectedDate = DateTime.now();

  // pay (kept in Orderscreen so sending logic remains here)
  final _payController = TextEditingController(text: "0");
  final _payKey = GlobalKey<FormState>();
  final _payFocusNode = FocusNode();
  String? _savedInvoiceId;
  Invoice? _savedInvoice;
  int _productFormVersion = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<InvoiceProvider>().prepareDraft();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _payFocusNode.addListener(() {
      if (_payFocusNode.hasFocus && _payController.text == '0') {
        _payController.clear();
      }
    });
    _animationController.forward();
  }

  void _selectDate(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    formattedDate = Utils.formatDate(selectedDate, locale: locale);
    formattedTime = Utils.formateTimeNow(selectedDate, locale: locale);
  }

  double get _paid => Money.tryParse(_payController.text)?.toDouble() ?? 0.0;

  double _rest(double totalCost) =>
      InvoiceProvider.calculateOutstandingBalance(totalCost, _paid);

  // Centralized error/toast handling
  void _showToast(String message, {bool isError = false}) {
    showAppSnackBar(context, message, isError: isError);
  }

  // Called by ProductInputForm
  void _onAddProduct(Product product) {
    context.read<InvoiceProvider>().addProduct(product);
    final strings = S.of(context);
    _showToast('${strings.product_added}: ${product.name}');
  }

  String _generateInvoiceSerial() {
    final now = DateTime.now();
    return "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}"
        "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
  }

  // Generates and shares an invoice as a PDF file
  bool _validateInvoice(InvoiceProvider provider) {
    if (!(_payKey.currentState?.validate() ?? false)) return false;
    if (provider.customerName == null ||
        provider.customerName!.isEmpty ||
        provider.customerName!.length < 4) {
      _showToast(S.of(context).please_choose_customer);
      return false;
    }
    return true;
  }

  Invoice _buildInvoice(InvoiceProvider provider) {
    if (_savedInvoice == null) {
      _selectDate(context);
    }

    return Invoice(
      id: _savedInvoice?.id ?? provider.draftInvoiceId,
      customerName: provider.customerName!,
      products: List.from(provider.products),
      totalCost: provider.totalCost,
      paid: _paid,
      rest: _rest(provider.totalCost),
      formattedDate: _savedInvoice?.formattedDate ?? formattedDate!,
      formattedTime: _savedInvoice?.formattedTime ?? formattedTime!,
      invoiceAction: provider.invoiceAction,
      invoiceSerial: _savedInvoice?.invoiceSerial ?? _generateInvoiceSerial(),
    );
  }

  Future<void> _saveInvoice({_InvoiceShareTarget? shareTarget}) async {
    final provider = context.read<InvoiceProvider>();
    final locale = Localizations.localeOf(context).languageCode;
    if (!_validateInvoice(provider)) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    late final Invoice invoice;
    try {
      invoice = _buildInvoice(provider);
      await provider.saveInvoice(invoice);
      if (!mounted) return;
      setState(() {
        _savedInvoice = invoice;
        _savedInvoiceId = invoice.id;
      });
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showToast('${S.of(context).save_invoice_failed}: $error', isError: true);
      return;
    }

    if (shareTarget != null) {
      try {
        final shareInvoice = shareTarget == _InvoiceShareTarget.whatsapp
            ? InvoiceService.generateAndShareInvoiceToWhatsApp
            : InvoiceService.generateAndShareInvoice;
        await shareInvoice(
          provider: provider,
          settings: context.read<InvoiceSettingsProvider>(),
          customerName: invoice.customerName,
          invoiceId: invoice.id,
          totalCost: invoice.totalCost,
          paid: invoice.paid,
          rest: invoice.rest,
          formattedDate: invoice.formattedDate,
          formattedTime: invoice.formattedTime,
          invoiceAction: invoice.invoiceAction,
          invoiceSerial: invoice.invoiceSerial,
          locale: locale,
        );
      } catch (error) {
        if (!mounted) return;
        Navigator.of(context).pop();
        _showToast(
          '${S.of(context).share_invoice_failed}: $error',
          isError: true,
        );
        return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    if (shareTarget != null) {
      _showToast(S.of(context).invoice_sent_successfully);
    } else {
      _showToast(S.of(context).invoice_saved_successfully);
    }
  }

  Future<void> _shareInvoice() =>
      _saveInvoice(shareTarget: _InvoiceShareTarget.allApps);

  Future<void> _sendInvoiceToWhatsApp() =>
      _saveInvoice(shareTarget: _InvoiceShareTarget.whatsapp);
  Future<void> _saveInvoiceOnly() => _saveInvoice();

  // Clear invoice button handler
  void _startNewInvoice() {
    final provider = context.read<InvoiceProvider>();
    final strings = S.of(context);
    final hasDraft =
        provider.products.isNotEmpty ||
        provider.customerName != null ||
        provider.invoiceAction != null;
    void resetDraft() {
      provider.clearInvoice();
      _payController.text = '0';
      setState(() {
        _savedInvoiceId = null;
        _savedInvoice = null;
        _productFormVersion++;
      });
    }

    if (!hasDraft) {
      resetDraft();
      _showToast(strings.new_invoice_ready);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(strings.new_invoice),
          ],
        ),
        content: Text(strings.clear_draft_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              resetDraft();
              _showToast(strings.new_invoice_ready);
            },
            child: Text(strings.new_label),
          ),
        ],
      ),
    );
  }

  void _deleteSavedInvoice() {
    final strings = S.of(context);
    final invoiceId = _savedInvoiceId;
    if (invoiceId == null) {
      _showToast(strings.no_saved_invoice_to_delete, isError: true);
      return;
    }

    final colors = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.warning, color: semanticColors.warning),
            const SizedBox(width: 8),
            Text(strings.delete_saved_invoice),
          ],
        ),
        content: Text(strings.delete_saved_invoice_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<InvoiceProvider>().deleteInvoice(invoiceId);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;

                context.read<InvoiceProvider>().clearInvoice();
                _payController.text = '0';
                setState(() {
                  _savedInvoiceId = null;
                  _savedInvoice = null;
                  _productFormVersion++;
                });
                _showToast(strings.invoice_deleted_new_ready);
              } catch (error) {
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;
                _showToast(
                  '${strings.could_not_delete_invoice}: $error',
                  isError: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              // backgroundColor: Colors.red,
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
  }

  // floating action button
  Widget _showModalForInvoiceSummary() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) => AnimatedScale(
        scale: provider.products.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: provider.products.isEmpty
              ? null
              : () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    enableDrag: true,
                    showDragHandle: true,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.75,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25.0),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext ctx) {
                      return InvoiceSummaryBottomSheet(
                        paid: _paid,
                        rest: _rest(provider.totalCost),
                      );
                    },
                  );
                },
          label: Text(
            S.of(context).preview,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          icon: const Icon(Icons.preview),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _payFocusNode.dispose();
    _payController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = S.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        elevation: 0,
        title: Text(strings.invoice_screen_title),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (MediaQuery.sizeOf(context).width < 420) ...[
                  IconButton(
                    onPressed: _startNewInvoice,
                    tooltip: strings.new_label,
                    color: colors.onPrimary,
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    onPressed: _savedInvoiceId == null
                        ? null
                        : _deleteSavedInvoice,
                    tooltip: strings.delete,
                    color: colors.onPrimary,
                    disabledColor: colors.onPrimary.withValues(alpha: 0.6),
                    icon: const Icon(Icons.delete_forever),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: _startNewInvoice,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(strings.new_label),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onPrimary,
                      side: BorderSide(
                        color: colors.onPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _savedInvoiceId == null
                        ? null
                        : _deleteSavedInvoice,
                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: Text(strings.delete),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: _savedInvoiceId == null
                          ? colors.onSurface.withValues(alpha: 0.38)
                          : colors.error,
                      backgroundColor: colors.surface,
                      disabledForegroundColor: colors.onSurface.withValues(
                        alpha: 0.38,
                      ),
                      disabledBackgroundColor: colors.surfaceContainerHighest,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),

      drawer: const SideNav(),
      extendBody: true,
      // Send data button
      floatingActionButton: _showModalForInvoiceSummary(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    // Name entering field
                    Card(
                      child: Consumer<InvoiceProvider>(
                        builder: (context, provider, _) =>
                            CustomerNameAutoComplete(
                              key: ValueKey(provider.customerName ?? 'empty'),
                              initialValue: provider.customerName,
                              onCustomerSelected: (name) {
                                provider.setCustomerName(name ?? '');
                              },
                            ),
                      ),
                    ),
                    verticalSpace(5),
                    ProductInputForm(
                      key: ValueKey(_productFormVersion),
                      onAdd: _onAddProduct,
                    ),
                    verticalSpace(10),
                    Consumer<InvoiceProvider>(
                      builder: (context, provider, _) {
                        if (provider.products.isNotEmpty) {
                          return SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                const MyDataTable(),
                                const Divider(height: 32),
                                _buildTotalCostCard(provider.totalCost),
                                verticalSpace(12),
                                _buildPaymentControls(),
                              ],
                            ),
                          );
                        }
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 60,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  strings.no_products_added,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  strings.start_adding_products,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // verticalSpace(100),
                    Consumer<InvoiceProvider>(
                      builder: (context, provider, _) =>
                          SizedBox(height: provider.products.isEmpty ? 16 : 88),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // resizeToAvoidBottomInset: false,
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildPaymentControls() {
    var width = MediaQuery.of(context).size.width;
    final colors = Theme.of(context).colorScheme;
    final strings = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Form(
            key: _payKey,
            child: AppTextFormField(
              focusNode: _payFocusNode,
              textDirection: TextDirection.ltr,
              controller: _payController,
              labelText: strings.collected_amount_label,
              suffixText: strings.currency,
              suffixIcon: _payController.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      onPressed: _payController.clear,
                      icon: const Icon(Icons.clear),
                    ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return strings.enter_collected_amount;
                }
                if (Money.tryParse(value) == null) {
                  return strings.invalidNumber;
                }
                return null;
              },
            ),
          ),
          verticalSpace(10),
          Row(
            children: [
              Expanded(
                child: AppTextButton(
                  onPressed: _saveInvoiceOnly,
                  buttonText: strings.save,
                  textStyle: TextStyles.font18WhiteMedium.copyWith(
                    color: colors.onSecondary,
                  ),
                  verticalPadding: 5,
                  buttonHeight: 48,
                  horizontalPadding: 4,
                  backgroundColor: colors.secondary,
                ),
              ),
              SizedBox(width: width < 400 ? 14 : 22),
              Expanded(
                child: AppTextButton(
                  onPressed: _shareInvoice,
                  buttonText: strings.send,
                  textStyle: TextStyles.font18WhiteMedium.copyWith(
                    color: colors.onPrimary,
                  ),
                  verticalPadding: 5,
                  buttonHeight: 48,
                  backgroundColor: colors.primary,
                ),
              ),
              SizedBox(width: width < 400 ? 14 : 22),
              IconButton.filled(
                tooltip: strings.share_via_whatsapp,
                onPressed: _sendInvoiceToWhatsApp,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(52, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const FaIcon(FontAwesomeIcons.whatsapp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCostCard(double totalCost) {
    final colors = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semanticColors.success,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final total = Text(
            AppFormatters.currency(totalCost, strings),
            style: TextStyle(
              color: colors.onSecondary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );
          final label = Text(
            strings.grand_total,
            style: TextStyle(
              color: colors.onSecondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );

          if (constraints.maxWidth < 380) {
            return Column(children: [label, const SizedBox(height: 4), total]);
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [label, total],
          );
        },
      ),
    );
  }
}
