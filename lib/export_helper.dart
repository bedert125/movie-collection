import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:restart_app/restart_app.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class ExportData {

  Future<bool> _requestPermissions() async {


    // var permission = await PermissionHandler()
    //     .checkPermissionStatus(PermissionGroup.storage);

    var permission = await Permission.storage.request();

    /* if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
    }*/

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

  Future writeDbExternalStorage(String _file) async {
    final downloadFileName = "MovieCollection_${DateTime.now().millisecondsSinceEpoch}.db";
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {

      //final dirList = await _getExternalStoragePath();
      //final path = dirList[0].path;
      print("load ${_file}");

        String _localPath = (await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS));

        var now = new DateTime.now();

        String formattedDate = now.toString().substring(0,10)+ '_${now.hour}-${now.minute}-${now.second}';

        var name = "/collectionBackup_"+formattedDate+".db";

        String filePath = _localPath + name;
        File origin = File(_file);

        var newFile = await origin.copy(filePath);

        /*File fileDef = File(filePath);
        await fileDef.create(recursive: true);
        Uint8List bytes = await origin.readAsBytes();
        await fileDef.writeAsBytes(bytes);*/



      /*final file = File('${dir.path}/$downloadFileName');

      // final jsonString = jsonEncode(_jsonLocal);
      ByteData data = await rootBundle.load(_file);
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      //print(jsonString);
      file.writeAsBytesSync(bytes);*/

      print("saved in ${newFile.path}");

     /* file.writeAsString(jsonString).then((File _file) {
        _fileFullPath = _file.path;

        print("saved in $_fileFullPath");
      });*/
      return name;
    }
    return "";
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


  Future importDb(String _dbPath) async{
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path);

      var newFile = await file.copy(_dbPath);
      print("loaded in ${newFile.path}");

      Restart.restartApp();

      return newFile.path;
    } else {
      // User canceled the picker
      return "";
    }
  }

}
