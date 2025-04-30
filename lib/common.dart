import 'dart:convert';
import 'dart:core';
import 'dart:io';

import './sp.dart';

class Common {
  static final Map<String, dynamic> _map = {};

  static const String login_key = "userdata";
  static const String profile_nickname_key = "profile_nickname";
  static const String profile_email_key = "profile_email";

  static const String search_ext_key = "search_ext";
  static const String search_language_key = "search_language";
  static const String sync_key = "sync";
  static const String reader_image_show_key = "reader_image_show";
  static const String online_read_key = "online_read";
  static const String checked = "1";
  static const String unchecked = "0";

  static const String log_suffix = ".exception";
  static const String book_metadata_suffix = ".meta";

  static const String serv_userid = "remix_userid";
  static const String serv_userkey = "remix_userkey";

  static String _documentDirectory = "";

  static String getData(String key) {
    var value = _map[key]?.toString();
    return value ?? "";
  }

  static void setData(String key, String value) {
    assert(_documentDirectory != "");
    _map[key] = value;
    SP.write("$_documentDirectory/config.json", jsonEncode(_map));
  }

  static void load() {
    assert(_documentDirectory != "");
    var filename = "$_documentDirectory/config.json";
    if (!File(filename).existsSync()) {
      File(filename).createSync();
    }
    var text = SP.read(filename);
    if (text != "") {
      var json = jsonDecode(text);
      _map.addAll(json);
    }
  }

  static void setDocumentDirectory(String dd) {
    assert(dd != "");
    if (_documentDirectory == "") {
      _documentDirectory = dd;
    }
  }

}

class Tuple<T1, T2, T3> {
  final T1 a;
  final T2 b;
  final T3 c;

  Tuple(this.a, this.b, this.c);

  @override
  String toString() {
    return "a:$a, b:$b, c:$c";
  }
}

abstract class ProgressListener {
  void onProgress(int downloaded, int total);
}
