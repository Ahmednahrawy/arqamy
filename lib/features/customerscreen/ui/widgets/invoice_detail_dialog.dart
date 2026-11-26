import 'package:material_ui/material_ui.dart';
import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/core/helpers/formatters.dart';
import 'package:arqamy/core/helpers/invoice_action_l10n.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:arqamy/core/services/invoice_service.dart';
import 'package:arqamy/core/services/invoice_excel_export_service.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/generated/l10n.dart';
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
    final strings = S.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    '${strings.invoiceNumber}${invoice.invoiceSerial}',
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
                      InvoiceActionL10n.label(invoice.invoiceAction, strings),
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
                      title: strings.customer_info,
                      icon: Icons.person,
                      children: [
                        _buildInfoRow(
                          context,
                          strings.name,
                          invoice.customerName,
                        ),
                        _buildInfoRow(
                          context,
                          strings.date,
                          invoice.formattedDate,
                        ),
                        _buildInfoRow(
                          context,
                          strings.time,
                          invoice.formattedTime,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Financial Summary Card
                    _buildInfoCard(
                      context: context,
                      title: strings.financial_summary,
                      icon: Icons.attach_money,
                      children: [
                        _buildInfoRow(
                          context,
                          strings.total_amount,
                          AppFormatters.currency(invoice.totalCost, strings),
                          isHighlighted: true,
                        ),
                        _buildInfoRow(
                          context,
                          strings.paid,
                          AppFormatters.currency(invoice.paid, strings),
                          color: semanticColors.success,
                        ),
                        _buildInfoRow(
                          context,
                          strings.remaining,
                          AppFormatters.currency(invoice.rest, strings),
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
                    label: strings.close,
                    onPressed: () => Navigator.pop(context),
                    color: colors.onSurfaceVariant,
                  ),
                  _buildActionButton(
                    icon: Icons.delete,
                    label: strings.delete,
                    onPressed: onDelete,
                    color: colors.error,
                  ),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: strings.edit,
                    onPressed: onEdit,
                    color: semanticColors.warning,
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: strings.share,
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final locale = Localizations.localeOf(
                        context,
                      ).languageCode;
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
                          locale: locale,
                        );
                      } catch (error) {
                        if (!scaffoldMessenger.mounted) return;
                        showAppSnackBarOn(
                          scaffoldMessenger,
                          '${strings.could_not_share_invoice}: $error',
                          isError: true,
                        );
                      }
                    },
                    color: colors.primary,
                  ),
                  _buildActionButton(
                    icon: Icons.table_chart,
                    label: strings.exportToExcel,
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final locale = Localizations.localeOf(
                        context,
                      ).languageCode;
                      try {
                        await InvoiceExcelExportService.generateAndShareInvoice(
                          invoice,
                          locale: locale,
                        );
                      } catch (error) {
                        if (!scaffoldMessenger.mounted) return;
                        showAppSnackBarOn(
                          scaffoldMessenger,
                          '${strings.invoice_excel_export_failed}: $error',
                          isError: true,
                        );
                      }
                    },
                    color: colors.tertiary,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
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
    final strings = S.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  strings.products,
                  style: const TextStyle(
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
                            '${strings.weight}: '
                            '${AppFormatters.weight(product.weight, strings)}',
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
                            '${strings.price}: '
                            '${AppFormatters.currency(product.price, strings)}'
                            '/${strings.kilograms}',
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
                        '${strings.empty_packages}: '
                        '${product.numberPackage} × '
                        '${AppFormatters.weight(product.packageWeight, strings)}',
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
                          '${strings.net_weight}: '
                          '${AppFormatters.weight(netWeight, strings)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        if (product.price == 0)
                          const SizedBox.shrink()
                        else
                          Text(
                            '${strings.total_amount}: '
                            '${AppFormatters.currency(total, strings)}',
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
      label: Text(label!, style: TextStyle(color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
