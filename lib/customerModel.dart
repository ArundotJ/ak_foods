class Customer {
  final String customerID;
  final String name;
  final int id;

  Customer(this.customerID, this.name, this.id);

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      json['CustomerID'],
      json['Name'],
      json['ID'],
    );
  }
}
