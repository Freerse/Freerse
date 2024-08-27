import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/content/content_component.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/ColorConstants.dart';
import '../../config/utils.dart';
import '../../model/Tweet.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/feed/avatar_holder.dart';
import '../../views/feed/tweetImage.dart';
import 'write_show_controller.dart';

class WriteShowPage extends StatelessWidget {
  final controller = Get.put(WriteShowController());
  late final NostrService nostrService = Get.find();

  late final Tweet data;
  WriteShowPage({required this.data});
  final LinkifyOptions linkifyOptions = LinkifyOptions(humanize: false);


  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,child:
    Scaffold(
      backgroundColor: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
        // backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          title: Text("YU_LAN".tr,style: Theme.of(context).textTheme.titleLarge,),
          centerTitle: true,
        ),
      body: SingleChildScrollView(
        child: Container(
            child: Obx((){
              var result = nostrService.userMetadataObj.getUserInfo(data.pubkey);
              var pic = result['picture']??'';
              var name = ViewUtils.userShowName(result, userId: data.pubkey);
              return Column(
                children: [
                  data.isArticle?Container(
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(20),left:ScreenUtil().setWidth(15),right: ScreenUtil().setWidth(15)),
                    child: Text(data.title,style: TextStyle(fontSize: ScreenUtil().setSp(22),fontWeight: FontWeight.bold)),
                  ):Container(),
                  Container(
                    child: Container(
                        width: ScreenUtil().screenWidth,
                        padding: EdgeInsets.only(left:ScreenUtil().setWidth(15),right: ScreenUtil().setWidth(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Container(height:ScreenUtil().setHeight(15)),
                                GestureDetector(
                                    child: CachedNetworkImage(
                                      imageUrl: pic,
                                      placeholder: (context, url) => AvatarHolder(),
                                      errorWidget: (context, url, error) => AvatarHolder(),
                                      imageBuilder: (context, imageProvider) => Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider, fit: BoxFit.cover),
                                        ),
                                      ),
                                    )
                                ),
                              ],
                            ),
                            Container(
                              width: 10,
                            ),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height:ScreenUtil().setHeight(15)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              name,
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                            Container(
                                              width: ScreenUtil().setWidth(5),
                                            ),

                                          ],
                                        ),

                                      ],
                                    ),
                                    Container(
                                      height: ScreenUtil().setHeight(4),
                                    ),
                                  ],
                                )
                            )
                          ],
                        )
                    ),
                  ),
                  data.isArticle?Container(
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(20),left:ScreenUtil().setWidth(15),right: ScreenUtil().setWidth(15)),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Image.asset(
                        'assets/images/default_header.png',
                        fit: BoxFit.cover,
                        width: ScreenUtil().setWidth(400),
                        height: ScreenUtil().setHeight(200),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/default_header.png',
                        fit: BoxFit.cover,
                        width: ScreenUtil().setWidth(400),
                        height: ScreenUtil().setHeight(200),
                      ),
                      imageUrl: data.coverImage,
                      imageBuilder: (context, imageProvider) => Container(
                        width: ScreenUtil().setWidth(400),
                        height: ScreenUtil().setHeight(200),
                        decoration: BoxDecoration(
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ):Container(),
                  data.isArticle?Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top: ScreenUtil().setHeight(20),bottom: ScreenUtil().setHeight(20)),
                    child: MarkdownBody(
                      data: data.content,
                      shrinkWrap: true,
                    ),
                  ):Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top: ScreenUtil().setHeight(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContentComponent(content: data.content, tags: []),
                        // Linkify(
                        //   options:linkifyOptions,
                        //   linkifiers: [UrlLinkifier()],
                        //   onOpen: (link) async {
                        //     launchUrl(Uri.parse(link.url));
                        //     return;
                        //     if (await canLaunchUrl(Uri.parse(link.url))) {
                        //       await launchUrl(Uri.parse(link.url));
                        //     } else {
                        //       throw 'Could not launch $link';
                        //     }
                        //   },
                        //   text: data.content,
                        //   style: Theme.of(context).textTheme.bodyMedium,
                        //   linkStyle: TextStyle(color: Colors.red),
                        // ),
                        Container(
                          height: ScreenUtil().setHeight(3),
                        ),
                        Container(
                          child: TweetImage(
                            picList: data.imageLinks,
                          ),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(15),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1,),
                ],
              );
            })
        ),
      ),
    ));
  }
}
