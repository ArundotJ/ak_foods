import 'dart:collection';
import 'dart:convert';
import 'package:ak_foods/constants.dart';
import 'package:ak_foods/customerModel.dart';
import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/dropDownSearchableView.dart';
import 'package:ak_foods/item_selection_popup.dart';
import 'package:ak_foods/product.dart';
import 'package:ak_foods/sales_details_view.dart';
import 'package:ak_foods/user.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  late String userName;
  // Dummy data for opening stock
  List<Product> openingStockItems = [];

  // Dummy data for current stock
  List<Product> currentStockItems = [];

  List<Customer> myCustomers = [];
  double totalValue = 0.0;
  double balanceAmount = 0.0;

  bool isUpdateNeeded = false;
  bool isCustomerSelectionDisabled = false;
  // Dummy data for sales
  final List<Map<String, dynamic>> salesItems = [
    {'name': 'Item 1', 'quantity': 5, 'returnQuantity': 1},
    {'name': 'Item 2', 'quantity': 10, 'returnQuantity': 2},
    {'name': 'Item 3', 'quantity': 15, 'returnQuantity': 3},
  ];

  @override
  void initState() {
    super.initState();
    userName = widget.user.name;
    _loadOpeningStockDetails();
    _loadCurrentStockDetails();
    loadCustomerData();
  }

  void _loadOpeningStockDetails() async {
    final String data = await DataBaseManager().queryFromSQL(
        "Select * from Voucher_OtherDetails1 inner join Voucher1 on Voucher1.Id = Voucher_OtherDetails1.VoucherID WHERE NAME = '$userName' AND Voucher1.Date = '${DateTime.now().getDateOnly()}'");
    final List result = jsonDecode(data);
    List<Product> dataList =
        result.map((value) => Product.fromJson(value)).toList();
    setState(() {
      openingStockItems = dataList;
    });
  }

  void loadCustomerData() async {
    final String data =
        await DataBaseManager().queryFromSQL("Select * from customer");
    final List result = jsonDecode(data);
    List<Customer> dataList =
        result.map((value) => Customer.fromJson(value)).toList();
    setState(() {
      myCustomers = dataList;
    });
  }

  void _loadCurrentStockDetails() async {
    final String data = await DataBaseManager().queryFromSQL(
        "Select * from Voucher_OtherDetails1 inner join Voucher1 on Voucher1.Id = Voucher_OtherDetails1.VoucherID WHERE NAME = '$userName' AND Voucher1.Date = '${DateTime.now().getDateOnly()}'");
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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'SALES',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400),
            ),
            Text(
              '$userName',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.start,
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Opening Stock Section
              // Current Stock Section
              Text(
                'Sales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              DropDownSearchView(
                items: myCustomers
                    .map((item) => ListItemData(item.name, item.customerID))
                    .toList(),
                selectedItem: ListItemData("Select Customer", ""),
                didSelectItem: (item) {
                  setState(() {
                    var selectedCustomer =
                        myCustomers.firstWhere((p) => p.customerID == item.id);
                  });
                },
                isDisabled: isCustomerSelectionDisabled,
                showDefaultValue: false,
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Item',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      'Rate',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      'Qty',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      'Rtn.Qty',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      'Amount',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
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
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              currentStockItems[index].productName,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${currentStockItems[index].rate}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: 50.0,
                              height: 40.0,
                              child: TextField(
                                keyboardType: TextInputType.numberWithOptions(),
                                onChanged: (value) => setState(() {
                                  if (value.isNotEmpty) {
                                    currentStockItems[index].quantityTaken =
                                        double.parse(value);
                                  }
                                }),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 10.0,
                                  ),
                                  border: OutlineInputBorder(),
                                  hintText: '',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Center(
                            child: SizedBox(
                              width: 50.0,
                              height: 40.0,
                              child: TextField(
                                keyboardType: TextInputType.numberWithOptions(),
                                onChanged: (value) => setState(() {
                                  if (value.isNotEmpty) {
                                    currentStockItems[index].quantityReturn =
                                        double.parse(value);
                                  }
                                }),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 10.0,
                                  ),
                                  border: OutlineInputBorder(),
                                  hintText: '',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${(currentStockItems[index].quantityTaken * currentStockItems[index].rate)}',
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

              SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                          child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.update,
                          color: isUpdateNeeded ? Colors.blue : Colors.grey,
                          size: 30.0,
                        ),
                        label: Text('Apply'),
                        onPressed: updateTotalValue,
                        style: ElevatedButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                          ),
                        ),
                      )),
                      SizedBox(width: 20),
                      Text(
                        "Total: ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$totalValue",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Paid: ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Center(
                        child: SizedBox(
                          width: 80.0,
                          height: 40.0,
                          child: TextField(
                            keyboardType: TextInputType.numberWithOptions(),
                            onChanged: (value) => setState(() {
                              if (value.isNotEmpty) {
                                balanceAmount =
                                    totalValue - double.parse(value);
                              }
                            }),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 10.0,
                              ),
                              border: OutlineInputBorder(),
                              hintText: '',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Balance: ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$balanceAmount",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                  child: ElevatedButton.icon(
                icon: Icon(
                  Icons.update,
                  color: isUpdateNeeded ? Colors.blue : Colors.grey,
                  size: 30.0,
                ),
                label: Text('Submit'),
                onPressed: updateTotalValue,
                style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                ),
              )),

              // // Sales Section
              // SalesDetailsView(
              //     myCustomers: myCustomers,
              //     currentStockItems: currentStockItems,
              //     user: widget.user,
              //     onTapAction: () {
              //       _loadCurrentStockDetails();
              //       _loadOpeningStockDetails();
              //     }),
            ],
          ),
        ),
      ),
    );
  }

  void updateTotalValue() async {
    double totalAmount = 0.0;
    for (var i = 0; i < currentStockItems.length; i++) {
      Product pro = currentStockItems[i];
      totalAmount += pro.rate * pro.quantityTaken;
    }
    setState(() {
      totalValue = totalAmount;
    });
  }

  void updateDamageItem() async {
    if (isUpdateNeeded == true) {
      for (var i = 0; i < openingStockItems.length; i++) {
        Product pro = openingStockItems[i];
        final String data = await DataBaseManager().updateQueryFromSQL(
            "Update Voucher_OtherDetails1 Set QtyDamaged = ${pro.quantityDamaged}  from Voucher_OtherDetails1 Inner Join Voucher1 on Voucher1.ID=Voucher_OtherDetails1.VoucherID Where Name= '$userName' and  ProductID= ${pro.productId}");
      }
      _loadCurrentStockDetails();
      setState(() {
        isUpdateNeeded = false;
      });
    }
  }

  void onPressedItem() async {
    final String data = await DataBaseManager()
        .queryFromSQL("Select * from Voucher_OtherDetails1");
    print(data);
  }
}
