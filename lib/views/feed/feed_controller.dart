import 'package:get/get.dart';

class FeedController extends GetxController {
  var commentsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }



/*  String getCommentsCount(Tweet tweet){
    int count = 0;
    sum(tweet.replies);
    return count.toString();
  }

  void sum(List<dynamic> list){
    if(list.length > 0){
      commentsCount.value = commentsCount.value+list.length;
      list.forEach((element) {
        sum(element.replies);
      });
    }else{
      return;
    }
  }*/
}
