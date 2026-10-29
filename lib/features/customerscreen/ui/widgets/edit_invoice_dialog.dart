import 'package:flutter/material.dart';
import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:provider/provider.dart';

class EditInvoiceDialog extends StatefulWidget {
  final Invoice invoice;

  const EditInvoiceDialog({
    super.key,
    required this.invoice,
  });

  @override
  State<EditInvoiceDialog> createState() => _EditInvoiceDialogState();
}

class _EditInvoiceDialogState extends State<EditInvoiceDialog> {
  late TextEditingController _paidController;
  late TextEditingController _customerNameController;
  double? _newRest;

  @override
  void initState() {
    super.initState();
    _paidController = TextEditingController(
      text: widget.invoice.paid.toStringAsFixed(2),
    );
    _customerNameController = TextEditingController(
      text: widget.invoice.customerName,
    );
    _calculateRest();
  }

  @override
  void dispose() {
    _paidController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  void _calculateRest() {
    final paid = double.tryParse(_paidController.text) ?? 0;
    setState(() {
      _newRest = widget.invoice.totalCost - paid;
    });
  }

  Future<void> _saveChanges() async {
    final provider = context.read<InvoiceProvider>();

    // Create updated invoice
    final updatedInvoice = Invoice(
      id: widget.invoice.id,
      customerName: _customerNameController.text.trim(),
      products: widget.invoice.products,
      totalCost: widget.invoice.totalCost,
      paid: double.tryParse(_paidController.text) ?? 0,
      rest: _newRest ?? widget.invoice.rest,
      formattedDate: widget.invoice.formattedDate,
      formattedTime: widget.invoice.formattedTime,
      invoiceAction: widget.invoice.invoiceAction,
      invoiceSerial: widget.invoice.invoiceSerial,
    );

    try {
      await provider.updateInvoice(updatedInvoice);
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'تعذر حفظ تعديلات الفاتورة: $error',
        isError: true,
      );
      return;
    }

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate changes were made
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Wrap(
                  children: [
                    Icon(Icons.edit, color: semanticColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      'تعديل الفاتورة #${widget.invoice.invoiceSerial}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Customer Name Field
                TextField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: 'اسم العميل',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Invoice Details (Read-only)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildReadOnlyRow(
                        'التاريخ',
                        '${widget.invoice.formattedDate} - ${widget.invoice.formattedTime}',
                      ),
                      const SizedBox(height: 8),
                      _buildReadOnlyRow(
                        'نوع العملية',
                        widget.invoice.invoiceAction ?? 'غير محدد',
                      ),
                      const SizedBox(height: 8),
                      _buildReadOnlyRow(
                        'الإجمالي',
                        '${widget.invoice.totalCost.toStringAsFixed(2)} جنيه',
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Paid Amount Field
                TextField(
                  controller: _paidController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculateRest(),
                  decoration: InputDecoration(
                    labelText: 'المبلغ المدفوع',
                    prefixIcon: const Icon(Icons.attach_money),
                    suffixText: 'جنيه',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Remaining Amount Display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _newRest == 0
                        ? semanticColors.success.withValues(alpha: 0.12)
                        : semanticColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _newRest == 0
                          ? semanticColors.success
                          : semanticColors.warning,
                      width: 1,
                    ),
                  ),
                  child: Wrap(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المبلغ المتبقي:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_newRest?.toStringAsFixed(2) ?? '0.00'} جنيه',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _newRest == 0
                              ? semanticColors.success
                              : semanticColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ التغييرات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value,
      {bool isHighlighted = false}) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? colors.primary : colors.onSurface,
          ),
        ),
      ],
    );
  }
}
