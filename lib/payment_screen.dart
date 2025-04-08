import 'dart:convert';

import 'package:ak_foods/constants.dart';
import 'package:ak_foods/customerModel.dart';
import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/dropDownSearchableView.dart';
import 'package:ak_foods/item_selection_popup.dart';
import 'package:ak_foods/product.dart';
import 'package:flutter/material.dart';

class PaymenyScreen extends StatefulWidget {
  const PaymenyScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymenyScreen> {
  List<Customer> myCustomers = [];
  String selectedItem = 'Select Item';
  Customer? selectedCustomer;
  String balanceAmount = "";
  double balance = 0.0;
  int transactionID = 0;
  String transactionNumber = "";
  DateTime selectedDate = DateTime.now();
  TextEditingController totalAmountController = TextEditingController();

  static const List<String> list = <String>['Cash', 'Online transfer'];
  String selectedPaymentMode = list.first;
  bool isNewButtonEnabled = false;
  bool isSaveButtonEnabled = true;

  @override
  void initState() {
    // TODO: implement initState
    _loadCustomersDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          DropDownSearchView(
            items: myCustomers
                .map((item) => ListItemData(item.name, item.customerID))
                .toList(),
            selectedItem: ListItemData("Select Customer", ""),
            didSelectItem: (item) {
              selectedCustomer =
                  myCustomers.firstWhere((p) => p.customerID == item.id);
              _fetchCutomerAccountDetails();
            },
            isDisabled: false,
            showDefaultValue: selectedCustomer == null,
          ),
          SizedBox(height: 20),
          selectedCustomer == null ? Center() : selectedCustomerDetails(),
        ],
      ),
    );
  }

  Widget selectedCustomerDetails() {
    return Column(
      children: [
        ListTile(
          title: Text("Balance: ",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text(balanceAmount),
        ),
        ListTile(
          title: Text("Transaction Number: ",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text(transactionNumber),
        ),
        ListTile(
          title: Text("Transaction Date: ",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Row(
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: const Text('Date: '),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Text("${selectedDate.toLocal()}".split(' ')[0]),
            ],
          ),
        ),
        ListTile(
          title: Text("Payment Mode",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: DropdownButton<String>(
            value: selectedPaymentMode,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(height: 2, color: Colors.deepPurpleAccent),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                selectedPaymentMode = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
        ),
        ListTile(
          title: Text("Amount: ",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: TextField(
            keyboardType: TextInputType.numberWithOptions(),
            controller: totalAmountController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.6),
              hintText: "Enter amount",
              hintStyle: TextStyle(
                  color: Colors.grey[400], fontWeight: FontWeight.bold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                icon: Icon(
                  Icons.save,
                  color: isSaveButtonEnabled ? Colors.blue : Colors.grey,
                  size: 30.0,
                ),
                label: Text('Save'),
                onPressed: () {
                  setState(() {
                    if (isSaveButtonEnabled) {
                      if (int.parse(totalAmountController.text) > balance) {
                        Constants.showAlert(
                            "Alert!",
                            "Invalid amount entered. Paid amount should be less that total amount",
                            context);
                        return;
                      }
                      _savePaymentDetails();
                      isNewButtonEnabled = true;
                      isSaveButtonEnabled = false;
                    }
                  });
                }),
            ElevatedButton.icon(
                icon: Icon(
                  Icons.new_label,
                  color: isNewButtonEnabled ? Colors.blue : Colors.grey,
                  size: 30.0,
                ),
                label: Text('New'),
                onPressed: () {
                  setState(() {
                    if (isNewButtonEnabled) {
                      selectedCustomer = null;
                      totalAmountController.text = "";
                    }
                  });
                }),
          ],
        ),
      ],
    );
  }

  void _savePaymentDetails() async {
    DateTime dateValue = selectedDate.getDateOnly();
    String paymentName =
        selectedPaymentMode == "Cash" ? "Cash Account" : "Bank Account";
    final String data = await DataBaseManager().updateQueryFromSQL(
        "insert into CreditCustomerPayment(T_ID, TransactionID, Date,PaymentMode, Customer_ID, Amount,Remarks,PaymentModeDetails) VALUES ('$transactionID', '$transactionNumber', '$dateValue', 'By $selectedPaymentMode','${selectedCustomer!.id}','${totalAmountController.text}','','')");
    final String leaderBook = await DataBaseManager().updateQueryFromSQL(
        "insert into LedgerBook(Date, Name, LedgerNo, Label,Debit,Credit,PartyID) VALUES ('$dateValue', '$paymentName','$transactionNumber', 'Payment','0.0','${totalAmountController.text}', '${selectedCustomer!.customerID}')");
    final String customerLeaderBook = await DataBaseManager().updateQueryFromSQL(
        "insert into CustomerLedgerBook(Date, Name, LedgerNo, Label,Debit,Credit,PartyID) VALUES ('$dateValue', '$paymentName','$transactionNumber', 'Payment','0.0','${totalAmountController.text}', '${selectedCustomer!.customerID}')");
    Constants.showSaveSuccessAlert(context);
    _fetchCutomerAccountDetails();
  }

  void _loadCustomersDetails() async {
    final String data =
        await DataBaseManager().queryFromSQL("Select * from customer");
    final List result = jsonDecode(data);
    List<Customer> dataList =
        result.map((value) => Customer.fromJson(value)).toList();
    setState(() {
      myCustomers = dataList;
    });
  }

  void _fetchCutomerAccountDetails() async {
    final String data = await DataBaseManager().queryFromSQL(
        "Select isNULL(Sum(Credit),0)-IsNull(Sum(Debit),0) from CustomerLedgerBook WHERE PartyID = '${selectedCustomer!.customerID}' group By PartyID");
    final List result = jsonDecode(data);
    if (result.length > 0) {
      double value = result[0][""];
      if (value > 0) {
        setState(() {
          balanceAmount = "${value.abs()} CR";
          balance = value;
        });
      } else {
        setState(() {
          balanceAmount = "${value.abs()} DR";
          balance = value;
        });
      }
      print(value);
    } else {
      setState(() {
        balanceAmount = "0.0";
        balance = 0;
      });
    }
    final String trNumber = await DataBaseManager().queryFromSQL(
        "SELECT TOP 1 T_ID FROM CreditCustomerPayment ORDER BY T_ID DESC");
    final List result_tr = jsonDecode(trNumber);
    if (result_tr.length > 0) {
      int previousNumber = result_tr[0]["T_ID"];
      transactionID = previousNumber + 1;
      setState(() {
        transactionNumber =
            "${selectedCustomer!.customerID.trim()} - T - ${transactionID.toString().padLeft(4, '0')}";
      });
    }

    print(result_tr);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
