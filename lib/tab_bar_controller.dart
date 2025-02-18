import 'package:ak_foods/home_screen.dart';
import 'package:ak_foods/user.dart';
import 'package:flutter/material.dart';

class TabbarView extends StatefulWidget {
  final User userData;
  const TabbarView({super.key, required this.userData});

  @override
  _TabbarViewState createState() => _TabbarViewState();
}

class _TabbarViewState extends State<TabbarView> {
  int _currentIndex = 0; // Index of the selected tab
  late String userName;

  // List of screens for each tab
  List<Widget> _screens = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userName = widget.userData.name;
    setState(() {
      _screens = [
        HomeScreen(
          userName: userName,
        ),
        SearchScreen(),
        BasketScreen(),
        AccountScreen(name: userName)
      ];
    });
  }

  // void _loadUserData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final result = prefs.getString(Constants.UserKey);
  //   if (result != null) {
  //     final data = jsonDecode(result);
  //     User userData = User.fromJson(data[0]);
  //     setState(() {
  //       userName = userData.name;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the selected screen
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
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Basket',
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

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

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
                Text('Welcome $name'),
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
