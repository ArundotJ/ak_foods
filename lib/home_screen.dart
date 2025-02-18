import 'dart:convert';

import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/product.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  late String userName;
  // Dummy data for opening stock
  List<Product> openingStockItems = [];

  // Dummy data for current stock
  List<Product> currentStockItems = [];

  // Dummy data for sales
  final List<Map<String, dynamic>> salesItems = [
    {'name': 'Item 1', 'quantity': 5, 'returnQuantity': 1},
    {'name': 'Item 2', 'quantity': 10, 'returnQuantity': 2},
    {'name': 'Item 3', 'quantity': 15, 'returnQuantity': 3},
  ];

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    _loadOpeningStockDetails();
    _loadCurrentStockDetails();
  }

  void _loadOpeningStockDetails() async {
    final String data = await DataBaseManager().queryFromSQL(
        "Select * from Voucher_OtherDetails1 inner join Voucher1 on Voucher1.Id = Voucher_OtherDetails1.VoucherID WHERE NAME = '$userName'");
    final List result = jsonDecode(data);
    List<Product> dataList =
        result.map((value) => Product.fromJson(value)).toList();
    setState(() {
      openingStockItems = dataList;
    });
  }

  void _loadCurrentStockDetails() async {
    // final String data = await DataBaseManager()
    //     .queryFromSQL("Select * from Voucher_OtherDetails1");
    // final List result = jsonDecode(data);
    // List<Product> dataList =
    //     result.map((value) => Product.fromJson(value)).toList();
    // setState(() {
    //   currentStockItems = dataList;
    // });
    final String data = await DataBaseManager().queryFromSQL(
        "Select * from Voucher_OtherDetails1 inner join Voucher1 on Voucher1.Id = Voucher_OtherDetails1.VoucherID WHERE NAME = '$userName'");
    final List result = jsonDecode(data);
    List<Product> dataList =
        result.map((value) => Product.fromJson(value)).toList();
    setState(() {
      currentStockItems = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome: $userName'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Opening Stock Section
              Text(
                'Opening Stock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Quantity",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 50),
                    Text("Damage",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: openingStockItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "${index + 1}",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              openingStockItems[index].productName,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                    '${openingStockItems[index].quantityTaken}'),
                                SizedBox(width: 100),
                                Text(
                                    '${openingStockItems[index].quantityDamaged}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),

              // Current Stock Section
              Text(
                'Current Stock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: currentStockItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "${index + 1}",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              currentStockItems[index].productName,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${currentStockItems[index].quantityTaken - currentStockItems[index].quantityDamaged}',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),

              // Sales Section
              Text(
                'Sales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: salesItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ElevatedButton(
                                  onPressed: onPressedItem,
                                  child: Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Item: ${salesItems[index]['name']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Quantity: ${salesItems[index]['quantity']}',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Return Quantity: ${salesItems[index]['returnQuantity']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressedItem() async {
    final String data = await DataBaseManager()
        .queryFromSQL("Select * from Voucher_OtherDetails1");
    print(data);
  }
}
