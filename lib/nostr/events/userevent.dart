import 'dart:convert';

import 'package:freerse/nostr/event.dart';

class UserEvent extends Event{
  String name = '';
  String website = '';
  String picture = '';
  String displayName = '';
  String about = '';
  String nip05 = '';
  String lud16 = '';
  String banner = '';
  int follow = 0;

  UserEvent(super.id, super.pubkey, super.createdAt, super.kind, super.tags, super.content, super.sig){
    var data = jsonDecode(content);
    name = data['name']??'';
    website = data['website']??'';
    picture = data['picture']??'';
    displayName = data['display_name']??'';
    about = data['about']??'';
    nip05 = data['nip05']??'';
    lud16 = data['lud16']??'';
    banner = data['banner']??'';
  }

}
