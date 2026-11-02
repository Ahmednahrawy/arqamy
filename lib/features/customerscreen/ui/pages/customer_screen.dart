import 'dart:async';

import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/core/services/invoice_service.dart';
import 'package:arqamy/features/customerscreen/ui/widgets/edit_invoice_dialog.dart';
import 'package:arqamy/features/customerscreen/ui/widgets/invoice_detail_dialog.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/customer_name.dart';
import 'package:provider/provider.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String? _customerName;
  List<Invoice> _customerInvoices = [];
  @override
  void initState() {
    super.initState();
    // تحميل الفواتير عند بدء التشغيل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _loadInvoices(errorMessage: 'تعذر تحميل سجل الفواتير'),
      );
    });
  }

  Future<void> _loadInvoices({required String errorMessage}) async {
    try {
      await context.read<InvoiceProvider>().loadInvoices();
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        '$errorMessage: $error',
        isError: true,
      );
    }
  }

  void _handleCustomerSelection(String? customerName) {
    final invoices = customerName != null && customerName.isNotEmpty
        ? context.read<InvoiceProvider>().getInvoicesByCustomer(customerName)
        : <Invoice>[];
    setState(() {
      _customerName = customerName;
      _customerInvoices = invoices;
    });
  }

  void _loadCustomerInvoices(String customerName) {
    final provider = context.read<InvoiceProvider>();
    setState(() {
      _customerInvoices = provider.getInvoicesByCustomer(customerName);
    });
  }

  void _showInvoiceDetails(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => InvoiceDetailDialog(
        invoice: invoice,
        onEdit: () {
          Navigator.pop(context);
          _editInvoice(invoice);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteInvoice(invoice.id);
        },
      ),
    );
  }

  void _editInvoice(Invoice invoice) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditInvoiceDialog(invoice: invoice),
    );

    if (result == true && _customerName != null) {
      // Reload invoices after edit
      await _loadInvoices(
        errorMessage: 'تم حفظ التعديل، لكن تعذر تحديث سجل الفواتير',
      );
      if (!mounted) return;
      _loadCustomerInvoices(_customerName!);
    }
  }

  void _deleteInvoice(String invoiceId) {
    final provider = context.read<InvoiceProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final colors = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: semanticColors.warning),
            const SizedBox(width: 8),
            const Text("تأكيد الحذف"),
          ],
        ),
        content: const Text(
          "هل أنت متأكد من حذف هذه الفاتورة؟\nلا يمكن التراجع عن هذا الإجراء.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.deleteInvoice(invoiceId);
              } catch (error) {
                showAppSnackBarOn(
                  messenger,
                  'تعذر حذف الفاتورة: $error',
                  isError: true,
                );
                return;
              }

              if (!dialogContext.mounted || !mounted) return;
              if (_customerName != null) {
                _loadCustomerInvoices(_customerName!);
              }
              Navigator.pop(dialogContext);
            },
            child: Text("حذف", style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final balance = InvoiceProvider.calculateCustomerBalance(_customerInvoices);
    final purchaseBalance = _customerInvoices
        .where((invoice) =>
            invoice.invoiceAction?.replaceAll('\u0640', '').trim() == 'شراء')
        .fold<double>(0, (sum, invoice) => sum + invoice.rest);
    final salesBalance = _customerInvoices
        .where((invoice) =>
            invoice.invoiceAction?.replaceAll('\u0640', '').trim() == 'بيع')
        .fold<double>(0, (sum, invoice) => sum + invoice.rest);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('موردين و عملاء'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: CustomerNameAutoComplete(
                      onCustomerSelected: _handleCustomerSelection,
                    ),
                  ),
                ),
                if (_customerName != null && _customerName!.isNotEmpty)
                  _buildCustomerSummary(
                    customerName: _customerName!,
                    invoiceCount: _customerInvoices.length,
                    balance: balance,
                    purchaseBalance: purchaseBalance,
                    salesBalance: salesBalance,
                  ),
                if (_customerName != null && _customerName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'سجل الفواتير',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          '${_customerInvoices.length} فاتورة',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _customerInvoices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  size: 42,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _customerName == null
                                    ? "اختر عميل لعرض الفواتير"
                                    : "لا توجد فواتير لهذا العميل",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: _customerInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = _customerInvoices[index];
                            return _buildInvoiceCard(invoice);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSummary({
    required String customerName,
    required int invoiceCount,
    required double balance,
    required double purchaseBalance,
    required double salesBalance,
  }) {
    final colors = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);
    final balanceColor = balance > 0
        ? semanticColors.warning
        : balance < 0
            ? colors.primary
            : semanticColors.success;
    final balanceLabel = balance > 0
        ? 'صافي مستحق لك'
        : balance < 0
            ? 'صافي مستحق للعميل'
            : 'الحساب متوازن';

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: const Icon(Icons.person_outline),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$invoiceCount فاتورة',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            balanceLabel,
            style: TextStyle(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${balance.abs().toStringAsFixed(2)} ج.م',
            style: TextStyle(
              color: balanceColor,
              fontSize: 27,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceBreakdown(
                  label: 'مشتريات',
                  amount: purchaseBalance,
                  color: colors.primary,
                  icon: Icons.south_west,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceBreakdown(
                  label: 'مبيعات',
                  amount: salesBalance,
                  color: semanticColors.success,
                  icon: Icons.north_east,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceBreakdown({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${amount.toStringAsFixed(2)} ج.م',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final colors = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);
    final actionColor = _getActionColor(context, invoice.invoiceAction);
    final action = invoice.invoiceAction ?? 'عملية';
    final isPaid = invoice.rest <= 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showInvoiceDetails(invoice),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 8, 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.receipt_long, color: actionColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'فاتورة #${invoice.invoiceSerial}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: actionColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            action,
                            style: TextStyle(
                              color: actionColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${invoice.formattedDate}  •  ${invoice.formattedTime}',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        Text(
                          'الإجمالي ${invoice.totalCost.toStringAsFixed(2)} ج.م',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          isPaid
                              ? 'مدفوع'
                              : 'متبقي ${invoice.rest.toStringAsFixed(2)} ج.م',
                          style: TextStyle(
                            color: isPaid
                                ? semanticColors.success
                                : semanticColors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'خيارات الفاتورة',
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editInvoice(invoice);
                      break;
                    case 'delete':
                      _deleteInvoice(invoice.id);
                      break;
                    case 'share':
                      _shareInvoice(invoice);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(
                        Icons.edit_outlined,
                        color: semanticColors.warning,
                      ),
                      title: const Text('تعديل'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(
                        Icons.share_outlined,
                        color: colors.primary,
                      ),
                      title: const Text('مشاركة'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: colors.error,
                      ),
                      title: const Text('حذف'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActionColor(BuildContext context, String? action) {
    final colors = Theme.of(context).colorScheme;
    switch (action?.replaceAll('\u0640', '').trim()) {
      case 'شراء':
        return colors.primary;
      case 'بيع':
        return colors.secondary;
      case 'تخزين':
        return colors.tertiary;
      default:
        return colors.onSurfaceVariant;
    }
  }

  Future<void> _shareInvoice(Invoice invoice) async {
    final settings = context.read<InvoiceSettingsProvider>();
    final tempProvider = InvoiceProvider();

    for (var product in invoice.products) {
      tempProvider.addProduct(product);
    }
// generateAndShareInvoice
    try {
      await InvoiceService.generateAndShareInvoice(
        provider: tempProvider,
        settings: settings,
        customerName: invoice.customerName,
        invoiceId: invoice.id,
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
      showAppSnackBar(
        context,
        'تعذر مشاركة الفاتورة: $error',
        isError: true,
      );
    }
  }
}
