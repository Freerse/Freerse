// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/model/GifFavoritesModel.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class MessageGifView extends StatefulWidget {
  final controller;
  Function? onPressed;
  MessageGifView({super.key, required this.controller, this.onPressed});
  @override
  MessageGifViewState createState() => MessageGifViewState();
}

class MessageGifViewState extends State<MessageGifView> {
  ValueNotifier<int> favoritesSize = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    favoritesSize.value = GifFavoritesModel().getFavoristeSize();
  }

  @override
  Widget build(BuildContext context) {
    return loadGifWidget();
  }

  loadGifWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: ValueListenableBuilder(
        valueListenable: favoritesSize,
        builder: (context, int value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left: 12, top: 10),
                child: Text(
                  "添加单个GIF",
                  style: TextStyle(
                    color:
                        Get.isDarkMode ? Color(0xFF595959) : Color(0xFFa4a4a4),
                    fontSize: ScreenUtil().setSp(40 / 3),
                  ),
                ),
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 5.0,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 5 - 10,
                    height: ScreenUtil().setWidth(80),
                    child: IconButton(
                      icon: Image.asset(
                        "assets/images/icon_gif_add.png",
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                        width: ScreenUtil().setWidth(80),
                        fit: BoxFit.contain,
                      ),
                      onPressed: () {
                        widget.controller.uploadGifImg().then(
                          (herf) {
                            if (herf.isNotEmpty)
                              GifFavoritesModel().addFavorite(herf);

                            favoritesSize.value =
                                GifFavoritesModel().getFavoristeSize();
                          },
                        );
                      },
                    ),
                  ),
                  ...loadGifImage(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  loadGifImage() {
    List favorites = GifFavoritesModel().getFavorite();
    List<Widget> gifList = [];

    for (int i = 0; i < favorites.length; i++)
      gifList.add(
        InkWell(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 5 - 10,
            height: ScreenUtil().setWidth(80),
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
              child: CachedNetworkImage(
                imageUrl: favorites[i],
                width: ScreenUtil().setWidth(60),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          onTap: () {
            widget.controller!.sendGifImg(favorites[i]);
          },
          onLongPress: () {},
        ),
      );

    return gifList;
  }
}
