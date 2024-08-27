// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/model/GifFavoritesModel.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:freerse/themes/Themes.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';

import 'config/message.dart';
import 'config/routers.dart';
import 'data/db.dart';
import 'services/SpUtils.dart';

SnackbarController? donateLoadingController;

var currentInitPage = Routes.INITIAL;

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SpUtil.getInstance().then((value) {
    GifFavoritesModel().loadFavorites();
  });


  var futureDB = DB.getCurrentDatabase();
  var futureInitService = initServices();
  await Future.wait([futureDB, futureInitService]);

  FlutterNativeSplash.remove();

  runApp(ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        /* if (Platform.isAndroid) {
        StatusBarControl.setColor(ColorConstants.hexToColor("#ededed"), animated:true);
        StatusBarControl.setTranslucent(false);
        StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
      }*/
        return RestartWidget(
          childBuilder: () {
            String? localSave = SpUtil.getString("APP_LOCALE");
            Locale localeNow = ui.window.locale;
            if (localSave.isNotEmpty) {
              List<String> localList = localSave.split("_");
              if (localList.length == 2) {
                localeNow = Locale(localList.first, localList.last);
              }
            }

            return GetMaterialApp(
              theme: SpUtil.getInt("APP_THEME") == 2
                  ? Themes.darkTheme
                  : Themes.lightTheme,
              darkTheme: Themes.darkTheme,
              getPages: Routes.routes,
              debugShowCheckedModeBanner: false,
              initialRoute: currentInitPage,
              translations: Messages(),
              locale: localeNow,
              fallbackLocale: Locale('en', 'US'),
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: <Locale>[
                Locale('en', 'US'),
                Locale('zh', 'CN'),
                Locale('zh', 'TW'),
                Locale('ja', 'JP'),
              ],
            );
          },
        );
      }));
}

Future<void> initServices({bool delay = true}) async {

  try {
    if (delay) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    print("nostrServcie begin to init");
    var nostrServcie = await NostrService().init();
    var ns = Get.put(nostrServcie);
    // print("myKey check before init!");
    // print(nostrServcie.myKeys);
    if (nostrServcie.myKeys != null &&
        StringUtils.isNotBlank(nostrServcie.myKeys.privateKey)) {
      currentInitPage = '/home';
    }
    print(ns);
  } catch (e) {}
}

class RestartWidget extends StatefulWidget {
  RestartWidget({required this.childBuilder});

  final Widget Function() childBuilder;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.childBuilder(),
    );
  }
}
