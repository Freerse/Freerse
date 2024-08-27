// ignore_for_file: sort_child_properties_last, prefer_const_constructors, avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/page/user_list/user_list_view.dart';
import 'package:freerse/page/zap/zap_custom_sender_view.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/bottom_more_dialog/bottom_user_more_dialog_view.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/helpers.dart';
import '../../services/nostr/nips/zap_service.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/common/gallery_page/gallery_page_view.dart';
import '../../views/feed/avatar_holder.dart';
import '../../views/feed/feed_view.dart';
import '../mine_profile/mine_profile_view.dart';
import 'user_controller.dart';

class UserPage extends StatelessWidget {
  final controller =
      Get.put(UserController(), tag: Helpers().getRandomString(12));
  late final NostrService nostrService = Get.find();

  ZapService zapService = Get.find();

  blockUser() async {
    // open dialog
    /*  var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Block user"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("Are you sure you want to block this user?"),
                SizedBox(height: 20),
                Text("You will no longer see their posts."),
                SizedBox(height: 10),
                Text(
                    "This happens only locally if you login on another client you will see their posts again.")
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text("Block"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
    if (!result) return;*/
/*
    // add to blocked list
    await widget._nostrService.addToBlocklist(widget.pubkey);

    Navigator.pop(context);*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        onPressed: () {
          Get.toNamed("/write", arguments: {"isArticle": false});
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        var result = controller.nostrService.userMetadataObj
            .getUserInfo(controller.pubkey.toString());
        var bannerUrl = result['banner'] ?? '';
        var name = ViewUtils.userShowName(result,
            userId: controller.pubkey.toString());
        var about = result['about'] ?? '';
        var lud06 = result['lud06'] ?? '';
        var lud16 = result['lud16'] ?? '';
        var nip05 = result['nip05'] ?? '';
        var website = result['website'] ?? '';

        bool isFollow = nostrService.userContactsObj
            .isFollowByMe(controller.pubkey.toString());

        bool isMe = false;
        if (nostrService.myKeys.publicKey == controller.pubkey.toString()) {
          isMe = true;
        }

        return Stack(
          children: [
            CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor:
                      Get.isDarkMode ? Color(0xFF191919) : Colors.white,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                  ),
                  expandedHeight: ScreenUtil().setHeight(170),
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      background: bannerUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: bannerUrl,
                              placeholder: (context, url) => Image.asset(
                                'assets/images/default_header.png',
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/default_header.png',
                                fit: BoxFit.cover,
                              ),
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/default_header.png',
                              fit: BoxFit.cover,
                            )),
                  actions: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Get.bottomSheet(BottomUserMoreDialogComponent(
                          pubkey: controller.pubkey.toString(),
                        ));
                      },
                      child: Container(
                        child: Icon(Icons.more_horiz,
                            size: 20,
                            color: controller.scrollOffset > 100
                                ? Get.isDarkMode
                                    ? Colors.white
                                    : Colors.black
                                : Colors.white),
                        margin: EdgeInsets.only(right: 10),
                      ),
                    ),

                    // PopupMenuButton<String>(
                    //   icon: Icon(
                    //     Icons.more_horiz,
                    //     size: 20,
                    //     color: controller.scrollOffset > 100?Colors.black:Colors.white,
                    //     ),
                    //   tooltip: "More",
                    //   onSelected: (e) => {
                    //     nostrService.searchFeedObj.switchBlackUser(userId: controller.pubkey.value)
                    //     // if (e == "block") {}
                    //   },
                    //   itemBuilder: (BuildContext context) {
                    //     var isBlocked = nostrService.searchFeedObj.blackUserIdList.contains(controller.pubkey.value);
                    //     return {isBlocked ? "QU_X_L_HEI".tr : "LA_HEI".tr}.map((String choice) {
                    //       return PopupMenuItem<String>(
                    //         value: choice,
                    //         child: Text(choice),
                    //       );
                    //     }).toList();
                    //   },
                    // ),
                  ],
                  // rounded back button
                  leading: Container(
                      margin: const EdgeInsets.all(0),
                      padding: const EdgeInsets.only(top: 0, right: 0, left: 0),
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          child: Icon(Icons.arrow_back,
                              size: 20,
                              color: controller.scrollOffset > 100
                                  ? Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black
                                  : Colors.white),
                        ),
                      )),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: Container(),
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate([
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                        child: GestureDetector(
                          onTap: () {
                            ZapCustomSenderView.show(controller.pubkey.value);
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Image.asset(
                              !Get.isDarkMode
                                  ? 'assets/images/user_light.png'
                                  : 'assets/images/user_light_dark.png',
                              width: ScreenUtil().setWidth(32)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed("/message",
                              arguments: controller.pubkey.value);
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          margin:
                              EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                          child: GestureDetector(
                            child: Image.asset(
                                !Get.isDarkMode
                                    ? 'assets/images/user_message.png'
                                    : 'assets/images/user_message_dark.png',
                                width: ScreenUtil().setWidth(32)),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (isMe) {
                            Get.to(() => MineProfilePage());
                            return;
                          }
                          if (isFollow) {
                            nostrService
                                .unFollowUser(controller.pubkey.toString());
                          } else {
                            nostrService
                                .followUser(controller.pubkey.toString());
                          }
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          margin:
                              EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                          height: ScreenUtil().setWidth(32),
                          width: ScreenUtil().setWidth(111),
                          decoration: BoxDecoration(
                            // color: Colors.white,
                            border: Border.all(
                              width: 1,
                              color: Get.isDarkMode
                                  ? Color(0xFF242424)
                                  : Color(0xFFe5e5e5),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              isMe
                                  ? "BIAN_JGRZ_LIAO".tr
                                  : isFollow
                                      ? "QU_X_G_ZHU".tr
                                      : "GUAN_ZHU".tr,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(12),
                                // color: ColorConstants.hexToColor("#101418"),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                    margin: EdgeInsets.only(
                        left: ScreenUtil().setWidth(25),
                        top: ScreenUtil().setHeight(25),
                        right: ScreenUtil().setHeight(25)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SelectableText.rich(TextSpan(
                                text: name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: ScreenUtil().setSp(23),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                            ),
                          ],
                        ),
                        Container(
                          height: ScreenUtil().setHeight(5),
                        ),
                        // Text(nip05,style:TextStyle(
                        //     color: Color(0xFF919191),
                        //     fontSize: ScreenUtil().setSp(16)
                        // ),),

                        nip05 == ''
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  var url = nip05;
                                  if (!website.startsWith("http")) {
                                    url = 'https://' + url;
                                  }
                                  launchUrl(Uri.parse(url));
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Text(
                                  nip05,
                                  style: TextStyle(
                                      color: Get.isDarkMode
                                          ? Color(0xFF5e5e5e)
                                          : Color(0xFF919191),
                                      fontSize: ScreenUtil().setSp(16)),
                                ),
                              ),
                        about.toString().isEmpty
                            ? Container()
                            : RichText(
                                text: TextSpan(
                                  children: parseContentWithTextSpans(
                                    about,
                                    TextStyle(
                                      color: Get.isDarkMode
                                          ? const Color(0xFFdbdbdb)
                                          : const Color(0xFF101418),
                                      fontSize: ScreenUtil().setSp(16),
                                    ),
                                  ),
                                ),
                              ),

                        // Container(
                        //     padding: EdgeInsets.only(
                        //         top: ScreenUtil().setHeight(20)),
                        //     child: SelectableText.rich(
                        //         TextSpan(text: about),
                        //         style: TextStyle(
                        //             color: Get.isDarkMode
                        //                 ? const Color(0xFFdbdbdb)
                        //                 : const Color(0xFF101418),
                        //             fontSize: ScreenUtil().setSp(16)))),
                        website == ''
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  var url = website;
                                  if (!website.startsWith("http")) {
                                    url = 'https://' + url;
                                  }
                                  launchUrl(Uri.parse(url));
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(10)),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/user_link.png',
                                        width: ScreenUtil().setWidth(12),
                                      ),
                                      Container(
                                        width: ScreenUtil().setWidth(5),
                                      ),
                                      Text(
                                        website,
                                        style: TextStyle(
                                            color: Get.isDarkMode
                                                ? Color(0xFF5e5e5e)
                                                : Color(0xFF919191),
                                            fontSize: ScreenUtil().setSp(16)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(20)),
                            child: Obx(() {
                              List<String> followData = [];
                              if (controller.showFollowers.value) {
                                List<dynamic> follows = nostrService
                                    .userFollowObj
                                    .getUserFollows(controller.pubkey.value);
                                followData = follows
                                    .map((dynamic item) => item.toString())
                                    .toList();
                              }
                              var relaysCount = 0;
                              List<String> relays = nostrService.userContactsObj
                                  .getUserRelys(controller.pubkey.value);
                              relaysCount = relays.length;

                              var following = nostrService.userContactsObj
                                  .followingFormat[controller.pubkey.value];
                              var followingLength = following != null
                                  ? following.length.toString()
                                  : "0";

                              return Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(
                                          () => UserListPage(
                                                title: "GUAN_ZHU".tr,
                                              ),
                                          arguments: {'data': following},
                                          preventDuplicates: false);
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: Row(
                                      children: [
                                        Text(followingLength),
                                        Container(
                                          width: ScreenUtil().setWidth(5),
                                        ),
                                        Text(
                                          "GUAN_ZHU".tr,
                                          style: TextStyle(
                                              color: Get.isDarkMode
                                                  ? Color(0xFF5e5e5e)
                                                  : Color(0xFF919191),
                                              fontSize: ScreenUtil().setSp(15)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  !controller.showFollowers.value
                                      ? GestureDetector(
                                          onTap: () {
                                            controller.showFollowers.value =
                                                true;
                                          },
                                          behavior: HitTestBehavior.translucent,
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(10),
                                                    right: ScreenUtil()
                                                        .setWidth(5)),
                                                child: Icon(
                                                  IconlyLight.download,
                                                  size:
                                                      ScreenUtil().setWidth(20),
                                                ),
                                              ),
                                              Text(
                                                "FEN_SI".tr,
                                                style: TextStyle(
                                                    color: Get.isDarkMode
                                                        ? Color(0xFF5e5e5e)
                                                        : Color(0xFF919191),
                                                    fontSize:
                                                        ScreenUtil().setSp(15)),
                                              ),
                                            ],
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            Get.to(
                                                () => UserListPage(
                                                      title: "FEN_SI".tr,
                                                    ),
                                                arguments: {'data': followData},
                                                preventDuplicates: false);
                                          },
                                          behavior: HitTestBehavior.translucent,
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(10),
                                                    right: ScreenUtil()
                                                        .setWidth(5)),
                                                child: Text(followData.length
                                                    .toString()),
                                              ),
                                              Text(
                                                "FEN_SI".tr,
                                                style: TextStyle(
                                                    color: Get.isDarkMode
                                                        ? Color(0xFF5e5e5e)
                                                        : Color(0xFF919191),
                                                    fontSize:
                                                        ScreenUtil().setSp(15)),
                                              ),
                                            ],
                                          ),
                                        ),
                                  Container(
                                    width: ScreenUtil().setWidth(10),
                                  ),
                                  /*Text(relaysCount.toString()),
                                    Container(width: ScreenUtil().setWidth(5),),
                                    Text("ZHONG_J_QI".tr,style: TextStyle(color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),fontSize: ScreenUtil().setSp(15)),),*/
                                ],
                              );
                            })),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: controller.tabController,
                    tabs: controller.myTabs,
                    indicatorColor: Theme.of(context).colorScheme.secondary,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 2.0,
                  ),
                  Divider(
                    height: 1,
                  ),
                ])),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return FeedComponent(
                        data: controller.tabIndex == 0
                            ? controller.myTweets[index]
                            : controller.tabIndex == 1
                                ? controller.myTweetsReply[index]
                                : controller.myTweetsArticle[index],
                        showComments: false,
                      );
                    },
                    childCount: controller.tabIndex == 0
                        ? controller.myTweets.length
                        : controller.tabIndex == 1
                            ? controller.myTweetsReply.length
                            : controller.myTweetsArticle.length,
                  ),
                ),
              ],
            ),
            _profileImage(),
            SafeArea(
              child: Container(
                height: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // fade in the text when the profile image is scrolled out of view
                    AnimatedOpacity(
                        opacity: controller.scrollController.hasClients &&
                                controller.scrollOffset > 100
                            ? 1.0
                            : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleLarge,
                        )),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  List<TextSpan> parseContentWithTextSpans(String? text, TextStyle? style) {
    final spans = <TextSpan>[];
    final linkRegExp = RegExp(r'(\s+)|(\bhttps?:\/\/[^\s]+)');
    text!.splitMapJoin(
      linkRegExp,
      onMatch: (Match match) {
        final linkText = match.group(0);
        spans.add(TextSpan(
          text: linkText,
          style: TextStyle(
            color: Color.fromARGB(255, 86, 203, 62),
            // decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              debugPrint('Link tapped: $linkText');
              if (linkText!.isNotEmpty) {
                launchUrl(
                  Uri.parse(linkText),
                );
              }
            },
        ));
        return '';
      },
      onNonMatch: (String text) {
        spans.add(TextSpan(text: text, style: style));
        return '';
      },
    );
    return spans;
  }

  Widget _profileImage() {
    final double defaultMargin = ScreenUtil().setHeight(160);
    final double defaultStart = ScreenUtil().setHeight(160);
    final double defaultEnd = defaultStart / 2;

    double top = defaultMargin;
    double scale = 1.0;

    if (controller.scrollController.hasClients) {
      double offset = controller.scrollOffset.value;
      top -= offset;

      if (offset < defaultMargin - defaultStart) {
        scale = 1.0;
      } else if (offset < defaultStart - defaultEnd) {
        scale = (defaultMargin - defaultEnd - offset) / defaultEnd;
      } else {
        scale = 0.0;
      }
    }

    return Positioned(
      top: top,
      left: 0,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(scale),
        child: Container(
            margin: const EdgeInsets.only(top: 0, left: 20),
            height: ScreenUtil().setHeight(100),
            width: ScreenUtil().setWidth(100),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Obx(() {
              var result = controller.nostrService.userMetadataObj
                  .getUserInfo(controller.pubkey.toString());
              var pic = result['picture'] ?? '';
              return GestureDetector(
                onTap: () {
                  if (StringUtils.isBlank(pic)) {
                    return;
                  }
                  Get.to(GalleryPhotoViewWrapper(galleryItems: [pic]));
                },
                behavior: HitTestBehavior.translucent,
                child: CachedNetworkImage(
                  imageUrl: pic,
                  placeholder: (context, url) => AvatarHolder(
                    width: 144,
                    height: 144,
                  ),
                  errorWidget: (context, url, error) => AvatarHolder(
                    width: 144,
                    height: 144,
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    width: ScreenUtil().setWidth(144),
                    height: ScreenUtil().setWidth(144),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
            })),
      ),
    );
  }
}
