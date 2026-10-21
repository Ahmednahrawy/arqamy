import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/core/services/invoice_service.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/invoice_summary_bottomsheet.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/product_input_form.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/material.dart';

import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/core/helpers/helper_date_price.dart';
import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/drawer/ui/side_nav.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/customer_name.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/my_data_table.dart';
import 'package:provider/provider.dart';

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
  String? _savedInvoiceId;
  Invoice? _savedInvoice;
  int _productFormVersion = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  _selectDate(BuildContext context) {
    formattedDate = Utils.formatDate(selectedDate);
    formattedTime = Utils.formateTimeNow(selectedDate);
  }

  double get _paid => double.tryParse(_payController.text) ?? 0.0;

  double _rest(double totalCost) =>
      ((totalCost < 0) ? (-totalCost) : totalCost) - _paid;

  // Centralized error/toast handling
  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

// Called by ProductInputForm
  void _onAddProduct(Product product) {
    context.read<InvoiceProvider>().addProduct(product);
    _showToast('تمت إضافة ${product.name} بنجاح');
  }

  String _generateInvoiceId() {
    final now = DateTime.now();
    return 'INV_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
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
      id: _savedInvoice?.id ?? _generateInvoiceId(),
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

  Future<void> _saveInvoice({required bool share}) async {
    final provider = context.read<InvoiceProvider>();
    if (!_validateInvoice(provider)) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
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
      _showToast('فشل حفظ الفاتورة: $error', isError: true);
      return;
    }

    if (share) {
      try {
        await InvoiceService.generateAndShareInvoice(
          provider: provider,
          settings: context.read<InvoiceSettingsProvider>(),
          customerName: invoice.customerName,
          totalCost: invoice.totalCost,
          paid: invoice.paid,
          rest: invoice.rest,
          formattedDate: invoice.formattedDate,
          formattedTime: invoice.formattedTime,
          invoiceAction: invoice.invoiceAction,
          invoiceSerial: invoice.invoiceSerial,
        );
      } catch (error) {
        if (!mounted) return;
        Navigator.of(context).pop();
        _showToast('تم حفظ الفاتورة ولكن فشلت المشاركة: $error', isError: true);
        return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    if (share) {
      _showToast(S.of(context).invoice_sent_successfully);
    } else {
      _showToast('تم حفظ الفاتورة بنجاح');
    }
  }

  Future<void> _sendInvoice() => _saveInvoice(share: true);

  Future<void> _saveInvoiceOnly() => _saveInvoice(share: false);

  // Clear invoice button handler
  void _startNewInvoice() {
    final provider = context.read<InvoiceProvider>();
    final hasDraft = provider.products.isNotEmpty ||
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
      _showToast('فاتورة جديدة جاهزة');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('فاتورة جديدة'),
          ],
        ),
        content: const Text(
          'سيتم مسح بيانات الفاتورة الحالية فقط. لن يتم حذف الفواتير المحفوظة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              resetDraft();
              _showToast('فاتورة جديدة جاهزة');
            },
            child: const Text('جديد'),
          ),
        ],
      ),
    );
  }

  void _deleteSavedInvoice() {
    final invoiceId = _savedInvoiceId;
    if (invoiceId == null) {
      _showToast('لا توجد فاتورة محفوظة مفتوحة للحذف', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('حذف الفاتورة المحفوظة'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من حذف الفاتورة المحفوظة؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
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
                _showToast('تم حذف الفاتورة وتهيئة فاتورة جديدة');
              } catch (error) {
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;
                _showToast('فشل حذف الفاتورة: $error', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
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
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.75,
                    ),
                    backgroundColor: ColorsManager.moreLighterGray,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25.0),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext ctx) {
                      return InvoiceSummaryBottomSheet(
                        payController: _payController,
                        payFormKey: _payKey,
                        onSave: _saveInvoiceOnly,
                        onSend: _sendInvoice,
                      );
                    },
                  );
                },
          label: const Text(
            'إرسال ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.send),
          backgroundColor: Colors.blue[700],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _payController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "إصدار فاتورة",
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (MediaQuery.sizeOf(context).width < 420) ...[
                    IconButton(
                      onPressed: _startNewInvoice,
                      tooltip: 'جديد',
                      color: Colors.white,
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed:
                          _savedInvoiceId == null ? null : _deleteSavedInvoice,
                      tooltip: 'مسح',
                      color: Colors.white,
                      disabledColor: Colors.white70,
                      icon: const Icon(Icons.delete_forever),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: _startNewInvoice,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('جديد'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed:
                          _savedInvoiceId == null ? null : _deleteSavedInvoice,
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('مسح'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            _savedInvoiceId == null ? Colors.grey : Colors.red,
                        backgroundColor: Colors.white,
                        disabledForegroundColor: Colors.grey,
                        disabledBackgroundColor: Colors.white70,
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
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
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
                                ],
                              ),
                            );
                          }
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_cart_outlined,
                                      size: 60, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد منتجات مضافة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ابدأ بإضافة منتجات للفاتورة',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
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
                        builder: (context, provider, _) => SizedBox(
                            height: provider.products.isEmpty ? 16 : 88),
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
      ),
    );
  }

  Widget _buildTotalCostCard(double totalCost) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final total = Text(
            '${totalCost.toStringAsFixed(2)} جنيه',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );
          const label = Text(
            'الإجمالي الكلي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );

          if (constraints.maxWidth < 380) {
            return Column(
              children: [
                label,
                const SizedBox(height: 4),
                total,
              ],
            );
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
