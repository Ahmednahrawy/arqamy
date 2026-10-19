import 'package:arqamy/core/services/invoice_service.dart';
import 'package:arqamy/features/customerscreen/ui/widgets/edit_invoice_dialog.dart';
import 'package:arqamy/features/customerscreen/ui/widgets/invoice_detail_dialog.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
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
      context.read<InvoiceProvider>().loadInvoices();
    });
  }

  void _handleCustomerSelection(String? customerName) {
    setState(() {
      _customerName = customerName;
      if (customerName != null && customerName.isNotEmpty) {
        _loadCustomerInvoices(customerName);
      } else {
        _customerInvoices.clear();
      }
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
      await context.read<InvoiceProvider>().loadInvoices();
      _loadCustomerInvoices(_customerName!);
    }
  }

  void _deleteInvoice(String invoiceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text("تأكيد الحذف"),
          ],
        ),
        content: const Text(
          "هل أنت متأكد من حذف هذه الفاتورة؟\nلا يمكن التراجع عن هذا الإجراء.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<InvoiceProvider>().deleteInvoice(invoiceId);
              if (_customerName != null) {
                _loadCustomerInvoices(_customerName!);
              }
              Navigator.pop(context);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('موردين و عملاء'),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                CustomerNameAutoComplete(
                    onCustomerSelected: _handleCustomerSelection),
                if (_customerName != null && _customerName!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.person, color: Colors.blue.shade700),
                            const SizedBox(height: 4),
                            Text(
                              _customerName!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.blue.shade300,
                        ),
                        Column(
                          children: [
                            Icon(Icons.receipt_long,
                                color: Colors.blue.shade700),
                            const SizedBox(height: 4),
                            Text(
                              '${_customerInvoices.length} فاتورة',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.blue.shade300,
                        ),
                        Column(
                          children: [
                            Icon(Icons.attach_money,
                                color: Colors.green.shade700),
                            const SizedBox(height: 4),
                            Text(
                              '${_calculateTotalDebt().toStringAsFixed(2)} ج.م',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _calculateTotalDebt() > 0
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                // Invoices list
                Expanded(
                  child: _customerInvoices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _customerName == null
                                    ? "اختر عميل لعرض الفواتير"
                                    : "لا توجد فواتير لهذا العميل",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _customerInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = _customerInvoices[index];
                            final isPaid = invoice.rest == 0;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _showInvoiceDetails(invoice),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Invoice icon with status color
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isPaid
                                              ? Colors.green.withValues(alpha: 0.1)
                                              : Colors.orange.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.receipt,
                                          color: isPaid
                                              ? Colors.green
                                              : Colors.orange,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Invoice details
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Wrap(
                                              children: [
                                                Text(
                                                  'فاتورة #${invoice.invoiceSerial}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getActionColor(
                                                        invoice.invoiceAction),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    invoice.invoiceAction ??
                                                        'عملية',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              invoice.formattedDate,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              children: [
                                                Text(
                                                  '${invoice.totalCost.toStringAsFixed(2)} ج.م',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                if (!isPaid)
                                                  Text(
                                                    'باقي: ${invoice.rest.toStringAsFixed(2)} ج.م',
                                                    style: TextStyle(
                                                      color: Colors.orange[700],
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                else
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: const Text(
                                                      'مدفوع',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Action buttons
                                      const SizedBox(width: 8),
                                      PopupMenuButton<String>(
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
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit,
                                                    color: Colors.orange),
                                                SizedBox(width: 8),
                                                Text('تعديل'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'share',
                                            child: Row(
                                              children: [
                                                Icon(Icons.share,
                                                    color: Colors.blue),
                                                SizedBox(width: 8),
                                                Text('مشاركة'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('حذف'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
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

  double _calculateTotalDebt() {
    return _customerInvoices.fold(0.0, (sum, invoice) => sum + invoice.rest);
  }

  Color _getActionColor(String? action) {
    switch (action) {
      case 'شراء':
        return Colors.blue;
      case 'بـيع':
        return Colors.green;
      case 'تخزين':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _shareInvoice(Invoice invoice) async {
    final settings = context.read<InvoiceSettingsProvider>();
    final tempProvider = InvoiceProvider();

    for (var product in invoice.products) {
      tempProvider.addProduct(product);
    }

    await InvoiceService.generateAndShareInvoice(
      provider: tempProvider,
      settings: settings,
      customerName: invoice.customerName,
      totalCost: invoice.totalCost,
      paid: invoice.paid,
      rest: invoice.rest,
      formattedDate: invoice.formattedDate,
      formattedTime: invoice.formattedTime,
      invoiceAction: invoice.invoiceAction,
      invoiceSerial: invoice.invoiceSerial,
    );
  }
}
