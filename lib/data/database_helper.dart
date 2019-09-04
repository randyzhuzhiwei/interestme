import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:interest_me_mobile_app/models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "interestme.db");

    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);

    return ourDb;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['username'] = "ran";
    map['password'] = "123";
    map['avatarname'] = "Mr Lucky";
    map['status'] =
        "I am a person who is positive about every aspect of life. There are many things I like to do, to see, and to experience. I like to read, I like to write; I like to think, I like to dream; I like to talk, I like to listen. I like to see the sunrise in the morning, I like to see the moonlight at night; I like to feel the music flowing on my face, I like to smell the wind coming from the ocean. ";
    return map;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        """CREATE TABLE User(id INTEGER PRIMARY KEY, username TEXT, password TEXT,avatarname TEXT, status TEXT)""");
    await db.insert("User", toMap());
    print("Table is created");
  }

  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int res = await dbClient.insert("User", user.toMap());
    return res;
  }

  Future<int> deleteUser(User user) async {
    var dbClient = await db;
    int res = await dbClient.delete("User");
    return res;
  }

  Future<List<Map<String, dynamic>>> query(String sqlStmt) async {
    var dbClient = await db;
    return await dbClient.rawQuery(sqlStmt);
  }
   Future<int> dropUser() async {
    var dbClient = await db;
    int res = await dbClient.execute(
        """DROP TABLE User""");
         print("Table is dropped");
    return res;
  }
     Future<int> createUsertabele() async {
    var dbClient = await db;
     int res = await dbClient.execute(
        """CREATE TABLE User(id INTEGER PRIMARY KEY, username TEXT, password TEXT,avatarname TEXT, status TEXT)""");
      print(res);
    await dbClient.insert("User", toMap());
    print("Table is created");

    return 1;
  }

}
