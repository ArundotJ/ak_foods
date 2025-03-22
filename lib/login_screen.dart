import 'package:ak_foods/constants.dart';
import 'package:ak_foods/data_manager.dart';
import 'package:ak_foods/tab_bar_controller.dart';
import 'package:flutter/material.dart';
import 'dart:convert' show base64, utf8;

import 'package:internet_connection_checker/internet_connection_checker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String userName = "";
  String password = "";
  bool isNetworkOnline = false;
  final connectionChecker = InternetConnectionChecker.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInitialNetworkState();
    final subscription = connectionChecker.onStatusChange.listen(
      (InternetConnectionStatus status) {
        if (status == InternetConnectionStatus.connected) {
          setState(() {
            isNetworkOnline = true;
          });
        } else {
          setState(() {
            isNetworkOnline = false;
          });
        }
      },
    );
  }

  void setInitialNetworkState() async {
    bool value = await connectionChecker.hasConnection;
    setState(() {
      isNetworkOnline = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade200, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Icon(
                  //   FlutterIcons.food_apple_mco, // Food-related icon
                  //   size: 100.0,
                  //   color: Colors.white,
                  // ),
                  SizedBox(height: 20.0),
                  Text(
                    'AK FOODS',
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (value) => setState(() {
                              userName = value;
                            }),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              hintText: 'Username',
                              prefixIcon: Icon(Icons.person, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          TextField(
                            onChanged: (value) => setState(() {
                              password = value;
                            }),
                            obscureText: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () async {
                              // Add your login logic here
                              if (isNetworkOnline) {
                                DataManager manager = DataManager();
                                var encodedPWD = utf8.encode(password);
                                final base64EncodedPWD =
                                    base64.encode(encodedPWD);
                                final result = await manager.login(
                                    userName, base64EncodedPWD);
                                if (result != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TabbarView(
                                              userData: result,
                                            )),
                                  );
                                } else {
                                  showAlertDialog(context);
                                }
                              } else {
                                Constants.showAlert(
                                    "Alert",
                                    "Please check the network connectivity to proceed!",
                                    context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade200,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // TextButton(
                  //   onPressed: () {
                  //     // Add your sign-up logic here
                  //   },
                  //   child: Text(
                  //     'Don\'t have an account? Sign Up',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Login failed!"),
      content: Text("Something wrong with the login details. Please verify"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
