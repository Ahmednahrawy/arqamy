import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/core/helpers/money.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:material_ui/material_ui.dart' as mui;

import 'package:arqamy/core/helpers/invoice_action_l10n.dart';
import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/core/widgets/text_button.dart';
import 'package:arqamy/core/widgets/text_form_field.dart';
import 'package:arqamy/config/theme/styles.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/generated/l10n.dart';

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
  final List<String> actions = InvoiceActionL10n.actions;

  String? _selectedProduct;

  final _weightController = TextEditingController();
  final _packageWeightController = TextEditingController(text: "2");
  final _packageNumberController = TextEditingController(text: "0");
  final _priceController = TextEditingController();
  final _weightFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _packageWeightFocusNode = FocusNode();
  final _packageNumberFocusNode = FocusNode();
  String _packageWeightDefaultText = '2';
  String _packageNumberDefaultText = '0';
  bool _showPackageWeight = true;
  bool _showPackageNumber = true;
  FocusNode? _firstInvalidFocusNode;
  final Map<TextEditingController, DateTime> _lastClearTaps = {};
  @override
  void initState() {
    super.initState();

    // Defaults are read once so a new invoice starts from the saved values.
    final settings = context.read<InvoiceSettingsProvider>();
    _packageWeightDefaultText = _formatDefaultNumber(
      settings.defaultPackageWeight,
    );
    _packageNumberDefaultText = settings.defaultPackageNumber.toString();
    _packageWeightController.text = _packageWeightDefaultText;
    _packageNumberController.text = _packageNumberDefaultText;
    _showPackageWeight = settings.showPackageWeight;
    _showPackageNumber = settings.showPackageNumber;

    _packageNumberFocusNode.addListener(() {
      if (_packageNumberFocusNode.hasFocus &&
          _packageNumberController.text == _packageNumberDefaultText) {
        _packageNumberController.clear();
      }
    });
    // Load products when form initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadMasterProducts();
    });
  }

  static String _formatDefaultNumber(double value) =>
      value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  void _clearFields() {
    _weightController.clear();
    // _priceController.clear();
    _packageWeightController.text = _packageWeightDefaultText;
    _packageNumberController.text = _packageNumberDefaultText;

    // _selectedProduct = null;
    // _action = null;
    setState(() {});
  }

  void _handleAdd() {
    final provider = context.read<InvoiceProvider>();
    final strings = S.of(context);

    // Ensure invoice action chosen at provider level
    if (provider.invoiceAction == null) {
      _showErrorSnackBar(strings.select_invoice_type_first);
      return;
    }

    if (_selectedProduct == null) {
      _showErrorSnackBar(strings.select_product);
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

    final settings = context.read<InvoiceSettingsProvider>();
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final packageWeight = _showPackageWeight
        ? double.tryParse(_packageWeightController.text) ?? 0.0
        : settings.defaultPackageWeight;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final numberPackage = _showPackageNumber
        ? int.tryParse(_packageNumberController.text) ?? 0
        : settings.defaultPackageNumber;
    final product = Product(
      name: _selectedProduct!,
      weight: weight,
      packageWeight: packageWeight,
      price: price,
      numberPackage: numberPackage,
      // action: _action!,
    );
    if (Money.tryFromDouble(product.netWeight * product.price) == null) {
      _showErrorSnackBar(strings.invalidNumber);
      return;
    }
    if (widget.onAdd != null) {
      widget.onAdd!(product);
    } else {
      try {
        provider.addProduct(product);
      } catch (e) {
        _showErrorSnackBar(strings.data_unavailable);
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

  Widget? _clearIcon(
    TextEditingController controller,
    FocusNode focusNode,
    String tooltip,
  ) {
    if (controller.text.isEmpty) return null;
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final now = DateTime.now();
          final last = _lastClearTaps[controller];
          if (last != null &&
              now.difference(last) < const Duration(milliseconds: 500)) {
            _lastClearTaps.remove(controller);
            setState(controller.clear);
            focusNode.requestFocus();
            return;
          }
          _lastClearTaps[controller] = now;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.close,
            size: 16,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _actionSelector() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        final colors = Theme.of(context).colorScheme;
        final strings = S.of(context);
        if (provider.invoiceAction != null) {
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(
                    '${strings.invoice}: '
                    '${InvoiceActionL10n.label(provider.invoiceAction, strings)}',
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: strings.change_invoice_type,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onSelected: provider.setInvoiceAction,
                  itemBuilder: (context) => actions
                      .where((action) => action != provider.invoiceAction)
                      .map(
                        (action) => PopupMenuItem<String>(
                          value: action,
                          child: Text(InvoiceActionL10n.label(action, strings)),
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
                              color: isSelected
                                  ? colors.primary
                                  : colors.outline,
                            ),
                          ),
                          child: Text(
                            InvoiceActionL10n.label(action, strings),
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
    final strings = S.of(context);
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
                builder: (context, provider, _) => mui.Material(
                  color: Colors.transparent,
                  child: DropdownSearch<String>(
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    items: (filter, _) => provider.masterProductList,
                    selectedItem: _selectedProduct,
                    decoratorProps: DropDownDecoratorProps(
                      decoration: mui.InputDecoration(
                        labelText: strings.product,
                        suffixIcon: const Icon(Icons.search),
                        hintText: strings.select_product_hint,
                        border: const mui.OutlineInputBorder(),
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      fit: FlexFit.tight,
                      itemBuilder: (context, item, isDisabled, isSelected) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Material(child: ListTile(title: Text(item))),
                        );
                      },
                      showSearchBox: true,
                    ),
                    onSelected: (value) {
                      setState(() {
                        _selectedProduct = value;
                        final action = InvoiceAction.tryParse(
                          provider.invoiceAction,
                        );
                        final defaultPrice = value == null || action == null
                            ? null
                            : provider.defaultProductPrice(value, action);
                        _priceController.text = defaultPrice == null
                            ? ''
                            : defaultPrice.toStringAsFixed(2);
                      });
                    },
                  ),
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
                      labelText: strings.weight_or_count,
                      hintText: strings.kilograms,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _firstInvalidFocusNode ??= _weightFocusNode;
                          return strings.weight_required;
                        }
                        if (double.tryParse(value) == null) {
                          _firstInvalidFocusNode ??= _weightFocusNode;
                          return strings.invalidNumber;
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
                      onEditingComplete: () {
                        if (_showPackageWeight) {
                          _focusField(_packageWeightFocusNode);
                        } else if (_showPackageNumber) {
                          _focusField(_packageNumberFocusNode);
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      },
                      labelText: strings.price,
                      hintText: strings.currency,
                      suffixIcon: _clearIcon(
                        _priceController,
                        _priceFocusNode,
                        strings.clear_field,
                      ),
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _firstInvalidFocusNode ??= _priceFocusNode;
                          return strings.price_required;
                        }
                        if (double.tryParse(value) == null) {
                          _firstInvalidFocusNode ??= _priceFocusNode;
                          return strings.invalidNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (_showPackageWeight || _showPackageNumber) ...[
                verticalSpace(8),
                Row(
                  children: [
                    if (_showPackageNumber)
                      Expanded(
                        child: AppTextFormField(
                          textDirection: TextDirection.ltr,
                          controller: _packageNumberController,
                          focusNode: _packageNumberFocusNode,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _handleAdd,
                          labelText: strings.packageCount,
                          digitsOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              _firstInvalidFocusNode ??=
                                  _packageNumberFocusNode;
                              return strings.package_count_required;
                            }
                            if (int.tryParse(value) == null) {
                              _firstInvalidFocusNode ??=
                                  _packageNumberFocusNode;
                              return strings.invalidNumber;
                            }
                            return null;
                          },
                        ),
                      ),
                    if (_showPackageNumber && _showPackageWeight)
                      horizontalSpace(8),
                    if (_showPackageWeight)
                      Expanded(
                        child: AppTextFormField(
                          textDirection: TextDirection.ltr,
                          controller: _packageWeightController,
                          focusNode: _packageWeightFocusNode,
                          textInputAction: _showPackageNumber
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onEditingComplete: () {
                            if (_showPackageNumber) {
                              _focusField(_packageNumberFocusNode);
                            } else {
                              FocusScope.of(context).unfocus();
                            }
                          },
                          labelText: strings.packageWeight,
                          suffixText: strings.kilograms,
                          suffixIcon: _clearIcon(
                            _packageWeightController,
                            _packageWeightFocusNode,
                            strings.clear_field,
                          ),
                          onChanged: (_) => setState(() {}),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              _firstInvalidFocusNode ??=
                                  _packageWeightFocusNode;
                              return strings.package_weight_required;
                            }
                            if (double.tryParse(value) == null) {
                              _firstInvalidFocusNode ??=
                                  _packageWeightFocusNode;
                              return strings.invalidNumber;
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ],
              verticalSpace(10),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppTextButton(
                      onPressed: _handleAdd,
                      buttonText: strings.addProduct,
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
