// ignore: file_names
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sound_mile/dataFile/data_file.dart';
import 'package:sound_mile/model/release_model.dart';

class LibraryController extends GetxController {
  List<ModelRelease> libraryLists = DataFile.libraryList;

  removeItem(int index) {
    libraryLists.removeAt(index);
    update();
  }
  
}