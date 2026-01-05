import 'package:get/get.dart';
import 'package:sound_mile/util/pref_data.dart';

class HomeController extends GetxController {
  RxInt index = 0.obs;
  var isPermitted = false.obs;
  var isShowPlayingSong = false.obs;
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // getIsShowPlayingData();
  }

  void getIsShowPlayingData() async {
    final bool isShowPlaying = await PrefData.getIsShowPlaying();

    isShowPlayingSong.value = isShowPlaying;
    update();
  }

  Future<void> setIsShowPlayingData(bool value) async {
    isShowPlayingSong.value = value;
    await PrefData.setIsShowPlaying(value);
    update();
  }

  

  void onChange(RxInt value) {
    index.value = value.value;
    update();
  }
}
class HomeScreenController extends GetxController {
  RxInt index = 0.obs;

  void reset() {
    index.value = 0;
    update();
  }

  void indexChange(RxInt value) {
    index.value = value.value;
    update();
  }
}