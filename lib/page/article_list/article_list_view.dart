import 'package:flutter/material.dart';
import 'package:freerse/views/feed/article_view.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import 'article_list_controller.dart';

class ArticleListPage extends StatelessWidget {
  final controller = Get.put(ArticleListController());
  late final NostrService nostrService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => SafeArea(top:false,bottom:false,child:
    Scaffold(
      backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
      appBar: AppBar(
        leading: IconButton(
          iconSize: 30,
          icon: Icon(Icons.chevron_left), onPressed: () {
          Get.back();
        },
        ),
        title: Text("WEN_ZDYX_XI".tr,style: Theme.of(context).textTheme.titleLarge,),
        centerTitle: true,
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refresh();
          },
          child: ListView.builder(
            itemCount: nostrService.userFeedObj.articleList.length,
            controller: controller.scrollController,
            itemBuilder: (context, index) {
              return ArticleComponent(showComments: false,data: nostrService.userFeedObj.articleList[index],);
              // return Column(
              //   children: [
              //     ArticleComponent(showComments: false,data: nostrService.userFeedObj.articleList[index],),
              //   ],
              // );
            },
          ),
        ),
      )
    )));
  }
}
