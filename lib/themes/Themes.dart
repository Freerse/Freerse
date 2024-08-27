import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../config/ColorConstants.dart';

class Themes {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: const Color(0xFF57cb3d),
    // primaryColorDark: Colors.orange,
    // primaryColorLight: Colors.red,
    brightness: Brightness.light,
    platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary:const Color(0xFF57cb3d),
        background: Colors.white
    ),
    scaffoldBackgroundColor: ColorConstants.statuabarColor,
      snackBarTheme: const SnackBarThemeData(),
    appBarTheme: const AppBarTheme(
      backgroundColor:  Color(0xFFededed),
      systemOverlayStyle: SystemUiOverlayStyle(
        // statusBarColor: Colors.red, // <-- SEE HERE
          statusBarColor: Color(0xFFededed), // <-- SEE HERE
          statusBarIconBrightness: Brightness.dark, //<-- For Android SEE HERE (dark icons)
          statusBarBrightness: Brightness.light, //<-- For iOS SEE HERE (dark icons)

        // statusBarColor : Colors.purple,
        // systemNavigationBarColor : Colors.purple,

      ),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600
      ),
      elevation: 0,
      iconTheme: IconThemeData(
          color: Colors.black
      ),
      toolbarHeight: 56,
    ),
    inputDecorationTheme: InputDecorationTheme(
        prefixStyle: const TextStyle(color: Colors.green),
        border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10)
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
      )
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.red
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF386ed8),
      selectionColor: Color(0xFFccdbee)
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
          color: Colors.black,
          // fontWeight: FontWeight.w500,
          fontSize: ScreenUtil().setSp(16.67)
      ),
      titleMedium: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: ScreenUtil().setSp(16.67)
      ),
      bodyLarge: TextStyle(
          color: Colors.black,
          fontSize: ScreenUtil().setSp(16.67)
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontSize: ScreenUtil().setSp(16.67)
      ),
      labelLarge:TextStyle(
          color: Color(0xFF919191),
          fontSize: ScreenUtil().setSp(16.67)
      ) ,
      labelMedium: TextStyle(
          color: Color(0xFF919191),
          fontSize: ScreenUtil().setSp(15)
      ),
      labelSmall: TextStyle(
          color: Color(0xFF919191),
          fontSize: ScreenUtil().setSp(13.3)
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Color(0xFF181818),
      unselectedLabelColor: Color(0xFF5f5f5f),
    ),
    scrollbarTheme: ScrollbarThemeData().copyWith(
        thickness: MaterialStateProperty.all(2),
        thumbColor: MaterialStateProperty.all(Colors.black)
    )
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: const Color(0xFF57cb3d),
    brightness: Brightness.dark,
    platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary:const Color(0xFF57cb3d),
        background: Color(0xFF191919)
    ),
    scaffoldBackgroundColor: ColorConstants.setPageBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111111),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        // statusBarColor: Colors.red, // <-- SEE HERE
        statusBarColor: Color(0xFF111111), // <-- SEE HERE
        systemNavigationBarColor: Colors.white, // <-- SEE HERE
        statusBarIconBrightness: Brightness.light, //<-- For Android SEE HERE (dark icons)
        statusBarBrightness: Brightness.dark, //<-- For iOS SEE HERE (dark icons)
      ),
      iconTheme: IconThemeData(
        color: Colors.white
      ),
      toolbarHeight: 56,
    ),
    bottomAppBarColor: ColorConstants.gray800,
    textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF386ed8),
        selectionColor: Color(0xFFccdbee)
    ),
    inputDecorationTheme: InputDecorationTheme(
        prefixStyle: const TextStyle(color: Colors.green),
        border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10)
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
      )
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.white,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
          color: Colors.white,
          // fontWeight: FontWeight.w500,
          fontSize: ScreenUtil().setSp(16.67)
      ),
      titleMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: ScreenUtil().setSp(16.67)
      ),
      bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: ScreenUtil().setSp(16.67)
      ),
      bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: ScreenUtil().setSp(16.67)
      ),
      labelLarge:TextStyle(
          color: Colors.white,
          fontSize: ScreenUtil().setSp(16.67)
      ) ,
      labelMedium: TextStyle(
          color: Colors.white,
          fontSize: ScreenUtil().setSp(15)
      ),
      labelSmall: TextStyle(
          color: Colors.white,
          fontSize: ScreenUtil().setSp(13.3)
      ),
    ),
      tabBarTheme: TabBarTheme(
        labelColor: Color(0xFFd1d1d1),
        unselectedLabelColor: Color(0xFF808080),
      ),
      scrollbarTheme: ScrollbarThemeData().copyWith(
        thickness: MaterialStateProperty.all(2),
          thumbColor: MaterialStateProperty.all(Colors.black)
      )
  );
}
