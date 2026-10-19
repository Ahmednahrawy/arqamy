import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/config/theme/styles.dart';
import 'package:arqamy/core/widgets/text_button.dart';
import 'package:arqamy/core/widgets/text_form_field.dart';
import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/features/orderscreen/ui/widgets/my_data_table.dart';
import 'package:provider/provider.dart';

class InvoiceSummaryBottomSheet extends StatefulWidget {
  final TextEditingController payController;
  final GlobalKey<FormState> payFormKey;
  final VoidCallback onSend;

  const InvoiceSummaryBottomSheet({
    Key? key,
    required this.payController,
    required this.payFormKey,
    required this.onSend,
  }) : super(key: key);

  @override
  State<InvoiceSummaryBottomSheet> createState() =>
      _InvoiceSummaryBottomSheetState();
}

class _InvoiceSummaryBottomSheetState extends State<InvoiceSummaryBottomSheet> {
  double _paid() => double.tryParse(widget.payController.text) ?? 0.0;

  double _rest(double totalCost) =>
      ((totalCost < 0) ? (-totalCost) : totalCost) - _paid();
  final _payFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    // ✅ Step 4: Add Listener
    _payFocusNode.addListener(() {
      // If the field gains focus and its text is exactly "0", clear it.
      if (_payFocusNode.hasFocus && widget.payController.text == "0") {
        widget.payController.clear();
      }
    });
  }
   @override
  void dispose() {
    // ✅ Step 5: Dispose FocusNode
    _payFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsetsGeometry.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    child: const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: MyDataTable(isInModal: true),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('إجمالي المبلغ: ${totalCost.toStringAsFixed(2)} L.E',
                          textDirection: TextDirection.rtl),
                      Text('التحصيل : ${_paid().toStringAsFixed(2)} L.E',
                          textDirection: TextDirection.rtl),
                      Text('الباقي: ${_rest(totalCost).toStringAsFixed(2)} L.E',
                          textDirection: TextDirection.rtl),
                    ],
                  ),
                  verticalSpace(5),
                  Form(
                    key: widget.payFormKey,
                    child: AppTextFormField(
                      focusNode: _payFocusNode,
                      textDirection: TextDirection.ltr,
                      controller: widget.payController,
                      labelText: 'تحصيل',
                      suffixText: 'جنيه',
                      suffixIcon: widget.payController.text == ''
                          ? const SizedBox.shrink()
                          : IconButton(
                              onPressed: () {
                                widget.payController.clear();
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'رجاء أدخل قيمة التحصيل';
                        if (double.tryParse(value) == null)
                          return 'ادخل رقم صالح';
                        return null;
                      },
                    ),
                  ),
                  verticalSpace(10),
                  AppTextButton(
                    onPressed: widget.onSend,
                    buttonText: 'إرسال',
                    textStyle: TextStyles.font18WhiteMedium,
                    verticalPadding: 5.sp,
                    buttonWidth: size.width * 0.5,
                    backgroundColor: ColorsManager.gray,
                  ),
                  verticalSpace(10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
