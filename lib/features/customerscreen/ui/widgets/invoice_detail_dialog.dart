import 'package:flutter/material.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:arqamy/core/services/invoice_service.dart';
import 'package:provider/provider.dart';

class InvoiceDetailDialog extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InvoiceDetailDialog({
    super.key,
    required this.invoice,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.read<InvoiceSettingsProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'فاتورة #${invoice.invoiceSerial}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      invoice.invoiceAction ?? 'عملية',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Info Card
                    _buildInfoCard(
                      title: 'معلومات العميل',
                      icon: Icons.person,
                      children: [
                        _buildInfoRow('الاسم', invoice.customerName),
                        _buildInfoRow('التاريخ', invoice.formattedDate),
                        _buildInfoRow('الوقت', invoice.formattedTime),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Financial Summary Card
                    _buildInfoCard(
                      title: 'الملخص المالي',
                      icon: Icons.attach_money,
                      children: [
                        _buildInfoRow(
                          'الإجمالي',
                          '${invoice.totalCost.toStringAsFixed(2)} جنيه',
                          isHighlighted: true,
                        ),
                        _buildInfoRow(
                          'المدفوع',
                          '${invoice.paid.toStringAsFixed(2)} جنيه',
                          color: Colors.green,
                        ),
                        _buildInfoRow(
                          'الباقي',
                          '${invoice.rest.toStringAsFixed(2)} جنيه',
                          color:
                              invoice.rest > 0 ? Colors.orange : Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Products Section
                    _buildProductsSection(),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Wrap(
                children: [
                  _buildActionButton(
                    icon: Icons.close,
                    label: 'إغلاق',
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'حذف',
                    onPressed: onDelete,
                    color: Colors.red,
                  ),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'تعديل',
                    onPressed: onEdit,
                    color: Colors.orange,
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'مشاركة',
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final tempProvider = InvoiceProvider();
                      for (var product in invoice.products) {
                        tempProvider.addProduct(product);
                      }
                      try {
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
                      } catch (error) {
                        if (!scaffoldMessenger.mounted) return;
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('تعذر مشاركة الفاتورة: $error'),
                          ),
                        );
                      }
                    },
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? color,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    if (invoice.products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'المنتجات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...invoice.products.map((product) {
              final netWeight = product.weight -
                  (product.packageWeight * product.numberPackage);
              final total = netWeight * product.price;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      children: [
                        if (product.numberPackage > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            'الوزن: ${product.weight} كجم',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (product.price == 0)
                          const SizedBox(width: 4)
                        else
                          Text(
                            'السعر: ${product.price} جنيه/كجم',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                    if (product.numberPackage > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        'الفارغ: ${product.numberPackage} × ${product.packageWeight} كجم',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      children: [
                        Text(
                          'صافي: ${netWeight.toStringAsFixed(2)} كجم',
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        if (product.price == 0)
                          const SizedBox.shrink()
                        else
                          Text(
                            'الإجمالي: ${total.toStringAsFixed(2)} جنيه',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label!,
        style: TextStyle(color: color),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
