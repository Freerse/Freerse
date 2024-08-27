import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';
import 'package:linkify/linkify.dart';

/// For details on how this RegEx works, go to this link.
/// https://regex101.com/r/QN046t/1
// final _userTagRegex = RegExp(
//   r'^(.*?)(?<![\w#])#([\w#]+(?:[.!][\w#]+)*)',
//   caseSensitive: false,
//   dotAll: true,
// );

// final atIdentifierRegex = RegExp(r'^#[a-zA-Z0-9]{1,}$',
// // final atIdentifierRegex = RegExp(r'^(#?\[*\])',
//   caseSensitive: false,
// );

// RegExp atIdentifierRegex = RegExp(r'^#[a-zA-Z0-9]{1,}$');
RegExp atIdentifierRegex = RegExp(r'#\[([1-9]\d?|0)\]');
// RegExp atIdentifierRegex = RegExp(r'^#?\d*]\d*$');
// Regex(r'^#?\d*]\d*$').firstMatch(input).string;


class AtUserLinkfier extends Linkifier {
  List<dynamic> tags;
  AtUserLinkfier({required this.tags});


  // void isMatch(String input) {
  //   RegExp regExpStr = RegExp(r'#\[([1-9]\d?|0)\]');
  //   bool isContainer = regExpStr.hasMatch(input);
  //   final matchAt = regExpStr.firstMatch(input);
  //   final text = matchAt?.group(0);
  //   print("'${input}' 是否包含字符串：'好好学习,好好爱自己' 中任意一个字符 ${isContainer} 撇皮到${text}\n");
  // }

  List<String> getMatchRefList(String input) {
    List<String> results = [];
    RegExp regExpStr = RegExp(r'#\[([1-9]\d?|0)\]');
    bool isContainer = regExpStr.hasMatch(input);
    Iterable<RegExpMatch> matchList = regExpStr.allMatches(input);
    for (RegExpMatch matchAt in matchList) {
      final text = matchAt?.group(0);
      final text1 = matchAt?.group(1);
      results.add(text!);
    }
    return results;


    // final text = matchAt?.group(0);
  }

  List<String> getNowTag(int tagIndex){
    List<String> rs = [];
    if(tags.length >= tagIndex+1){
      List<dynamic> tagInfoList = tags[tagIndex];
      if(tagInfoList.isNotEmpty){
        print('${'tag=' + tagInfoList[0]} |id=' + tagInfoList[1]);
        rs.add(tagInfoList[0]);
        rs.add(tagInfoList[1]);
      }
    }
    return rs;
  }

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];


    String input = '12#[0]23a#[1]bsdfsd#[2]';
    // getMatchRefList(input);

    // final matchAt = atIdentifierRegex.firstMatch(input);
    // bool isContainer = atIdentifierRegex.hasMatch(input);
    // final text = matchAt?.group(0);
    // print('tags=' + tags[0]);

    if(tags.isNotEmpty){
      List<dynamic> tagInfoList = tags[0];
      if(tagInfoList.isNotEmpty){
        //print('tags=' + tagInfoList[0] + ' |id=' + tagInfoList[1]);
      }
    }


    elements.forEach((element) {

      if (element is TextElement) {
        final match = atIdentifierRegex.firstMatch(element.text);
        // final matchAt = atIdentifierRegex.firstMatch(element.text);
        // if(matchAt != null){
        //   final text = element.text.toString();
        // }

        // List<String> matchRefList = getMatchRefList(element.text);

        if (match == null) {
          list.add(element);
        } else {
          String keyWord = match.group(0)!;
          String index = match.group(1)!;
          // final text = element.text.replaceFirst(keyWord, '');
          List<String> subStrings = element.text.split(keyWord);
          if(subStrings.length == 2){
            list.add(TextElement(subStrings[0]));
          }

          List<String> tagInfo = getNowTag(int.parse(index));
          String infoKey = tagInfo[1];

          list.add(UserNameTagElement('@${ViewUtils.formatLongText(infoKey!)}', '@${'${tagInfo[0]}_${infoKey!}'}', tagInfo[0], infoKey));

          // if (match.group(1)?.isNotEmpty == true) {
          //   list.add(TextElement(match.group(1)!));
          // }
          //
          // if (match.group(2)?.isNotEmpty == true) {
          //   list.add(UserTagElement('@${match.group(2)!}'));
          // }

          if (subStrings[1].isNotEmpty) {
            list.addAll(parse([TextElement(subStrings[1])], options));
          }
        }
      } else {
        list.add(element);
      }
    });

    return list;
  }
}

class UserNameTagElement extends LinkableElement {
  String text;
  final String url;
  final String type;
  final String userId;
  late final NostrService nostrService = Get.find();

  UserNameTagElement(this.text, this.url, this.type, this.userId) : super(text, url){
    parseUserName();
  }


  void parseUserName(){
    if(type == 'p'){
      if(userId != null && userId != ''){
        var result = nostrService.userMetadataObj.getUserInfo(userId.toString());
        text = '@' + ViewUtils.userShowName(result, userId: userId);
      }
    }

  }

  @override
  String toString() {
    return "UserNameTagElement: '$url' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) =>
      other is UserNameTagElement &&
          super.equals(other) &&
          other.url == url;
}
