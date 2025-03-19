import 'package:ak_foods/product.dart';
import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  // Sample data for the receipt
  final String customerName = "John Doe";
  final String billNumber = "12345";
  final String date = "2023-10-01";
  final List<Map<String, dynamic>> products = [
    {
      "serialNumber": 1,
      "productName": "Product A",
      "rate": 100.0,
      "quantity": 2,
      "returnQuantity": 0,
      "netQuantity": 2,
      "totalAmount": 200.0,
    },
    {
      "serialNumber": 2,
      "productName": "Product B",
      "rate": 150.0,
      "quantity": 1,
      "returnQuantity": 0,
      "netQuantity": 1,
      "totalAmount": 150.0,
    },
    {
      "serialNumber": 3,
      "productName": "Product C",
      "rate": 200.0,
      "quantity": 3,
      "returnQuantity": 1,
      "netQuantity": 2,
      "totalAmount": 400.0,
    },
  ];

  double getOverallTotal() {
    return products.fold(0.0, (sum, product) => sum + product["totalAmount"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AK Foods"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      customerName,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Bill Number: $billNumber",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Date: $date",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Product List Section
            Text(
              "Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            addedProductList(),
            SizedBox(height: 20),

            // Overall Total Section
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "Overall Total: \$${getOverallTotal().toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> addedProducts = [];
  Widget addedProductList() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(""),
              Text(
                "Product",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(""),
              Text(""),
              Text("Rate",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(
                "QtyDel",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                "QtyRtn",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text("Total",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: addedProducts.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}'),
                      Text(addedProducts[index].productName.trim(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal)),
                      Text('${addedProducts[index].rate}'),
                      Text('${addedProducts[index].quantityDelivered}'),
                      Text('${addedProducts[index].quantityReturn}'),
                      Text('${addedProducts[index].totalAmount}'),
                    ],
                  ),
                ),
                onTap: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
