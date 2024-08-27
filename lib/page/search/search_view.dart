import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/page/search/search_list/search_list_view.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/user_view.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/common/appbar.dart';
import '../../views/feed/avatar_holder.dart';
import 'feed_global/feed_global_view.dart';
import 'search_controller.dart' as sc;

class SearchPage extends StatelessWidget {
  final controller = Get.put(sc.SearchController());
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

  List<String> tagList = ["Foodstr", "Art", "Music", "Coffeechain","Plebchain", "Nostr","Bitcoin","AI","Zap","Blockchain"];
  List<String> tagDesc = ["delicious food is not to be missed", "when art lives together, life will be colorful", "Music is the resonance of the soul", "Share every cup of coffee","Pleb's victory", "Nostr allows you to own your mind","Bitcoin allows you to own your wealth",
    "AI is changing the world at an astonishing rate","Zap the people and posts you want to zap","Blockchain"];

  @override
  Widget build(BuildContext context) {
    List<Widget> itemWidgetList = [];

    for (var i = 0; i < tagList.length; i++) {
      var str = tagList[i];
      var desc = tagDesc[i];
      var icon = 'assets/images/label'+(i+1).toString()+'.png';
      itemWidgetList.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Container(
            padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(icon,width: ScreenUtil().setWidth(28)),
                Container(width: 10,),
                Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#'+str,style: TextStyle(color: Get.isDarkMode ? Colors.white : Color(0xFF181818),fontSize: ScreenUtil().setSp(16)),),
                    Text(desc,style: TextStyle(color: Color(0xFFB4B4B4),fontSize: ScreenUtil().setSp(12)),)
                  ],
                ))
              ],
            )
        ),
        onTap: (){
          Get.to(()=>SearchListPage(),arguments: {"keyword":'#'+str});
        },
      ));
    }
    return SafeArea(
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
            title: Container(
              margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(5)),
              width: ScreenUtil().setWidth(260),
              height: ScreenUtil().setHeight(38),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? ColorConstants.searchBg : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  // contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  contentPadding: EdgeInsets.only(left: 10, top: 2),
                  //prefixIcon: Icon(Icons.search),
                  suffixIcon: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Icon(Icons.search),
                    onTap: () {
                      Get.to(()=>SearchListPage(),arguments: {"keyword":controller.searchController.text});
                    },
                  ),
                  hintText: "SOU_S_NONE".tr,
                  hintStyle: TextStyle(color:  const Color(0xFFB3B3B3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (String searchText) {
                  Get.to(()=>SearchListPage(),arguments: {"keyword":searchText});
                },
                style: TextStyle(fontSize: 16),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT) + 2),
              child: TabBar(
                controller: controller.controller,
                tabs: controller.myTabs,
                indicatorColor: Theme.of(context).colorScheme.secondary,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2.0,
              ),
            ),
          ),
          // appBar: PreferredSize(
          //   preferredSize: Size.fromHeight(ScreenUtil().setHeight(90)),
          //   child: AppBar(
          //     title: SizedBox(
          //       width: ScreenUtil().setWidth(260),
          //       height: ScreenUtil().setHeight(40),
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: TextField(
          //           controller: controller.searchController,
          //           decoration: InputDecoration(
          //             // contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          //             contentPadding: EdgeInsets.only(left: 10, top: 2),
          //             //prefixIcon: Icon(Icons.search),
          //             suffixIcon: GestureDetector(
          //               behavior: HitTestBehavior.translucent,
          //               child: Icon(Icons.search),
          //               onTap: () {
          //                 Get.to(()=>SearchListPage(),arguments: {"keyword":controller.searchController.text});
          //               },
          //             ),
          //             hintText: "SOU_S_NONE".tr,
          //             hintStyle: TextStyle(color: ColorConstants.hexToColor('#B3B3B3')),
          //             border: OutlineInputBorder(
          //               borderRadius: BorderRadius.circular(10),
          //               borderSide: BorderSide.none,
          //             ),
          //           ),
          //           onSubmitted: (String searchText) {
          //             Get.to(()=>SearchListPage(),arguments: {"keyword":searchText});
          //           },
          //           style: TextStyle(fontSize: 16),
          //         ),
          //       ),
          //     ),
          //     leading: Padding(
          //         padding: EdgeInsets.only(left: ScreenUtil().setWidth(4),top: ScreenUtil().setHeight(3)),
          //         child: Row(
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //           /*  Obx(() => Text(nostrService.relays.connectedCount.string,style: Theme.of(context).textTheme.bodyLarge)),
          //             Text('/15',style: Theme.of(context).textTheme.labelLarge),*/
          //           ],
          //         )
          //     ),
          //     centerTitle: true,
          //     // actions: <Widget>[
          //     //   PopupMenuButton<String>(
          //     //     color: ColorConstants.hexToColor("#4c4c4c"),
          //     //     icon: Image.asset("assets/images/icon_add.png",width: ScreenUtil().setWidth(36),),
          //     //     itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
          //     //       SelectView(Icons.message, "FA_Q_Q_LIAO".tr, 'A'),
          //     //       SelectView(Icons.scanner, "SAO_Y_SAO".tr, 'C'),
          //     //       SelectView(Icons.qr_code, "SHOU_F_KUAN".tr, 'B'),
          //     //     ],
          //     //     onSelected: (String action) {
          //     //       // 点击选项的时候
          //     //       switch (action) {
          //     //         case 'A': break;
          //     //         case 'B': break;
          //     //         case 'C': break;
          //     //       }
          //     //     },
          //     //   ),
          //     // ],
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
          body:
          Container(
            color: Get.isDarkMode ? ColorConstants.setPageBg : Colors.white,
            child:
          TabBarView(
            controller: controller.controller,
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child:  Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: itemWidgetList),
                ),
              ),
              // ListView.builder(
              //   itemCount: controller.userIds.length,
              //   itemBuilder: (context, index) {
              //     return Column(
              //       children: [
              //         UserComponent(userId: controller.userIds[index]),
              //         ViewUtils.oneLine(marginLeft: Cons.IMAGE_LINE_ML)
              //       ],
              //     );
              //   },
              // ),
              FeedGlobalPage(),
            ],
          )
          )
        )
    );
  }
}
