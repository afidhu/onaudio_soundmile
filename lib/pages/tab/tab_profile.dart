// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';

// import '../../../util/constant.dart';
// import '../../../util/constant_widget.dart';

// class TabProfile extends StatefulWidget {
//   const TabProfile({Key? key}) : super(key: key);

//   @override
//   State<TabProfile> createState() => _TabProfileState();
// }

// class _TabProfileState extends State<TabProfile> {
//   final UserController userControroller = Get.put(UserController());
//   String _username = 'Loading...';
//   String _email = 'Loading...';
//   final HomeController controller = Get.put(HomeController());

//   void backClick() {
//     Constant.closeApp();
//   }

//   Future<void> _loadData() async {
//     String username = await PrefData.getUsernameText();
//     String email = await PrefData.getEmailText();
//     setState(() {
//       _username = username;
//       _email = email;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         getVerSpace(30.h),
//         getAppBar(() {
//           backClick();
//         }, "Profile")
//             .paddingSymmetric(horizontal: 20.h),
//         getVerSpace(30.h),
//         Expanded(
//           flex: 1,
//           child: ListView(
//             primary: true,
//             shrinkWrap: false,
//             children: [
//               ClipOval(
//                 child: (userControroller.user.value.profilePhoto != null &&
//                         userControroller.user.value.profilePhoto
//                             .toString()
//                             .isNotEmpty)
//                     ? Image.network(
//                         userControroller.user.value.profilePhoto.toString(),
//                         height: 110.h,
//                         width: 110.h,
//                         fit: BoxFit.cover,
//                         errorBuilder: (BuildContext context, Object exception,
//                             StackTrace? stackTrace) {
//                           return getAssetImage("gallery.jpg",
//                               boxFit: BoxFit.cover,
//                               width: 40.dg,
//                               height: 40.dg);
//                         },
//                       )
//                     : Icon(
//                         Icons.photo,
//                         size: 110.h,
//                       ),
//               ),
//               getVerSpace(50.h),

//               // Name Row with Icon
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.person, color: Colors.white, size: 50.sp),
//                   SizedBox(width: 10.w),
//                   getCustomFont(
//                     userControroller.user.value.name.toString(),
//                     20.sp,
//                     Colors.white,
//                     1,
//                     fontWeight: FontWeight.w700,
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//               Divider(
//                   color: hintColor,
//                   thickness: 1.h,
//                   indent: 40.w,
//                   endIndent: 40.w),
//               getVerSpace(10.h),

//               // Username Row with Icon
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.account_circle, color: hintColor, size: 50.sp),
//                   SizedBox(width: 10.w),
//                   getCustomFont(
//                     userControroller.user.value.username.toString(),
//                     15.sp,
//                     hintColor,
//                     1,
//                     fontWeight: FontWeight.w700,
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//               Divider(
//                   color: hintColor,
//                   thickness: 1.h,
//                   indent: 40.w,
//                   endIndent: 40.w),
//               getVerSpace(10.h),

//               // Email Row with Icon
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.email, color: hintColor, size: 50.sp),
//                   SizedBox(width: 10.w),
//                   getCustomFont(
//                     userControroller.user.value.email.toString(),
//                     14.sp,
//                     hintColor,
//                     1,
//                     fontWeight: FontWeight.w400,
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//               Divider(
//                   color: hintColor,
//                   thickness: 1.h,
//                   indent: 40.w,
//                   endIndent: 40.w),
//               getVerSpace(10.h),

//               // Phone Row with Icon
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.phone, color: hintColor, size: 50.sp),
//                   SizedBox(width: 10.w),
//                   getCustomFont(
//                     userControroller.user.value.phone.toString(),
//                     14.sp,
//                     hintColor,
//                     1,
//                     fontWeight: FontWeight.w400,
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),

//               getVerSpace(30.h),

//               getButton(
//                 context,
//                 bgDark,
//                 "Logout",
//                 accentColor,
//                 () {
//                   final homeController = Get.find<HomeController>();
//                   homeController.index.value = 0;

//                   PrefData.clearSession();
//                   Constant.sendToNext(context, Routes.loginRoute);
//                 },
//                 18.sp,
//                 weight: FontWeight.w700,
//                 buttonHeight: 60.h,
//                 borderRadius: BorderRadius.circular(12.h),
//                 borderWidth: 1.h,
//                 isBorder: true,
//                 borderColor: accentColor,
//               ).marginSymmetric(horizontal: 20.h),
//               getVerSpace(40.h),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
