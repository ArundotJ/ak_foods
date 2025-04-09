final class InvoiceProduct {
  final String name;
  final double salesRate;
  final double quantity;
  final double quantityRtn;
  final double totalAmount;

  InvoiceProduct(this.name, this.salesRate, this.quantity, this.quantityRtn,
      this.totalAmount);

  factory InvoiceProduct.fromJson(Map<String, dynamic> json) {
    return InvoiceProduct(json['ProductName'], json['SalesRate'], json['Qty'],
        json['SubUnitQty'], json['TotalAmount']);
  }
}
