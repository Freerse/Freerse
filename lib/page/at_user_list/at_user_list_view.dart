import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/views/UserRealComponent.dart';
import 'package:get/get.dart';

import '../../services/nostr/nostr_service.dart';
import '../../views/common/ViewUtils.dart';
import 'at_user_list_controller.dart';

class AtUserListPage extends StatelessWidget {
  late String title;
  AtUserListPage({required this.title});

  final controller = Get.put(AtUserListController(),tag: Helpers().getRandomString(12));
  late final NostrService nostrService = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,child:
    Scaffold(
        backgroundColor: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
        appBar: AppBar(
          backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          title: Text(title,style: Theme.of(context).textTheme.titleLarge,),
          centerTitle: true,
        ),
        body:
        Obx((){
          return Column(children: [
              Container(
                color: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
                padding: EdgeInsets.only(right: ScreenUtil().setWidth(8), left: ScreenUtil().setWidth(8),bottom: ScreenUtil().setHeight(10)),
                child: Container(
                height: ScreenUtil().setHeight(40),
                decoration: BoxDecoration(
                  // color:  Colors.red,
                  color: Get.isDarkMode ? ColorConstants.searchBg : Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
                child:
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    //prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        // Get.to(()=>SearchListPage(),arguments: {"keyword":controller.searchController.text});
                      },
                    ),
                    hintText: "SOU_SUO".tr,
                    hintStyle: TextStyle(color: ColorConstants.hexToColor('#B3B3B3')),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (String searchText) {
                    controller.filterUsers();
                  },
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            Expanded(child:
              ListView.builder(
                itemCount: controller.showUserList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: (){
                          Get.back(result: controller.showUserList[index]);
                          // Get.toNamed("/user", arguments: controller.showUserList[index]);
                        },
                        child: UserRealComponent(userItem: controller.showUserList[index]),
                        behavior: HitTestBehavior.translucent,
                      ),
                      ViewUtils.oneLine(marginLeft: Cons.IMAGE_LINE_ML)
                    ],
                  );
                },
              )
            )
          ],);
        })
    ));


  }
}
