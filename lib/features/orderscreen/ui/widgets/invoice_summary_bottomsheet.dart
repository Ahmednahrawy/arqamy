import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter/material.dart';

import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/my_data_table.dart';
import 'package:provider/provider.dart';

class InvoiceSummaryBottomSheet extends StatelessWidget {
  const InvoiceSummaryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Consumer<InvoiceProvider>(
          builder: (context, provider, _) {
            final totalCost = provider.totalCost;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  verticalSpace(5),
                  SizedBox(
                    width: size.width,
                    // child: const SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: MyDataTable(isInModal: true),
                    // ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: MyDataTable(isInModal: true),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('إجمالي المبلغ: ${totalCost.toStringAsFixed(2)} L.E',
                          textDirection: TextDirection.rtl),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
