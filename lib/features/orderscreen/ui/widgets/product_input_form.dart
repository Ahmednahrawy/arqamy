import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/core/widgets/text_button.dart';
import 'package:arqamy/core/widgets/text_form_field.dart';
import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/config/theme/styles.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';

class ProductInputForm extends StatefulWidget {
  // final List<String> productList;
  final void Function(Product)? onAdd; // optional callback for backward-compat

  const ProductInputForm({
    super.key,
    // required this.productList,
    this.onAdd,
  });

  @override
  State<ProductInputForm> createState() => _ProductInputFormState();
}

class _ProductInputFormState extends State<ProductInputForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> actions = ['شراء', 'بـيع', 'تخزين'];

  String? _selectedProduct;

  final _weightController = TextEditingController();
  final _packageWeightController = TextEditingController(text: "2");
  final _packageNumberController = TextEditingController(text: "0");
  final _focusNodePackageNumber = FocusNode();
  final _priceController = TextEditingController();
  @override
  void initState() {
    super.initState();

    _focusNodePackageNumber.addListener(() {
      if (_focusNodePackageNumber.hasFocus &&
          _packageNumberController.text == "0") {
        _packageNumberController.clear();
      }
    });
    // Load products when form initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadMasterProducts();
    });
  }

  void _clearFields() {
    _weightController.clear();
    // _priceController.clear();
    _packageNumberController.text = "0";

    // do not reset defaults for package weight/number to avoid annoying UX
    // _selectedProduct = null;
    // _action = null;
    setState(() {});
  }

  void _handleAdd() {
    final provider = context.read<InvoiceProvider>();

    // Ensure invoice action chosen at provider level
    if (provider.invoiceAction == null) {
      _showErrorSnackBar('رجاء اختر نوع الفاتورة أولاً');
      return;
    }

    if (_selectedProduct == null) {
      _showErrorSnackBar('رجاء اختر منتج');
      // remove after work well the following line, it is for debugging only
      debugPrint('Selected Product: $_selectedProduct');

      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final packageWeight =
          double.tryParse(_packageWeightController.text) ?? 0.0;
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final numberPackage = int.tryParse(_packageNumberController.text) ?? 0;
      final product = Product(
        name: _selectedProduct!,
        weight: weight,
        packageWeight: packageWeight,
        price: price,
        numberPackage: numberPackage,
        // action: _action!,
      );
      // If an explicit callback provided (old code), use it.
      if (widget.onAdd != null) {
        widget.onAdd!(product);
      } else {
        // Otherwise, try to add via provider (if registered).
        try {
          // final provider = Provider.of<InvoiceProvider>(context, listen: false);
          provider.addProduct(product);
        } catch (e) {
          // No provider registered — fallback to showing error so developer notices.
          _showErrorSnackBar('Provider not found');
        }
      }
      _clearFields();
      FocusScope.of(context).unfocus();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _actionSelector(double width) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        if (provider.invoiceAction == null) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: actions.map((action) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: AppTextButton(
                        borderRadius: 9,
                        onPressed: () => provider.setInvoiceAction(action),
                        buttonWidth: width * 0.28,
                        buttonHeight: 12,
                        verticalPadding: 2,
                        buttonText: action,
                        backgroundColor: ColorsManager.mainBlue,
                        textStyle: TextStyles.font16WhiteSemiBold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
        return Center(
          child: Chip(
            label: Text('نوع الفاتورة: ${provider.invoiceAction}'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _packageWeightController.dispose();
    _packageNumberController.dispose();
    _priceController.dispose();
    _focusNodePackageNumber.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action buttons
          _actionSelector(size.width),
          verticalSpace(10),
          Consumer<InvoiceProvider>(
            builder: (context, provider, _) => DropdownSearch<String>(
              autoValidateMode: AutovalidateMode.onUserInteraction,
              items: (filter, _) => provider.masterProductList,
              selectedItem: _selectedProduct,
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: 'المنتج',
                  suffixIcon: Icon(Icons.search),
                  hintText: 'اختر منتج',
                ),
              ),
              popupProps: PopupProps.menu(
                fit: FlexFit.tight,
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: ColorsManager.lightGray,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: ListTile(title: Text(item)),
                  );
                },
                showSearchBox: true,
              ),
              onSelected: (value) => setState(() => _selectedProduct = value),
            ),
          ),
          verticalSpace(8),
          Row(
            children: [
              Expanded(
                child: AppTextFormField(
                  textDirection: TextDirection.ltr,
                  controller: _weightController,
                  labelText: 'الوزن أو العدد',
                  hintText: 'كجم',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'رجاء أدخل الوزن';
                    }
                    if (double.tryParse(value) == null) {
                      return 'ادخل رقم صالح';
                    }
                    return null;
                  },
                ),
              ),
              horizontalSpace(8),
              Expanded(
                child: AppTextFormField(
                  textDirection: TextDirection.ltr,
                  controller: _priceController,
                  labelText: 'السعر',
                  hintText: 'جنيه',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'رجاء أدخل السعر';
                    }
                    if (double.tryParse(value) == null) {
                      return 'ادخل رقم صالح';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          verticalSpace(8),
          Row(
            children: [
              Expanded(
                child: AppTextFormField(
                  textDirection: TextDirection.ltr,
                  controller: _packageWeightController,
                  labelText: 'وزن العبوة',
                  suffixText: 'كجم',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'أدخل وزن العبوة الفارغة';
                    }
                    if (double.tryParse(value) == null) {
                      return 'ادخل رقم صالح';
                    }
                    return null;
                  },
                ),
              ),
              horizontalSpace(8),
              Expanded(
                child: AppTextFormField(
                  textDirection: TextDirection.ltr,
                  controller: _packageNumberController,
                  focusNode: _focusNodePackageNumber,
                  labelText: 'عدد الفارغ',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'أدخل عدد العبوات أولا';
                    }
                    if (int.tryParse(value) == null) {
                      return 'ادخل رقم صالح';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          verticalSpace(10),

          // Add button
          AppTextButton(
            onPressed: _handleAdd,
            buttonText: 'أضف منتج',
            textStyle: TextStyles.font16WhiteSemiBold,
            backgroundColor: ColorsManager.mainBlue,
            buttonWidth: size.width * 0.6,
          ),
        ],
      ),
    );
  }
}
