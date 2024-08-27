import 'dart:convert';

import '../utils/string_utils.dart';

class Tweet {
  String id;
  String pubkey;
  String userFirstName;
  String userUserName;
  String userProfilePic;
  String content;
  List<String> imageLinks;
  int tweetedAt;
  int likesCount;
  int commentsCount;
  int retweetsCount;
  List<dynamic> tags;
  List<dynamic> replies;
  bool isReply = false;
  bool isSecondReply = false;
  dynamic eventString;
  Tweet? parentTweet;
  bool isRepost;

  bool isArticle;
  String title;
  String coverImage;
  String jsonEnocde;

  static Tweet blank() {
    return Tweet(id: '', pubkey: '', userFirstName: '', userUserName: '', userProfilePic: '', content: '', imageLinks: [], tweetedAt: 0, tags: [], likesCount: 0, commentsCount: 0, retweetsCount: 0, replies: []);
  }

  Tweet(
      {required this.id,
      required this.pubkey,
      required this.userFirstName,
      required this.userUserName,
      required this.userProfilePic,
      required this.content,
      required this.imageLinks,
      required this.tweetedAt,
      required this.tags,
      required this.likesCount,
      required this.commentsCount,
      required this.retweetsCount,
      required this.replies,
      this.isReply = false,
      this.isSecondReply = false,
      this.eventString = '',
      this.isRepost = false,
        this.isArticle = false,
        this.title = '',
        this.coverImage = '',
        this.jsonEnocde = ''
      });

  bool isBlank() {
    return id == "";
  }

  @override
  bool operator ==(other) {
    return other is Tweet && id == other.id;
  }


  String getRootId(){
    var rootId = '';
    var listIds = [];
    if(isReply){
      tags.forEach((element) {
        if (element[0] == "e") {
          if (element.length > 3 && element[3] == "root") {
            rootId = element[1];
            return;
          }
          listIds.add(element[1]);
        }
      });
      if (StringUtils.isBlank(rootId) && listIds.length > 0) {
        rootId = listIds[0];
      }
    }
    return rootId;
  }

  String getRootPubkey(){
    var rootPubkey = '';
    var listIds = [];
    if(isReply){
      tags.forEach((element) {
        if (element[0] == "p") {
          listIds.add(element[1]);
        }
      });
      if (StringUtils.isBlank(rootPubkey) && listIds.length > 0) {
        rootPubkey = listIds[0];
      }
    }
    return rootPubkey;
  }

  // 这个应该是回复id
  String getSecondId(){
    var secondId = '';
    var listIds = [];
    if(isSecondReply){
      tags.forEach((element) {
        if (element[0] == "e") {
          if (element.length > 3 && element[3] == "reply") {
            secondId = element[1];
            return;
          }
          listIds.add(element[1]);
        }
      });
      if (StringUtils.isBlank(secondId) && listIds.length > 1) {
        secondId = listIds[1];
      }
    }
    return secondId;
  }

  void setRepostTweet(Tweet parent){
    parentTweet = parent;
    isRepost = true;
  }

  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
        id: json['id'],
        pubkey: json['pubkey'],
        userFirstName: json['userFirstName'],
        userUserName: json['userUserName'],
        userProfilePic: json['userProfilePic'],
        content: json['tweet'],
        imageLinks: json['imageLinks'].cast<String>(),
        tweetedAt: json['tweetedAt'],
        tags: json['tags'],
        replies: json['replies'],
        likesCount: json['likesCount'],
        commentsCount: json['commentsCount'],
        retweetsCount: json['retweetsCount'],
        isReply: json['isReply'],
        isArticle: json['isArticle']
    );
  }

  factory Tweet.fromHttpJson(Map<String, dynamic> json) {
    return Tweet(
        id: json['id'],
        pubkey: json['author']['pubkey'],
        userFirstName: json['author']['pubkey'],
        userUserName: json['author']['pubkey'],
        userProfilePic: json['author']['pubkey'],
        content: json['event']['content'],
        imageLinks: [],
        tweetedAt: json['event']['created_at'],
        tags:  json['event']['tags'],
        replies: [],
        eventString: json['event'],
        likesCount: 0,
        commentsCount: 0,
        retweetsCount: 0,
        isReply: false,
        isArticle: false
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pubkey': pubkey,
        'userFirstName': userFirstName,
        'userUserName': userUserName,
        'userProfilePic': userProfilePic,
        'tweet': content,
        'imageLinks': imageLinks,
        'tweetedAt': tweetedAt,
        'tags': tags,
        'replies': replies,
        'likesCount': likesCount,
        'commentsCount': commentsCount,
        'retweetsCount': retweetsCount,
        'isReply': isReply,
        'isArticle':isArticle
      };

  factory Tweet.fromNostrEvent(dynamic eventMap) {
    // extract media links from content and remove from content
    String jsonEnocdeTemp = jsonEncode(eventMap);
    String content = eventMap["content"];
    List<String> imageLinks = [];
    RegExp exp = RegExp(r"(https?:\/\/[^\s]+)");
    Iterable<RegExpMatch> matches = exp.allMatches(content);
    for (var match in matches) {
      var link = match.group(0);
      if (link!.endsWith(".jpg") ||
          link.endsWith(".jpeg") ||
          link.endsWith(".png") ||
          link.endsWith(".gif") ||
          link.endsWith(".webp") ||
          link.contains("void.cat")) {
        imageLinks.add(link);
        content = content.replaceAll(link, "");
      }
    }

    // check if it is a reply
    var isReply = false;
    var tempReply = 0;
    // 有时候 event 里面会有多个 e，该 map 用于过滤
    Map<String, int> eTags = {};
    String? replyId;
    String? rootId;

    var isArticle = false;
    String titleTemp = '';
    String covertemp = '';
    for (var t in eventMap["tags"]) {
      if (t[0] == "e") {
        if (t.length > 3 && t[3] == "reply") {
          replyId = t[1];
        } else if (t.length > 3 && t[3] == "root") {
          rootId = t[1];
        }
        isReply = true;
        // tempReply++;
        eTags[t[1]] = 1;
      }else if(t[0] == 'p'){

      }else if(t[0] == 'title'){
        isArticle = true;
        titleTemp = t[1];
      }else if(t[0] == 'image'){
        isArticle = true;
        covertemp = t[1];
      }
    }
    tempReply = eTags.keys.length;


    var isSecondReply = (rootId != replyId && StringUtils.isNotBlank(replyId)) || tempReply>=2 ? true : false;

    return Tweet(
        id: eventMap["id"],
        pubkey: eventMap["pubkey"],
        userFirstName: "name",
        userUserName: eventMap["pubkey"],
        userProfilePic: "",
        content: content,
        imageLinks: imageLinks,
        tweetedAt: eventMap["created_at"],
        tags: eventMap["tags"],
        replies: [],
        likesCount: 0,
        commentsCount: 0,
        retweetsCount: 0,
        isReply: isReply,
        isSecondReply: isSecondReply,
        eventString: eventMap,
        isArticle: isArticle,
        title: titleTemp,
        coverImage: covertemp,
         jsonEnocde: jsonEnocdeTemp
    );
  }

  static Tweet? genRepostTweet(Map<String, dynamic> eventMap) {
    var tweet = Tweet.fromNostrEvent(eventMap);
    var repostContent = eventMap['content'];
    if (StringUtils.isNotBlank(repostContent)) {
      try {
        var tweetRepost = Tweet.fromNostrEvent(jsonDecode(repostContent));
        tweet.setRepostTweet(tweetRepost);
      } catch (e) {
        return null;
      }
      return tweet;
    }

    return null;
  }

}
