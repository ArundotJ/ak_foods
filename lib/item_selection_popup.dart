import 'dart:convert';
import 'dart:ffi';

import 'package:ak_foods/customerModel.dart';
import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/home_screen.dart';
import 'package:flutter/material.dart';

final class ListItemData {
  String title;
  String id;

  ListItemData(this.title, this.id);
}

class ItemSelectionPopup extends StatefulWidget {
  final List<ListItemData> allItems;
  const ItemSelectionPopup({super.key, required this.allItems});
  @override
  _ItemSelectionPopupState createState() => _ItemSelectionPopupState();
}

class _ItemSelectionPopupState extends State<ItemSelectionPopup> {
  List<ListItemData> allItems = [];
  List<ListItemData> filteredItems = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allItems = widget.allItems;
    filteredItems = allItems;
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = allItems
          .where((item) => item.title.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          // List of Items
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredItems[index].title),
                  onTap: () {
                    Navigator.pop(context, filteredItems[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
