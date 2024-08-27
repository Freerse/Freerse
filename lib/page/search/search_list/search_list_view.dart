import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/feed/avatar_holder.dart';
import 'package:freerse/views/user_view.dart';
import 'package:get/get.dart';

import '../../../config/ColorConstants.dart';
import '../../../views/common/appbar.dart';
import '../../../views/feed/feed_view.dart';
import 'search_list_controller.dart';

class SearchListPage extends StatelessWidget {
  final controller = Get.put(SearchListController(), tag: Helpers().getRandomString(10));

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,child:
    Scaffold(
        backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
        // backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          elevation: 3,
          onPressed: () {
            Get.toNamed("/write", arguments: {"isArticle":false});
          },
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
              Get.back();
            },
          ),
          title: Text(controller.keyword,style:  Theme.of(context).textTheme.titleLarge,),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT) + 2),
            child: TabBar(
              controller: controller.controller,
              tabs: controller.myTabs,
              unselectedLabelColor: Get.isDarkMode ? ColorConstants.tabUnSelect : Colors.black38,
              indicatorColor: Theme.of(context).colorScheme.secondary,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2.0,
            ),
          ),
        ),
      //   appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(ScreenUtil().setHeight(105)),
      //   child: AppBar(
      //     leading: IconButton(
      //       color: Colors.black,
      //       iconSize: 30,
      //       icon: Icon(Icons.chevron_left), onPressed: () {
      //       Get.back();
      //     },
      //     ),
      //     title: Text(controller.keyword,style: Theme.of(context).textTheme.titleLarge,),
      //     centerTitle: true,
      //     bottom: TabBar(
      //       controller: controller.controller,
      //       tabs: controller.myTabs,
      //       unselectedLabelColor: Get.isDarkMode ? ColorConstants.tabUnSelect : Colors.black38,
      //       indicatorColor: Theme.of(context).colorScheme.secondary,
      //       indicatorSize: TabBarIndicatorSize.label,
      //       indicatorWeight: 2.0,
      //     ),
      //   ),
      // ),
      body: TabBarView(controller: controller.controller,children: [
        Obx(() => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return FeedComponent(data: controller.feed[index],showComments: false,);
                },
                childCount:controller.feed.length,
              ),
            ),
          ],
        )),
        Obx(() => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // return UserComponent(userId: controller.userIdList[index]);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UserComponent(userId: controller.userIdList[index]),
                          ViewUtils.oneLine(marginLeft: Cons.IMAGE_LINE_ML)
                        ],
                      );
                },
                childCount:controller.userIdList.length,
              ),
            ),
          ],
        )),
      ],
      )
    ));
  }
}
