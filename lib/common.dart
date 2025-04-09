import 'dart:core';

class Common {
  static final Map<String, dynamic> _map = {};

  static const String login_key = "userdata";
  static const String serv_userid = "remix_userid";
  static const String serv_userkey = "remix_userkey";

  static String getData(String key) {
    return "";
  }
}

class Tuple<T1, T2, T3> {
  final T1 a;
  final T2 b;
  final T3 c;

  Tuple(this.a, this.b, this.c);
}

abstract class ProgressListener {
  void onProgress(int downloaded, int total);
}
