import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/feed/feed_like/feed_like_view.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../config/Cons.dart';
import '../../model/socket_control.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/common/ViewUtils.dart';
import '../../views/common/appbar.dart';
import '../../views/feed/feed_view.dart';
import '../../views/light_view.dart';
import 'notify_controller.dart';
import 'notify_counter_view.dart';

class NotifyPage extends StatelessWidget {
  final controller = Get.put(NotifyController());
  late final NostrService nostrService = Get.find();

  SelectView(IconData icon, String text, String id) {
    return PopupMenuItem<String>(
        value: id,
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(width: ScreenUtil().setWidth(10)),
            Icon(icon, color: Colors.white),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(text,style: TextStyle(color: Colors.white),),
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
          appBar: AppBar(
            title: Text('TONG_ZHI'.tr,style:  Theme.of(context).textTheme.titleLarge,),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT) + 2),
              child: TabBar(
                controller: controller.tabController,
                tabs: controller.myTabs,
                unselectedLabelColor: Get.isDarkMode ? ColorConstants.tabUnSelect : Colors.black38,
                indicatorColor: Theme.of(context).colorScheme.secondary,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2.0,
              ),
            ),
          ),
          body: Obx(() {
            var feedList = controller.feedCounterMap.value.values.toList();
            var likeList = controller.likeCounterMap.value.values.toList();
            var lightList = controller.lightCounterMap.value.values.toList();

            // 使用黑名单过滤 feed
            var blackUserIdList = nostrService.searchFeedObj.blackUserIdList;
            feedList.removeWhere((element) {
              if (element.isEvent && element.tweet != null) {
                var pubkey = element.tweet!.pubkey;
                return blackUserIdList.contains(pubkey);
              }

              return false;
            });

            feedList.sort((counter0, counter1) {
              return counter1.lastCreatedAt() - counter0.lastCreatedAt();
            });
            likeList.sort((counter0, counter1) {
              return counter1.lastCreatedAt() - counter0.lastCreatedAt();
            });
            lightList.sort((counter0, counter1) {
              return counter1.lastCreatedAt() - counter0.lastCreatedAt();
            });

            // print("likeList.length ${likeList.length} feedId ${likeList[0].feedId} likeList[0].items.length ${likeList[0].items.length}");

            return TabBarView(
              controller: controller.tabController,
              children: [
                ListView.builder(itemBuilder: (BuildContext context, int index) {
                  var counter = feedList[index];
                  if (counter.isEvent) {
                    return FeedComponent(
                      data: counter.tweet,
                      showComments: false,
                    );
                  } else {
                    return NotifyCounterView (
                      notifyCounter:counter,
                      action: "RETWEETED".tr,
                      iconImage: "assets/images/feed_repost_p.png",
                    );
                  }
                }, itemCount: feedList.length,),
                ListView.builder(itemBuilder: (BuildContext context, int index) {
                  var counter = lightList[index];
                  return NotifyCounterView (
                    notifyCounter:counter,
                    action: "ZAPED".tr,
                    iconImage: "assets/images/feed_zap_p.png",
                  );
                }, itemCount: lightList.length,),
                ListView.builder(itemBuilder: (BuildContext context, int index) {
                  var counter = likeList[index];
                  return NotifyCounterView (
                    notifyCounter:counter,
                    action: "REACTED".tr,
                    iconImage: "assets/images/feed_like_p.png",
                  );
                }, itemCount: likeList.length,),
              ],
            );
          }),
          // body: TabBarView(
          //   controller: controller.tabController,
          //   children: [
          //     CustomScrollView(
          //       controller: controller.scrollController1,
          //       slivers: [
          //         SliverList(
          //           delegate: SliverChildBuilderDelegate(
          //                 (BuildContext context, int index) {
          //               return FeedComponent(data: controller.feedList[index],showComments: false,);
          //             },
          //             childCount: controller.feedList.length,
          //           ),
          //         ),
          //       ],
          //     ),
          //     CustomScrollView(
          //       controller: controller.scrollController2,
          //       slivers: [
          //         SliverList(
          //           delegate: SliverChildBuilderDelegate(
          //                 (BuildContext context, int index) {
          //               return Column(
          //                 children: [
          //                   LightComponent(lightItem: controller.lightList[index]),
          //                   ViewUtils.oneLine(marginLeft: 85),
          //                 ],
          //               );
          //             },
          //             childCount: controller.lightList.length,
          //           ),
          //         ),
          //       ],
          //     ),
          //     CustomScrollView(
          //       controller: controller.scrollController3,
          //       slivers: [
          //         SliverList(
          //           delegate: SliverChildBuilderDelegate(
          //                 (BuildContext context, int index) {
          //               return FeedLikeComponent(data: controller.likeList[index]);
          //             },
          //             childCount: controller.likeList.length,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        )
    );
  }
}
