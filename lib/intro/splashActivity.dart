import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sound_mile/intro/permission_screen.dart' show PermissionPage;
import 'package:sound_mile/util/color_category.dart';

import '../controllers/home_conroller.dart';
import '../controllers/player_controller.dart';
import '../pages/home_screen.dart';
import '../util/constant_widget.dart';
import '../util/pref_data.dart';

class SpritePainter extends CustomPainter {
  final Animation<double>? _animation;

  SpritePainter(this._animation) : super(repaint: _animation);

  void circle(Canvas canvas, Rect rect, double value) {
    double opacity = (1.0 - (value / 4.0)).clamp(0.0, 2.0);
    Color color = secondaryColor.withOpacity(opacity);

    double size = rect.width / 2;
    double area = size * size;
    double radius = sqrt(area * value / 4);

    final Paint paint = Paint()..color = color;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    for (int wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + _animation!.value);
    }
  }

  @override
  bool shouldRepaint(SpritePainter oldDelegate) {
    return true;
  }
}

class SplashActivity2 extends StatefulWidget {
  @override
  SplashActivity2State createState() => SplashActivity2State();
}

class SplashActivity2State extends State<SplashActivity2>
    with SingleTickerProviderStateMixin {
  HomeController homeController = Get.put(
    HomeController(),
  );
  late bool isPermitted;

  @override
  void initState() {
    super.initState();
    getIsFirst();
    _controller = AnimationController(
      vsync: this,
    );

    _startAnimation();
    startTime();
  }

  void getIsFirst() async {
    homeController.getIsShowPlayingData();
    isPermitted = (await PrefData.getIsPermitted())!;
    await Future.delayed(const Duration(milliseconds: 50));

    // ignore: unnecessary_null_comparison
    if (!isPermitted || isPermitted == null) {
      Get.to(const PermissionPage());
    } else {
      // await Future.delayed(const Duration(milliseconds: 50));
      await PlayerController().fetchSongs();
      Get.to(HomeScreen(), transition: Transition.fadeIn);
    }
  }

  AnimationController? _controller;
  late Timer timer;
  startTime() async {
    var duration = Duration(seconds: 6);
    timer = Timer(duration, navigationPage);
    return timer;
  }

  @override
  void dispose() {
    timer.cancel();
    _controller!.dispose();
    super.dispose();
  }

  void navigationPage() {
    // Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //         builder: (BuildContext context) => LoginOptionsActivity3()));
  }

  // @override
  // void initState() {
  //   super.initState();

  //   _controller = AnimationController(
  //     vsync: this,
  //   );

  //   _startAnimation();
  //   startTime();
  // }

  void _startAnimation() {
    _controller!.stop();
    _controller!.reset();
    _controller!.repeat(
      period: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              bgDark,
              secondaryColor,
              bgDark,
            ])),
        child: Center(
          child: Stack(
            children: <Widget>[
              Center(
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Container(
                        color: bgDark,
                        // child: Image.asset(
                        //   'assets/images/headphones.png',
                        //   height: 250.0,
                        //   width: 250.0,
                        //   scale: 1,
                        // ),
                      ),
                    ),
                    Center(
                      child: Container(
                          // child: Image.asset(
                          //   'mile_maroon.png',
                          //   height: 215.0,
                          //   width: 215.0,
                          //   scale: 1,
                          // ),
                          ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  CustomPaint(
                    painter: SpritePainter(_controller),
                    child: SizedBox(
                      width: 200.0,
                      height: 200.0,
                    ),
                  ),
                  Center(
                    child: Container(
                      child: getAssetImage(
                        'mile_maroon.png',
                        height: 50.h,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
