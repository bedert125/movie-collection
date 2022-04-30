class Config {

  static var _prefs;

  static setLocalPreferences(prefs){
    print("setLocalPreferences");
    _prefs = prefs;

    print(prefs.toString());

    _ORDER_BY = prefs.getString('ORDER_BY') ?? "id asc";
    _VIEW = prefs.getString('VIEW') ?? "L";
    _LANG = int.parse(prefs.getString('LANG') ?? "1");
    _IMDB_API_KEY = prefs.getString('IMDB_API_KEY') ?? null;
    _IMDB_KEY = prefs.getString('IMDB_KEY') ?? null;
    _OMDB_KEY = prefs.getString('OMDB_KEY') ?? null;
    _E_BAY_KEY = prefs.getString('E_BAY_KEY') ?? null;
  }

  static bool _NEEDS_UPDATE = true;
  static bool get NEEDS_UPDATE{
    print("GET _NEEDS_UPDATE $_NEEDS_UPDATE");
    return _NEEDS_UPDATE;
  }

  static set NEEDS_UPDATE(bool value) {
    _NEEDS_UPDATE = value ?? false;
    print("SET _NEEDS_UPDATE CONF $_NEEDS_UPDATE");
  }

  static String SEARCH = "";

  static String _VIEW = "L";
  static String get VIEW => _VIEW;
  static set VIEW(String value) {
    _prefs.setString('VIEW', value);
    _VIEW = value;
  }

  static String _ORDER_BY = "";
  static String get ORDER_BY => _ORDER_BY;
  static set ORDER_BY(String value) {
    print("value CONF $value");
    _prefs.setString('ORDER_BY', value);
    _ORDER_BY = value;
  }

  static Map<int,String> LANG_LIST;
  static int _LANG = 1;
  static int get LANG => _LANG;
  static set LANG(int value) {
    _prefs.setString('LANG', value.toString());
    _LANG = value;
  }

  static String _IMDB_API_KEY = null;
  static String get IMDB_API_KEY => _IMDB_API_KEY;
  static set IMDB_API_KEY(String value) {
    _prefs.setString('IMDB_API_KEY', value);
    _IMDB_API_KEY = value;
  }

  static String _OMDB_KEY = null;
  static String get OMDB_KEY => _OMDB_KEY;
  static set OMDB_KEY(String value) {
    _prefs.setString('OMDB_KEY', value);
    _OMDB_KEY = value;
  }

  static String _IMDB_KEY = null;
  static String get IMDB_KEY => _IMDB_KEY;
  static set IMDB_KEY(String value) {
    _prefs.setString('IMDB_KEY', value);
    _IMDB_KEY = value;
  }

  static String _E_BAY_KEY = null;
  static String get E_BAY_KEY => _E_BAY_KEY;
  static set E_BAY_KEY(String value) {
    _prefs.setString('E_BAY_KEY', value);
    _E_BAY_KEY = value;
  }


  static int dbModification = 0;
}