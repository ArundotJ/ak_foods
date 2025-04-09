import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ak_foods/constants.dart';
import 'package:ak_foods/customerModel.dart';
import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/invoice.dart';
import 'package:ak_foods/product.dart';
import 'package:ak_foods/receptDetailsScreen.dart';
import 'package:ak_foods/user.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

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

  void _loadInvoiceInfoDetails() async {
    final String data = await DataBaseManager().queryFromSQL(
        "select ProductName,SalesRate,Qty,TotalAmount from Invoice_Product Inner Join InvoiceInfo On InvoiceInfo.Inv_ID=Invoice_Product.InvoiceId Inner Join Product On Product.PID=Invoice_Product.ProductId Where InvoiceId='1'");

    final List result = jsonDecode(data);
    List<Product> dataList =
        result.map((value) => Product.fromJson(value, true)).toList();
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
                  return GestureDetector(
                    child: Card(child: reportCell(index)),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              insetPadding: EdgeInsets.all(8.0),
                              title: Column(
                                children: [
                                  Text(
                                    "AK Foods",
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "Cash Bill",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              content: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Screenshot(
                                  controller: screenshotController,
                                  child: ReceiptScreen(
                                    invoiceData: invoiceList[index],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text("Cancel")),
                                TextButton(
                                    onPressed: () async {
                                      screenshotController
                                          .capture(
                                              delay: Duration(milliseconds: 10))
                                          .then((image) async {
                                        if (image != null) {
                                          Uint8List bytes =
                                              Uint8List.fromList(image);
                                          final directory =
                                              await getApplicationDocumentsDirectory();
                                          final imagePath = await File(
                                                  '${directory.path}/image.png')
                                              .create();
                                          await imagePath.writeAsBytes(bytes);

                                          /// Share Plugin
                                          // final result =
                                          //     await Share.shareXFiles(
                                          //         [XFile('$imagePath')],
                                          //         text: 'Receipt');
                                          // final result =
                                          //    await Share.
                                          // if (result.status ==
                                          //     ShareResultStatus.success) {
                                          //   print(
                                          //       'Thank you for sharing the picture!');
                                          // }
                                        }
                                      }).catchError((onError) {
                                        print(onError);
                                      });

                                      // await screenshotController
                                      //     .capture(
                                      //         delay: const Duration(
                                      //             microseconds: 10))
                                      //     .then((image) => {
                                      //       if (image != null) {
                                      //         String directory = ""
                                      //         final imagePath = await File(
                                      //                 '${directory.path}/image.png')
                                      //             .create();
                                      //         await imagePath
                                      //             .writeAsBytes(image);

                                      //         /// Share Plugin
                                      //         ///
                                      //         final result =
                                      //             await Share.shareXFiles(
                                      //                 [XFile('$imagePath')],
                                      //                 text: 'Receipt');

                                      //         if (result.status ==
                                      //             ShareResultStatus.success) {
                                      //           print(
                                      //               'Thank you for sharing the picture!');
                                      //         }
                                      //       }
                                      //     });

                                      // await screenshotController
                                      //     .capture(
                                      //         delay: const Duration(
                                      //             milliseconds: 10))
                                      //     .then((Uint8List image) async {
                                      //       if (image != null) {
                                      //         final directory =
                                      //             await getApplicationDocumentsDirectory();
                                      //         final imagePath = await File(
                                      //                 '${directory.path}/image.png')
                                      //             .create();
                                      //         await imagePath
                                      //             .writeAsBytes(image);

                                      //         /// Share Plugin
                                      //         ///
                                      //         final result =
                                      //             await Share.shareXFiles(
                                      //                 [XFile('$imagePath')],
                                      //                 text: 'Receipt');

                                      //         if (result.status ==
                                      //             ShareResultStatus.success) {
                                      //           print(
                                      //               'Thank you for sharing the picture!');
                                      //         }
                                      //       }
                                    },
                                    child: Text("Share")),

                                // TextButton(
                                //     onPressed: () {}, child: Text("Print"))
                              ],
                            );
                          });
                    },
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

  Widget reportCell(int index) {
    return Padding(
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
    );
  }
}
