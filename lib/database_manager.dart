import 'package:mssql_connection/mssql_connection.dart';

class DataBaseManager {
  static final DataBaseManager _singleton = DataBaseManager._internal();
  static MssqlConnection mssqlConnection = MssqlConnection.getInstance();
  factory DataBaseManager() {
    return _singleton;
  }

  DataBaseManager._internal();

  Future<bool> connectSQLServer() async {
    bool isConnected = await mssqlConnection.connect(
      ip: '103.21.58.193',
      port: '1433',
      databaseName: 'akfoods_Inventory_DB',
      username: 'akfoodsarun',
      password: 'akfoodsadminarun@123',
      timeoutInSeconds: 15,
    );
    return isConnected;
  }

  Future<String> queryFromSQL(String query) async {
    return await mssqlConnection.getData(query);
  }

  Future<String> updateQueryFromSQL(String query) async {
    return await mssqlConnection.writeData(query);
  }
}
