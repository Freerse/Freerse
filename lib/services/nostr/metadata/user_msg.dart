import '../nips/nip04.dart';

class UserMsg {
  UserMsg({
      required this.id,
      required this.create,
      this.plainContent,
      this.decryptFunc,
      this.sourceContent,
      this.decryptPubkey,
      required this.sig,
      required this.sender,
      required this.receiver,
      required this.tags,
      this.isPic = false,
      this.isTimeLine = false,});

  String id;
  int create;
  String? plainContent;
  String sig;
  String sender;
  String receiver;
  List<dynamic> tags;
  bool isPic;
  bool isTimeLine;

  String Function(String, String)? decryptFunc;
  String? sourceContent;
  String? decryptPubkey;

  String get content {
    if (plainContent == null && decryptFunc != null && sourceContent != null && decryptPubkey != null) {
      try {
        plainContent = decryptFunc!(decryptPubkey!, sourceContent!);
      } catch (e) {
        print("decrypt content error");
        print(e);
        return sourceContent!;
      }
      return plainContent!;
    } else {
      return plainContent!;
    }
  }

  // Map<String, dynamic> toJson() {
  //   final map = <String, dynamic>{};
  //   map['id'] = id;
  //   map['create'] = create;
  //   map['content'] = content;
  //   map['sig'] = sig;
  //   map['sender'] = sender;
  //   map['receiver'] = receiver;
  //   return map;
  // }

}
