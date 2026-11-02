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

  /// `Suppliers`
  String get suppliers {
    return Intl.message('Suppliers', name: 'suppliers', desc: '', args: []);
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
    return Intl.message(
      'Select Language',
      name: 'select_language',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'are_you_sure_logout',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Change Password',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Terms of Service',
      name: 'terms_of_service',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us`
  String get contact_us {
    return Intl.message('Contact Us', name: 'contact_us', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Search by serial or product name`
  String get customerInvoiceSearchHint {
    return Intl.message(
      'Search by serial or product name',
      name: 'customerInvoiceSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Search by serial, product or customer`
  String get allInvoicesSearchHint {
    return Intl.message(
      'Search by serial, product or customer',
      name: 'allInvoicesSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Recent invoices`
  String get recentInvoices {
    return Intl.message(
      'Recent invoices',
      name: 'recentInvoices',
      desc: '',
      args: [],
    );
  }

  /// `No invoices yet`
  String get noRecentInvoices {
    return Intl.message(
      'No invoices yet',
      name: 'noRecentInvoices',
      desc: '',
      args: [],
    );
  }

  /// `Clear search`
  String get clearInvoiceSearch {
    return Intl.message(
      'Clear search',
      name: 'clearInvoiceSearch',
      desc: '',
      args: [],
    );
  }

  /// `No invoices match your search`
  String get noInvoicesMatchSearch {
    return Intl.message(
      'No invoices match your search',
      name: 'noInvoicesMatchSearch',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get no_results_found {
    return Intl.message(
      'No results found',
      name: 'no_results_found',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Page Not Found',
      name: 'page_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Please choose a customer before proceeding.`
  String get please_choose_customer {
    return Intl.message(
      'Please choose a customer before proceeding.',
      name: 'please_choose_customer',
      desc: '',
      args: [],
    );
  }

  /// `Invoice sent successfully`
  String get invoice_sent_successfully {
    return Intl.message(
      'Invoice sent successfully',
      name: 'invoice_sent_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacy {
    return Intl.message('Privacy', name: 'privacy', desc: '', args: []);
  }

  /// `Invoice Management`
  String get invoice_management {
    return Intl.message(
      'Invoice Management',
      name: 'invoice_management',
      desc: '',
      args: [],
    );
  }

  /// `Invoice Templates`
  String get invoice_template {
    return Intl.message(
      'Invoice Templates',
      name: 'invoice_template',
      desc: '',
      args: [],
    );
  }

  /// `Manage and customize invoice formats`
  String get invoice_templated_desc {
    return Intl.message(
      'Manage and customize invoice formats',
      name: 'invoice_templated_desc',
      desc: '',
      args: [],
    );
  }

  /// `Edit invoice`
  String get editInvoice {
    return Intl.message(
      'Edit invoice',
      name: 'editInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Customer name`
  String get customerName {
    return Intl.message(
      'Customer name',
      name: 'customerName',
      desc: '',
      args: [],
    );
  }

  /// `Invoice date and time`
  String get invoiceDateTime {
    return Intl.message(
      'Invoice date and time',
      name: 'invoiceDateTime',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Invoice type',
      name: 'invoiceType',
      desc: '',
      args: [],
    );
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

  /// `Item`
  String get product {
    return Intl.message('Item', name: 'product', desc: '', args: []);
  }

  /// `Remove item`
  String get removeProduct {
    return Intl.message(
      'Remove item',
      name: 'removeProduct',
      desc: '',
      args: [],
    );
  }

  /// `Product name`
  String get productName {
    return Intl.message(
      'Product name',
      name: 'productName',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get weight {
    return Intl.message('Weight', name: 'weight', desc: '', args: []);
  }

  /// `Package weight`
  String get packageWeight {
    return Intl.message(
      'Package weight',
      name: 'packageWeight',
      desc: '',
      args: [],
    );
  }

  /// `Package count`
  String get packageCount {
    return Intl.message(
      'Package count',
      name: 'packageCount',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Invoice total',
      name: 'invoiceTotal',
      desc: '',
      args: [],
    );
  }

  /// `Outstanding balance`
  String get outstandingBalance {
    return Intl.message(
      'Outstanding balance',
      name: 'outstandingBalance',
      desc: '',
      args: [],
    );
  }

  /// `Enter a name`
  String get nameRequired {
    return Intl.message(
      'Enter a name',
      name: 'nameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid finite number`
  String get invalidNumber {
    return Intl.message(
      'Enter a valid finite number',
      name: 'invalidNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter a whole number`
  String get invalidInteger {
    return Intl.message(
      'Enter a whole number',
      name: 'invalidInteger',
      desc: '',
      args: [],
    );
  }

  /// `Add at least one product before saving.`
  String get invoiceNeedsProduct {
    return Intl.message(
      'Add at least one product before saving.',
      name: 'invoiceNeedsProduct',
      desc: '',
      args: [],
    );
  }

  /// `The stored date or time could not be parsed. Choose a replacement if needed.`
  String get legacyDatePickerHint {
    return Intl.message(
      'The stored date or time could not be parsed. Choose a replacement if needed.',
      name: 'legacyDatePickerHint',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Could not save invoice changes',
      name: 'couldNotSaveInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Save changes`
  String get saveChanges {
    return Intl.message(
      'Save changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Storage value`
  String get storageInvoiceValue {
    return Intl.message(
      'Storage value',
      name: 'storageInvoiceValue',
      desc: '',
      args: [],
    );
  }

  /// `Stored net weight`
  String get storedNetWeight {
    return Intl.message(
      'Stored net weight',
      name: 'storedNetWeight',
      desc: '',
      args: [],
    );
  }

  /// `Storage invoices`
  String get storageInvoiceCount {
    return Intl.message(
      'Storage invoices',
      name: 'storageInvoiceCount',
      desc: '',
      args: [],
    );
  }

  /// `EGP`
  String get storageCurrency {
    return Intl.message('EGP', name: 'storageCurrency', desc: '', args: []);
  }

  /// `kg`
  String get kilograms {
    return Intl.message('kg', name: 'kilograms', desc: '', args: []);
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
