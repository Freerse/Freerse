// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_unnecessary_containers, must_be_immutable

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:freerse/views/common/content/content_card_image.dart';
import 'package:freerse/views/common/content/content_card_title.dart';
import 'package:freerse/views/common/mentioned_event/mentioned_event_view.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../config/ColorConstants.dart';
import '../../../nostr/nips/nip_019_hrps.dart';
import '../../../nostr/nips/nip_019_tlv.dart';
import '../../../page/search/search_list/search_list_view.dart';
import '../../../services/nostr/nostr_service.dart';
import '../../feed/tweetImage.dart';
import '../../vedio/content_video_component.dart';
import '../ViewUtils.dart';

class ContentComponent extends StatelessWidget {
  static final String NL = "\n";

  static final String SP = " ";

  GestureTapCallback? onTap;

  String content;

  List<dynamic> tags;

  NostrService nostrService = Get.find();

  bool showInFeed;

  int limitMaxLines = 8;

  Color? fontColor;

  double? fontSize;

  bool showShowmore;

  ContentComponent({
    this.onTap,
    required this.content,
    required this.tags,
    this.showInFeed = true,
    this.limitMaxLines = 8,
    this.fontColor,
    this.fontSize,
    this.showShowmore = true,
  });

  static final int NIP19_STR_LENGTH = 63;

  Map favIconList = {};
  Map webSiteTitleMap = {};
  double width = 0;

  // final String videoUrl = "https://jomin-web.web.app/resource/video/video_iu.mp4";
  // late VideoPlayerController _videoPlayerController;
  //
  // Future<void> initializePlayer(String url) async {
  //   _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
  //   await _videoPlayerController.initialize();
  //   _videoPlayerController.setLooping(true);
  //   _videoPlayerController.setVolume(0);
  //   await _videoPlayerController.play();
  //
  //   // if (mounted) {
  //   //   setState(() {});
  //   // }
  // }

  Future<http.Response> fetchThumbnail(String url) async {
    final response = await http.get(Uri.parse(url));
    return response;
  }

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyMedium!;
    if (fontColor != null || fontSize != null) {
      style = TextStyle(
        color: fontColor,
        fontSize: fontSize,
      );
    }

    width = MediaQuery.of(context).size.width;

    List<InlineSpan> list = [];
    List<String> imageList = [];
    List<Widget> cardList = [];
    Widget componentVedio = Container();

    var buffer = StringBuffer();
    content = content.trim();

    if (tags != null) {
      for (var i = 0; i < tags.length; i++) {
        var tag = tags[i];
        if (tag is List && tag.length > 1) {
          var key = tag[0];
          var value = tag[1];
          String? code;

          if (key == "p") {
            code = Nip019.encodePubKey(value);
          } else if (key == "e") {
            code = Nip019.encodeNoteId(value);
          }

          if (code != null) {
            code = "${Nip019Hrps.NOSTR_PRE}$code";
            content = content.replaceFirst("#[$i]", code);
          }
        }
      }
    }
    if (StringUtils.isBlank(content)) {
      return Container();
    }

    var lineStrs = content.split(NL);
    for (var i = 0; i < lineStrs.length; i++) {
      var lineStr = lineStrs[i];
      var strs = lineStr.split(SP);
      for (var j = 0; j < strs.length; j++) {
        var str = strs[j];
        if (str.indexOf("http") == 0) {
          var urlText = str;
          if (str.contains("#")) {
            urlText = urlText.substring(0, str.indexOf("#"));
          }
          var isImg = urlText!.endsWith(".jpg") ||
              urlText.endsWith(".jpeg") ||
              urlText.endsWith(".png") ||
              urlText.endsWith(".gif") ||
              urlText.endsWith(".webp") ||
              urlText.contains("void.cat");

          var isVedio = urlText.endsWith(".mp4") || urlText.endsWith(".mov");

          if (isVedio) {
            bufferToList(list, buffer);
            // componentVedio = ContentVideoComponent(url: urlText);
            list.add(WidgetSpan(child: ContentVideoComponent(url: urlText)));
          } else if (isImg) {
            bufferToList(list, buffer);
            imageList.add(urlText);
          } else {
            bufferToList(list, buffer);

            // cardList.add(buildCard(str));
            list.add(
              buildHighlightText(
                str,
                textOnTap: () {
                  if (str.isNotEmpty) {
                    launchUrl(Uri.parse(str));
                  }
                },
              ),
            );
          }
        } else if (str.indexOf(Nip019Hrps.NOSTR_PRE) == 0) {
          bufferToList(list, buffer);

          str = str.replaceFirst(Nip019Hrps.NOSTR_PRE, "");
          if (Nip019.isPubkey(str)) {
            var strs = subStr(str, NIP19_STR_LENGTH);
            var pubkey = Nip019.decode(strs[0]);
            if (StringUtils.isNotBlank(pubkey)) {
              list.add(buildMentionedUser(pubkey));
            } else {
              list.add(buildHighlightText(Nip019Hrps.NOSTR_PRE + strs[0]));
            }
            if (strs.length > 1) {
              buffer.write(strs[1]);
            }
          } else if (Nip019.isNoteId(str)) {
            if (showInFeed) {
              var strs = subStr(str, NIP19_STR_LENGTH);
              var eventId = Nip019.decode(strs[0]);
              if (StringUtils.isNotBlank(eventId)) {
                list.add(
                  WidgetSpan(
                    child: MentionedEventView(
                      eventId: eventId,
                    ),
                  ),
                );
              } else {
                list.add(buildHighlightText(Nip019Hrps.NOSTR_PRE + strs[0]));
              }
              if (strs.length > 1) {
                buffer.write(strs[1]);
              }
            } else {
              buffer.write(Nip019Hrps.NOSTR_PRE + str);
            }
          } else if (Nip19Tlv.isNprofile(str)) {
            var nprofile = Nip19Tlv.decodeNprofile(str);
            if (nprofile != null) {
              list.add(buildMentionedUser(nprofile.pubkey));
            }
          } else if (Nip19Tlv.isNevent(str)) {
            if (showInFeed) {
              var nevent = Nip19Tlv.decodeNevent(str);
              if (nevent != null) {
                list.add(
                  WidgetSpan(
                    child: MentionedEventView(
                      eventId: nevent.id,
                    ),
                  ),
                );
              }
            } else {
              buffer.write(Nip019Hrps.NOSTR_PRE + str);
            }
          } else {
            list.add(buildHighlightText(Nip019Hrps.NOSTR_PRE + str));
          }
        } else if (str.indexOf("#") == 0 && str.length > 1) {
          bufferToList(list, buffer);

          list.add(buildHighlightText(str, textOnTap: () {
            if (str != null) {
              Get.to(() => SearchListPage(),
                  arguments: {"keyword": str}, preventDuplicates: false);
            }
          }));
        } else {
          buffer.write(str);
        }

        if (strs.length > 1 && j < strs.length - 1) {
          buffer.write(SP);
        }
      }

      if (lineStrs.length > 1 && i < lineStrs.length - 1) {
        buffer.write(NL);
      }
    }

    if (buffer.isNotEmpty) {
      bufferToList(list, buffer);
    }

    if (!showInFeed) {
      // int maxLines = 8;

      StringBuffer allBuffer = StringBuffer();
      for (var item in list) {
        if (item is TextSpan) {
          allBuffer.write(item.text);
        } else if (item is WidgetSpan) {
          if (item.child is MentionedEventView) {
            allBuffer.write(NL);
            allBuffer.write(NL);
            allBuffer.write(NL);
            allBuffer.write(NL);
          }
          if (item.child is ContentVideoComponent) {
            for (var i = 0; i < 10; i++) {
              allBuffer.write(NL);
            }
          } else {
            allBuffer.write("12345678");
          }
        }
      }

      return Container(
        width: double.maxFinite,
        child: LayoutBuilder(builder: (context, constraints) {
          var allText = allBuffer.toString();

          TextPainter textPainter =
              TextPainter(textDirection: TextDirection.ltr);
          textPainter.text = TextSpan(
            text: allText,
            style: style,
            // style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          );
          textPainter.layout(
              minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);

          var lineHeight = textPainter.preferredLineHeight;
          var lineNum = textPainter.height / lineHeight;
          // print("lineNum $lineNum lineHeight $lineHeight");

          if (lineNum <= limitMaxLines) {
            return SelectableText.rich(
              TextSpan(
                children: list,
              ),
              onTap: onTap,
              // style: Theme.of(context).textTheme.bodyMedium,
              style: style,
            );
          } else {

            int preItemLine = 0;
            StringBuffer buffer = StringBuffer();
            List<InlineSpan> newList = [];
            var listLength = list.obs.length;
            var index = 0;
            for (; index < listLength; index++) {
              var item = list[index];
              if (item is TextSpan) {
                buffer.write(item.text);
              } else if (item is WidgetSpan) {
                if (item.child is MentionedEventView) {
                } else if (item.child is ContentVideoComponent) {
                  for (var i = 0; i < 10; i++) {
                    allBuffer.write(NL);
                  }
                } else {
                  allBuffer.write("12345678");
                }
              }

              textPainter.text = TextSpan(
                text: buffer.toString(),
                // style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
              );
              textPainter.layout(
                  minWidth: constraints.minWidth,
                  maxWidth: constraints.maxWidth);

              var currentLineNum = textPainter.height / lineHeight;
              if (currentLineNum <= limitMaxLines) {
                preItemLine = currentLineNum.toInt();
                newList.add(item);
              } else {
                if (item is WidgetSpan) {
                  break;
                } else if (item is TextSpan) {
                  var currentGroupLineNum =
                      currentLineNum - preItemLine;
                  var removeLineNum = currentLineNum - limitMaxLines;
                  print(
                      "currentLineNum $currentLineNum currentGroupLineNum $currentGroupLineNum removeLineNum $removeLineNum");

                  var currentItemText = item.text;
                  var currentRemainLineNum =
                      currentGroupLineNum - removeLineNum;
                  if (currentRemainLineNum > 2) {
                    currentRemainLineNum -= 1.5;
                  }
                  var subEndLength = (currentRemainLineNum /
                          currentGroupLineNum *
                          currentItemText!.length)
                      .toInt();
                  var newItemText = currentItemText.substring(0, subEndLength);

                  newList.add(TextSpan(text: newItemText));
                  break;
                }
              }
            }
            if (showShowmore && index < listLength) {
              newList.add(TextSpan(text: "... " + "SHOW_MORE".tr));
            }

            return Column(
              children: [
                SelectableText.rich(
                  TextSpan(
                    children: newList,
                  ),
                  onTap: onTap,
                  // style: Theme.of(context).textTheme.bodyMedium,
                  // style: TextStyle(fontSize: fontSize, color: Colors.blue),
                  style: style,
                ),
                if (cardList.isNotEmpty) cardList[0],
              ],
            );
          }
        }),
      );
    } else {
      return Container(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText.rich(
                TextSpan(
                  children: list,
                ),
                onTap: onTap,
                // style: Theme.of(context).textTheme.bodyMedium,
                style: style,
              ),
              imageList.isEmpty
                  ? Container()
                  : Container(
                      height: ScreenUtil().setHeight(3),
                    ),
              imageList.isEmpty
                  ? Container()
                  : TweetImage(
                      picList: imageList,
                    ),
              if (cardList.isNotEmpty) cardList[0],
              componentVedio
            ],
          ));
    }
  }

  void bufferToList(List<InlineSpan> list, StringBuffer buffer) {
    list.add(TextSpan(text: buffer.toString()));
    buffer.clear();
  }

  WidgetSpan buildMentionedUser(String pubkey) {
    return WidgetSpan(child: Obx(() {
      var userInfo = nostrService.userMetadataObj.getUserInfo(pubkey);
      var name = ViewUtils.userShowName(userInfo, userId: pubkey);

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          print("pubkey $pubkey");
          Get.toNamed("/user", arguments: pubkey, preventDuplicates: false);
        },
        child: Text(
          "@$name",
          style: TextStyle(
            color: ColorConstants.greenColor,
            decoration: TextDecoration.none,
            fontSize: Get.textTheme.bodyMedium!.fontSize,
          ),
        ),
      );
    }));
  }

  buildCard(String url) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(1, 247, 247, 247), width: 0.5),
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 247, 247, 247),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: ContentCardImage(url: url),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 2),
            child: ContentCardTitle(url: url),
          ),
        ],
      ),
    );
  }

  TextSpan buildHighlightText(String text, {GestureTapCallback? textOnTap}) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: ColorConstants.greenColor,
        decoration: TextDecoration.none,
      ),
      recognizer: TapGestureRecognizer()..onTap = textOnTap,
    );
  }

  List<String> subStr(String str, int maxLength) {
    List<String> strs = [];
    if (str.length > maxLength) {
      strs.add(str.substring(0, maxLength));
      strs.add(str.substring(maxLength));
    } else {
      strs.add(str);
    }
    return strs;
  }
}
