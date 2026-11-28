// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "Use at least ${count} characters";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "account_balanced": MessageLookupByLibrary.simpleMessage(
      "Account balanced",
    ),
    "addProduct": MessageLookupByLibrary.simpleMessage("Add product"),
    "add_discount": MessageLookupByLibrary.simpleMessage("Add discount"),
    "add_new_product": MessageLookupByLibrary.simpleMessage("Add new product"),
    "allInvoicesFilter": MessageLookupByLibrary.simpleMessage("All"),
    "allInvoicesSearchHint": MessageLookupByLibrary.simpleMessage(
      "Search by serial, product or customer",
    ),
    "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "applyFilters": MessageLookupByLibrary.simpleMessage("Apply"),
    "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "are_you_sure_logout": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "auth_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirm password",
    ),
    "auth_confirm_password_required": MessageLookupByLibrary.simpleMessage(
      "Confirm your password",
    ),
    "auth_email": MessageLookupByLibrary.simpleMessage("Email"),
    "auth_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Enter a valid email address",
    ),
    "auth_email_required": MessageLookupByLibrary.simpleMessage(
      "Enter your email",
    ),
    "auth_error_email_in_use": MessageLookupByLibrary.simpleMessage(
      "An account with this email already exists",
    ),
    "auth_error_network": MessageLookupByLibrary.simpleMessage(
      "No internet connection. Check your connection and try again.",
    ),
    "auth_error_service_unavailable": MessageLookupByLibrary.simpleMessage(
      "Sign-in is not available right now. Try again later.",
    ),
    "auth_error_too_many_requests": MessageLookupByLibrary.simpleMessage(
      "Too many attempts. Try again later.",
    ),
    "auth_error_unknown": MessageLookupByLibrary.simpleMessage(
      "Something went wrong. Please try again.",
    ),
    "auth_error_user_disabled": MessageLookupByLibrary.simpleMessage(
      "This account has been disabled",
    ),
    "auth_error_weak_password": MessageLookupByLibrary.simpleMessage(
      "This password is too weak",
    ),
    "auth_error_wrong_credentials": MessageLookupByLibrary.simpleMessage(
      "Incorrect email or password",
    ),
    "auth_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Forgot password?",
    ),
    "auth_have_account": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "auth_hide_password": MessageLookupByLibrary.simpleMessage("Hide password"),
    "auth_no_account": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "auth_password": MessageLookupByLibrary.simpleMessage("Password"),
    "auth_password_required": MessageLookupByLibrary.simpleMessage(
      "Enter your password",
    ),
    "auth_password_too_short": m0,
    "auth_passwords_do_not_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "auth_reset_link_sent": MessageLookupByLibrary.simpleMessage(
      "If an account exists for this email, a reset link has been sent.",
    ),
    "auth_reset_password_intro": MessageLookupByLibrary.simpleMessage(
      "Enter your email and we will send you a link to reset your password.",
    ),
    "auth_reset_password_title": MessageLookupByLibrary.simpleMessage(
      "Reset password",
    ),
    "auth_send_reset_link": MessageLookupByLibrary.simpleMessage(
      "Send reset link",
    ),
    "auth_show_password": MessageLookupByLibrary.simpleMessage("Show password"),
    "auth_sign_in": MessageLookupByLibrary.simpleMessage("Sign in"),
    "auth_sign_up": MessageLookupByLibrary.simpleMessage("Create account"),
    "backup_failed": MessageLookupByLibrary.simpleMessage(
      "Could not create the backup",
    ),
    "backup_invoices": MessageLookupByLibrary.simpleMessage("Back up invoices"),
    "backup_invoices_desc": MessageLookupByLibrary.simpleMessage(
      "Save all invoices to a file you can keep safe",
    ),
    "backup_no_invoices": MessageLookupByLibrary.simpleMessage(
      "There are no invoices to back up yet",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "change_invoice_type": MessageLookupByLibrary.simpleMessage(
      "Change invoice type",
    ),
    "change_password": MessageLookupByLibrary.simpleMessage("Change Password"),
    "choose_logo": MessageLookupByLibrary.simpleMessage("Choose logo"),
    "clearDateFilter": MessageLookupByLibrary.simpleMessage(
      "Clear date filter",
    ),
    "clearInvoiceSearch": MessageLookupByLibrary.simpleMessage("Clear search"),
    "clear_discount": MessageLookupByLibrary.simpleMessage("Clear discount"),
    "clear_draft_message": MessageLookupByLibrary.simpleMessage(
      "Only the current invoice data will be cleared. Saved invoices will not be deleted.",
    ),
    "clear_field": MessageLookupByLibrary.simpleMessage("Double-tap to clear"),
    "clear_text": MessageLookupByLibrary.simpleMessage("Clear"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "collected_amount_label": MessageLookupByLibrary.simpleMessage("Collected"),
    "column_customer": MessageLookupByLibrary.simpleMessage("Customer"),
    "column_date": MessageLookupByLibrary.simpleMessage("Date"),
    "column_net_weight": MessageLookupByLibrary.simpleMessage("Net weight"),
    "column_package_count": MessageLookupByLibrary.simpleMessage(
      "Package count",
    ),
    "column_package_weight": MessageLookupByLibrary.simpleMessage(
      "Package weight",
    ),
    "column_price": MessageLookupByLibrary.simpleMessage("Price"),
    "column_product": MessageLookupByLibrary.simpleMessage("Product"),
    "column_serial": MessageLookupByLibrary.simpleMessage("Invoice #"),
    "column_show_all": MessageLookupByLibrary.simpleMessage("Show all"),
    "column_time": MessageLookupByLibrary.simpleMessage("Time"),
    "column_total": MessageLookupByLibrary.simpleMessage("Total"),
    "column_type": MessageLookupByLibrary.simpleMessage("Type"),
    "column_visibility_description": MessageLookupByLibrary.simpleMessage(
      "Show or hide columns in exported invoices",
    ),
    "column_weight": MessageLookupByLibrary.simpleMessage("Weight"),
    "company_description": MessageLookupByLibrary.simpleMessage(
      "Company description",
    ),
    "company_info_on_invoice": MessageLookupByLibrary.simpleMessage(
      "Company info shown on invoice",
    ),
    "company_name": MessageLookupByLibrary.simpleMessage("Company name"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirm_delete": MessageLookupByLibrary.simpleMessage("Confirm deletion"),
    "confirm_delete_invoice": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this invoice?\nThis action cannot be undone.",
    ),
    "confirm_delete_product": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this product?",
    ),
    "contact_us": MessageLookupByLibrary.simpleMessage("Contact Us"),
    "couldNotSaveInvoice": MessageLookupByLibrary.simpleMessage(
      "Could not save invoice changes",
    ),
    "could_not_add_product": MessageLookupByLibrary.simpleMessage(
      "Could not add the product",
    ),
    "could_not_delete_invoice": MessageLookupByLibrary.simpleMessage(
      "Could not delete the invoice",
    ),
    "could_not_delete_product": MessageLookupByLibrary.simpleMessage(
      "Could not delete the product",
    ),
    "could_not_load_invoices": MessageLookupByLibrary.simpleMessage(
      "Could not load the invoice history",
    ),
    "could_not_save_appearance": MessageLookupByLibrary.simpleMessage(
      "Could not save the appearance setting",
    ),
    "could_not_save_settings": MessageLookupByLibrary.simpleMessage(
      "Could not save invoice settings",
    ),
    "could_not_share_invoice": MessageLookupByLibrary.simpleMessage(
      "Could not share the invoice",
    ),
    "could_not_update_product": MessageLookupByLibrary.simpleMessage(
      "Could not update the product",
    ),
    "currency": MessageLookupByLibrary.simpleMessage("EGP"),
    "customerInvoiceSearchHint": MessageLookupByLibrary.simpleMessage(
      "Search by serial or product name",
    ),
    "customerName": MessageLookupByLibrary.simpleMessage("Customer name"),
    "customer_info": MessageLookupByLibrary.simpleMessage(
      "Customer information",
    ),
    "customer_name_min_length": MessageLookupByLibrary.simpleMessage(
      "Enter at least 4 characters",
    ),
    "customers": MessageLookupByLibrary.simpleMessage("Customers"),
    "customers_and_suppliers": MessageLookupByLibrary.simpleMessage(
      "Customers and suppliers",
    ),
    "dark_mode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "data_unavailable": MessageLookupByLibrary.simpleMessage(
      "Could not access invoice data. Please try again.",
    ),
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "dateRangeFilter": MessageLookupByLibrary.simpleMessage("Date range"),
    "default_package_count": MessageLookupByLibrary.simpleMessage(
      "Default package count",
    ),
    "default_package_weight": MessageLookupByLibrary.simpleMessage(
      "Default package weight",
    ),
    "default_price_optional": MessageLookupByLibrary.simpleMessage(
      "Default price (optional)",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_product": MessageLookupByLibrary.simpleMessage("Delete product"),
    "delete_saved_invoice": MessageLookupByLibrary.simpleMessage(
      "Delete saved invoice",
    ),
    "delete_saved_invoice_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete the saved invoice? This action cannot be undone.",
    ),
    "discount": MessageLookupByLibrary.simpleMessage("Discount"),
    "discount_amount": MessageLookupByLibrary.simpleMessage("Discount amount"),
    "discount_exceeds_total": MessageLookupByLibrary.simpleMessage(
      "Discount cannot exceed the invoice total",
    ),
    "discount_percent": MessageLookupByLibrary.simpleMessage(
      "Discount percent",
    ),
    "discount_percent_range": MessageLookupByLibrary.simpleMessage(
      "Percent must be between 0 and 100",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editInvoice": MessageLookupByLibrary.simpleMessage("Edit invoice"),
    "edit_product": MessageLookupByLibrary.simpleMessage("Edit product"),
    "empty_packages": MessageLookupByLibrary.simpleMessage("Empty packages"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enter_collected_amount": MessageLookupByLibrary.simpleMessage(
      "Please enter the collected amount",
    ),
    "enter_manager_name": MessageLookupByLibrary.simpleMessage(
      "Enter the manager name",
    ),
    "enter_phone": MessageLookupByLibrary.simpleMessage(
      "Enter the phone number",
    ),
    "error_adding_suggestions": MessageLookupByLibrary.simpleMessage(
      "Could not add the suggestion",
    ),
    "error_loading_suggestions": MessageLookupByLibrary.simpleMessage(
      "Could not load suggestions",
    ),
    "error_saving_suggestions": MessageLookupByLibrary.simpleMessage(
      "Could not save suggestions",
    ),
    "error_submitting_suggestions": MessageLookupByLibrary.simpleMessage(
      "Could not submit the suggestion",
    ),
    "excel_columns": MessageLookupByLibrary.simpleMessage("Excel Columns"),
    "exportToExcel": MessageLookupByLibrary.simpleMessage("Export Excel"),
    "export_products": MessageLookupByLibrary.simpleMessage("Export products"),
    "financial_summary": MessageLookupByLibrary.simpleMessage(
      "Financial summary",
    ),
    "grand_total": MessageLookupByLibrary.simpleMessage("Grand total"),
    "help": MessageLookupByLibrary.simpleMessage("Help"),
    "help_backup_body": MessageLookupByLibrary.simpleMessage(
      "In Settings, open Invoice actions and choose Backup invoices to save a copy.",
    ),
    "help_backup_title": MessageLookupByLibrary.simpleMessage(
      "Backing up invoices",
    ),
    "help_contact_body": MessageLookupByLibrary.simpleMessage(
      "Contact the app support team for further assistance.",
    ),
    "help_contact_title": MessageLookupByLibrary.simpleMessage(
      "Need more help?",
    ),
    "help_create_invoice_body": MessageLookupByLibrary.simpleMessage(
      "Open the home screen, choose a customer, add products, then save the invoice.",
    ),
    "help_create_invoice_title": MessageLookupByLibrary.simpleMessage(
      "Creating an invoice",
    ),
    "help_intro": MessageLookupByLibrary.simpleMessage(
      "Find answers to common questions about using Arqamy.",
    ),
    "help_language_body": MessageLookupByLibrary.simpleMessage(
      "Open the side menu and use the Language row to switch between Arabic and English.",
    ),
    "help_language_title": MessageLookupByLibrary.simpleMessage(
      "Changing the language",
    ),
    "help_restore_body": MessageLookupByLibrary.simpleMessage(
      "In Settings, open Invoice actions and choose Restore from backup.",
    ),
    "help_restore_title": MessageLookupByLibrary.simpleMessage(
      "Restoring invoices",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "import_action": MessageLookupByLibrary.simpleMessage("Restore"),
    "import_products": MessageLookupByLibrary.simpleMessage("Import products"),
    "invalidInteger": MessageLookupByLibrary.simpleMessage(
      "Enter a whole number",
    ),
    "invalidNumber": MessageLookupByLibrary.simpleMessage(
      "Enter a valid finite number",
    ),
    "invalid_default_package_count": MessageLookupByLibrary.simpleMessage(
      "Enter a whole package count of zero or more",
    ),
    "invalid_default_package_weight": MessageLookupByLibrary.simpleMessage(
      "Enter a package weight of zero or more",
    ),
    "invalid_default_price": MessageLookupByLibrary.simpleMessage(
      "Enter a default price of zero or more",
    ),
    "inventory": MessageLookupByLibrary.simpleMessage("Inventory"),
    "inventory_empty": MessageLookupByLibrary.simpleMessage(
      "No inventory items yet",
    ),
    "inventory_items": MessageLookupByLibrary.simpleMessage("Inventory items"),
    "inventory_low_stock": MessageLookupByLibrary.simpleMessage("Low stock"),
    "inventory_minimum": MessageLookupByLibrary.simpleMessage("Min"),
    "inventory_total_items": MessageLookupByLibrary.simpleMessage("Items"),
    "inventory_total_quantity": MessageLookupByLibrary.simpleMessage("Units"),
    "invoice": MessageLookupByLibrary.simpleMessage("Invoice"),
    "invoiceActionFilter": MessageLookupByLibrary.simpleMessage("Invoice type"),
    "invoiceDateTime": MessageLookupByLibrary.simpleMessage(
      "Invoice date and time",
    ),
    "invoiceFilters": MessageLookupByLibrary.simpleMessage("Invoice filters"),
    "invoiceNeedsProduct": MessageLookupByLibrary.simpleMessage(
      "Add at least one product before saving.",
    ),
    "invoiceNumber": MessageLookupByLibrary.simpleMessage("Invoice #"),
    "invoiceTotal": MessageLookupByLibrary.simpleMessage("Invoice total"),
    "invoiceType": MessageLookupByLibrary.simpleMessage("Invoice type"),
    "invoice_actions": MessageLookupByLibrary.simpleMessage("Invoice actions"),
    "invoice_count_one": MessageLookupByLibrary.simpleMessage("1 invoice"),
    "invoice_count_two": MessageLookupByLibrary.simpleMessage("2 invoices"),
    "invoice_deleted_new_ready": MessageLookupByLibrary.simpleMessage(
      "Invoice deleted. A new invoice is ready",
    ),
    "invoice_excel_export_failed": MessageLookupByLibrary.simpleMessage(
      "Could not export the invoice to Excel",
    ),
    "invoice_exported_to_excel": MessageLookupByLibrary.simpleMessage(
      "Invoice exported to Excel",
    ),
    "invoice_history": MessageLookupByLibrary.simpleMessage("Invoice history"),
    "invoice_management": MessageLookupByLibrary.simpleMessage(
      "Invoice Management",
    ),
    "invoice_options": MessageLookupByLibrary.simpleMessage("Invoice options"),
    "invoice_saved_reload_failed": MessageLookupByLibrary.simpleMessage(
      "Changes saved, but the invoice history could not be refreshed",
    ),
    "invoice_saved_successfully": MessageLookupByLibrary.simpleMessage(
      "Invoice saved successfully",
    ),
    "invoice_screen_title": MessageLookupByLibrary.simpleMessage(
      "Issue invoice",
    ),
    "invoice_sent_successfully": MessageLookupByLibrary.simpleMessage(
      "Invoice sent successfully",
    ),
    "invoice_settings": MessageLookupByLibrary.simpleMessage(
      "Invoice settings",
    ),
    "invoice_settings_saved": MessageLookupByLibrary.simpleMessage(
      "Invoice settings saved",
    ),
    "invoice_template": MessageLookupByLibrary.simpleMessage(
      "Invoice Templates",
    ),
    "invoice_templated_desc": MessageLookupByLibrary.simpleMessage(
      "Manage and customize invoice formats",
    ),
    "invoices_few": MessageLookupByLibrary.simpleMessage("invoices"),
    "invoices_many": MessageLookupByLibrary.simpleMessage("invoices"),
    "kilograms": MessageLookupByLibrary.simpleMessage("kg"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "ledger_import": MessageLookupByLibrary.simpleMessage("Import to ledger"),
    "ledger_import_accounts": MessageLookupByLibrary.simpleMessage(
      "Accounts created",
    ),
    "ledger_import_action": MessageLookupByLibrary.simpleMessage("Import"),
    "ledger_import_already": MessageLookupByLibrary.simpleMessage(
      "Already imported",
    ),
    "ledger_import_confirm": MessageLookupByLibrary.simpleMessage(
      "A backup is saved first. Invoices that are ready are copied into the ledger in Egyptian pounds (EGP). Your saved invoices are not changed, and invoices that need a decision are skipped.",
    ),
    "ledger_import_desc": MessageLookupByLibrary.simpleMessage(
      "Debug preview: copy invoices into the payment ledger",
    ),
    "ledger_import_failed": MessageLookupByLibrary.simpleMessage(
      "Could not import to the ledger",
    ),
    "ledger_import_held": MessageLookupByLibrary.simpleMessage(
      "Held for a decision",
    ),
    "ledger_import_imported": MessageLookupByLibrary.simpleMessage(
      "Invoices imported",
    ),
    "ledger_import_missing_customer": MessageLookupByLibrary.simpleMessage(
      "Skipped: customer not found",
    ),
    "ledger_import_nothing": MessageLookupByLibrary.simpleMessage(
      "No invoices are ready to import. Link customers first, or check the held invoices.",
    ),
    "ledger_import_ready": MessageLookupByLibrary.simpleMessage(
      "Ready to import",
    ),
    "legacyDatePickerHint": MessageLookupByLibrary.simpleMessage(
      "The stored date or time could not be parsed. Choose a replacement if needed.",
    ),
    "light_mode": MessageLookupByLibrary.simpleMessage("Light Mode"),
    "link_customers": MessageLookupByLibrary.simpleMessage("Link customers"),
    "link_customers_action": MessageLookupByLibrary.simpleMessage("Link"),
    "link_customers_confirm": MessageLookupByLibrary.simpleMessage(
      "A backup is saved first. Invoices whose customer name has a single spelling are linked to a customer record. Names with several spellings are left for you to confirm later.",
    ),
    "link_customers_created": MessageLookupByLibrary.simpleMessage(
      "Customers created",
    ),
    "link_customers_desc": MessageLookupByLibrary.simpleMessage(
      "Debug preview: give each customer a stable ID",
    ),
    "link_customers_failed": MessageLookupByLibrary.simpleMessage(
      "Could not link customers",
    ),
    "link_customers_linked": MessageLookupByLibrary.simpleMessage(
      "Invoices linked",
    ),
    "link_customers_need_confirmation": MessageLookupByLibrary.simpleMessage(
      "Customers needing confirmation",
    ),
    "link_customers_reused": MessageLookupByLibrary.simpleMessage(
      "Existing customers reused",
    ),
    "link_customers_unnamed": MessageLookupByLibrary.simpleMessage(
      "Invoices without a name",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "manager_name": MessageLookupByLibrary.simpleMessage("Manager name"),
    "manager_phone": MessageLookupByLibrary.simpleMessage("Manager phone"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameRequired": MessageLookupByLibrary.simpleMessage("Enter a name"),
    "net_due_to_customer": MessageLookupByLibrary.simpleMessage(
      "Net due to the customer",
    ),
    "net_due_to_you": MessageLookupByLibrary.simpleMessage("Net due to you"),
    "net_weight": MessageLookupByLibrary.simpleMessage("Net weight"),
    "net_weight_kg": MessageLookupByLibrary.simpleMessage("Net weight (kg)"),
    "new_invoice": MessageLookupByLibrary.simpleMessage("New invoice"),
    "new_invoice_ready": MessageLookupByLibrary.simpleMessage(
      "A new invoice is ready",
    ),
    "new_label": MessageLookupByLibrary.simpleMessage("New"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noInvoicesMatchFilters": MessageLookupByLibrary.simpleMessage(
      "No invoices match the search or filters",
    ),
    "noInvoicesMatchSearch": MessageLookupByLibrary.simpleMessage(
      "No invoices match your search",
    ),
    "noProductsMatchSearch": MessageLookupByLibrary.simpleMessage(
      "No products match your search",
    ),
    "noRecentInvoices": MessageLookupByLibrary.simpleMessage("No invoices yet"),
    "no_customer_invoices": MessageLookupByLibrary.simpleMessage(
      "No invoices for this customer",
    ),
    "no_products": MessageLookupByLibrary.simpleMessage("No products"),
    "no_products_added": MessageLookupByLibrary.simpleMessage(
      "No products added",
    ),
    "no_results_found": MessageLookupByLibrary.simpleMessage(
      "No results found",
    ),
    "no_saved_invoice_to_delete": MessageLookupByLibrary.simpleMessage(
      "No saved invoice is open to delete",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "operation": MessageLookupByLibrary.simpleMessage("Transaction"),
    "order_defaults": MessageLookupByLibrary.simpleMessage("Order defaults"),
    "other_invoice_info": MessageLookupByLibrary.simpleMessage(
      "Other invoice info",
    ),
    "outstandingBalance": MessageLookupByLibrary.simpleMessage(
      "Outstanding balance",
    ),
    "packageCount": MessageLookupByLibrary.simpleMessage("Package count"),
    "packageWeight": MessageLookupByLibrary.simpleMessage("Package weight"),
    "package_count_required": MessageLookupByLibrary.simpleMessage(
      "Enter the package count first",
    ),
    "package_weight_kg": MessageLookupByLibrary.simpleMessage(
      "Package weight (kg)",
    ),
    "package_weight_required": MessageLookupByLibrary.simpleMessage(
      "Enter the empty package weight",
    ),
    "page_not_found": MessageLookupByLibrary.simpleMessage("Page Not Found"),
    "paid": MessageLookupByLibrary.simpleMessage("Paid"),
    "paidAmount": MessageLookupByLibrary.simpleMessage("Amount paid"),
    "paidStatus": MessageLookupByLibrary.simpleMessage("Paid"),
    "partiallyPaidStatus": MessageLookupByLibrary.simpleMessage(
      "Partially paid",
    ),
    "paymentStatusFilter": MessageLookupByLibrary.simpleMessage(
      "Payment status",
    ),
    "pdf_collected": MessageLookupByLibrary.simpleMessage("Collected"),
    "pdf_columns": MessageLookupByLibrary.simpleMessage("PDF Columns"),
    "pdf_document_title": MessageLookupByLibrary.simpleMessage(
      "Customer invoice",
    ),
    "pdf_invoice_total": MessageLookupByLibrary.simpleMessage("Invoice total"),
    "pdf_issued": MessageLookupByLibrary.simpleMessage("Issued"),
    "pdf_management": MessageLookupByLibrary.simpleMessage("Management"),
    "pdf_mr": MessageLookupByLibrary.simpleMessage("Mr."),
    "pdf_phone": MessageLookupByLibrary.simpleMessage("Tel"),
    "pdf_product_summary": MessageLookupByLibrary.simpleMessage(
      "Product summary",
    ),
    "pdf_purchase_invoice": MessageLookupByLibrary.simpleMessage(
      "Purchase invoice",
    ),
    "pdf_remaining": MessageLookupByLibrary.simpleMessage("Remaining"),
    "pdf_sale_invoice": MessageLookupByLibrary.simpleMessage("Sale invoice"),
    "pdf_storage_invoice": MessageLookupByLibrary.simpleMessage(
      "Storage invoice",
    ),
    "please_choose_customer": MessageLookupByLibrary.simpleMessage(
      "Please choose a customer before proceeding.",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "price": MessageLookupByLibrary.simpleMessage("Price"),
    "price_egp": MessageLookupByLibrary.simpleMessage("Price (EGP)"),
    "price_per_kg": MessageLookupByLibrary.simpleMessage("Price per kg"),
    "price_required": MessageLookupByLibrary.simpleMessage(
      "Please enter the price",
    ),
    "privacy": MessageLookupByLibrary.simpleMessage("Privacy"),
    "privacy_account_body": MessageLookupByLibrary.simpleMessage(
      "You can use Arqamy without an account. If you create one, your email address and sign-in details are stored by Google\'s Firebase Authentication so you can sign in and reset your password. Your invoices and customer details are not uploaded.",
    ),
    "privacy_account_title": MessageLookupByLibrary.simpleMessage(
      "Optional account",
    ),
    "privacy_choices_body": MessageLookupByLibrary.simpleMessage(
      "You can back up or restore your invoices from Settings at any time, and clear app data through your device settings.",
    ),
    "privacy_choices_title": MessageLookupByLibrary.simpleMessage(
      "Your choices",
    ),
    "privacy_data_body": MessageLookupByLibrary.simpleMessage(
      "Invoice details, customer names, products, and settings are saved locally on your device.",
    ),
    "privacy_data_title": MessageLookupByLibrary.simpleMessage(
      "Data stored on your device",
    ),
    "privacy_intro": MessageLookupByLibrary.simpleMessage(
      "Arqamy keeps your invoices and customer details on this device. We do not collect or share them.",
    ),
    "privacy_policy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "privacy_usage_body": MessageLookupByLibrary.simpleMessage(
      "Your data is only used to display, organize, and back up your invoices inside the app.",
    ),
    "privacy_usage_title": MessageLookupByLibrary.simpleMessage(
      "How we use your data",
    ),
    "product": MessageLookupByLibrary.simpleMessage("Product"),
    "productName": MessageLookupByLibrary.simpleMessage("Product name"),
    "productSearchHint": MessageLookupByLibrary.simpleMessage(
      "Search products",
    ),
    "product_added": MessageLookupByLibrary.simpleMessage(
      "Product added successfully",
    ),
    "product_added_successfully": MessageLookupByLibrary.simpleMessage(
      "Product added successfully",
    ),
    "product_already_exists": MessageLookupByLibrary.simpleMessage(
      "A product with this name already exists",
    ),
    "product_deleted_successfully": MessageLookupByLibrary.simpleMessage(
      "Product deleted",
    ),
    "product_details": MessageLookupByLibrary.simpleMessage("Product details"),
    "product_management": MessageLookupByLibrary.simpleMessage(
      "Product management",
    ),
    "product_management_desc": MessageLookupByLibrary.simpleMessage(
      "Add, edit, and delete products",
    ),
    "product_updated_successfully": MessageLookupByLibrary.simpleMessage(
      "Product updated successfully",
    ),
    "products": MessageLookupByLibrary.simpleMessage("Products"),
    "products_export_empty": MessageLookupByLibrary.simpleMessage(
      "There are no products to export",
    ),
    "products_export_failed": MessageLookupByLibrary.simpleMessage(
      "Could not export products",
    ),
    "products_import_confirm": MessageLookupByLibrary.simpleMessage(
      "Restoring will replace your current products and default prices. Continue?",
    ),
    "products_import_empty": MessageLookupByLibrary.simpleMessage(
      "The file contains no products",
    ),
    "products_import_failed": MessageLookupByLibrary.simpleMessage(
      "Could not restore products",
    ),
    "products_imported": MessageLookupByLibrary.simpleMessage(
      "Products restored",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "purchase": MessageLookupByLibrary.simpleMessage("Purchase"),
    "purchases": MessageLookupByLibrary.simpleMessage("Purchases"),
    "qr_data": MessageLookupByLibrary.simpleMessage("QR data"),
    "quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "recentInvoices": MessageLookupByLibrary.simpleMessage("Recent invoices"),
    "remaining": MessageLookupByLibrary.simpleMessage("Remaining"),
    "removeProduct": MessageLookupByLibrary.simpleMessage("Remove product"),
    "resetInvoiceFilters": MessageLookupByLibrary.simpleMessage(
      "Reset filters",
    ),
    "reset_action": MessageLookupByLibrary.simpleMessage("Reset"),
    "reset_defaults_confirm": MessageLookupByLibrary.simpleMessage(
      "Reset all invoice settings and order defaults?",
    ),
    "reset_to_defaults": MessageLookupByLibrary.simpleMessage(
      "Reset to defaults",
    ),
    "restore_action": MessageLookupByLibrary.simpleMessage("Restore"),
    "restore_confirm_message": MessageLookupByLibrary.simpleMessage(
      "Invoices from the backup will be merged with your saved invoices. A saved invoice with the same ID is replaced by the backup copy. All other saved invoices are kept.",
    ),
    "restore_done": MessageLookupByLibrary.simpleMessage("Backup restored"),
    "restore_empty_backup": MessageLookupByLibrary.simpleMessage(
      "The backup contains no invoices",
    ),
    "restore_failed": MessageLookupByLibrary.simpleMessage(
      "Could not restore the backup",
    ),
    "restore_invalid_backup": MessageLookupByLibrary.simpleMessage(
      "This is not a valid invoice backup",
    ),
    "restore_invoices": MessageLookupByLibrary.simpleMessage(
      "Restore from backup",
    ),
    "restore_invoices_desc": MessageLookupByLibrary.simpleMessage(
      "Add invoices from a backup file",
    ),
    "restore_new_invoices": MessageLookupByLibrary.simpleMessage(
      "New invoices",
    ),
    "restore_replaced_invoices": MessageLookupByLibrary.simpleMessage(
      "Invoices to replace",
    ),
    "restore_settings_included": MessageLookupByLibrary.simpleMessage(
      "Invoice settings will also be restored.",
    ),
    "sale": MessageLookupByLibrary.simpleMessage("Sale"),
    "sales": MessageLookupByLibrary.simpleMessage("Sales"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save changes"),
    "save_invoice_failed": MessageLookupByLibrary.simpleMessage(
      "Could not save the invoice",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "selectDateRange": MessageLookupByLibrary.simpleMessage(
      "Select date range",
    ),
    "select_invoice_type_first": MessageLookupByLibrary.simpleMessage(
      "Please select the invoice type first",
    ),
    "select_language": MessageLookupByLibrary.simpleMessage("Select Language"),
    "select_product": MessageLookupByLibrary.simpleMessage(
      "Please select a product",
    ),
    "select_product_hint": MessageLookupByLibrary.simpleMessage(
      "Select a product",
    ),
    "send": MessageLookupByLibrary.simpleMessage("Send"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "share_app": MessageLookupByLibrary.simpleMessage("Share App"),
    "share_app_message": MessageLookupByLibrary.simpleMessage(
      "Check out the Arqamy app on Google Play",
    ),
    "share_invoice_bundle_via_whatsapp": MessageLookupByLibrary.simpleMessage(
      "Send PDF + Excel via WhatsApp",
    ),
    "share_invoice_failed": MessageLookupByLibrary.simpleMessage(
      "The invoice was saved, but sharing failed",
    ),
    "share_via_whatsapp": MessageLookupByLibrary.simpleMessage(
      "Share via WhatsApp",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "show_package_number": MessageLookupByLibrary.simpleMessage(
      "Show package count field",
    ),
    "show_package_weight": MessageLookupByLibrary.simpleMessage(
      "Show package weight field",
    ),
    "start_adding_products": MessageLookupByLibrary.simpleMessage(
      "Start adding products to the invoice",
    ),
    "storage": MessageLookupByLibrary.simpleMessage("Storage"),
    "storageCurrency": MessageLookupByLibrary.simpleMessage("EGP"),
    "storageInvoiceCount": MessageLookupByLibrary.simpleMessage(
      "Storage invoices",
    ),
    "storageInvoiceValue": MessageLookupByLibrary.simpleMessage(
      "Storage value",
    ),
    "storedNetWeight": MessageLookupByLibrary.simpleMessage(
      "Stored net weight",
    ),
    "subtotal": MessageLookupByLibrary.simpleMessage("Subtotal"),
    "suggestion_removed": MessageLookupByLibrary.simpleMessage(
      "Suggestion removed",
    ),
    "suppliers": MessageLookupByLibrary.simpleMessage("Customers & suppliers"),
    "switch_to_amount": MessageLookupByLibrary.simpleMessage(
      "Switch to amount",
    ),
    "switch_to_percent": MessageLookupByLibrary.simpleMessage(
      "Switch to percent",
    ),
    "system_mode": MessageLookupByLibrary.simpleMessage("System"),
    "tap_to_add_product": MessageLookupByLibrary.simpleMessage(
      "Tap + to add a new product",
    ),
    "terms_of_service": MessageLookupByLibrary.simpleMessage(
      "Terms of Service",
    ),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "total_amount": MessageLookupByLibrary.simpleMessage("Total amount"),
    "total_cost": MessageLookupByLibrary.simpleMessage("Total Cost"),
    "total_egp": MessageLookupByLibrary.simpleMessage("Total (EGP)"),
    "total_price": MessageLookupByLibrary.simpleMessage("Total price"),
    "totals": MessageLookupByLibrary.simpleMessage("Totals"),
    "unpaidStatus": MessageLookupByLibrary.simpleMessage("Unpaid"),
    "unspecified": MessageLookupByLibrary.simpleMessage("Unspecified"),
    "update_app": MessageLookupByLibrary.simpleMessage("Update App"),
    "weight": MessageLookupByLibrary.simpleMessage("Weight"),
    "weight_details": MessageLookupByLibrary.simpleMessage("Weight details"),
    "weight_kg": MessageLookupByLibrary.simpleMessage("Weight (kg)"),
    "weight_or_count": MessageLookupByLibrary.simpleMessage("Weight or count"),
    "weight_required": MessageLookupByLibrary.simpleMessage(
      "Please enter the weight",
    ),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
