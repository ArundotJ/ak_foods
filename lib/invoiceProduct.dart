final class InvoiceProduct {
  final String name;
  final double salesRate;
  final double quantity;
  final double quantityRtn;
  final double totalAmount;
  final double balance;
  final double totalPaid;
  final double grandTotal;

  InvoiceProduct(this.name, this.salesRate, this.quantity, this.quantityRtn,
      this.totalAmount, this.balance, this.totalPaid, this.grandTotal);

  factory InvoiceProduct.fromJson(Map<String, dynamic> json) {
    return InvoiceProduct(
      json['ProductName'],
      json['SalesRate'],
      json['Qty'],
      json['SubUnitQty'],
      json['TotalAmount'],
      json['Balance'],
      json['TotalPaid'],
      json['GrandTotal'],
    );
  }
}
