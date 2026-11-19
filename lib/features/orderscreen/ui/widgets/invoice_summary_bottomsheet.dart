import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:material_ui/material_ui.dart';

import 'package:arqamy/core/helpers/formatters.dart';
import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/my_data_table.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:provider/provider.dart';

class InvoiceSummaryBottomSheet extends StatelessWidget {
  final double paid;
  final double rest;
  const InvoiceSummaryBottomSheet({
    super.key,
    required this.paid,
    required this.rest,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Consumer<InvoiceProvider>(
        builder: (context, provider, _) {
          final totalCost = provider.totalCost;
          final strings = S.of(context);
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                verticalSpace(5),
                SizedBox(
                  width: size.width,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: MyDataTable(isInModal: true),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${strings.total_amount}: '
                      '${AppFormatters.currency(totalCost, strings)}',
                    ),
                    Text(
                      '${strings.collected_amount_label}: '
                      '${AppFormatters.currency(paid, strings)}',
                    ),
                    Text(
                      '${strings.remaining}: '
                      '${AppFormatters.currency(rest, strings)}',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
