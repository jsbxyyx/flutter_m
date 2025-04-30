import 'package:flutter_m/common.dart';
import 'package:flutter_m/session.dart';
import 'package:path_provider/path_provider.dart';

class Init {
  static Future initialize() async {
    await _loadConfigs();
  }

  static _loadConfigs() async {
    print("starting loading configs");
    Common.setDocumentDirectory((await getApplicationDocumentsDirectory()).path);
    Common.load();
    SessionManager.setSession(Common.getData(Common.login_key));
    print("finished loading configs");
  }
}
