import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/nostr/nostr_service.dart';
import '../../../views/feed/feed_view.dart';
import 'feed_global_controller.dart';

class FeedGlobalPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _FeedGlobalPage();
  }

}

class _FeedGlobalPage extends State<FeedGlobalPage> {

  final _controller = Get.put(FeedGlobalController());
  late final NostrService nostrService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget main = SingleChildScrollView(
        child: Container(
          height: Get.mediaQuery.size.height,
          width: double.infinity,
          // child: Text("No data!"),
        ),
      );
      if (nostrService.globalFeedObj.feed.length > 0) {
        main = ListView.builder(
          controller: _controller.scrollControllerUserFeedReplyOriginal,
          itemBuilder: (context, index) {
            return FeedComponent(data: nostrService.globalFeedObj.feed[index],showComments: false,);
          },
          itemCount: nostrService.globalFeedObj.feed.length,
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await _controller.refreshData();
        },
        child: main,
      );

      // return RefreshIndicator(child: CustomScrollView(
      //   controller: _controller.scrollControllerUserFeedReplyOriginal,
      //   physics: const BouncingScrollPhysics(),
      //   slivers: [
      //     SliverList(
      //       delegate: SliverChildBuilderDelegate(
      //             (BuildContext context, int index) {
      //           return FeedComponent(data: nostrService.globalFeedObj.feed[index],showComments: false,);
      //         },
      //         childCount:nostrService.globalFeedObj.feed.length,
      //       ),
      //     ),
      //   ],
      // ), onRefresh: () async {
      //   await _controller.refreshData();
      // });
    });
  }

}
