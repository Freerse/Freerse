import 'package:sqflite/sqflite.dart';

class DB {
  static const _VERSION = 1;

  static const _dbName = "freerse.db";

  static Database? _database;

  static init() async {
    String path = _dbName;

    // init db
    _database = await openDatabase(path, version: _VERSION,
        onCreate: (Database db, int version) async {
      db.execute(
          "create table event(key_index  INTEGER, id         text,pubkey     text,created_at integer,kind       integer,tags       text,content    text);");
      db.execute(
          "create unique index event_key_index_id_uindex on event (key_index, id);");
      db.execute(
          "create index event_date_index    on event (key_index, kind, created_at);");
      db.execute(
          "create index event_pubkey_index    on event (key_index, kind, pubkey, created_at);");
    });
  }

  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  static Future<DatabaseExecutor> getDB(DatabaseExecutor? db) async {
    if (db != null) {
      return db;
    }
    return getCurrentDatabase();
  }

  static void close() {
    _database?.close();
    _database = null;
  }
}
