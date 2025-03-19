import 'dart:convert';

import 'package:ak_foods/constants.dart';
import 'package:ak_foods/customerModel.dart';
import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/dropDownSearchableView.dart';
import 'package:ak_foods/invoice.dart';
import 'package:ak_foods/item_selection_popup.dart';
import 'package:ak_foods/product.dart';
import 'package:ak_foods/user.dart';
import 'package:flutter/material.dart';

class SalesDetailsView extends StatefulWidget {
  List<Customer> myCustomers;
  List<Product> currentStockItems;
  User user;
  Function onTapAction;

  SalesDetailsView(
      {super.key,
      required this.myCustomers,
      required this.currentStockItems,
      required this.user,
      required this.onTapAction});
  @override
  State<SalesDetailsView> createState() => _SalesDetailsView();
}

class _SalesDetailsView extends State<SalesDetailsView> {
  Product? selectedProduct;
  Customer? selectedCustomer;
  // Controller for the quantity TextField
  TextEditingController _quantityDeleveredController = TextEditingController();
  TextEditingController _quantityReturnController = TextEditingController();
  double productTotal = 0.0;
  List<Product> addedProducts = [];
  bool isSaveButtonEnabled = false;
  bool isCustomerSelectionDisabled = false;
  double selectedProductAvailableQty = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 5),
        Text(
          "Select customer",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        DropDownSearchView(
          items: widget.myCustomers
              .map((item) => ListItemData(item.name, item.customerID))
              .toList(),
          selectedItem: ListItemData("Select Customer", ""),
          didSelectItem: (item) {
            setState(() {
              selectedCustomer =
                  widget.myCustomers.firstWhere((p) => p.customerID == item.id);
            });
          },
          isDisabled: isCustomerSelectionDisabled,
          showDefaultValue: selectedCustomer == null,
        ),
        SizedBox(height: 5),
        Text(
          "Select Product",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        DropDownSearchView(
          items: widget.currentStockItems
              .where((item) => item.quantityTaken > 0)
              .toList()
              .map(
                  (item) => ListItemData(item.productName, "${item.productId}"))
              .toList(),
          selectedItem: ListItemData("Select Product", ""),
          didSelectItem: (item) {
            setState(() {
              selectedProduct = widget.currentStockItems
                  .firstWhere((p) => p.productName == item.title);
              isCustomerSelectionDisabled = true;
              if (selectedProduct != null) {
                _quantityDeleveredController = TextEditingController(text: '');
                _quantityReturnController = TextEditingController(text: '');
                productTotal = selectedProduct!.totalAmount;
              }
            });
          },
          isDisabled: false,
          showDefaultValue: selectedProduct == null,
        ),
        SizedBox(
          height: 10,
        ),
        selectedProduct != null
            ? productDetailsView(context, selectedProduct!)
            : Center(),
        addedProducts.length > 0 ? addedProductList() : Center(),
      ],
    );
  }

  Widget productDetailsView(BuildContext context, Product product) {
    getAvailableQuantity();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            "Product Name: ${product.productName}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Product Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rate: ${product.rate}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Qty available: $selectedProductAvailableQty",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Product Quantity
          Row(
            children: [
              Text(
                "QuantityDelivered: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: TextField(
                  controller: _quantityDeleveredController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        updateQuantityDelivered(value, product);
                      });
                    } else {
                      setState(() {
                        updateQuantityDelivered("0.0", product);
                      });
                    }
                    // Update quantity and recalculate total amount
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                "QuantityReturn: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: TextField(
                  controller: _quantityReturnController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        updateQuantityReturn(value, product);
                      });
                    } else {
                      setState(() {
                        updateQuantityReturn("0.0", product);
                      });
                    }
                    // Update quantity and recalculate total amount
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Total Amount
          Text(
            "Total Amount: ${productTotal.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                  child: ElevatedButton.icon(
                label: Text(addedProducts.contains(product)
                    ? product.isUpdated
                        ? 'Update Product'
                        : 'Delete Product'
                    : 'Add Product'),
                onPressed: () {
                  if (product.quantityDelivered < selectedProductAvailableQty) {
                    addProductTapped(product);
                    isSaveButtonEnabled = true;
                  } else {
                    Constants.showAlert(
                        "Alert!",
                        "Quantity should be lessthan available quantity",
                        context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                ),
              )),
              Center(
                  child: ElevatedButton.icon(
                label: Text('Remove Product'),
                onPressed: () {
                  resetProductSelection();
                  if (addedProducts.contains(product)) {
                    addedProducts.remove(product);
                  }
                  resetProductDetails(product);
                },
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
    );
  }

  void getAvailableQuantity() async {
    final String data = await DataBaseManager().queryFromSQL(
        "select QtyTaken - (QtyDamaged + QtyDelivered) As stockavailable from Voucher_otherdetails1 where productid ='${selectedProduct!.productId}' AND VoucherID = '${selectedProduct!.voicherID}'");
    final List result = jsonDecode(data);
    setState(() {
      if (result.length > 0) {
        selectedProductAvailableQty = result[0]["stockavailable"];
      } else {
        selectedProductAvailableQty = 0;
      }
    });
  }

  void resetProductDetails(Product product) {
    product.isUpdated = false;
    product.quantityDelivered = 0;
    product.quantityReturn = 0;
    product.totalAmount = 0;
  }

  void resetProductSelection() {
    setState(() {
      isCustomerSelectionDisabled = false;
      selectedProduct = null;
    });
  }

  void updateQuantityDelivered(String value, Product product) {
    double receivedValue = double.parse(value);
    if (receivedValue < selectedProductAvailableQty) {
      product.isUpdated = receivedValue != product.quantityTaken;
      product.quantityDelivered = receivedValue;
      product.totalAmount =
          product.rate * (product.quantityDelivered - product.quantityReturn);
      productTotal = product.totalAmount;
    } else {
      Constants.showAlert(
          "Alert!", "Quantity should be lessthan available quantity", context);
    }
  }

  void updateQuantityReturn(String value, Product product) {
    double receivedValue = double.parse(value);
    product.isUpdated = receivedValue != product.quantityTaken;
    product.quantityReturn = receivedValue;
    product.totalAmount =
        product.rate * (product.quantityDelivered - product.quantityReturn);
    productTotal = product.totalAmount;
  }

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
                onTap: () {
                  setState(() {
                    selectedProduct = addedProducts[index];
                    _quantityDeleveredController = TextEditingController(
                        text: '${selectedProduct!.quantityDelivered}');
                    _quantityReturnController = TextEditingController(
                        text: '${selectedProduct!.quantityReturn}');
                  });
                },
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                  child: ElevatedButton.icon(
                label: Text("New"),
                icon: Icon(
                  Icons.new_label,
                  color: isSaveButtonEnabled ? Colors.blue : Colors.grey,
                  size: 30.0,
                ),
                onPressed: () {
                  setState(() {
                    addedProducts.clear();
                    selectedProduct = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                ),
              )),
              Center(
                  child: ElevatedButton.icon(
                label: Text("Save"),
                icon: Icon(
                  Icons.save,
                  color: isSaveButtonEnabled ? Colors.blue : Colors.grey,
                  size: 30.0,
                ),
                onPressed: () {
                  if (isSaveButtonEnabled) {
                    updateSalesDetails();
                    widget.onTapAction();
                    isSaveButtonEnabled = false;
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                ),
              )),
              SizedBox(width: 20),
              Text("Total: ${getTotalAmount()}",
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  double getTotalAmount() {
    double totalAmountValue = 0;
    for (int i = 0; i < addedProducts.length; i++) {
      totalAmountValue += addedProducts[i].totalAmount;
    }
    return totalAmountValue;
  }

  Future<void> updateSalesDetails() async {
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
          "Insert into InvoiceInfo (Inv_ID, InvoiceNo, InvoiceDate, TaxType, Customer_ID, SalesmanID, SubTotal, CGST, SGST, IGST, GrandTotal,TotalPaid,Balance,Remarks,FreightCharges,OtherCharges,Total,RoundOff) VALUES ('$newInvoiceID','INV-$invoiceNumber','${DateTime.now().getDateOnly()}', 'Inclusive','${selectedCustomer!.id}', '','${getTotalAmount()}','0','0','0','${getTotalAmount()}','0','${getTotalAmount()}','${widget.user.name}','0.0','0.0','${getTotalAmount()}','0.00')");
      widget.onTapAction();
    }

    for (var i = 0; i < addedProducts.length; i++) {
      Product pro = addedProducts[i];
      final String data = await DataBaseManager().updateQueryFromSQL(
          "Update Voucher_OtherDetails1 Set QtyDelivered = QtyDelivered + ${pro.quantityDelivered}, QtyReturned = QtyReturned + ${pro.quantityReturn} , TotalAmount = ${pro.totalAmount} Where ProductID= ${pro.productId} and VoucherID= ${pro.voicherID}");
      final double quantity = (pro.quantityDelivered - pro.quantityReturn);
      final String invoiceProduct = await DataBaseManager().updateQueryFromSQL(
          "Insert into Invoice_Product(InvoiceID, ProductID, BatchNo,Qty, SalesRate, DiscountPer, Discount, CGSTPer, CGSTAmt, SGSTPer, SGSTAmt, IGSTPer, IGSTAmt,MfgDate,ExpiryDate, TotalAmount, PurchaseRate, Margin,MRP,Barcode,SubUnitQty) VALUES ('$newInvoiceID','${pro.productId}','First','$quantity','${pro.rate}','0','0','0','0','0','0','0','0','${DateTime.now().getDateOnly()}','${DateTime.now().getDateOnly()}','${quantity * pro.rate}', '${pro.rate}', '0', '${pro.rate}','0','$quantity')");
      final String vcDetails2 = await DataBaseManager().updateQueryFromSQL(
          "Insert into Voucher_OtherDetails2(VoucherID,CustomerID,customerName,ProductID,ProductName,Rate,QtyDelivered,QtyReturned,NetQty,TotalAmount,SalesmanID,SalesmanName) VALUES ('${pro.voicherID}', '${selectedCustomer!.id}','${selectedCustomer!.name.trim()}','${pro.productId}','${pro.productName.trim()}', '${pro.rate}','${pro.quantityDelivered}','${pro.quantityReturn}','$quantity','${pro.totalAmount}','$newInvoiceID', '${widget.user.name.trim()}')");
      final String tempStock = await DataBaseManager().updateQueryFromSQL(
          "Update Temp_stock set Qty = Qty - '$quantity', SubUnitQty = SubUnitQty - '$quantity' WHERE ProductID = '${pro.productId}'");
    }
    final String invoicePayment = await DataBaseManager().updateQueryFromSQL(
        "Insert into Invoice_Payment(InvoiceID,PaymentMode,TotalPaid,PaymentDate) VALUES ('$newInvoiceID','Credit Terms - 7 days','${getTotalAmount()}','${DateTime.now().getDateOnly()}')");
    if (selectedCustomer != null) {
      final String ledgerBook = await DataBaseManager().updateQueryFromSQL(
          "Insert into LedgerBook(Date, Name, LedgerNo, Label,Debit,Credit,PartyID) VALUES ('${DateTime.now().getDateOnly()}', '${selectedCustomer!.name}','INV-$invoiceNumber','Sales','${getTotalAmount()}','0.0','${selectedCustomer!.customerID}')");
      final String customerLedgerBook = await DataBaseManager().updateQueryFromSQL(
          "Insert into CustomerLedgerBook(Date, Name, LedgerNo, Label,Debit,Credit,PartyID) VALUES ('${DateTime.now().getDateOnly()}', '${selectedCustomer!.name}','INV-$invoiceNumber','Sales','${getTotalAmount()}','0.0','${selectedCustomer!.customerID}')");
    }

    Constants.showSaveSuccessAlert(context);
  }

  void addProductTapped(Product product) {
    if (!addedProducts.contains(product)) {
      setState(() {
        addedProducts.add(product);
        selectedProduct = null;
      });
    } else {
      setState(() {
        if (product.isUpdated) {
          // Update query need to add
          setState(() {
            selectedProduct = null;
          });
        } else {
          addedProducts.remove(product);
          selectedProduct = null;
        }
      });
    }
  }
}
