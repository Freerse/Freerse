// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/views/feed/feed_header/feed_header_view.dart';
import 'package:freerse/views/feed/feed_view.dart';
import 'package:get/get.dart';

import '../../services/nostr/nostr_service.dart';
import 'feed_detail_controller.dart';

class FeedDetailPage extends StatelessWidget {
  final NostrService nostrService = Get.find();
  late final controller =
      Get.put(FeedDetailController(), tag: nostrService.setTag());

  @override
  Widget build(BuildContext context) {
    print(controller.data.toJson());
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor:
            Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
        floatingActionButton: FloatingActionButton(
          elevation: 3,
          onPressed: () {
            Get.toNamed("/write", arguments: {"isArticle": false});
          },
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            "TUI_W_X_QING".tr,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        // backgroundColor: Color(0xFFfefefe),
        // backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
        body: Obx(
          () {
            return CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                    child: Column(
                  children: [
                    FeedHeaderComponent(
                      data: controller.data,
                      commentsCount: controller.replays.length,
                    )
                  ],
                )),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return FeedComponent(
                        data: controller.replays[index],
                        showComments: true,
                      );
                    },
                    childCount: controller.replays.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
