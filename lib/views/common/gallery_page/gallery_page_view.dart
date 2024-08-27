import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/utils/image_tool.dart';
import 'package:freerse/views/common/circle_icon_btn.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../config/ColorConstants.dart';
import 'gallery_page_controller.dart';

class GalleryExampleItem {
  GalleryExampleItem({
    required this.id,
    required this.resource,
    this.isSvg = false,
  });

  final String id;
  final String resource;
  final bool isSvg;
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<String> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<ImageProvider> images = [];

  @override
  void initState() {
    super.initState();
    for (var imagePath in widget.galleryItems) {
      images.add(CachedNetworkImageProvider(imagePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
            Positioned(
              left: 20.w,
              bottom: Get.mediaQuery.padding.bottom + 23.w,
              child: Text(
                "${currentIndex + 1} / ${widget.galleryItems.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  decoration: null,
                ),
              ),
            ),
            Positioned(
              right: 20.w,
              bottom: Get.mediaQuery.padding.bottom + 20.w,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10.w),
                    child: CircleIconBtn(
                      iconData: Icons.share,
                      onTap: () {
                        share();
                      },
                    ),
                  ),
                  Container(
                    child: CircleIconBtn(
                      iconData: Icons.download,
                      onTap: () {
                        saveImage();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20.w,
              top: Get.mediaQuery.padding.top + 20.w,
              child: CircleIconBtn(
                iconData: Icons.close,
                onTap: () {
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<String> _saveImageToTemp(String imageUrl) async {
  //   var appDocDir = await getTemporaryDirectory();
  //   var filename = p.basename(imageUrl);
  //   String saveDir = appDocDir.path + "/" + Helpers().getRandomString(10) + "/";
  //   _checkAndCreateDir(saveDir);
  //   var saveFilePath = saveDir + filename;
  //   await Dio().download(imageUrl, saveFilePath);
  //   return saveFilePath;
  // }

  // void _checkAndCreateDir(String dirPath) {
  //   var dir = Directory(dirPath);
  //   if (!dir.existsSync()) {
  //     dir.createSync();
  //   }
  // }

  Future<void> share() async {
    Get.defaultDialog(title: "LOADING".tr + "...",content: CircularProgressIndicator(
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation(ColorConstants.greenColor),
    ));
    // String item = widget.galleryItems[currentIndex];
    // var tempFilePath = await _saveImageToTemp(item);
    var imageData = await images[currentIndex].getBytes(context, format: ImageByteFormat.png);
    Get.back();
    // Share.shareXFiles([XFile(tempFilePath)]);
    if (imageData != null) {
      Share.shareXFiles([XFile.fromData(imageData!, mimeType: "image/png")]);
    }
  }

  Future<void> saveImage() async {
    Get.defaultDialog(title: "LOADING".tr + "...",content: CircularProgressIndicator(
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation(ColorConstants.greenColor),
    ));
    Map? result;
    try {
      if (Platform.isIOS) {
        result = await _doSaveImage();
      } else if (Platform.isAndroid) {
        PermissionStatus permission = await Permission.storage.request();
        if (permission == PermissionStatus.granted) {
          result = await _doSaveImage();
        } else {
          print("Permission not found");
        }
      }
    } finally {
      Get.back();
    }

    if (result != null && result["isSuccess"] == true) {
      Get.snackbar("TI_SHI".tr, "SAVE_IMAGE_SUCCESS".tr, duration: Duration(seconds: 3));
    }
  }

  Future<Map> _doSaveImage() async {
    // String item = widget.galleryItems[currentIndex];
    // print(item);
    // var tempFilePath = await _saveImageToTemp(item);
    var imageData = await images[currentIndex].getBytes(context, format: ImageByteFormat.png);
    // print(tempFilePath);
    // return await ImageGallerySaver.saveFile(tempFilePath);
    if (imageData != null) {
      return await ImageGallerySaver.saveImage(imageData!, quality: 100);
    }

    return {};
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final String item = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
      // imageProvider: CachedNetworkImageProvider(item),
      imageProvider: images[index],
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item),
    );
  }
}
