import 'dart:convert';

import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/invoice.dart';
import 'package:ak_foods/invoiceProduct.dart';
import 'package:ak_foods/product.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class ReceiptScreen extends StatefulWidget {
  final Invoice invoiceData;
  const ReceiptScreen({super.key, required this.invoiceData});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  // Sample data for the receipt
  List<InvoiceProduct> addedProducts = [];

  @override
  void initState() {
    // TODO: implement initState
    _loadInvoiceInfoDetails();
    super.initState();
  }

  void _loadInvoiceInfoDetails() async {
    final String data = await DataBaseManager().queryFromSQL(
        "select ProductName,SalesRate,SubUnitQty,Qty,TotalAmount, Balance, TotalPaid, GrandTotal  from Invoice_Product Inner Join InvoiceInfo On InvoiceInfo.Inv_ID=Invoice_Product.InvoiceId Inner Join Product On Product.PID=Invoice_Product.ProductId Where InvoiceId='${widget.invoiceData.inv_ID}'");

    final List result = jsonDecode(data);
    List<InvoiceProduct> dataList =
        result.map((value) => InvoiceProduct.fromJson(value)).toList();
    setState(() {
      addedProducts = dataList;
    });
  }

  double getOverallTotal() {
    return addedProducts.fold(0.0, (sum, product) => sum + product.totalAmount);
  }

  double getOverallGrandTotal() {
    return addedProducts.fold(0.0, (sum, product) => sum + product.grandTotal);
  }

  double getOverallBalance() {
    return addedProducts.fold(0.0, (sum, product) => sum + product.balance);
  }

  double getOverallTotalPaid() {
    return addedProducts.fold(0.0, (sum, product) => sum + product.totalPaid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${widget.invoiceData.name}".trim(),
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Bill Number: ${widget.invoiceData.invoiceNo}".trim(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Date: ${widget.invoiceData.invoiceDate}",
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
            child: Container(
              width: 250,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Overall Total:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${getOverallTotal().toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Balance:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${getOverallBalance().toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Paid:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${getOverallTotalPaid().toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Grand Total:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${getOverallGrandTotal().toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addedProductList() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(64, 5, 0, 5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Product",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text("Rate",
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(
                  "Quantity",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Qty Rtn",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text("Total",
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
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
                      Container(
                        width: 50,
                        child: Text(addedProducts[index].name.trim(),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal)),
                      ),
                      Text('${addedProducts[index].salesRate}'),
                      Text('${addedProducts[index].quantity}'),
                      Text('${addedProducts[index].quantityRtn}'),
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
