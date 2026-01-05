import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';

import '../../../controllers/home_conroller.dart';
import '../../../util/color_category.dart';
import '../../../util/constant_widget.dart';
import 'upper_library_tab/playlist_tab/playlist_tab.dart';
import 'upper_library_tab/allbum.dart';
import 'upper_library_tab/artist.dart';
import 'upper_library_tab/recent.dart';

class TabLibrary extends StatefulWidget {
  const TabLibrary({Key? key}) : super(key: key);

  @override
  State<TabLibrary> createState() => _TabLibraryState();
}

class _TabLibraryState extends State<TabLibrary>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  final recent = const _KeepAliveTab(child: RecentTab());
  final artist = const _KeepAliveTab(child: ArtistTab());
  final album = const _KeepAliveTab(child: AlbumTab());
  final playlist = const _KeepAliveTab(child: PlaylistTab());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  void backClick() {
    final homeController = Get.find<HomeController>();
    homeController.selectedIndex.value = 0; 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getVerSpace(30.h),
        SizedBox(
          // height: 51.h,
          child: Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: backClick,
                  icon: Icon(
                    CupertinoIcons.arrow_left,
                    size: 30.h,
                    color: textColor,
                  ),
                ),
              ),
              getHorSpace(10.h),
              getCustomFont(
                'My Library',
                20.sp,
                textColor,
                1,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w700,
              ),
            ],
          ).paddingSymmetric(horizontal: 10),
        ),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'Artist'),
            Tab(text: 'Albums'),
            Tab(text: 'PlayList'),
          ],
          labelColor: secondaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: secondaryColor,
        ),
        Expanded(
          child: IndexedStack(
            index: _currentTabIndex,
            children: [
              recent,
              artist,
              album,
              playlist,
            ],
          ),
        ),
      ],
    );
  }
}

/// Wrapper to preserve state of each tab
class _KeepAliveTab extends StatefulWidget {
  final Widget child;
  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
