final class Product {
  String productName;
  int voicherID;
  int vd_id;
  double quantityTaken;
  double quantityReturn;
  double defaultQuantityReturn = 0.0;
  double rate;
  double quantityDamaged;
  int productId;
  double totalAmount;
  bool isUpdated = false;
  double quantityDelivered = 0.0;
  double actualQtyDelivered;

  Product(
      this.productName,
      this.voicherID,
      this.vd_id,
      this.quantityTaken,
      this.quantityReturn,
      this.rate,
      this.quantityDamaged,
      this.productId,
      this.totalAmount,
      this.quantityDelivered,
      this.actualQtyDelivered);

  factory Product.fromJson(Map<String, dynamic> json, bool isQDRemonte) {
    return Product(
      json['ProductName'],
      json['VoucherID'],
      json['VD_ID'],
      json['QtyTaken'],
      json['QtyReturned'],
      json['Rate'],
      json['QtyDamaged'],
      json['ProductID'],
      json['TotalAmount'],
      isQDRemonte ? json['QtyDelivered'] : 0.0,
      json['QtyDelivered'],
    );
  }

  double get currentQuantity {
    return ((quantityTaken - quantityDamaged) - actualQtyDelivered) -
        quantityReturn;
  }
}
