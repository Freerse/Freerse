import 'dart:convert';

import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/data/event_db.dart';
import 'package:freerse/page/login/SplashView/SplashView.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';
import 'dart:io';

import 'package:status_bar_control/status_bar_control.dart';

import '../../../config/Cons.dart';
import '../../../config/routers.dart';
import '../../../home/home_controller.dart';
import '../../../main.dart';
import '../../../services/SpUtils.dart';
import '../../../services/nostr/metadata/metadata_injector.dart';
import '../../../services/nostr/nips/zap_service.dart';
import '../../../services/nostr/relays/relays_injector.dart';
import '../mine_setting_controller.dart';


class SetThemeController extends GetxController {
  var copy1 = false.obs;
  var copy2 = false.obs;
  var storage = const FlutterSecureStorage();
  late final NostrService nostrService = Get.find();

  @override
  void onInit() {
    ViewUtils.changeStateColor();
  }

  Future<void>  logout(BuildContext context) async {
    try {
      await storage.delete(key: "nostrKeys");
      await storage.delete(key: ZapService.STORAGE_KEY);
    } catch (e) {
    }
    try {
      LocalStorageInterface prefs = await LocalStorage.getInstance();
      var jsonCache = JsonCacheCrossLocalStorage(prefs);
      await jsonCache.clear();
    } catch (e) {
    }
    // 删除 db 内容
    EventDB.deleteAll(Cons.DEFAULT_DB_KEY_INDEX);
    // 这尼玛还有一些单例的。。。
    // RelaysInjector().clear();
    // MetadataInjector().clear();
    // await Get.deleteAll(force: true);
    // Get.reset();
    // var context = Get.context;
    // if (context != null) {
    // currentInitPage = Routes.INITIAL;
    // await initServices(delay: false);
    // RestartWidget.restartApp(context);
    // } else {
    //   Get.offAll(SplashView());
    // }
    //exit(0);
    await restartApp(context);
  }

  Future<void>  restartApp(BuildContext context) async {
    var theme = await SpUtil.getInt("APP_THEME");
    print("读取主题$theme");
    RelaysInjector().clear();
    MetadataInjector().clear();
    await Get.deleteAll(force: true);
    Get.reset();
    currentInitPage = Routes.INITIAL;
    await initServices(delay: false);
    RestartWidget.restartApp(context);
  }

  Future<void>  setTheme(style) async {
    SpUtil.putInt("APP_THEME", style);
    // Get.changeTheme(ThemeData.dark());
    // MineSettingController setController = Get.find();
    // setController.refresh();
    // HomeController homeController = Get.find();
    // homeController.refresh();
    // Get.forceAppUpdate();
    print("设置主题" + style.toString());

    await restartApp(Get.context!!);
  }
}
