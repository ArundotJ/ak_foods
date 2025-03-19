final class Invoice {
  final int inv_ID;
  final String? invoiceNo;
  final String? invoiceDate;
  final int? customer_ID;
  final double? subTotal;
  final double? total;
  final double? grandTotal;
  final double? totalPaid;

  Invoice(this.inv_ID, this.invoiceNo, this.invoiceDate, this.customer_ID,
      this.subTotal, this.total, this.grandTotal, this.totalPaid);

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
        json['Inv_ID'],
        json['InvoiceNo'],
        json['InvoiceDate'],
        json['Customer_ID'],
        json['SubTotal'],
        json['Total'],
        json['GrandTotal'],
        json['TotalPaid']);
  }
}
