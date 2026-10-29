import 'package:flutter/material.dart';
import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:arqamy/core/services/invoice_service.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
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
    final colors = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);

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
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'فاتورة #${invoice.invoiceSerial}',
                    style: TextStyle(
                      color: colors.onPrimary,
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
                      color: colors.onPrimary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      invoice.invoiceAction ?? 'عملية',
                      style: TextStyle(
                        color: colors.onPrimary,
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
                      context: context,
                      title: 'معلومات العميل',
                      icon: Icons.person,
                      children: [
                        _buildInfoRow(context, 'الاسم', invoice.customerName),
                        _buildInfoRow(
                            context, 'التاريخ', invoice.formattedDate),
                        _buildInfoRow(context, 'الوقت', invoice.formattedTime),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Financial Summary Card
                    _buildInfoCard(
                      context: context,
                      title: 'الملخص المالي',
                      icon: Icons.attach_money,
                      children: [
                        _buildInfoRow(
                          context,
                          'الإجمالي',
                          '${invoice.totalCost.toStringAsFixed(2)} جنيه',
                          isHighlighted: true,
                        ),
                        _buildInfoRow(
                          context,
                          'المدفوع',
                          '${invoice.paid.toStringAsFixed(2)} جنيه',
                          color: semanticColors.success,
                        ),
                        _buildInfoRow(
                          context,
                          'الباقي',
                          '${invoice.rest.toStringAsFixed(2)} جنيه',
                          color: invoice.rest > 0
                              ? semanticColors.warning
                              : semanticColors.success,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Products Section
                    _buildProductsSection(context),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
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
                    color: colors.onSurfaceVariant,
                  ),
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'حذف',
                    onPressed: onDelete,
                    color: colors.error,
                  ),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'تعديل',
                    onPressed: onEdit,
                    color: semanticColors.warning,
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
                        if (!scaffoldMessenger.mounted) return;
                        showAppSnackBarOn(
                          scaffoldMessenger,
                          'تعذر مشاركة الفاتورة: $error',
                          isError: true,
                        );
                      }
                    },
                    color: colors.primary,
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
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;
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
                Icon(icon, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    BuildContext context,
    String label,
    String value, {
    Color? color,
    bool isHighlighted = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
              fontSize: isHighlighted ? 18 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              color: color ?? colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    if (invoice.products.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
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
                Icon(Icons.shopping_cart, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
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
              final netWeight = product.netWeight;
              final total = product.totalPrice;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outlineVariant),
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
                              color: colors.onSurfaceVariant,
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
                              color: colors.onSurfaceVariant,
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
                          color: colors.onSurfaceVariant,
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
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
