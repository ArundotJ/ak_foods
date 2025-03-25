import 'dart:convert';

import 'package:ak_foods/constants.dart';
import 'package:ak_foods/customerModel.dart';
import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/product.dart';
import 'package:ak_foods/user.dart';
import 'package:flutter/material.dart';

class MyStocksScreen extends StatefulWidget {
  final User user;
  const MyStocksScreen({super.key, required this.user});

  @override
  _MyStocksScreenState createState() => _MyStocksScreenState();
}

class _MyStocksScreenState extends State<MyStocksScreen> {
  // Dummy data for opening stock
  List<Product> openingStockItems = [];

  // Dummy data for current stock
  List<Product> currentStockItems = [];
  List<Customer> myCustomers = [];
  bool isUpdateNeeded = false;

  @override
  void initState() {
    // TODO: implement initState
    _loadOpeningStockDetails();
    _loadCurrentStockDetails();
    super.initState();
  }

  void _loadOpeningStockDetails() async {
    final String data = await DataBaseManager().queryFromSQL(
        "Select * from Voucher_OtherDetails1 inner join Voucher1 on Voucher1.Id = Voucher_OtherDetails1.VoucherID WHERE NAME = '${widget.user.name.trim()}' AND Voucher1.Date = '${DateTime.now().getDateOnly()}'");
    final List result = jsonDecode(data);
    List<Product> dataList =
        result.map((value) => Product.fromJson(value, true)).toList();
    setState(() {
      openingStockItems = dataList;
    });
  }

  void _loadCurrentStockDetails() async {
    final String data = await DataBaseManager().queryFromSQL(
        "Select * from Voucher_OtherDetails1 inner join Voucher1 on Voucher1.Id = Voucher_OtherDetails1.VoucherID WHERE NAME = '${widget.user.name.trim()}' AND Voucher1.Date = '${DateTime.now().getDateOnly()}'");
    final List result = jsonDecode(data);
    List<Product> dataList =
        result.map((value) => Product.fromJson(value, true)).toList();
    setState(() {
      currentStockItems = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My Stocks"),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    SizedBox(width: 100),
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
                          Container(
                            width: 200,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    '${openingStockItems[index].quantityTaken}'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      child: Container(
                                        width: 30, // Small size
                                        height: 30, // Small size
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.add,
                                              color: Colors.white, size: 20),
                                          onPressed: () {
                                            if (openingStockItems[index]
                                                    .quantityDamaged <
                                                openingStockItems[index]
                                                    .quantityTaken) {
                                              setState(() {
                                                openingStockItems[index]
                                                    .quantityDamaged += 1;
                                                isUpdateNeeded = true;
                                              });
                                            }
                                          },
                                          padding: EdgeInsets
                                              .zero, // Remove default padding
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      child: Container(
                                        width: 30, // Small size
                                        height: 30, // Small size
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.remove,
                                              color: Colors.white, size: 20),
                                          onPressed: () {
                                            if (openingStockItems[index]
                                                    .quantityDamaged >
                                                0) {
                                              setState(() {
                                                openingStockItems[index]
                                                    .quantityDamaged -= 1;
                                                isUpdateNeeded = true;
                                              });
                                            }
                                          },
                                          padding: EdgeInsets
                                              .zero, // Remove default padding
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          '${openingStockItems[index].quantityDamaged}'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Center(
                  child: ElevatedButton.icon(
                icon: Icon(
                  Icons.update,
                  color: isUpdateNeeded ? Colors.blue : Colors.grey,
                  size: 30.0,
                ),
                label: Text('Update'),
                onPressed: updateDamageItem,
                style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                ),
              )),
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
                              '${currentStockItems[index].currentQuantity}',
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
            ]),
          ),
        ));
  }

  void updateDamageItem() async {
    if (isUpdateNeeded == true) {
      for (var i = 0; i < openingStockItems.length; i++) {
        Product pro = openingStockItems[i];
        final String data = await DataBaseManager().updateQueryFromSQL(
            "Update Voucher_OtherDetails1 Set QtyDamaged = ${pro.quantityDamaged}  from Voucher_OtherDetails1 Inner Join Voucher1 on Voucher1.ID=Voucher_OtherDetails1.VoucherID Where Name= '${widget.user.name}' and  ProductID= ${pro.productId}");
      }
      setState(() {
        isUpdateNeeded = false;
      });
      _loadCurrentStockDetails();
    }
  }
}
