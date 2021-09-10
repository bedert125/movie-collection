import 'dart:convert';
import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportData {

  Future<bool> _requestPermissions() async {
    var permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
    }

    return permission == PermissionStatus.granted;
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory(await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS));
    }

    // in this example we are using only Android and iOS so I can assume
    // that you are not trying it for other platforms and the if statement
    // for iOS is unnecessary

    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }


 /*
  void readJson() async {
    // Initialize _filePath
    _filePath = await _localFile;

    // 0. Check whether the _file exists
    _fileExists = await _filePath.exists();
    print('0. File exists? $_fileExists');

    // If the _file exists->read it: update initialized _json by what's in the _file
    if (_fileExists) {
      try {
        //1. Read _jsonString<String> from the _file.
        _jsonString = await _filePath.readAsString();
        print('1.(_readJson) _jsonString: $_jsonString');

        //2. Update initialized _json by converting _jsonString<String>->_json<Map>
        _json = jsonDecode(_jsonString);
        print('2.(_readJson) _json: $_json \n - \n');
      } catch (e) {
        // Print exception errors
        print('Tried reading _file error: $e');
        // If encountering an error, return null
      }
    }
  }
*/

  String _fileFullPath;
  /*
  Future<List<Directory>> _getExternalStoragePath() {
    return getExternalStorageDirectories(type: StorageDirectory.downloads);
  }*/

  Map<String, dynamic> _jsonLocal = {};

  Future add(String key, dynamic value) async {
    _jsonLocal.addAll({key: value});
  }


  Future writeExternalStorage() async {
    final downloadFileName = "MovieCollection_${DateTime.now().millisecondsSinceEpoch}.json";
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {

      //final dirList = await _getExternalStoragePath();
      //final path = dirList[0].path;

      final file = File('${dir.path}/$downloadFileName');

      final jsonString = jsonEncode(_jsonLocal);

      //print(jsonString);

      file.writeAsString(jsonString).then((File _file) {
        _fileFullPath = _file.path;

        print("saved in $_fileFullPath");
      });
    }
  }




}
