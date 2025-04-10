import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import './ba.dart';
import './common.dart';
import './session.dart';

final a = String.fromCharCodes(Ba.abtoa("a([0c\$)u:j!w:\$!w:\$!x.nh5eg=="));
final base = "https://$a/xbook";

Future<Tuple<int, String, dynamic>> search(
  String keyword,
  int page,
  List<String> languages,
  List<String> extensions,
) async {
  var params = [
    ["page", page],
  ];
  if (languages.isNotEmpty) {
    for (var item in languages) {
      params.add(["languages[]", item]);
    }
  }
  if (extensions.isNotEmpty) {
    for (var item in extensions) {
      params.add(["extensions[]", item]);
    }
  }
  var body = jsonEncode({
    "method": "GET",
    "url": "/s/${Uri.encodeComponent(keyword)}",
    "headers": {"cookie": SessionManager.getSession()},
    "params": params,
  });
  print("request: $body");

  var response = await http.post(
    Uri.parse(base),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  var statusCode = response.statusCode;
  if (statusCode > 299) {
    return Tuple(1, response.headers["X-message"].toString(), "");
  }
  var result = const Utf8Decoder().convert(response.bodyBytes);
  print("response: $statusCode : $result");

  return Tuple(0, "", jsonDecode(result));
}

Future<Tuple<int, String, dynamic>> detail(String url) async {
  var body = jsonEncode({
    "method": "GET",
    "url": "$url",
    "headers": {"cookie": SessionManager.getSession()},
  });
  print("request: $body");

  var response = await http.post(
    Uri.parse(base),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  var statusCode = response.statusCode;
  if (statusCode > 299) {
    return Tuple(1, response.headers["X-message"].toString(), "");
  }
  var result = const Utf8Decoder().convert(response.bodyBytes);
  print("response: $statusCode : $result");

  return Tuple(0, "", jsonDecode(result));
}

Future<Tuple<int, String, dynamic>> login(String email, String password) async {
  var body = jsonEncode({
    "method": "POST",
    "url": "/rpc.php",
    "headers": {
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    },
    "params": {},
    "data":
        "isModal=true&email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&site_mode=books&action=login&redirectUrl=${Uri.encodeComponent("")}&gg_json_mode=1",
  });
  print("request: $body");

  var response = await http.post(
    Uri.parse(base),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  var statusCode = response.statusCode;
  if (statusCode > 299) {
    return Tuple(1, response.headers['X-message'].toString(), "");
  }
  var result = const Utf8Decoder().convert(response.bodyBytes);
  print("response: $statusCode : $result");

  var resp = jsonDecode(result);

  var status = int.parse(resp["status"].toString());
  if (status > 299) {
    return Tuple(1, response.headers["X-message"].toString(), "");
  }
  var data = jsonDecode(resp["data"].toString());
  var dataResponse = data["response"];

  var forceRedirection = dataResponse['forceRedirection'].toString();
  if (forceRedirection == "") {
    return Tuple(1, dataResponse["message"].toString(), "");
  }

  String session = forceRedirection.substring(2).replaceAll("&", ";");
  return Tuple(0, "", session);
}

Future<void> downloadApk(String downloadUrl, ProgressListener listener) async {
  var body = jsonEncode({
    "method": "GET",
    "url": downloadUrl,
    "headers": {"cookie": SessionManager.getSession(), "b": "1"},
    "params": {},
  });
  print("request: $body");

  var client = http.Client();
  var request = http.Request("POST", Uri.parse(base));
  request.headers["Content-Type"] = "application/json";
  request.body = body;

  var response = client.send(request);

  List<List<int>> chunks = [];
  int downloaded = 0;

  response.asStream().listen((http.StreamedResponse r) {
    var total = r.contentLength;

    var path = Uri.parse(downloadUrl).path;
    var filename = path.substring(path.lastIndexOf("/") + 1);

    r.stream.listen(
      (List<int> chunk) {
        chunks.add(chunk);
        downloaded += chunk.length;
        listener.onProgress(downloaded, total!);
      },
      onDone: () async {
        print('downloadPercentage: ${downloaded / total! * 100}');

        var directory = await getDownloadsDirectory();
        var dir = directory?.path;

        File file = new File('$dir/$filename');
        final Uint8List bytes = Uint8List(total);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        await file.writeAsBytes(bytes);
      },
    );
  });
}

Future<Tuple<int, String, dynamic>> profile() async {
  var body = jsonEncode({
    "method": "GET",
    "url": "/profileEdit",
    "headers": {"cookie": SessionManager.getSession()},
    "params": {},
  });
  print("request: $body");

  var response = await http.post(
    Uri.parse(base),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  var statusCode = response.statusCode;
  if (statusCode > 299) {
    return Tuple(1, response.headers['X-message'].toString(), "");
  }
  var result = const Utf8Decoder().convert(response.bodyBytes);
  print("response: $statusCode : $result");

  var resp = jsonDecode(result);

  var status = int.parse(resp["status"].toString());
  if (status > 299) {
    return Tuple(1, response.headers["X-message"].toString(), "");
  }
  var email = resp["data"]['email'];
  if (email == "") {
    return Tuple(1, "未登录", "");
  }
  return Tuple(0, "", resp["data"]);
}

Future<Tuple<int, String, dynamic>> sendCode(
  String emailStr,
  String password,
  String nickname,
) async {
  var body = jsonEncode({
    "method": "POST",
    "url": "/papi/user/verification/send-code",
    "headers": {"content-type": "multipart/form-data"},
    "params": {},
    "data": {
      "email": emailStr,
      "password": password,
      "name":
          nickname == ""
              ? Uri.encodeComponent(emailStr.split("@")[0])
              : Uri.encodeComponent(nickname),
      "rx": 215,
      "action": "registration",
      "redirectUrl": "",
    },
  });
  print("request: $body");

  var response = await http.post(
    Uri.parse(base),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  var statusCode = response.statusCode;
  if (statusCode > 299) {
    return Tuple(1, response.headers['X-message'].toString(), "");
  }
  var result = const Utf8Decoder().convert(response.bodyBytes);
  print("response: $statusCode : $result");

  var resp = jsonDecode(result);

  var status = int.parse(resp["status"].toString());
  if (status > 299) {
    return Tuple(1, response.headers["X-message"].toString(), "");
  }
  var data = jsonDecode(resp["data"].toString());
  // data["success"] == 1 1:success 0:error
  return Tuple(0, "", data);
}

Future<Tuple<int, String, dynamic>> sendCodePasswordRecovery(
  String emailStr,
) async {
  var body = jsonEncode({
    "method": "POST",
    "url": "/papi/user/verification/send-code",
    "headers": {"content-type": "multipart/form-data"},
    "params": {},
    "data": {"email": emailStr, "action": "passwordrecovery"},
  });
  print("request: $body");

  var response = await http.post(
    Uri.parse(base),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  var statusCode = response.statusCode;
  if (statusCode > 299) {
    return Tuple(1, response.headers['X-message'].toString(), "");
  }
  var result = const Utf8Decoder().convert(response.bodyBytes);
  print("response: $statusCode : $result");

  var resp = jsonDecode(result);

  var status = int.parse(resp["status"].toString());
  if (status > 299) {
    return Tuple(1, response.headers["X-message"].toString(), "");
  }
  var data = jsonDecode(resp["data"].toString());
  // data["success"] == 1 1:success 0:error
  return Tuple(0, "", data);
}

Future<Tuple<int, String, dynamic>> registration(
  String emailStr,
  String password,
  String verifyCode,
  String nickname,
) async {
  var body = jsonEncode({
    "method": "POST",
    "url": "/rpc.php",
    "headers": {
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    },
    "params": {},
    "data":
        "isModal=true&email=${Uri.encodeComponent(emailStr)}&password=$password&name=${nickname == "" ? Uri.encodeComponent(emailStr.split("@")[0]) : Uri.encodeComponent(nickname)}&rx=215&action=registration&redirectUrl=&verifyCode=$verifyCode&gg_json_mode=1",
  });
  print("request: $body");

  var response = await http.post(
    Uri.parse(base),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  var statusCode = response.statusCode;
  if (statusCode > 299) {
    return Tuple(1, response.headers['X-message'].toString(), "");
  }
  var result = const Utf8Decoder().convert(response.bodyBytes);
  print("response: $statusCode : $result");

  var resp = jsonDecode(result);

  var status = int.parse(resp["status"].toString());
  if (status > 299) {
    return Tuple(1, response.headers["X-message"].toString(), "");
  }
  var data = jsonDecode(resp["data"].toString());
  var forceRedirection = data["response"]["forceRedirection"].toString();
  if (forceRedirection == "") {
    return Tuple(1, response.headers['X-message'].toString(), "");
  }
  var session = forceRedirection.substring(2).replaceAll("&", ";");
  return Tuple(0, "", session);
}


