import 'dart:convert';

import 'package:freerse/utils/string_utils.dart';
import 'package:sqflite/sqflite.dart';

import '../model/EventModel.dart';
import 'db.dart';

class EventDB {
  static Future<List<EventModel>> list(int keyIndex, int kind, int skip, limit,
      {DatabaseExecutor? db, String? pubkey}) async {
    db = await DB.getDB(db);
    List<EventModel> l = [];
    List<dynamic> args = [];

    var sql = "select * from event where key_index = ? and kind = ? ";
    args.add(keyIndex);
    args.add(kind);
    if (StringUtils.isNotBlank(pubkey)) {
      sql += " and pubkey = ? ";
      args.add(pubkey);
    }
    sql += " order by created_at desc limit ?, ?";
    args.add(skip);
    args.add(limit);

    List<Map<String, dynamic>> list = await db.rawQuery(sql, args);
    for (var listObj in list) {
      l.add(loadFromJson(listObj));
    }
    return l;
  }

  static Future<int> insert(int keyIndex, EventModel o,
      {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var jsonObj = o.toJson();
    var tags = jsonEncode(o.tags);
    jsonObj["tags"] = tags;
    jsonObj.remove("sig");
    jsonObj["key_index"] = keyIndex;
    return await db.insert("event", jsonObj);
  }

  static Future<EventModel?> get(int keyIndex, String id,
      {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var list = await db.query("event",
        where: "key_index = ? and id = ?", whereArgs: [keyIndex, id]);
    if (list.isNotEmpty) {
      return EventModel.fromJson(list[0]);
    }
  }

  static Future<void> deleteAll(int keyIndex, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    db.execute("delete from event where key_index = ?", [keyIndex]);
  }

  static EventModel loadFromJson(Map<String, dynamic> data) {
    Map<String, dynamic> m = {};
    m.addAll(data);

    var tagsStr = data["tags"];
    var tagsObj = jsonDecode(tagsStr);
    m["tags"] = tagsObj;
    m["sig"] = "";
    return EventModel.fromJson(m);
  }
}
