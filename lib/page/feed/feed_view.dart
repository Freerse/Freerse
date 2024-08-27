// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pk_skeleton_null_safe/pk_skeleton_null_safe.dart';

import '../../config/ColorConstants.dart';
import '../../config/Cons.dart';
import '../../model/socket_control.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/feed/feed_view.dart';
import 'feed_controller.dart';

class FeedPage extends StatelessWidget {
  final FeedController _controller = Get.put(FeedController());
  late final NostrService _nostrService = Get.find();

  SelectView(IconData icon, String text, String id) {
    return PopupMenuItem<String>(
        value: id,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(width: ScreenUtil().setWidth(10)),
            Icon(icon, color: Colors.white),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ));
  }

  int _countRedyRelays(Map<String, SocketControl> relays) {
    int count = 0;
    for (var r in relays.values) {
      if (r.socketIsRdy) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
            backgroundColor:
                Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
            appBar: AppBar(
              title: Text(
                'Freerse',
                style: Theme.of(context).textTheme.titleLarge!.merge(TextStyle(
                      fontSize: 20.sp,
                    )),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                    ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT) + 2),
                child: TabBar(
                  controller: _controller.controller,
                  tabs: _controller.myTabs,
                  unselectedLabelColor: Get.isDarkMode
                      ? ColorConstants.tabUnSelect
                      : Colors.black38,
                  indicatorColor: Theme.of(context).colorScheme.secondary,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 2.0,
                ),
              ),
            ),
            // backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              elevation: 3,
              onPressed: () {
                Get.toNamed("/write", arguments: {"isArticle": false});
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.add),
            ),
            body: TabBarView(
              controller: _controller.controller,
              children: [
                Obx(() {
                  var feedList = _controller.userFeedOriginalOnly;
                  if (_controller.isLoading.isTrue) {
                    return PKCardListSkeleton(
                      isCircularImage: true,
                      isBottomLinesActive: true,
                      length: 10,
                    );
                  }
                  return RefreshIndicator(
                    color: const Color(0xFF57cb3d),
                    onRefresh: () {
                      _controller.initUserFeed();
                      return Future.delayed(const Duration(milliseconds: 2000));
                    },
                    child: ListView.builder(
                      controller: _controller.scrollControllerUserFeedOriginal,
                      itemBuilder: (context, index) {
                        var feed = feedList[index];
                        if (feed == null) {
                          return null;
                        }

                        return FeedComponent(
                          data: feed,
                          showComments: false,
                        );
                      },
                      itemCount: feedList.length,
                    ),
                    // child: CustomScrollView(
                    //   controller: _controller.scrollControllerUserFeedOriginal,
                    //   physics: const BouncingScrollPhysics(),
                    //   slivers: [
                    //     SliverList(
                    //       delegate: SliverChildBuilderDelegate(
                    //             (BuildContext context, int index) {
                    //           return FeedComponent(data: _controller.userFeedOriginalOnly[index],showComments: false,);
                    //         },
                    //         childCount: _controller.userFeedOriginalOnly.length,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  );
                }),
                Obx(() {
                  if (_controller.isLoading.isTrue) {
                    return PKCardListSkeleton(
                      isCircularImage: true,
                      isBottomLinesActive: true,
                      length: 10,
                    );
                  }
                  return RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      onRefresh: () {
                        _controller.initUserFeed();
                        return Future.delayed(
                            const Duration(milliseconds: 150));
                      },
                      child: CustomScrollView(
                        controller:
                            _controller.scrollControllerUserFeedReplyOriginal,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return FeedComponent(
                                  data: _controller
                                      .userFeedReplyOriginalOnly[index],
                                  showComments: false,
                                );
                              },
                              childCount:
                                  _controller.userFeedReplyOriginalOnly.length,
                            ),
                          ),
                        ],
                      ));
                }),
                Obx(() {
                  var feedList = _nostrService.hotGlobalFeed;
                  if (_controller.isLoading.isTrue) {
                    return PKCardListSkeleton(
                      isCircularImage: true,
                      isBottomLinesActive: true,
                      length: 10,
                    );
                  }
                  return RefreshIndicator(
                    color: Theme.of(context).primaryColor,
                    onRefresh: () {
                      _controller.loadHotFeed();
                      return Future.delayed(const Duration(milliseconds: 2000));
                    },
                    child: ListView.builder(
                      controller:
                          _controller.scrollControllerHotFeedReplyOriginal,
                      itemBuilder: (context, index) {
                        var feed = feedList[index];
                        if (feed == null) {
                          return null;
                        }

                        return FeedComponent(
                          data: feed,
                          showComments: false,
                        );
                      },
                      itemCount: feedList.length,
                    ),
                  );
                }),
              ],
            )));
  }
}
