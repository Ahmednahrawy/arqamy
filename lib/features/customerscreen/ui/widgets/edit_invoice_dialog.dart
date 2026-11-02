import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/core/helpers/invoice_date_parser.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
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
  static const _actions = ['شراء', 'بيع', 'تخزين'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _paidController;
  late final TextEditingController _customerNameController;
  late final List<_ProductDraft> _products;
  late String? _invoiceAction;
  late String _formattedDate;
  late String _formattedTime;
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  bool _saving = false;
  double? _previewTotal;
  double? _previewRest;

  @override
  void initState() {
    super.initState();
    _paidController = TextEditingController(
      text: widget.invoice.paid.toString(),
    );
    _customerNameController = TextEditingController(
      text: widget.invoice.customerName,
    );
    _products = widget.invoice.products.map(_ProductDraft.fromProduct).toList();
    _invoiceAction = widget.invoice.invoiceAction;
    _formattedDate = widget.invoice.formattedDate;
    _formattedTime = widget.invoice.formattedTime;
    _selectedDate = _parseStoredDate(widget.invoice.formattedDate);
    _selectedTime = _parseStoredTime(widget.invoice.formattedTime);
    _previewTotal = widget.invoice.totalCost;
    _previewRest = widget.invoice.rest;
  }

  @override
  void dispose() {
    _paidController.dispose();
    _customerNameController.dispose();
    for (final product in _products) {
      product.dispose();
    }
    super.dispose();
  }

  String get _locale => Localizations.localeOf(context).languageCode;

  double? _parseFiniteDouble(String value) {
    final parsed = double.tryParse(value.trim());
    return parsed != null && parsed.isFinite ? parsed : null;
  }

  List<Product>? _readProducts() {
    final products = <Product>[];
    for (final draft in _products) {
      final weight = _parseFiniteDouble(draft.weight.text);
      final packageWeight = _parseFiniteDouble(draft.packageWeight.text);
      final numberPackage = int.tryParse(draft.numberPackage.text.trim());
      final price = _parseFiniteDouble(draft.price.text);
      if (weight == null ||
          packageWeight == null ||
          numberPackage == null ||
          price == null ||
          draft.name.text.trim().isEmpty) {
        return null;
      }
      products.add(
        Product(
          name: draft.name.text.trim(),
          weight: weight,
          packageWeight: packageWeight,
          numberPackage: numberPackage,
          price: price,
        ),
      );
    }
    return products;
  }

  void _refreshPreview() {
    final products = _readProducts();
    final paid = _parseFiniteDouble(_paidController.text);
    setState(() {
      _previewTotal = products == null
          ? null
          : InvoiceProvider.calculateInvoiceTotal(products);
      _previewRest = _previewTotal == null || paid == null
          ? null
          : InvoiceProvider.calculateOutstandingBalance(_previewTotal!, paid);
    });
  }

  DateTime? _parseStoredDate(String value) {
    return InvoiceDateParser.parseDate(value);
  }

  TimeOfDay? _parseStoredTime(String value) {
    return InvoiceDateParser.parseTime(value);
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (!mounted || selectedDate == null) return;
    setState(() {
      _selectedDate = selectedDate;
      _formattedDate = intl.DateFormat.yMMMd(_locale).format(selectedDate);
    });
  }

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (!mounted || selectedTime == null) return;
    setState(() {
      _selectedTime = selectedTime;
      _formattedTime = intl.DateFormat.Hm(_locale).format(
        DateTime(2000, 1, 1, selectedTime.hour, selectedTime.minute),
      );
    });
  }

  Future<void> _saveChanges() async {
    final strings = S.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final products = _readProducts();
    if (products == null || products.isEmpty) {
      showAppSnackBar(context, strings.invoiceNeedsProduct, isError: true);
      return;
    }

    final paid = _parseFiniteDouble(_paidController.text)!;
    final totalCost = InvoiceProvider.calculateInvoiceTotal(products);
    final updatedInvoice = Invoice(
      id: widget.invoice.id,
      customerName: _customerNameController.text.trim(),
      products: products,
      totalCost: totalCost,
      paid: paid,
      rest: InvoiceProvider.calculateOutstandingBalance(totalCost, paid),
      formattedDate: _formattedDate,
      formattedTime: _formattedTime,
      invoiceAction: _invoiceAction,
      invoiceSerial: widget.invoice.invoiceSerial,
    );

    setState(() => _saving = true);
    try {
      await context.read<InvoiceProvider>().updateInvoice(updatedInvoice);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(
        context,
        '${strings.couldNotSaveInvoice}: $error',
        isError: true,
      );
      return;
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final colors = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);

    return Directionality(
      textDirection: Directionality.of(context),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 720,
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.82,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${strings.editInvoice} #${widget.invoice.invoiceSerial}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('customer-name'),
                      controller: _customerNameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: strings.customerName,
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? strings.nameRequired
                              : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDateTimeControls(strings, colors),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('invoice-action'),
                      initialValue: _actions.contains(_invoiceAction)
                          ? _invoiceAction
                          : null,
                      decoration: InputDecoration(
                        labelText: strings.invoiceType,
                        prefixIcon: const Icon(Icons.swap_horiz),
                      ),
                      hint: Text(_invoiceAction ?? strings.unspecified),
                      items: [
                        ..._actions.map(
                          (action) => DropdownMenuItem(
                            value: action,
                            child: Text(_localizedAction(action, strings)),
                          ),
                        ),
                        if (_invoiceAction != null &&
                            !_actions.contains(_invoiceAction))
                          DropdownMenuItem(
                            value: _invoiceAction,
                            child: Text(_invoiceAction!),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _invoiceAction = value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            strings.products,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        TextButton.icon(
                          key: const ValueKey('add-product'),
                          onPressed: () {
                            setState(
                                () => _products.add(_ProductDraft.empty()));
                            _refreshPreview();
                          },
                          icon: const Icon(Icons.add),
                          label: Text(strings.addProduct),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_products.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          strings.invoiceNeedsProduct,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ),
                    ..._products.asMap().entries.map(
                          (entry) => _buildProductEditor(
                            entry.value,
                            entry.key,
                            strings,
                            colors,
                          ),
                        ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('paid-amount'),
                      controller: _paidController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textDirection: TextDirection.ltr,
                      onChanged: (_) => _refreshPreview(),
                      decoration: InputDecoration(
                        labelText: strings.paidAmount,
                        suffixText: strings.currency,
                        prefixIcon: const Icon(Icons.payments_outlined),
                      ),
                      validator: (value) =>
                          _parseFiniteDouble(value ?? '') == null
                              ? strings.invalidNumber
                              : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFinancialPreview(strings, colors, semanticColors),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              _saving ? null : () => Navigator.pop(context),
                          child: Text(strings.cancel),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _saving ? null : _saveChanges,
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(strings.saveChanges),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _localizedAction(String action, S strings) => switch (action) {
        'شراء' => strings.purchase,
        'بيع' => strings.sale,
        'تخزين' => strings.storage,
        _ => action,
      };

  Widget _buildDateTimeControls(S strings, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(strings.invoiceDateTime,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              key: const ValueKey('select-invoice-date'),
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${strings.date}: $_formattedDate',
              ),
            ),
            OutlinedButton.icon(
              key: const ValueKey('select-invoice-time'),
              onPressed: _selectTime,
              icon: const Icon(Icons.schedule),
              label: Text(
                '${strings.time}: $_formattedTime',
              ),
            ),
          ],
        ),
        if (_selectedDate == null || _selectedTime == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              strings.legacyDatePickerHint,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildProductEditor(
    _ProductDraft draft,
    int index,
    S strings,
    ColorScheme colors,
  ) {
    return Card(
      key: ValueKey('product-row-$index'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${strings.product} ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  key: ValueKey('remove-product-$index'),
                  tooltip: strings.removeProduct,
                  onPressed: () {
                    setState(() => _products.removeAt(index).dispose());
                    _refreshPreview();
                  },
                  icon: Icon(Icons.delete_outline, color: colors.error),
                ),
              ],
            ),
            TextFormField(
              key: ValueKey('product-name-$index'),
              controller: draft.name,
              onChanged: (_) => _refreshPreview(),
              decoration: InputDecoration(labelText: strings.productName),
              validator: (value) => value == null || value.trim().isEmpty
                  ? strings.nameRequired
                  : null,
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final fieldWidth = (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: _numberField(
                        key: ValueKey('product-weight-$index'),
                        controller: draft.weight,
                        label: strings.weight,
                        error: strings.invalidNumber,
                        onChanged: _refreshPreview,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _numberField(
                        key: ValueKey('product-package-weight-$index'),
                        controller: draft.packageWeight,
                        label: strings.packageWeight,
                        error: strings.invalidNumber,
                        onChanged: _refreshPreview,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        key: ValueKey('product-package-count-$index'),
                        controller: draft.numberPackage,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        onChanged: (_) => _refreshPreview(),
                        decoration:
                            InputDecoration(labelText: strings.packageCount),
                        validator: (value) =>
                            int.tryParse((value ?? '').trim()) == null
                                ? strings.invalidInteger
                                : null,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _numberField(
                        key: ValueKey('product-price-$index'),
                        controller: draft.price,
                        label: strings.price,
                        error: strings.invalidNumber,
                        onChanged: _refreshPreview,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String error,
    required VoidCallback onChanged,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textDirection: TextDirection.ltr,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          _parseFiniteDouble(value ?? '') == null ? error : null,
    );
  }

  Widget _buildFinancialPreview(
    S strings,
    ColorScheme colors,
    AppSemanticColors semanticColors,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _previewRow(strings.invoiceTotal, _previewTotal, colors),
          const SizedBox(height: 8),
          _previewRow(
            strings.outstandingBalance,
            _previewRest,
            colors,
            valueColor: _previewRest == 0
                ? semanticColors.success
                : semanticColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _previewRow(
    String label,
    double? value,
    ColorScheme colors, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value == null ? '—' : value.toStringAsFixed(2),
          style: TextStyle(
            color: valueColor ?? colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ProductDraft {
  _ProductDraft({
    required this.name,
    required this.weight,
    required this.packageWeight,
    required this.numberPackage,
    required this.price,
  });

  factory _ProductDraft.fromProduct(Product product) => _ProductDraft(
        name: TextEditingController(text: product.name),
        weight: TextEditingController(text: product.weight.toString()),
        packageWeight:
            TextEditingController(text: product.packageWeight.toString()),
        numberPackage:
            TextEditingController(text: product.numberPackage.toString()),
        price: TextEditingController(text: product.price.toString()),
      );

  factory _ProductDraft.empty() => _ProductDraft(
        name: TextEditingController(),
        weight: TextEditingController(),
        packageWeight: TextEditingController(text: '0'),
        numberPackage: TextEditingController(text: '0'),
        price: TextEditingController(text: '0'),
      );

  final TextEditingController name;
  final TextEditingController weight;
  final TextEditingController packageWeight;
  final TextEditingController numberPackage;
  final TextEditingController price;

  void dispose() {
    name.dispose();
    weight.dispose();
    packageWeight.dispose();
    numberPackage.dispose();
    price.dispose();
  }
}
