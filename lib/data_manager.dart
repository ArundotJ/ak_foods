import 'dart:convert';

import 'package:ak_foods/database_manager.dart';
import 'package:ak_foods/user.dart';

class DataManager {
  Future<User?> login(String userName, String password) async {
    bool isConnected = await DataBaseManager().connectSQLServer();
    if (isConnected == true) {
      String result = await DataBaseManager().queryFromSQL(
          "SELECT * FROM registration WHERE UserID = '$userName' AND Password = '$password' ");
      final data = jsonDecode(result);
      if (data.length > 0 && data[0] != null) {
        return User.fromJson(data[0]);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
