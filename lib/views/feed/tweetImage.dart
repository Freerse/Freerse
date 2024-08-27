import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../common/gallery_page/gallery_page_view.dart';


class TweetImage extends StatelessWidget {
  const TweetImage(
      {Key? key, required this.picList})
      : super(key: key);

  final List<String> picList;
  @override
  Widget build(BuildContext context) {
    if(picList.length == 0){
      return Container();
    }
    if(picList.length == 1){
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        alignment: Alignment.centerRight,
        child:Padding(
          padding: const EdgeInsets.only(top: 0),
          child: InkWell(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            onTap: () {
              Get.to(GalleryPhotoViewWrapper(galleryItems: picList));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
              child: Container(
                width: context.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: picList[0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if(picList.length == 2){
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        alignment: Alignment.centerRight,
        height: ScreenUtil().setHeight(200),
        child:Padding(
          padding: const EdgeInsets.only(top: 0),
          child: InkWell(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            onTap: () {
              Get.to(GalleryPhotoViewWrapper(galleryItems: picList));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              child: Flex(
                // 表示主轴方向是水平方向
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: context.width,
                      height: ScreenUtil().setHeight(200),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: CachedNetworkImage(
                          imageUrl: picList[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: context.width,
                      height: ScreenUtil().setHeight(200),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: CachedNetworkImage(
                          imageUrl: picList[1],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if(picList.length == 3){
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        alignment: Alignment.centerRight,
        child:Padding(
          padding: const EdgeInsets.only(top: 0),
          child: InkWell(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            onTap: () {
              Get.to(GalleryPhotoViewWrapper(galleryItems: picList));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Container(
                    width: context.width,
                    height: ScreenUtil().setHeight(100),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                    ),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: CachedNetworkImage(
                        imageUrl: picList[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: context.width,
                          height: ScreenUtil().setHeight(100),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: CachedNetworkImage(
                              imageUrl: picList[1],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: context.width,
                          height: ScreenUtil().setHeight(100),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: CachedNetworkImage(
                              imageUrl: picList[2],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ),
          ),
        ),
      );
    }



    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      alignment: Alignment.centerRight,
      child:Padding(
        padding: const EdgeInsets.only(top: 0),
        child: InkWell(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          onTap: () {
            Get.to(GalleryPhotoViewWrapper(galleryItems: picList));
          },
          child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: context.width,
                          height: ScreenUtil().setHeight(100),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: CachedNetworkImage(
                              imageUrl: picList[0],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: context.width,
                          height: ScreenUtil().setHeight(100),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: CachedNetworkImage(
                              imageUrl: picList[1],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 2,
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: context.width,
                          height: ScreenUtil().setHeight(100),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: CachedNetworkImage(
                              imageUrl: picList[2],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: context.width,
                          height: ScreenUtil().setHeight(100),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: CachedNetworkImage(
                              imageUrl: picList[3],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}
