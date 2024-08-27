import 'dart:convert';

class EventModel {
  String? content;
  int? createdAt;
  String? id;
  int? kind;
  String? pubkey;
  String? sig;
  List<List>? tags;

  EventModel({this.content, this.createdAt, this.id, this.kind, this.pubkey, this.sig, this.tags});

  EventModel.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    createdAt = json['created_at'];
    id = json['id'];
    kind = json['kind'];
    pubkey = json['pubkey'];
    sig = json['sig'];
    if (json['tags'] != null) {
      var jsonTagList = json['tags'];
      if (json['tags'] is String) {
        jsonTagList = jsonDecode(json['tags']);
      }
      tags = <List>[];
      jsonTagList.forEach((v) {
        var tempList = <String>[];
        v.forEach((vv){
          tempList.add(vv);
        });
        tags!.add(tempList);
      });
    }
  }

  Map<String, dynamic> toJson({bool hasTags = false}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['kind'] = this.kind;
    data['pubkey'] = this.pubkey;
    data['sig'] = this.sig;
    if (hasTags) {
      data['tags'] = this.tags;
    }
    return data;
  }
}
