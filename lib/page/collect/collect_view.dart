import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../model/socket_control.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/feed/feed_view.dart';
import 'collect_controller.dart';

class CollectPage extends StatelessWidget {
  final CollectController _controller = Get.put(CollectController());
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
          title: Text("WO_D_S_CANG".tr,style: Theme.of(context).textTheme.titleLarge,),
          centerTitle: true,
        ),
        body: Obx((){
          return ListView.builder(
            itemCount: nostrService.userFeedObj.feedCollect.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  FeedComponent(data:  nostrService.userFeedObj.feedCollect[index],showComments: false,)
                ],
              );
            },
          );
        })
    ));
  }
}
