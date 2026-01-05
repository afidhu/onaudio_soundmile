import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_delete/flutter_media_delete.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:sound_mile/controllers/audio_controller.dart';
import 'package:sound_mile/controllers/playlist_controller.dart';
import 'package:sound_mile/helpers/playlist_helper.dart';

import '../controllers/home_conroller.dart';
import '../controllers/player_controller.dart';
import '../pages/player/music_player.dart';
import '../pages/tab/library_tab/upper_library_tab/playlist_tab/Add_playlist_dialog.dart';
import '../pages/tab/library_tab/upper_library_tab/playlist_tab/add_to_playlist.dart'
    show AddToPlaylist;
import 'color_category.dart';
import 'constant.dart';

final OnAudioQuery audioQuery = OnAudioQuery();
PlayerController playerController = Get.put(PlayerController());
HomeController homeController = Get.put(HomeController());
final PlayListController playListController = Get.put(PlayListController());
final SongController songController = Get.put(SongController());
showToast(String s, BuildContext context) {
  if (s.isNotEmpty) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        // timeInSecForIosWeb: 1,

        backgroundColor: secondaryColor,
        textColor: textColor,
        fontSize: 12.sp);

    // Toast.show(s, context,
    //     duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }
}

Widget getAssetImage(String image,
    {double? width,
    double? height,
    Color? color,
    BoxFit boxFit = BoxFit.contain}) {
  return Image.asset(
    Constant.assetImagePath + image,
    color: color,
    width: width,
    height: height,
    fit: boxFit,
  );
}

Widget buildRecentImage(BuildContext context, int id) {
  return FutureBuilder<Uint8List?>(
    future: getArtwork(id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            'assets/images/headphones.png', // Path to your asset image

            height: double.infinity,
            width: double.infinity,
          ),
        );
        ;
      } else if (snapshot.hasData && snapshot.data != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            'assets/images/headphones.png', // Path to your asset image

            height: double.infinity,
            width: double.infinity,
          ),
        );
      }
    },
  );
}

Widget buildMusicImage(BuildContext context, double? borderRadius) {
  PlayerController playerController = Get.put(PlayerController());

  return Obx(() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.445,
      child: FutureBuilder<Uint8List?>(
        future: getArtwork(playerController.playingSong.value?.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return _buildStaticImage(snapshot.data!, borderRadius);
          } else {
            return _buildPlaceholderImage(borderRadius);
          }
        },
      ),
    );
  });
}

Widget _buildStaticImage(Uint8List imageData, double? borderRadius) {
  return Container(
    // height: 400.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      image: DecorationImage(
        image: MemoryImage(imageData),
        fit: BoxFit.cover, // Fixed BoxFit value
      ),
    ),
    child: SizedBox(
      height: double.infinity,
      width: double.infinity,
    ),
  );
}

Widget _buildPlaceholderImage(double? borderRadius) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius ?? 0),
    child: Image.asset(
      'assets/images/headphones.png',
      fit: BoxFit.cover, // Ensure the placeholder also uses the same fit
      // height: double.infinity,
      // width: double.infinity,
    ),
  );
}

buildBottomMusicBar(BuildContext context) {
  return Obx(
    () {
      return SizedBox(
        height: (homeController.isShowPlayingSong.value) ? 61.h : 0.h,
        child: Stack(
          children: [
            if (homeController.isShowPlayingSong.value)
              Positioned(
                top: 0,
                left: 0,
                right: 1,
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      MusicPlayer(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: secondaryColor,
                        width: 0.3.w,
                      ),
                    ),
                    color: (playerController.secondColor.value ?? accentColor),
                    child: Row(
                      children: [
                        Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            bool isNext =
                                direction == DismissDirection.endToStart;
                            bool noNext = !playerController
                                    .audioPlayer.hasNext &&
                                playerController.loopMode.value == LoopMode.one;
                            bool noPrevious =
                                !playerController.audioPlayer.hasPrevious;

                            if ((isNext && noNext) || (!isNext && noPrevious)) {
                              showToast('Repeat', context);
                              playerController.audioPlayer.seek(Duration.zero);
                              playerController.audioPlayer.play();
                              return false;
                            }

                            isNext
                                ? playerController.playNextSong()
                                : playerController.playPreviousSong();
                            return null;
                          },
                          background: Container(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Icon(
                                (playerController.audioPlayer.hasNext &&
                                        playerController.loopMode.value !=
                                            LoopMode.one)
                                    ? Icons.arrow_back
                                    : Icons.loop,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(
                                (playerController.audioPlayer.hasNext &&
                                        playerController.loopMode.value !=
                                            LoopMode.one)
                                    ? Icons.arrow_forward
                                    : Icons.loop,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              getHorSpace(12.h),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                height: 50.h,
                                width: 50.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11.h),
                                ),
                                child: QueryArtworkWidget(
                                  artworkBorder: BorderRadius.circular(22.h),
                                  id: playerController.playingSong.value?.id ??
                                      0,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: ClipRRect(
                                    borderRadius: BorderRadius.circular(22.h),
                                    child: Image.asset(
                                      'assets/images/headphones.png',
                                      fit: BoxFit.cover,
                                      height: 60.h,
                                      width: 60.w,
                                    ),
                                  ),
                                ),
                              ),
                              getHorSpace(20.w),
                              SizedBox(
                                width: 225.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    getCustomFont(
                                      playerController
                                              .playingSong.value?.title ??
                                          '',
                                      10.sp,
                                      Colors.white,
                                      1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    getVerSpace(6.h),
                                    getCustomFont(
                                      "${playerController.playingSong.value?.artist ?? ''}  ",
                                      8.sp,
                                      searchHint,
                                      1,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => IconButton(
                            icon: Icon(
                              (playerController.isPlaying.value)
                                  ? CupertinoIcons.pause_circle
                                  : CupertinoIcons.play_circle,
                              color: textColor,
                            ),
                            onPressed: () async {
                              playerController.togglePlayPause();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

Future<Uint8List?> getArtwork(int? id) async {
  if (id == null) return null;
  return await audioQuery.queryArtwork(id, ArtworkType.AUDIO,
      size: 1000, quality: 100);
}

Widget getSvgImage(String image,
    {double? width,
    double? height,
    Color? color,
    BoxFit boxFit = BoxFit.contain}) {
  return SvgPicture.asset(
    Constant.assetImagePath + image,
    color: color,
    width: width,
    height: height,
    fit: boxFit,
  );
}

Widget getVerSpace(double verSpace) {
  return SizedBox(
    height: verSpace,
  );
}

Widget getHorSpace(double verSpace) {
  return SizedBox(
    width: verSpace,
  );
}

Widget getRichText(
    String firstText,
    Color firstColor,
    FontWeight firstWeight,
    double firstSize,
    String secondText,
    Color secondColor,
    FontWeight secondWeight,
    double secondSize,
    String thirdText,
    Color thirdColor,
    FontWeight thirdWeight,
    double thirdSize,
    {TextAlign textAlign = TextAlign.center,
    double? txtHeight}) {
  return RichText(
    textAlign: textAlign,
    text: TextSpan(
        text: firstText,
        style: TextStyle(
          color: firstColor,
          fontWeight: firstWeight,
          fontFamily: Constant.fontsFamily,
          fontSize: firstSize,
          height: txtHeight,
        ),
        children: [
          TextSpan(
              text: secondText,
              style: TextStyle(
                  color: secondColor,
                  fontWeight: secondWeight,
                  fontFamily: Constant.fontsFamily,
                  fontSize: secondSize,
                  height: txtHeight)),
          TextSpan(
              text: thirdText,
              style: TextStyle(
                color: thirdColor,
                fontWeight: thirdWeight,
                fontFamily: Constant.fontsFamily,
                fontSize: thirdSize,
                height: txtHeight,
              ))
        ]),
  );
}

Widget getSearchWidget(
    BuildContext context, String s, TextEditingController textEditingController,
    {bool withSufix = false,
    bool minLines = false,
    bool isPass = false,
    bool isEnable = true,
    bool isprefix = false,
    Widget? prefix,
    double? height,
    String? suffiximage,
    Function? imagefunction,
    List<TextInputFormatter>? inputFormatters,
    FormFieldValidator<String>? validator,
    BoxConstraints? constraint,
    ValueChanged<String>? onChanged,
    double vertical = 17,
    double horizontal = 20,
    int? length,
    String obscuringCharacter = '•',
    GestureTapCallback? onTap,
    bool isReadonly = false,
    ValueChanged<String>? onSubmit}) {
  return StatefulBuilder(
    builder: (context, setState) {
      return Container(
        height: 60.h,
        decoration: BoxDecoration(
            color: lightBg, borderRadius: BorderRadius.circular(22.h)),
        alignment: Alignment.centerLeft,
        child: CupertinoTextField(
          onSubmitted: onSubmit,
          readOnly: isReadonly,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          maxLines: (minLines) ? null : 1,
          controller: textEditingController,
          obscureText: isPass,
          cursorColor: accentColor,
          maxLength: length,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              fontFamily: Constant.fontsFamily),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.h), color: lightBg),
          padding: EdgeInsets.symmetric(
              vertical: vertical.h, horizontal: horizontal.h),
          suffix: withSufix == true
              ? GestureDetector(
                  onTap: () {
                    imagefunction!();
                  },
                  child: getSvgImage(suffiximage.toString(),
                          width: 24.w, height: 24.h)
                      .paddingOnly(right: 18.h))
              : null,
          prefix: isprefix == true ? prefix : null,
          placeholder: s,
          placeholderStyle: TextStyle(
              color: searchHint,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              fontFamily: Constant.fontsFamily),
        ),
      );
    },
  );
}

Widget getTwoRichText(
    String firstText,
    Color firstColor,
    FontWeight firstWeight,
    double firstSize,
    String secondText,
    Color secondColor,
    FontWeight secondWeight,
    double secondSize,
    {TextAlign textAlign = TextAlign.center,
    double? txtHeight,
    Function? function}) {
  return RichText(
    textAlign: textAlign,
    text: TextSpan(
        text: firstText,
        style: TextStyle(
          color: firstColor,
          fontWeight: firstWeight,
          fontFamily: Constant.fontsFamily,
          fontSize: firstSize,
          height: txtHeight,
        ),
        children: [
          TextSpan(
              text: secondText,
              style: TextStyle(
                  color: secondColor,
                  fontWeight: secondWeight,
                  fontFamily: Constant.fontsFamily,
                  fontSize: secondSize,
                  height: txtHeight),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  function!();
                }),
        ]),
  );
}

Widget getButton(BuildContext context, Color bgColor, String text,
    Color textColor, Function function, double fontsize,
    {bool isBorder = false,
    EdgeInsetsGeometry? insetsGeometry,
    borderColor = Colors.transparent,
    FontWeight weight = FontWeight.bold,
    bool isIcon = false,
    String? image,
    Color? imageColor,
    double? imageWidth,
    double? imageHeight,
    bool smallFont = false,
    double? buttonHeight,
    double? buttonWidth,
    List<BoxShadow> boxShadow = const [],
    EdgeInsetsGeometry? insetsGeometrypadding,
    BorderRadius? borderRadius,
    double? borderWidth}) {
  return InkWell(
    onTap: () {
      function();
    },
    child: Container(
      margin: insetsGeometry,
      padding: insetsGeometrypadding,
      width: buttonWidth,
      height: buttonHeight,
      decoration: getButtonDecoration(
        bgColor,
        borderRadius: borderRadius,
        shadow: boxShadow,
        border: (isBorder)
            ? Border.all(color: borderColor, width: borderWidth!)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (isIcon) ? getSvgImage(image!) : getHorSpace(0),
          (isIcon) ? getHorSpace(15.h) : getHorSpace(0),
          getCustomFont(text, fontsize, textColor, 1,
              textAlign: TextAlign.center,
              fontWeight: weight,
              fontFamily: Constant.fontsFamily)
        ],
      ),
    ),
  );
}

Widget getCustomFont(String text, double fontSize, Color fontColor, int maxLine,
    {String fontFamily = Constant.fontsFamily,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextDecoration decoration = TextDecoration.none,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.start,
    txtHeight}) {
  return Text(
    text,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
        decoration: decoration,
        fontSize: fontSize,
        fontStyle: FontStyle.normal,
        color: fontColor,
        fontFamily: fontFamily,
        height: txtHeight,
        fontWeight: fontWeight),
    maxLines: maxLine,
    softWrap: true,
    textAlign: textAlign,
  );
}

BoxDecoration getButtonDecoration(Color bgColor,
    {BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow> shadow = const [],
    DecorationImage? image}) {
  return BoxDecoration(
      color: bgColor,
      borderRadius: borderRadius,
      border: border,
      boxShadow: shadow,
      image: image);
}

Widget defaultTextField(
  BuildContext context,
  TextEditingController controller,
  String hint,
  IconData prefixIcon, {
  bool isPass = false,
  bool showPassword = false,
  VoidCallback? togglePasswordVisibility,
  FormFieldValidator<String>? validator,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  bool isEnable = true,
  bool isReadonly = false,
}) {
  return TextFormField(
    enabled: isEnable,
    readOnly: isReadonly,
    validator: validator,
    obscureText: isPass && !showPassword,
    controller: controller,
    style: TextStyle(
        color: hintColor, fontSize: 16.sp, fontWeight: FontWeight.w400),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: hintColor, fontSize: 16.sp, fontWeight: FontWeight.w400),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: dividerColor, width: 1.w),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: dividerColor, width: 1.w),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: accentColor, width: 1.w),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1.w),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1.w),
      ),
      errorStyle: TextStyle(
          color: errorColor, fontSize: 12.sp, fontWeight: FontWeight.w400),
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.h),
        child: Icon(
          prefixIcon,
          size: 24.h,
        ),
      ),
      prefixIconConstraints: BoxConstraints(maxHeight: 24.h, maxWidth: 60.w),
      filled: true,
      suffixIcon: isPass
          ? IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: togglePasswordVisibility,
            )
          : null,
    ),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
  );
}

Widget getProfileTextField(
  BuildContext context,
  TextEditingController controller,
  String hint,
  String prefixImage, {
  bool isPass = false,
  FormFieldValidator<String>? validator,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  bool isEnable = true,
  bool isReadonly = false,
}) {
  return TextFormField(
    enabled: isEnable,
    readOnly: isReadonly,
    validator: validator,
    obscureText: isPass,
    controller: controller,
    style: TextStyle(
        color: isReadonly == true ? searchHint : Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: searchHint, fontSize: 16.sp, fontWeight: FontWeight.w400),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: dividerColor, width: 1.w),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: dividerColor, width: 1.w),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: accentColor, width: 1.w),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1.w),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1.w),
      ),
      errorStyle: TextStyle(
          color: errorColor, fontSize: 12.sp, fontWeight: FontWeight.w400),
      prefixIcon: getSvgImage(prefixImage, width: 24.h, height: 24.w)
          .paddingSymmetric(horizontal: 18.h),
      prefixIconConstraints: BoxConstraints(maxHeight: 24.h, maxWidth: 60.w),
      filled: true,
    ),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
  );
}

Widget getDivider(
    {double dividerHeight = 0,
    Color setColor = Colors.grey,
    double endIndent = 0,
    double indent = 0,
    double thickness = 1}) {
  return Divider(
    height: dividerHeight.h,
    color: setColor,
    endIndent: endIndent.w,
    indent: indent.w,
    thickness: thickness,
  );
}

Widget getMultilineCustomFont(String text, double fontSize, Color fontColor,
    {String fontFamily = Constant.fontsFamily,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextDecoration decoration = TextDecoration.none,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.start,
    txtHeight = 1.0}) {
  return Text(
    text,
    style: TextStyle(
        decoration: decoration,
        fontSize: fontSize,
        fontStyle: FontStyle.normal,
        color: fontColor,
        fontFamily: fontFamily,
        height: txtHeight,
        fontWeight: fontWeight),
    textAlign: textAlign,
  );
}

Widget getToolbarWithIcon(Function function) {
  return Stack(alignment: Alignment.topCenter, children: [
    getSvgImage("mfariji.svg", width: 60.w, height: 80.w),
    // getAssetImage("splash_logo.png", height: 88.h, width: 68.h),
    // getSvgImage(image)
    Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
            onTap: () {
              function();
            },
            child: getSvgImage("arrow_back.svg", width: 24.w, height: 24.w)))
  ]);
}

Widget getAppBar(Function function, String title, {int? height}) {
  return Container(
    height: (height ?? 150).h, // Use default height if not provided
    // color: secondaryColor,

    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () {
              function();
            },
            icon: Icon(
              CupertinoIcons.arrow_left,
              size: 30.h,
              color: textColor,
            ),
          ),
        ),
        getVerSpace(10.h),
        Row(
          children: [
            getHorSpace(10.h),
            Expanded(
              child: getCustomFont(
                title,
                20.sp,
                textColor,
                1,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Divider(
          color: secondaryColor,
          thickness: 0.3,
        ),
      ],
    ),
  );
}

Widget getProfileWidget(Function function, String image, String name) {
  return GestureDetector(
    onTap: () {
      function();
    },
    child: Column(
      children: [
        Row(
          children: [
            getSvgImage(image, width: 24.w, height: 24.w)
                .marginOnly(left: 18.h),
            getHorSpace(18.h),
            Expanded(
              flex: 1,
              child: getCustomFont(name, 16.sp, hintColor, 1,
                  fontWeight: FontWeight.w400),
            ),
            getSvgImage("arrow_right.svg", height: 16.h, width: 16.w)
          ],
        ).paddingOnly(top: 20.h, bottom: 16.h),
        getDivider(setColor: dividerColor)
      ],
    ),
  );
}

Future<bool> requestManageStoragePermission() async {
  if (await Permission.manageExternalStorage.isGranted) {
    return true;
  } else {
    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }
}

Future<void> deleteFile(String path) async {
  try {
    await FlutterMediaDelete.deleteMediaFile(path);
    // if (result) {
    // print("****************$result");
    // debugPrint('File deleted successfully: $path');
    // } else {
    //   debugPrint('Failed to delete file: $path');
    // }
  } catch (e) {
    debugPrint('Error deleting file: $e');
  }
}

Widget buildMoreVertButton(BuildContext context, int songId) {
  return Theme(
    data: Theme.of(Get.context!).copyWith(
      popupMenuTheme: PopupMenuThemeData(
        color: containerBg,
        surfaceTintColor: containerBg,
      ),
    ),
    child: PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: textColor,
        size: 20.sp,
      ),
      onSelected: (String value) async {
        final allSongs = playerController.allSongs;
        final SongModel song = allSongs.firstWhere((s) => s.id == songId);

        if (value == 'Option 1') {
          if (playerController.favouriteSongsIds.contains(songId)) {
            // Remove from favourites
            await PlaylistHelper.PlaylistHelper()
                .removeSongFromPlaylist(1, songId);
            showToast("Removed from Favourites", context);
          } else {
            // Add to favourites
            await PlaylistHelper.PlaylistHelper().addSongToPlaylist(1, songId);
            showToast("Added to Favourites", context);
          }
          playListController.fetchSongsInPlaylist(songId);
          playListController.getPlaylistsWithSongCount();
        } else if (value == 'Option 2') {
          showAddPlaylistModal(context, songId);
        } else if (value == 'Option 3') {
          try {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: containerBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Delete Song",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Are you sure you want to delete '${song.title}'?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              "Delete",
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );

            if (shouldDelete == true) {
              if (song.data.isNotEmpty && await File(song.data).exists()) {
                await deleteFile(song.data);
                songController.deleteSong(songId);
                showToast("Song deleted successfully", context);
              } else {
                showToast("File not found or already deleted", context);
              }
            }
          } catch (e) {
            showToast("Error deleting the file", context);
          }
        } else if (value == 'Option 4') {
          try {
            if (song.data.isNotEmpty && await File(song.data).exists()) {
              await Share.shareXFiles(
                [XFile(song.data)],
                text: 'Check out this song!',
              );
            } else {
              showToast("File not found for sharing", context);
            }
          } catch (e) {
            showToast("Error sharing the file", context);
          }
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'Option 1',
            child: Row(
              children: [
                Obx(() {
                  // Check if the current song is in the favourites list
                  var isFavourite =
                      playerController.favouriteSongsIds.contains(songId);
                  return Icon(
                    isFavourite
                        ? CupertinoIcons.heart_circle_fill
                        : CupertinoIcons.heart_circle,
                    color: textColor,
                    size: 20.sp,
                  );
                }),
                getHorSpace(5.w),
                getCustomFont(
                    playerController.favouriteSongsIds.contains(songId)
                        ? 'Remove'
                        : 'Favourite',
                    15.sp,
                    textColor,
                    1),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Option 2',
            child: Row(
              children: [
                Icon(CupertinoIcons.add_circled, color: textColor, size: 20.h),
                getHorSpace(5.w),
                getCustomFont('Playlist', 15.sp, textColor, 1),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Option 4',
            child: Row(
              children: [
                Icon(Icons.share, color: textColor, size: 20.h),
                getHorSpace(5.w),
                getCustomFont('Share', 15.sp, textColor, 1),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Option 3',
            child: Row(
              children: [
                Icon(CupertinoIcons.delete, color: textColor, size: 20.h),
                getHorSpace(5.w),
                getCustomFont('Delete', 15.sp, textColor, 1),
              ],
            ),
          ),
        ];
      },
    ),
  );
}

Widget buildPlaylistMoreVertButton(BuildContext context, int playlistId) {
  return Theme(
    data: Theme.of(Get.context!).copyWith(
      popupMenuTheme: PopupMenuThemeData(
        color: containerBg,
        surfaceTintColor: containerBg,
      ),
    ),
    child: PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: textColor,
        size: 25.h,
      ),
      onSelected: (String value) async {
        if (value == "Option 2") {
          PlaylistHelper.PlaylistHelper().deletePlaylist(playlistId);
        } else if (value == "Option 1") {
          Get.to(AddToPlaylist(playlistId: playlistId),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut);
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'Option 1',
            child: Row(
              children: [
                Icon(CupertinoIcons.plus_circle, color: textColor, size: 20.h),
                getHorSpace(5.w),
                getCustomFont('Add Song', 15.sp, textColor, 1),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Option 2',
            child: Row(
              children: [
                Icon(CupertinoIcons.delete, color: textColor, size: 20.h),
                getHorSpace(5.w),
                getCustomFont('Delete', 15.sp, textColor, 1),
              ],
            ),
          ),
        ];
      },
    ),
  );
}
