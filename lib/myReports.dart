import 'dart:convert';

import 'package:ak_foods/constants.dart';
import 'package:ak_foods/customerModel.dart';
import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/invoice.dart';
import 'package:ak_foods/product.dart';
import 'package:ak_foods/user.dart';
import 'package:flutter/material.dart';

class MyReportsScreen extends StatefulWidget {
  final User user;
  const MyReportsScreen({super.key, required this.user});

  @override
  _MyReportsScreenState createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  // Dummy data for opening stock
  List<Invoice> invoiceList = [];

  // Dummy data for current stock

  bool isUpdateNeeded = false;
  double totalValue = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    _loadOpeningStockDetails();
    super.initState();
  }

  void _loadOpeningStockDetails() async {
    // final String data = await DataBaseManager().queryFromSQL(
    //     "Select * from invoiceinfo where invoicedate='${DateTime.now().getDateOnly()}' and Remarks='${widget.user.name.trim()}'");
    //
    final String data = await DataBaseManager().queryFromSQL(
        "Select * from invoiceinfo inner join customer on customer.id= invoiceinfo.customer_id where invoicedate= '${DateTime.now().getDateOnly()}' and invoiceinfo.remarks = '${widget.user.name.trim()}'");

    final List result = jsonDecode(data);
    List<Invoice> dataList =
        result.map((value) => Invoice.fromJson(value)).toList();
    setState(() {
      invoiceList = dataList;
      updateTotalValue();
    });
  }

  void updateTotalValue() {
    double actualTotal = 0.0;
    for (var i = 0; i < invoiceList.length; i++) {
      actualTotal += invoiceList[i].total!;
    }
    setState(() {
      totalValue = actualTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sales"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Opening Stock Section
              Text(
                'Sales Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SLNO",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Bill No",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Customer",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text("Total",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: invoiceList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${index + 1}",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "${invoiceList[index].invoiceNo}".trim(),
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "${invoiceList[index].name}".trim(),
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "${invoiceList[index].total}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "Total: $totalValue",
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ]),
          ),
        ));
  }
}
