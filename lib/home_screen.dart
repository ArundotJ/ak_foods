import 'dart:collection';
import 'dart:convert';
import 'package:ak_foods/constants.dart';
import 'package:ak_foods/customerModel.dart';
import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/dropDownSearchableView.dart';
import 'package:ak_foods/invoice.dart';
import 'package:ak_foods/item_selection_popup.dart';
import 'package:ak_foods/product.dart';
import 'package:ak_foods/sales_details_view.dart';
import 'package:ak_foods/user.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
  double amountPaid = 0.0;
  double balanceAmount = 0.0;
  Customer? selectedCustomer = null;
  String selectedPaymentMode = "By Cash";
  String defaultTextForSelectCustomer = "Select Customer";
  final connectionChecker = InternetConnectionChecker.instance;

  bool isUpdateNeeded = false;
  bool isCustomerSelectionDisabled = false;
  bool isNetworkOnline = true;
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
    loadCustomerData();
    _loadOpeningStockDetails();
    _loadCurrentStockDetails();
    setCurrentNetwork();

    final subscription = connectionChecker.onStatusChange.listen(
      (InternetConnectionStatus status) {
        if (status == InternetConnectionStatus.connected) {
          setState(() {
            isNetworkOnline = true;
            showToast(true);
          });
        } else {
          setState(() {
            isNetworkOnline = false;
            showToast(false);
          });
        }
      },
    );
  }

  void setCurrentNetwork() async {
    isNetworkOnline = await InternetConnectionChecker.instance.hasConnection;
  }

  void showToast(bool isOnline) {
    Fluttertoast.showToast(
        msg: isOnline ? "Internet connection back" : "No internet connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void resetSelectedData() {
    setState(() {
      selectedCustomer = null;
      totalValue = 0.0;
      amountPaid = 0.0;
      balanceAmount = 0.0;
    });
  }

  void _loadOpeningStockDetails() async {
    final String data = await DataBaseManager().queryFromSQL(
        "Select * from Voucher_OtherDetails1 inner join Voucher1 on Voucher1.Id = Voucher_OtherDetails1.VoucherID WHERE NAME = '$userName' AND Voucher1.Date = '${DateTime.now().getDateOnly()}'");
    final List result = jsonDecode(data);
    List<Product> dataList =
        result.map((value) => Product.fromJson(value, false)).toList();
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
        result.map((value) => Product.fromJson(value, false)).toList();
    setState(() {
      currentStockItems = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Column(
            children: [
              Text('SALES',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400)),
              Text(
                'Welcome $userName',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.new_label, color: Colors.red),
            onPressed: () {
              // handle the press
              resetSelectedData();
            },
          ),
        ],
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
                    selectedCustomer =
                        myCustomers.firstWhere((p) => p.customerID == item.id);
                  });
                },
                isDisabled: isCustomerSelectionDisabled,
                showDefaultValue: selectedCustomer == null,
              ),
              selectedCustomer != null ? actualContent() : Center()

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

  AppBar appBar() {
    return AppBar(
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
          Row(
            children: [
              Text(
                '$userName',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.start,
              ),
              Center(
                  child: ElevatedButton.icon(
                icon: Icon(
                  Icons.update,
                  color: isUpdateNeeded ? Colors.blue : Colors.grey,
                  size: 10.0,
                ),
                label: Text('Submit'),
                onPressed: submitButtonTapped,
                style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
      automaticallyImplyLeading: false,
    );
  }

  Widget actualContent() {
    return Column(
      children: [
        SizedBox(height: 10),
        productHeading(),
        SizedBox(height: 10),
        productsListWithCustomization(),
        SizedBox(height: 20),
        totalBalanceView(),
      ],
    );
  }

  Column totalBalanceView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
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
            Container(
              width: 150,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mode: ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: selectedPaymentMode,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                            height: 2, color: Colors.deepPurpleAccent),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            selectedPaymentMode = value!;
                          });
                        },
                        items: ["By Cash", "By Bank"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.numberWithOptions(),
                            onChanged: (value) => setState(() {
                              if (value.isNotEmpty) {
                                amountPaid = double.parse(value);
                                balanceAmount = totalValue - amountPaid;
                              }
                            }),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            )
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
          onPressed: submitButtonTapped,
          style: ElevatedButton.styleFrom(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20.0),
            ),
          ),
        )),
      ],
    );
  }

  ListView productsListWithCustomization() {
    return ListView.builder(
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
                    child: Column(
                      children: [
                        Text(
                          currentStockItems[index].productName,
                          style: TextStyle(fontSize: 16),
                        ),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'QTY:',
                        //       style: TextStyle(fontSize: 12),
                        //     ),
                        //     Text(
                        //       '${(currentStockItems[index].quantityTaken - currentStockItems[index].quantityDamaged) - currentStockItems[index].quantityDelivered}',
                        //       style: TextStyle(fontSize: 12),
                        //     ),
                        //   ],
                        // )
                      ],
                    )),
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
                          currentStockItems[index].quantityDelivered =
                              double.parse(value);
                        }
                      }),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
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
                        fillColor: Colors.white,
                        filled: true,
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
                    '${(currentStockItems[index].quantityDelivered * currentStockItems[index].rate)}',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Padding productHeading() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Item',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          Text(
            '',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          Text(
            'Rate',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          Text(
            'Qty',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          Text(
            'Rtn.Qty',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          Text(
            'Amount',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  void submitButtonTapped() async {
    if (isNetworkOnline) {
      final String data = await DataBaseManager().queryFromSQL(
          "SELECT TOP 1 Inv_ID FROM InvoiceInfo ORDER BY Inv_ID DESC");
      final List result = jsonDecode(data);
      List<Invoice> invoices =
          result.map((value) => Invoice.fromJson(value)).toList();
      int newInvoiceID = 1;
      if (invoices.length > 0) {
        Invoice topInvoice = invoices[0];
        newInvoiceID = topInvoice.inv_ID + 1;
      }
      String invoiceNumber = newInvoiceID.toString().padLeft(4, '0');
      print(invoices);
      if (selectedCustomer != null) {
        final String updateData = await DataBaseManager().updateQueryFromSQL(
            "Insert into InvoiceInfo (Inv_ID, InvoiceNo, InvoiceDate, TaxType, Customer_ID, SalesmanID, SubTotal, CGST, SGST, IGST, GrandTotal,TotalPaid,Balance,Remarks,FreightCharges,OtherCharges,Total,RoundOff) VALUES ('$newInvoiceID','INV-$invoiceNumber','${DateTime.now().getDateOnly()}', 'Inclusive','${selectedCustomer!.id}', '','$totalValue','0','0','0','$totalValue','0','$totalValue','${widget.user.name}','0.0','0.0','$totalValue','0.00')");
        for (var i = 0; i < currentStockItems.length; i++) {
          Product pro = currentStockItems[i];
          final String data = await DataBaseManager().updateQueryFromSQL(
              "Update Voucher_OtherDetails1 Set QtyDelivered = QtyDelivered + ${pro.quantityDelivered}, QtyReturned = QtyReturned + ${pro.quantityReturn} , TotalAmount = ${pro.totalAmount} Where ProductID= ${pro.productId} and VoucherID= ${pro.voicherID}");
          final double quantity = (pro.quantityDelivered);
          final String invoiceProduct = await DataBaseManager().updateQueryFromSQL(
              "Insert into Invoice_Product(InvoiceID, ProductID, BatchNo,Qty, SalesRate, DiscountPer, Discount, CGSTPer, CGSTAmt, SGSTPer, SGSTAmt, IGSTPer, IGSTAmt,MfgDate,ExpiryDate, TotalAmount, PurchaseRate, Margin,MRP,Barcode,SubUnitQty) VALUES ('$newInvoiceID','${pro.productId}','First','$quantity','${pro.rate}','0','0','0','0','0','0','0','0','${DateTime.now().getDateOnly()}','${DateTime.now().getDateOnly()}','${quantity * pro.rate}', '${pro.rate}', '0', '${pro.rate}','0','$quantity')");
          final String vcDetails2 = await DataBaseManager().updateQueryFromSQL(
              "Insert into Voucher_OtherDetails2(VoucherID,CustomerID,customerName,ProductID,ProductName,Rate,QtyDelivered,QtyReturned,NetQty,TotalAmount,SalesmanID,SalesmanName) VALUES ('${pro.voicherID}', '${selectedCustomer!.id}','${selectedCustomer!.name.trim()}','${pro.productId}','${pro.productName.trim()}', '${pro.rate}','${pro.quantityDelivered}','${pro.quantityReturn}','$quantity','${pro.rate * pro.quantityDelivered}','$newInvoiceID', '${widget.user.name.trim()}')");
          final String tempStock = await DataBaseManager().updateQueryFromSQL(
              "Update Temp_stock set Qty = Qty - '$quantity', SubUnitQty = SubUnitQty - '$quantity' WHERE ProductID = '${pro.productId}'");
        }
        if (balanceAmount > 0.0) {
          final String invoicePayment = await DataBaseManager().updateQueryFromSQL(
              "Insert into Invoice_Payment(InvoiceID,PaymentMode,TotalPaid,PaymentDate) VALUES ('$newInvoiceID','Credit Terms - 7 days','$totalValue','${DateTime.now().getDateOnly()}')");
        }
        if (selectedCustomer != null) {
          final String ledgerBook = await DataBaseManager().updateQueryFromSQL(
              "Insert into LedgerBook(Date, Name, LedgerNo, Label,Debit,Credit,PartyID) VALUES ('${DateTime.now().getDateOnly()}', '${selectedCustomer!.name}','INV-$invoiceNumber','Sales','$totalValue','0.0','${selectedCustomer!.customerID}')");
          final String customerLedgerBook = await DataBaseManager()
              .updateQueryFromSQL(
                  "Insert into CustomerLedgerBook(Date, Name, LedgerNo, Label,Debit,Credit,PartyID) VALUES ('${DateTime.now().getDateOnly()}', '${selectedCustomer!.name}','INV-$invoiceNumber','Sales','$totalValue','0.0','${selectedCustomer!.customerID}')");
        }

        if (amountPaid > 0.0) {
          final String ledgerBook = await DataBaseManager().updateQueryFromSQL(
              "Insert into LedgerBook(Date, Name, LedgerNo, Label,Debit,Credit,PartyID) VALUES ('${DateTime.now().getDateOnly()}', '${selectedPaymentMode == "By Cash" ? "Cash Account" : "Bank Account"}','INV-$invoiceNumber','Payment','0.0','$amountPaid','${selectedCustomer!.customerID}')");
          final String customerLedgerBook = await DataBaseManager()
              .updateQueryFromSQL(
                  "Insert into CustomerLedgerBook(Date, Name, LedgerNo, Label,Debit,Credit,PartyID) VALUES ('${DateTime.now().getDateOnly()}', '${selectedPaymentMode == "By Cash" ? "Cash Account" : "Bank Account"}','INV-$invoiceNumber','Payment','0.0','$amountPaid','${selectedCustomer!.customerID}')");

          final String invoicePayment = await DataBaseManager().updateQueryFromSQL(
              "Insert into Invoice_Payment(InvoiceID,PaymentMode,TotalPaid,PaymentDate) VALUES ('$newInvoiceID','${selectedPaymentMode == "By Cash" ? "Cash Account" : "Bank Account"}','$amountPaid','${DateTime.now().getDateOnly()}')");
        }

        Constants.showSaveSuccessAlert(context);
        resetSelectedData();
      }
    } else {
      Constants.showAlert("Alert",
          "You are offline, Please check your network connectivity", context);
    }
  }

  void updateTotalValue() async {
    double totalAmount = 0.0;
    for (var i = 0; i < currentStockItems.length; i++) {
      Product pro = currentStockItems[i];
      totalAmount += pro.rate * pro.quantityDelivered;
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
