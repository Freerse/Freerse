import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/feed/feed_header/feed_header_view.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/ColorConstants.dart';
import '../../config/utils.dart';
import '../../helpers/helpers.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/feed/avatar_holder.dart';
import '../../views/feed/feed_view.dart';
import '../../views/feed/tweetImage.dart';
import 'feed_detail_reply_controller.dart';


class FeedDetailReplyPage extends StatelessWidget {
  final NostrService nostrService = Get.find();
  late final controller = Get.put(FeedDetailReplyController(),tag: nostrService.setTagReply());

  Widget _buildHead(){
    List<Widget> listWidget = [];
    for(var i=0;i<controller.header.length;i++){
      if(i == 0){
        listWidget.add(FeedComponent(data: controller.header[i], showComments: false,showDivder: false,));
      }else{
        listWidget.add(FeedComponent(data: controller.header[i], showComments: false,showDivder: false,showDivderTop: false,));
      }
    }
    listWidget.add(FeedHeaderComponent(data: controller.data.value,showDivder: false,commentsCount: controller.replays.length,));
    listWidget.add(Divider(height: 1));
    return Column(
      children:listWidget
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // backgroundColor: ColorConstants.hexToColor("#fefefe"),
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
          floatingActionButton: FloatingActionButton(
            elevation: 3,
            onPressed: () {
              Get.toNamed("/write", arguments: {"isArticle":false});
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            leading: IconButton(
              iconSize: 30,
              icon: Icon(Icons.chevron_left), onPressed: () {
              Get.back();
            },
            ),
            title: Text("TUI_W_LIAN".tr,style: Theme.of(context).textTheme.titleLarge,),
            centerTitle: true,
          ),
          body: Obx((){
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: _buildHead()
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return FeedComponent(data: controller.replays[index],showComments: true,events: controller.datas,);
                    },
                    childCount: controller.replays.length,
                  ),
                ),
                SliverToBoxAdapter(
                    child: Container(height: 300,),
                ),
              ],
            );
          }),
    ));
  }


}
