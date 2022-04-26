import 'dart:convert';
import 'package:http/http.dart' as http;
import 'conf/config.dart';

class Request {
  static getTranslatedData(String imdb) async {
    /*var urlMovieData = 'https://imdb-api.com/'+
        Config.LANG_LIST[Config.LANG] + '/API/Wikipedia/'+
        Config.IMDB_API_KEY+'/' + imdb;*/

    var urlMovieData  = Uri(
        scheme: 'https',
        host: 'imdb-api.com',
        path: Config.LANG_LIST[Config.LANG] +
            '/API/Wikipedia/'+
            Config.IMDB_API_KEY+'/' + imdb);

    print("urlMovieData $urlMovieData");
    var response = await http.get(urlMovieData);
    return jsonDecode(response.body);
  }
}