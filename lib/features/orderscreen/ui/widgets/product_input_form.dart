import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/core/widgets/text_button.dart';
import 'package:arqamy/core/widgets/text_form_field.dart';
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
  final List<String> actions = ['شراء', 'بيع', 'تخزين'];

  String? _selectedProduct;

  final _weightController = TextEditingController();
  final _packageWeightController = TextEditingController(text: "2");
  final _packageNumberController = TextEditingController(text: "0");
  final _priceController = TextEditingController();
  final _weightFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _packageWeightFocusNode = FocusNode();
  final _packageNumberFocusNode = FocusNode();
  FocusNode? _firstInvalidFocusNode;
  @override
  void initState() {
    super.initState();

    _packageNumberFocusNode.addListener(() {
      if (_packageNumberFocusNode.hasFocus &&
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
    _firstInvalidFocusNode = null;
    if (!(_formKey.currentState?.validate() ?? false)) {
      final firstInvalidFocusNode = _firstInvalidFocusNode;
      if (firstInvalidFocusNode != null) {
        _focusField(firstInvalidFocusNode);
      }
      return;
    }

    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final packageWeight = double.tryParse(_packageWeightController.text) ?? 0.0;
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
    if (widget.onAdd != null) {
      widget.onAdd!(product);
    } else {
      try {
        provider.addProduct(product);
      } catch (e) {
        _showErrorSnackBar('Provider not found');
      }
    }
    _clearFields();
    FocusScope.of(context).unfocus();
  }

  void _focusField(FocusNode focusNode) {
    focusNode.requestFocus();
    final fieldContext = focusNode.context;
    if (fieldContext != null) {
      Scrollable.ensureVisible(
        fieldContext,
        alignment: 0.4,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    showAppSnackBar(context, message, isError: true);
  }

  Widget _actionSelector() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        final colors = Theme.of(context).colorScheme;
        if (provider.invoiceAction != null) {
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(' فاتورة: ${provider.invoiceAction}'),
                ),
                PopupMenuButton<String>(
                  tooltip: 'تغيير نوع الفاتورة',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onSelected: provider.setInvoiceAction,
                  itemBuilder: (context) => actions
                      .where((action) => action != provider.invoiceAction)
                      .map(
                        (action) => PopupMenuItem<String>(
                          value: action,
                          child: Text(action),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: actions.map((action) {
              final isSelected = provider.invoiceAction == action;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    child: Material(
                      color: isSelected ? colors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: () => provider.setInvoiceAction(action),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color:
                                  isSelected ? colors.primary : colors.outline,
                            ),
                          ),
                          child: Text(
                            action,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
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
    _weightFocusNode.dispose();
    _priceFocusNode.dispose();
    _packageWeightFocusNode.dispose();
    _packageNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _actionSelector(),
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
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: ListTile(title: Text(item)),
                      );
                    },
                    showSearchBox: true,
                  ),
                  onSelected: (value) =>
                      setState(() => _selectedProduct = value),
                ),
              ),
              verticalSpace(8),
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      textDirection: TextDirection.ltr,
                      controller: _weightController,
                      focusNode: _weightFocusNode,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => _focusField(_priceFocusNode),
                      labelText: 'الوزن أو العدد',
                      hintText: 'كجم',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _firstInvalidFocusNode ??= _weightFocusNode;
                          return 'رجاء أدخل الوزن';
                        }
                        if (double.tryParse(value) == null) {
                          _firstInvalidFocusNode ??= _weightFocusNode;
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
                      focusNode: _priceFocusNode,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          _focusField(_packageWeightFocusNode),
                      labelText: 'السعر',
                      hintText: 'جنيه',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _firstInvalidFocusNode ??= _priceFocusNode;
                          return 'رجاء أدخل السعر';
                        }
                        if (double.tryParse(value) == null) {
                          _firstInvalidFocusNode ??= _priceFocusNode;
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
                      focusNode: _packageWeightFocusNode,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          _focusField(_packageNumberFocusNode),
                      labelText: 'وزن العبوة',
                      suffixText: 'كجم',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _firstInvalidFocusNode ??= _packageWeightFocusNode;
                          return 'أدخل وزن العبوة الفارغة';
                        }
                        if (double.tryParse(value) == null) {
                          _firstInvalidFocusNode ??= _packageWeightFocusNode;
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
                      focusNode: _packageNumberFocusNode,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _handleAdd,
                      labelText: 'عدد الفارغ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _firstInvalidFocusNode ??= _packageNumberFocusNode;
                          return 'أدخل عدد العبوات أولا';
                        }
                        if (int.tryParse(value) == null) {
                          _firstInvalidFocusNode ??= _packageNumberFocusNode;
                          return 'ادخل رقم صالح';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              verticalSpace(10),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppTextButton(
                      onPressed: _handleAdd,
                      buttonText: 'أضف منتج',
                      textStyle: TextStyles.font16WhiteSemiBold.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonHeight: 52,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
