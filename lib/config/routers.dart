import 'package:freerse/home/home_view.dart';
import 'package:freerse/page/article_list/article_list_view.dart';
import 'package:freerse/page/chat_setting/chat_setting_view.dart';
import 'package:freerse/page/login/SplashView/SplashView.dart';
import 'package:freerse/page/message/message_view.dart';
import 'package:freerse/page/message_detail/message_detail_view.dart';
import 'package:freerse/page/new_friend/new_friend_view.dart';
import 'package:freerse/page/user/user_view.dart';
import 'package:freerse/page/write_page/write_page_view.dart';
import 'package:get/get.dart';

import '../home/home_binding.dart';
import '../page/feed_detail/feed_detail_view.dart';

class Routes {
  static const INITIAL = '/load';

  static final routes = [
    GetPage(name: '/load', page: () => SplashView(),),
    GetPage(name: '/home', page: () => HomePage(),),
    GetPage(name: '/user', page: () => UserPage()),
    GetPage(name: '/message', page: () => MessageDetailPage()),
    GetPage(name: '/newfriend', page: () => NewFriendPage()),
    GetPage(name: '/write', page: () => WritePagePage()),
    GetPage(name: '/feed', page: () => FeedDetailPage()),
    GetPage(name: '/articlelist', page: () => ArticleListPage()),
    GetPage(name: '/chatSetting', page: () => ChatSettingPage()),
  ];
}
