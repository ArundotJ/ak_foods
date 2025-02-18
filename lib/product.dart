final class Product {
  String productName;
  int voicherID;
  int vd_id;
  double quantityTaken;
  double quantityReturn;
  double rate;
  double quantityDamaged;
  int productId;
  double quantityDelivered;
  double totalAmount;

  Product(
      this.productName,
      this.voicherID,
      this.vd_id,
      this.quantityTaken,
      this.quantityReturn,
      this.rate,
      this.quantityDamaged,
      this.productId,
      this.quantityDelivered,
      this.totalAmount);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        json['ProductName'],
        json['VoucherID'],
        json['VD_ID'],
        json['QtyTaken'],
        json['QtyReturned'],
        json['Rate'],
        json['QtyDamaged'],
        json['ProductID'],
        json['QtyDelivered'],
        json['TotalAmount']);
  }
}
