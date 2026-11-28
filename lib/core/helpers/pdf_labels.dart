/// Localized labels used by the generated PDF invoice.
///
/// Kept independent from the widget-based `S` lookup so invoices can be
/// generated without a build context (for example from background services and
/// tests). Values mirror the matching entries in the ARB files.
class PdfLabels {
  const PdfLabels({
    required this.isRtl,
    required this.documentTitle,
    required this.management,
    required this.phone,
    required this.invoice,
    required this.mr,
    required this.issued,
    required this.productSummary,
    required this.invoiceTotal,
    required this.collected,
    required this.remaining,
    required this.subtotal,
    required this.discount,
    required this.currency,
    required this.purchaseTitle,
    required this.saleTitle,
    required this.storageTitle,
    required this.product,
    required this.weightKg,
    required this.packageWeight,
    required this.packageWeightKg,
    required this.packageCount,
    required this.netWeightKg,
    required this.priceEgp,
    required this.totalEgp,
    required this.totalPrice,
    required this.kilograms,
  });

  final bool isRtl;
  final String documentTitle;
  final String management;
  final String phone;
  final String invoice;
  final String mr;
  final String issued;
  final String productSummary;
  final String invoiceTotal;
  final String collected;
  final String remaining;
  final String subtotal;
  final String discount;
  final String currency;
  final String purchaseTitle;
  final String saleTitle;
  final String storageTitle;
  final String product;
  final String weightKg;
  final String packageWeight;
  final String packageWeightKg;
  final String packageCount;
  final String netWeightKg;
  final String priceEgp;
  final String totalEgp;
  final String totalPrice;
  final String kilograms;

  static const ar = PdfLabels(
    isRtl: true,
    documentTitle: 'فاتورة العميل',
    management: 'إدارة',
    phone: 'ت',
    invoice: 'فاتورة',
    mr: 'السيد',
    issued: 'إصدار',
    productSummary: 'ملخص المنتجات',
    invoiceTotal: 'إجمالي الفاتورة',
    collected: 'تحصيل',
    remaining: 'الباقي',
    subtotal: 'الإجمالي قبل الخصم',
    discount: 'خصم',
    currency: 'ج.م',
    purchaseTitle: 'فاتورة مشتريات',
    saleTitle: 'فاتورة بيع',
    storageTitle: 'فاتورة تخزين',
    product: 'المنتج',
    weightKg: 'الوزن (كجم)',
    packageWeight: 'وزن العبوة',
    packageWeightKg: 'وزن العبوة (كجم)',
    packageCount: 'عدد العبوات',
    netWeightKg: 'صافي الوزن (كجم)',
    priceEgp: 'السعر (جنيه)',
    totalEgp: 'الإجمالي (جنيه)',
    totalPrice: 'إجمالي السعر',
    kilograms: 'كجم',
  );

  static const en = PdfLabels(
    isRtl: false,
    documentTitle: 'Customer invoice',
    management: 'Management',
    phone: 'Tel',
    invoice: 'Invoice',
    mr: 'Mr.',
    issued: 'Issued',
    productSummary: 'Product summary',
    invoiceTotal: 'Invoice total',
    collected: 'Collected',
    remaining: 'Remaining',
    subtotal: 'Subtotal',
    discount: 'Discount',
    currency: 'EGP',
    purchaseTitle: 'Purchase invoice',
    saleTitle: 'Sale invoice',
    storageTitle: 'Storage invoice',
    product: 'Product',
    weightKg: 'Weight (kg)',
    packageWeight: 'Package weight',
    packageWeightKg: 'Package weight (kg)',
    packageCount: 'Package count',
    netWeightKg: 'Net weight (kg)',
    priceEgp: 'Price (EGP)',
    totalEgp: 'Total (EGP)',
    totalPrice: 'Total price',
    kilograms: 'kg',
  );

  /// Note shown below the table when every package has the same weight.
  String packageWeightNote(String weight) =>
      '$packageWeight: $weight $kilograms';

  static PdfLabels forLocale(String locale) =>
      locale.toLowerCase().startsWith('en') ? en : ar;
}
