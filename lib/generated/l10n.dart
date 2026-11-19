// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Log out`
  String get logout {
    return Intl.message('Log out', name: 'logout', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Customers & suppliers`
  String get suppliers {
    return Intl.message('Customers & suppliers', name: 'suppliers', desc: '', args: []);
  }

  /// `Customers`
  String get customers {
    return Intl.message('Customers', name: 'customers', desc: '', args: []);
  }

  /// `Inventory`
  String get inventory {
    return Intl.message('Inventory', name: 'inventory', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message('Dark Mode', name: 'dark_mode', desc: '', args: []);
  }

  /// `Light Mode`
  String get light_mode {
    return Intl.message('Light Mode', name: 'light_mode', desc: '', args: []);
  }

  /// `Appearance`
  String get appearance {
    return Intl.message('Appearance', name: 'appearance', desc: '', args: []);
  }

  /// `System`
  String get system_mode {
    return Intl.message('System', name: 'system_mode', desc: '', args: []);
  }

  /// `Select Language`
  String get select_language {
    return Intl.message('Select Language', name: 'select_language', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Are you sure you want to log out?`
  String get are_you_sure_logout {
    return Intl.message('Are you sure you want to log out?', name: 'are_you_sure_logout', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Change Password`
  String get change_password {
    return Intl.message('Change Password', name: 'change_password', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message('Notifications', name: 'notifications', desc: '', args: []);
  }

  /// `Help`
  String get help {
    return Intl.message('Help', name: 'help', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Terms of Service`
  String get terms_of_service {
    return Intl.message('Terms of Service', name: 'terms_of_service', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message('Privacy Policy', name: 'privacy_policy', desc: '', args: []);
  }

  /// `Contact Us`
  String get contact_us {
    return Intl.message('Contact Us', name: 'contact_us', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `No results found`
  String get no_results_found {
    return Intl.message('No results found', name: 'no_results_found', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Share App`
  String get share_app {
    return Intl.message('Share App', name: 'share_app', desc: '', args: []);
  }

  /// `Update App`
  String get update_app {
    return Intl.message('Update App', name: 'update_app', desc: '', args: []);
  }

  /// `Total Cost`
  String get total_cost {
    return Intl.message('Total Cost', name: 'total_cost', desc: '', args: []);
  }

  /// `Page Not Found`
  String get page_not_found {
    return Intl.message('Page Not Found', name: 'page_not_found', desc: '', args: []);
  }

  /// `Please choose a customer before proceeding.`
  String get please_choose_customer {
    return Intl.message('Please choose a customer before proceeding.', name: 'please_choose_customer', desc: '', args: []);
  }

  /// `Invoice sent successfully`
  String get invoice_sent_successfully {
    return Intl.message('Invoice sent successfully', name: 'invoice_sent_successfully', desc: '', args: []);
  }

  /// `Privacy`
  String get privacy {
    return Intl.message('Privacy', name: 'privacy', desc: '', args: []);
  }

  /// `Invoice Management`
  String get invoice_management {
    return Intl.message('Invoice Management', name: 'invoice_management', desc: '', args: []);
  }

  /// `Invoice Templates`
  String get invoice_template {
    return Intl.message('Invoice Templates', name: 'invoice_template', desc: '', args: []);
  }

  /// `Manage and customize invoice formats`
  String get invoice_templated_desc {
    return Intl.message('Manage and customize invoice formats', name: 'invoice_templated_desc', desc: '', args: []);
  }

  /// `Edit invoice`
  String get editInvoice {
    return Intl.message('Edit invoice', name: 'editInvoice', desc: '', args: []);
  }

  /// `Customer name`
  String get customerName {
    return Intl.message('Customer name', name: 'customerName', desc: '', args: []);
  }

  /// `Invoice date and time`
  String get invoiceDateTime {
    return Intl.message('Invoice date and time', name: 'invoiceDateTime', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Invoice type`
  String get invoiceType {
    return Intl.message('Invoice type', name: 'invoiceType', desc: '', args: []);
  }

  /// `Unspecified`
  String get unspecified {
    return Intl.message('Unspecified', name: 'unspecified', desc: '', args: []);
  }

  /// `Products`
  String get products {
    return Intl.message('Products', name: 'products', desc: '', args: []);
  }

  /// `Add product`
  String get addProduct {
    return Intl.message('Add product', name: 'addProduct', desc: '', args: []);
  }

  /// `Product`
  String get product {
    return Intl.message('Product', name: 'product', desc: '', args: []);
  }

  /// `Remove product`
  String get removeProduct {
    return Intl.message('Remove product', name: 'removeProduct', desc: '', args: []);
  }

  /// `Product name`
  String get productName {
    return Intl.message('Product name', name: 'productName', desc: '', args: []);
  }

  /// `Weight`
  String get weight {
    return Intl.message('Weight', name: 'weight', desc: '', args: []);
  }

  /// `Package weight`
  String get packageWeight {
    return Intl.message('Package weight', name: 'packageWeight', desc: '', args: []);
  }

  /// `Package count`
  String get packageCount {
    return Intl.message('Package count', name: 'packageCount', desc: '', args: []);
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Amount paid`
  String get paidAmount {
    return Intl.message('Amount paid', name: 'paidAmount', desc: '', args: []);
  }

  /// `EGP`
  String get currency {
    return Intl.message('EGP', name: 'currency', desc: '', args: []);
  }

  /// `Invoice total`
  String get invoiceTotal {
    return Intl.message('Invoice total', name: 'invoiceTotal', desc: '', args: []);
  }

  /// `Outstanding balance`
  String get outstandingBalance {
    return Intl.message('Outstanding balance', name: 'outstandingBalance', desc: '', args: []);
  }

  /// `Enter a name`
  String get nameRequired {
    return Intl.message('Enter a name', name: 'nameRequired', desc: '', args: []);
  }

  /// `Enter a valid finite number`
  String get invalidNumber {
    return Intl.message('Enter a valid finite number', name: 'invalidNumber', desc: '', args: []);
  }

  /// `Enter a whole number`
  String get invalidInteger {
    return Intl.message('Enter a whole number', name: 'invalidInteger', desc: '', args: []);
  }

  /// `Add at least one product before saving.`
  String get invoiceNeedsProduct {
    return Intl.message('Add at least one product before saving.', name: 'invoiceNeedsProduct', desc: '', args: []);
  }

  /// `The stored date or time could not be parsed. Choose a replacement if needed.`
  String get legacyDatePickerHint {
    return Intl.message('The stored date or time could not be parsed. Choose a replacement if needed.', name: 'legacyDatePickerHint', desc: '', args: []);
  }

  /// `Purchase`
  String get purchase {
    return Intl.message('Purchase', name: 'purchase', desc: '', args: []);
  }

  /// `Sale`
  String get sale {
    return Intl.message('Sale', name: 'sale', desc: '', args: []);
  }

  /// `Storage`
  String get storage {
    return Intl.message('Storage', name: 'storage', desc: '', args: []);
  }

  /// `Could not save invoice changes`
  String get couldNotSaveInvoice {
    return Intl.message('Could not save invoice changes', name: 'couldNotSaveInvoice', desc: '', args: []);
  }

  /// `Save changes`
  String get saveChanges {
    return Intl.message('Save changes', name: 'saveChanges', desc: '', args: []);
  }

  /// `Storage value`
  String get storageInvoiceValue {
    return Intl.message('Storage value', name: 'storageInvoiceValue', desc: '', args: []);
  }

  /// `Stored net weight`
  String get storedNetWeight {
    return Intl.message('Stored net weight', name: 'storedNetWeight', desc: '', args: []);
  }

  /// `Storage invoices`
  String get storageInvoiceCount {
    return Intl.message('Storage invoices', name: 'storageInvoiceCount', desc: '', args: []);
  }

  /// `EGP`
  String get storageCurrency {
    return Intl.message('EGP', name: 'storageCurrency', desc: '', args: []);
  }

  /// `kg`
  String get kilograms {
    return Intl.message('kg', name: 'kilograms', desc: '', args: []);
  }

  /// `Search by serial or product name`
  String get customerInvoiceSearchHint {
    return Intl.message('Search by serial or product name', name: 'customerInvoiceSearchHint', desc: '', args: []);
  }

  /// `Search by serial, product or customer`
  String get allInvoicesSearchHint {
    return Intl.message('Search by serial, product or customer', name: 'allInvoicesSearchHint', desc: '', args: []);
  }

  /// `Recent invoices`
  String get recentInvoices {
    return Intl.message('Recent invoices', name: 'recentInvoices', desc: '', args: []);
  }

  /// `No invoices yet`
  String get noRecentInvoices {
    return Intl.message('No invoices yet', name: 'noRecentInvoices', desc: '', args: []);
  }

  /// `Clear search`
  String get clearInvoiceSearch {
    return Intl.message('Clear search', name: 'clearInvoiceSearch', desc: '', args: []);
  }

  /// `No invoices match your search`
  String get noInvoicesMatchSearch {
    return Intl.message('No invoices match your search', name: 'noInvoicesMatchSearch', desc: '', args: []);
  }

  /// `Invoice type`
  String get invoiceActionFilter {
    return Intl.message('Invoice type', name: 'invoiceActionFilter', desc: '', args: []);
  }

  /// `Invoice #`
  String get invoiceNumber {
    return Intl.message('Invoice #', name: 'invoiceNumber', desc: '', args: []);
  }

  /// `Date range`
  String get dateRangeFilter {
    return Intl.message('Date range', name: 'dateRangeFilter', desc: '', args: []);
  }

  /// `Select date range`
  String get selectDateRange {
    return Intl.message('Select date range', name: 'selectDateRange', desc: '', args: []);
  }

  /// `Clear date filter`
  String get clearDateFilter {
    return Intl.message('Clear date filter', name: 'clearDateFilter', desc: '', args: []);
  }

  /// `Payment status`
  String get paymentStatusFilter {
    return Intl.message('Payment status', name: 'paymentStatusFilter', desc: '', args: []);
  }

  /// `All`
  String get allInvoicesFilter {
    return Intl.message('All', name: 'allInvoicesFilter', desc: '', args: []);
  }

  /// `Paid`
  String get paidStatus {
    return Intl.message('Paid', name: 'paidStatus', desc: '', args: []);
  }

  /// `Partially paid`
  String get partiallyPaidStatus {
    return Intl.message('Partially paid', name: 'partiallyPaidStatus', desc: '', args: []);
  }

  /// `Unpaid`
  String get unpaidStatus {
    return Intl.message('Unpaid', name: 'unpaidStatus', desc: '', args: []);
  }

  /// `Reset filters`
  String get resetInvoiceFilters {
    return Intl.message('Reset filters', name: 'resetInvoiceFilters', desc: '', args: []);
  }

  /// `Invoice filters`
  String get invoiceFilters {
    return Intl.message('Invoice filters', name: 'invoiceFilters', desc: '', args: []);
  }

  /// `Apply`
  String get applyFilters {
    return Intl.message('Apply', name: 'applyFilters', desc: '', args: []);
  }

  /// `No invoices match the search or filters`
  String get noInvoicesMatchFilters {
    return Intl.message('No invoices match the search or filters', name: 'noInvoicesMatchFilters', desc: '', args: []);
  }

  /// `Issue invoice`
  String get invoice_screen_title {
    return Intl.message('Issue invoice', name: 'invoice_screen_title', desc: '', args: []);
  }

  /// `New invoice`
  String get new_invoice {
    return Intl.message('New invoice', name: 'new_invoice', desc: '', args: []);
  }

  /// `New`
  String get new_label {
    return Intl.message('New', name: 'new_label', desc: '', args: []);
  }

  /// `Delete saved invoice`
  String get delete_saved_invoice {
    return Intl.message('Delete saved invoice', name: 'delete_saved_invoice', desc: '', args: []);
  }

  /// `Only the current invoice data will be cleared. Saved invoices will not be deleted.`
  String get clear_draft_message {
    return Intl.message('Only the current invoice data will be cleared. Saved invoices will not be deleted.', name: 'clear_draft_message', desc: '', args: []);
  }

  /// `Are you sure you want to delete the saved invoice? This action cannot be undone.`
  String get delete_saved_invoice_confirm {
    return Intl.message('Are you sure you want to delete the saved invoice? This action cannot be undone.', name: 'delete_saved_invoice_confirm', desc: '', args: []);
  }

  /// `No saved invoice is open to delete`
  String get no_saved_invoice_to_delete {
    return Intl.message('No saved invoice is open to delete', name: 'no_saved_invoice_to_delete', desc: '', args: []);
  }

  /// `A new invoice is ready`
  String get new_invoice_ready {
    return Intl.message('A new invoice is ready', name: 'new_invoice_ready', desc: '', args: []);
  }

  /// `Invoice deleted. A new invoice is ready`
  String get invoice_deleted_new_ready {
    return Intl.message('Invoice deleted. A new invoice is ready', name: 'invoice_deleted_new_ready', desc: '', args: []);
  }

  /// `Could not save the invoice`
  String get save_invoice_failed {
    return Intl.message('Could not save the invoice', name: 'save_invoice_failed', desc: '', args: []);
  }

  /// `The invoice was saved, but sharing failed`
  String get share_invoice_failed {
    return Intl.message('The invoice was saved, but sharing failed', name: 'share_invoice_failed', desc: '', args: []);
  }

  /// `Invoice saved successfully`
  String get invoice_saved_successfully {
    return Intl.message('Invoice saved successfully', name: 'invoice_saved_successfully', desc: '', args: []);
  }

  /// `Preview`
  String get preview {
    return Intl.message('Preview', name: 'preview', desc: '', args: []);
  }

  /// `Collected`
  String get collected_amount_label {
    return Intl.message('Collected', name: 'collected_amount_label', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Share via WhatsApp`
  String get share_via_whatsapp {
    return Intl.message('Share via WhatsApp', name: 'share_via_whatsapp', desc: '', args: []);
  }

  /// `Grand total`
  String get grand_total {
    return Intl.message('Grand total', name: 'grand_total', desc: '', args: []);
  }

  /// `No products added`
  String get no_products_added {
    return Intl.message('No products added', name: 'no_products_added', desc: '', args: []);
  }

  /// `Start adding products to the invoice`
  String get start_adding_products {
    return Intl.message('Start adding products to the invoice', name: 'start_adding_products', desc: '', args: []);
  }

  /// `Please enter the collected amount`
  String get enter_collected_amount {
    return Intl.message('Please enter the collected amount', name: 'enter_collected_amount', desc: '', args: []);
  }

  /// `Product added successfully`
  String get product_added {
    return Intl.message('Product added successfully', name: 'product_added', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Please select the invoice type first`
  String get select_invoice_type_first {
    return Intl.message('Please select the invoice type first', name: 'select_invoice_type_first', desc: '', args: []);
  }

  /// `Please select a product`
  String get select_product {
    return Intl.message('Please select a product', name: 'select_product', desc: '', args: []);
  }

  /// `Could not access invoice data. Please try again.`
  String get data_unavailable {
    return Intl.message('Could not access invoice data. Please try again.', name: 'data_unavailable', desc: '', args: []);
  }

  /// `Invoice`
  String get invoice {
    return Intl.message('Invoice', name: 'invoice', desc: '', args: []);
  }

  /// `Change invoice type`
  String get change_invoice_type {
    return Intl.message('Change invoice type', name: 'change_invoice_type', desc: '', args: []);
  }

  /// `Select a product`
  String get select_product_hint {
    return Intl.message('Select a product', name: 'select_product_hint', desc: '', args: []);
  }

  /// `Weight or count`
  String get weight_or_count {
    return Intl.message('Weight or count', name: 'weight_or_count', desc: '', args: []);
  }

  /// `Please enter the weight`
  String get weight_required {
    return Intl.message('Please enter the weight', name: 'weight_required', desc: '', args: []);
  }

  /// `Please enter the price`
  String get price_required {
    return Intl.message('Please enter the price', name: 'price_required', desc: '', args: []);
  }

  /// `Enter the package count first`
  String get package_count_required {
    return Intl.message('Enter the package count first', name: 'package_count_required', desc: '', args: []);
  }

  /// `Enter the empty package weight`
  String get package_weight_required {
    return Intl.message('Enter the empty package weight', name: 'package_weight_required', desc: '', args: []);
  }

  /// `Enter at least 4 characters`
  String get customer_name_min_length {
    return Intl.message('Enter at least 4 characters', name: 'customer_name_min_length', desc: '', args: []);
  }

  /// `Could not load suggestions`
  String get error_loading_suggestions {
    return Intl.message('Could not load suggestions', name: 'error_loading_suggestions', desc: '', args: []);
  }

  /// `Could not save suggestions`
  String get error_saving_suggestions {
    return Intl.message('Could not save suggestions', name: 'error_saving_suggestions', desc: '', args: []);
  }

  /// `Could not add the suggestion`
  String get error_adding_suggestions {
    return Intl.message('Could not add the suggestion', name: 'error_adding_suggestions', desc: '', args: []);
  }

  /// `Could not submit the suggestion`
  String get error_submitting_suggestions {
    return Intl.message('Could not submit the suggestion', name: 'error_submitting_suggestions', desc: '', args: []);
  }

  /// `Suggestion removed`
  String get suggestion_removed {
    return Intl.message('Suggestion removed', name: 'suggestion_removed', desc: '', args: []);
  }

  /// `Weight details`
  String get weight_details {
    return Intl.message('Weight details', name: 'weight_details', desc: '', args: []);
  }

  /// `Totals`
  String get totals {
    return Intl.message('Totals', name: 'totals', desc: '', args: []);
  }

  /// `Product details`
  String get product_details {
    return Intl.message('Product details', name: 'product_details', desc: '', args: []);
  }

  /// `Confirm deletion`
  String get confirm_delete {
    return Intl.message('Confirm deletion', name: 'confirm_delete', desc: '', args: []);
  }

  /// `Are you sure you want to delete this product?`
  String get confirm_delete_product {
    return Intl.message('Are you sure you want to delete this product?', name: 'confirm_delete_product', desc: '', args: []);
  }

  /// `Net weight`
  String get net_weight {
    return Intl.message('Net weight', name: 'net_weight', desc: '', args: []);
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Total amount`
  String get total_amount {
    return Intl.message('Total amount', name: 'total_amount', desc: '', args: []);
  }

  /// `Remaining`
  String get remaining {
    return Intl.message('Remaining', name: 'remaining', desc: '', args: []);
  }

  /// `Customers and suppliers`
  String get customers_and_suppliers {
    return Intl.message('Customers and suppliers', name: 'customers_and_suppliers', desc: '', args: []);
  }

  /// `Invoice history`
  String get invoice_history {
    return Intl.message('Invoice history', name: 'invoice_history', desc: '', args: []);
  }

  /// `No invoices for this customer`
  String get no_customer_invoices {
    return Intl.message('No invoices for this customer', name: 'no_customer_invoices', desc: '', args: []);
  }

  /// `Net due to the customer`
  String get net_due_to_customer {
    return Intl.message('Net due to the customer', name: 'net_due_to_customer', desc: '', args: []);
  }

  /// `Net due to you`
  String get net_due_to_you {
    return Intl.message('Net due to you', name: 'net_due_to_you', desc: '', args: []);
  }

  /// `Account balanced`
  String get account_balanced {
    return Intl.message('Account balanced', name: 'account_balanced', desc: '', args: []);
  }

  /// `Purchases`
  String get purchases {
    return Intl.message('Purchases', name: 'purchases', desc: '', args: []);
  }

  /// `Sales`
  String get sales {
    return Intl.message('Sales', name: 'sales', desc: '', args: []);
  }

  /// `Invoice options`
  String get invoice_options {
    return Intl.message('Invoice options', name: 'invoice_options', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Are you sure you want to delete this invoice? This action cannot be undone.`
  String get confirm_delete_invoice {
    return Intl.message('Are you sure you want to delete this invoice?\nThis action cannot be undone.', name: 'confirm_delete_invoice', desc: '', args: []);
  }

  /// `Could not delete the invoice`
  String get could_not_delete_invoice {
    return Intl.message('Could not delete the invoice', name: 'could_not_delete_invoice', desc: '', args: []);
  }

  /// `Could not load the invoice history`
  String get could_not_load_invoices {
    return Intl.message('Could not load the invoice history', name: 'could_not_load_invoices', desc: '', args: []);
  }

  /// `Changes saved, but the invoice history could not be refreshed`
  String get invoice_saved_reload_failed {
    return Intl.message('Changes saved, but the invoice history could not be refreshed', name: 'invoice_saved_reload_failed', desc: '', args: []);
  }

  /// `Could not share the invoice`
  String get could_not_share_invoice {
    return Intl.message('Could not share the invoice', name: 'could_not_share_invoice', desc: '', args: []);
  }

  /// `1 invoice`
  String get invoice_count_one {
    return Intl.message('1 invoice', name: 'invoice_count_one', desc: '', args: []);
  }

  /// `2 invoices`
  String get invoice_count_two {
    return Intl.message('2 invoices', name: 'invoice_count_two', desc: '', args: []);
  }

  /// `invoices`
  String get invoices_few {
    return Intl.message('invoices', name: 'invoices_few', desc: '', args: []);
  }

  /// `invoices`
  String get invoices_many {
    return Intl.message('invoices', name: 'invoices_many', desc: '', args: []);
  }

  /// `Transaction`
  String get operation {
    return Intl.message('Transaction', name: 'operation', desc: '', args: []);
  }

  /// `Customer information`
  String get customer_info {
    return Intl.message('Customer information', name: 'customer_info', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Financial summary`
  String get financial_summary {
    return Intl.message('Financial summary', name: 'financial_summary', desc: '', args: []);
  }

  /// `Paid`
  String get paid {
    return Intl.message('Paid', name: 'paid', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Price per kg`
  String get price_per_kg {
    return Intl.message('Price per kg', name: 'price_per_kg', desc: '', args: []);
  }

  /// `Empty packages`
  String get empty_packages {
    return Intl.message('Empty packages', name: 'empty_packages', desc: '', args: []);
  }

  /// `Invoice settings`
  String get invoice_settings {
    return Intl.message('Invoice settings', name: 'invoice_settings', desc: '', args: []);
  }

  /// `Choose logo`
  String get choose_logo {
    return Intl.message('Choose logo', name: 'choose_logo', desc: '', args: []);
  }

  /// `Manager name`
  String get manager_name {
    return Intl.message('Manager name', name: 'manager_name', desc: '', args: []);
  }

  /// `Enter the manager name`
  String get enter_manager_name {
    return Intl.message('Enter the manager name', name: 'enter_manager_name', desc: '', args: []);
  }

  /// `Manager phone`
  String get manager_phone {
    return Intl.message('Manager phone', name: 'manager_phone', desc: '', args: []);
  }

  /// `Enter the phone number`
  String get enter_phone {
    return Intl.message('Enter the phone number', name: 'enter_phone', desc: '', args: []);
  }

  /// `Company name`
  String get company_name {
    return Intl.message('Company name', name: 'company_name', desc: '', args: []);
  }

  /// `Company description`
  String get company_description {
    return Intl.message('Company description', name: 'company_description', desc: '', args: []);
  }

  /// `QR data`
  String get qr_data {
    return Intl.message('QR data', name: 'qr_data', desc: '', args: []);
  }

  /// `Invoice settings saved`
  String get invoice_settings_saved {
    return Intl.message('Invoice settings saved', name: 'invoice_settings_saved', desc: '', args: []);
  }

  /// `Could not save invoice settings`
  String get could_not_save_settings {
    return Intl.message('Could not save invoice settings', name: 'could_not_save_settings', desc: '', args: []);
  }

  /// `Product management`
  String get product_management {
    return Intl.message('Product management', name: 'product_management', desc: '', args: []);
  }

  /// `Add, edit, and delete products`
  String get product_management_desc {
    return Intl.message('Add, edit, and delete products', name: 'product_management_desc', desc: '', args: []);
  }

  /// `Add new product`
  String get add_new_product {
    return Intl.message('Add new product', name: 'add_new_product', desc: '', args: []);
  }

  /// `Edit product`
  String get edit_product {
    return Intl.message('Edit product', name: 'edit_product', desc: '', args: []);
  }

  /// `Delete product`
  String get delete_product {
    return Intl.message('Delete product', name: 'delete_product', desc: '', args: []);
  }

  /// `Product added successfully`
  String get product_added_successfully {
    return Intl.message('Product added successfully', name: 'product_added_successfully', desc: '', args: []);
  }

  /// `Product updated successfully`
  String get product_updated_successfully {
    return Intl.message('Product updated successfully', name: 'product_updated_successfully', desc: '', args: []);
  }

  /// `Product deleted`
  String get product_deleted_successfully {
    return Intl.message('Product deleted', name: 'product_deleted_successfully', desc: '', args: []);
  }

  /// `Could not add the product`
  String get could_not_add_product {
    return Intl.message('Could not add the product', name: 'could_not_add_product', desc: '', args: []);
  }

  /// `Could not update the product`
  String get could_not_update_product {
    return Intl.message('Could not update the product', name: 'could_not_update_product', desc: '', args: []);
  }

  /// `Could not delete the product`
  String get could_not_delete_product {
    return Intl.message('Could not delete the product', name: 'could_not_delete_product', desc: '', args: []);
  }

  /// `No products`
  String get no_products {
    return Intl.message('No products', name: 'no_products', desc: '', args: []);
  }

  /// `Tap + to add a new product`
  String get tap_to_add_product {
    return Intl.message('Tap + to add a new product', name: 'tap_to_add_product', desc: '', args: []);
  }

  /// `Check out the Arqamy app on Google Play`
  String get share_app_message {
    return Intl.message('Check out the Arqamy app on Google Play', name: 'share_app_message', desc: '', args: []);
  }

  /// `Could not save the appearance setting`
  String get could_not_save_appearance {
    return Intl.message('Could not save the appearance setting', name: 'could_not_save_appearance', desc: '', args: []);
  }

  /// `Customer invoice`
  String get pdf_document_title {
    return Intl.message('Customer invoice', name: 'pdf_document_title', desc: '', args: []);
  }

  /// `Purchase invoice`
  String get pdf_purchase_invoice {
    return Intl.message('Purchase invoice', name: 'pdf_purchase_invoice', desc: '', args: []);
  }

  /// `Sale invoice`
  String get pdf_sale_invoice {
    return Intl.message('Sale invoice', name: 'pdf_sale_invoice', desc: '', args: []);
  }

  /// `Storage invoice`
  String get pdf_storage_invoice {
    return Intl.message('Storage invoice', name: 'pdf_storage_invoice', desc: '', args: []);
  }

  /// `Management`
  String get pdf_management {
    return Intl.message('Management', name: 'pdf_management', desc: '', args: []);
  }

  /// `Tel`
  String get pdf_phone {
    return Intl.message('Tel', name: 'pdf_phone', desc: '', args: []);
  }

  /// `Mr.`
  String get pdf_mr {
    return Intl.message('Mr.', name: 'pdf_mr', desc: '', args: []);
  }

  /// `Issued`
  String get pdf_issued {
    return Intl.message('Issued', name: 'pdf_issued', desc: '', args: []);
  }

  /// `Product summary`
  String get pdf_product_summary {
    return Intl.message('Product summary', name: 'pdf_product_summary', desc: '', args: []);
  }

  /// `Invoice total`
  String get pdf_invoice_total {
    return Intl.message('Invoice total', name: 'pdf_invoice_total', desc: '', args: []);
  }

  /// `Collected`
  String get pdf_collected {
    return Intl.message('Collected', name: 'pdf_collected', desc: '', args: []);
  }

  /// `Remaining`
  String get pdf_remaining {
    return Intl.message('Remaining', name: 'pdf_remaining', desc: '', args: []);
  }

  /// `Weight (kg)`
  String get weight_kg {
    return Intl.message('Weight (kg)', name: 'weight_kg', desc: '', args: []);
  }

  /// `Package weight (kg)`
  String get package_weight_kg {
    return Intl.message('Package weight (kg)', name: 'package_weight_kg', desc: '', args: []);
  }

  /// `Net weight (kg)`
  String get net_weight_kg {
    return Intl.message('Net weight (kg)', name: 'net_weight_kg', desc: '', args: []);
  }

  /// `Price (EGP)`
  String get price_egp {
    return Intl.message('Price (EGP)', name: 'price_egp', desc: '', args: []);
  }

  /// `Total (EGP)`
  String get total_egp {
    return Intl.message('Total (EGP)', name: 'total_egp', desc: '', args: []);
  }

  /// `Total price`
  String get total_price {
    return Intl.message('Total price', name: 'total_price', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
