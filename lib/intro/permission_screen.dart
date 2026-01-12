import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_mile/controllers/player_controller.dart';
import 'package:sound_mile/intro/splashActivity.dart' show SplashActivity2;
import 'package:sound_mile/util/color_category.dart';
import 'package:sound_mile/util/constant_widget.dart';
import 'package:sound_mile/util/pref_data.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  Future<double> _getAndroidVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Parse the Android version release string to a double
    double androidVersion = double.tryParse(androidInfo.version.release) ?? 0.0;

    return androidVersion;
  }

  Future<void> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final double androidVersion = await _getAndroidVersion();
        // Extract the major version number correctly
        // String versionString = Platform.version.split(' ')[0];
        // int androidVersion = int.parse(versionString.split('.')[0]);

        // For Android 13 and above
        if (androidVersion >= 13) {
          final permissions = [
            Permission.photos,
            Permission.videos,
            Permission.audio,
          ];

          final statuses = await permissions.request();

          if (statuses.values.every((status) => status.isGranted)) {
            onPermissionGranted();
          } else {
            showPermissionDeniedDialog();
          }
        } else {
          // For Android versions below 13
          final status = await Permission.storage.status;
          if (status.isGranted) {
            onPermissionGranted();
          } else if (status.isDenied || status.isPermanentlyDenied) {
            final requestStatus = await Permission.storage.request();
            if (requestStatus.isGranted) {
              onPermissionGranted();
            } else {
              showPermissionDeniedDialog();
            }
          } else {
            showPermissionDeniedDialog();
          }
        }
      } else {
        // Handle permissions for other platforms if required
        onPermissionGranted();
      }
    } catch (e) {
      showErrorDialog('An error occurred while requesting permissions.');
    }
  }

  void onPermissionGranted() async {
    await PrefData.setIsPermitted(true);
    PlayerController().fetchSongs();

    // Show success dialog
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Permission Granted'),
            content: Text('Required permissions have been granted.'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Get.to(() => SplashActivity2(),
                      transition: Transition.fadeIn);
                },
              )
            ],
          );
        },
      );
    }
  }

  void showPermissionDeniedDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Permission Denied'),
          content: Text('Permission is required to access and play music.'),
          actions: [
            CupertinoDialogAction(
              child: Text('Retry'),
              onPressed: () {
                Navigator.pop(context);
                requestPermission();
              },
            ),
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            getSvgImage('permission.svg', height: 100.h),
            SizedBox(height: 20.h),
            Text(
              'Sound Mile requires storage permission to access and play music.',
              style: TextStyle(fontSize: 14, color: textColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 200.h),
            FloatingActionButton.extended(
              onPressed: requestPermission,
              label: Text(
                'Allow',
                style: TextStyle(color: bgDark),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
