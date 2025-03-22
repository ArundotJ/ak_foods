import 'package:ak_foods/home_screen.dart';
import 'package:ak_foods/item_selection_popup.dart';
import 'package:ak_foods/myStocks.dart';
import 'package:ak_foods/payment_screen.dart';
import 'package:ak_foods/receptDetailsScreen.dart';
import 'package:ak_foods/user.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class TabbarView extends StatefulWidget {
  final User userData;
  const TabbarView({super.key, required this.userData});

  @override
  _TabbarViewState createState() => _TabbarViewState();
}

class _TabbarViewState extends State<TabbarView> {
  int _currentIndex = 0; // Index of the selected tab

  // List of screens for each tab
  List<Widget> _screens = [];
  final connectionChecker = InternetConnectionChecker.instance;
  bool isNetworkOnline = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInitialNetworkState();
    setState(() {
      _screens = [
        HomeScreen(
          user: widget.userData,
        ),
        MyStocksScreen(
          user: widget.userData,
        ),
        PaymenyScreen(),
        AccountScreen(name: widget.userData.name)
      ];
    });

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
      body: isNetworkOnline == true
          ? _screens[_currentIndex]
          : NoInternetScreen(), // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected tab index
          });
        },
        type: BottomNavigationBarType.fixed, // Ensure all tabs are visible
        selectedItemColor: Colors.red.shade300, // Color of the selected tab
        unselectedItemColor: Colors.grey, // Color of unselected tabs
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Stocks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Search Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  _BasketScreenState createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  String selectedItem = 'Select Item';
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Basket Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  final String name;

  const AccountScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Section
        Expanded(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // User Icon
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.blue,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '$name',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                // Logout Button
                ElevatedButton(
                  onPressed: () {
                    // Add logout functionality here
                    _logout(context);
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          ),
        ),
        // Bottom Section
        Expanded(
          flex: 3,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              ListTile(
                leading: Icon(Icons.inventory),
                title: Text('My Stock'),
                onTap: () {
                  // Navigate to My Stock screen
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Sales'),
                onTap: () {
                  // Navigate to Sales screen
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.account_box),
                title: Text('My Account'),
                onTap: () {
                  // Navigate to My Account screen
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _logout(BuildContext context) {
    Navigator.pop(context);
  }
}

class NoInternetScreen extends StatelessWidget {
  // Function to simulate checking internet connection
  Future<void> _checkInternetConnection(BuildContext context) async {
    // Simulate a network call or connection check
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image to represent no internet
            Icon(Icons.wifi,
                color: Colors.red), // Add your image to the assets folder
            SizedBox(height: 20),
            // Message
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            // Retry button
            ElevatedButton(
              onPressed: () => _checkInternetConnection(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
