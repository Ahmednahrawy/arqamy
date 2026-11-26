/// Localized headers used in exported invoice worksheets.
///
/// Kept independent from the widget-based `S` lookup so workbooks can be built
/// without a build context. Values mirror the matching entries in the ARB
/// files for the columns the exporter writes.
class ExcelLabels {
  const ExcelLabels({
    required this.isRtl,
    required this.serial,
    required this.date,
    required this.time,
    required this.customer,
    required this.type,
    required this.product,
    required this.weightKg,
    required this.packageWeightKg,
    required this.packageCount,
    required this.netWeightKg,
    required this.priceEgp,
    required this.totalEgp,
    required this.invoiceTotal,
    required this.collected,
    required this.remaining,
    required this.subtotal,
    required this.discount,
    required this.purchase,
    required this.sale,
    required this.storage,
  });

  final bool isRtl;
  final String serial;
  final String date;
  final String time;
  final String customer;
  final String type;
  final String product;
  final String weightKg;
  final String packageWeightKg;
  final String packageCount;
  final String netWeightKg;
  final String priceEgp;
  final String totalEgp;
  final String invoiceTotal;
  final String collected;
  final String remaining;
  final String subtotal;
  final String discount;
  final String purchase;
  final String sale;
  final String storage;

  static const ar = ExcelLabels(
    isRtl: true,
    serial: 'رقم الفاتورة',
    date: 'التاريخ',
    time: 'الوقت',
    customer: 'العميل',
    type: 'النوع',
    product: 'المنتج',
    weightKg: 'الوزن (كجم)',
    packageWeightKg: 'وزن العبوة (كجم)',
    packageCount: 'عدد العبوات',
    netWeightKg: 'صافي الوزن (كجم)',
    priceEgp: 'السعر (جنيه)',
    totalEgp: 'الإجمالي (جنيه)',
    invoiceTotal: 'إجمالي الفاتورة',
    collected: 'تحصيل',
    remaining: 'الباقي',
    subtotal: 'الإجمالي قبل الخصم',
    discount: 'خصم',
    purchase: 'شراء',
    sale: 'بيع',
    storage: 'تخزين',
  );

  static const en = ExcelLabels(
    isRtl: false,
    serial: 'Invoice serial',
    date: 'Date',
    time: 'Time',
    customer: 'Customer',
    type: 'Type',
    product: 'Product',
    weightKg: 'Weight (kg)',
    packageWeightKg: 'Package weight (kg)',
    packageCount: 'Package count',
    netWeightKg: 'Net weight (kg)',
    priceEgp: 'Price (EGP)',
    totalEgp: 'Total (EGP)',
    invoiceTotal: 'Invoice total',
    collected: 'Collected',
    remaining: 'Remaining',
    subtotal: 'Subtotal',
    discount: 'Discount',
    purchase: 'Purchase',
    sale: 'Sale',
    storage: 'Storage',
  );

  static ExcelLabels forLocale(String locale) =>
      locale.toLowerCase().startsWith('en') ? en : ar;
}
