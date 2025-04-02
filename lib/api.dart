import 'dart:convert';
import 'package:http/http.dart' as http;
import './ba.dart';

final a = String.fromCharCodes(Ba.abtoa("a([0c\$)u:j!w:\$!w:\$!x.nh5eg=="));
final base = "https://$a/xbook";

Future<Map<String, dynamic>> search(String keyword, int page, List<String> languages, List<String> extensions) async {
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
    "headers": {"cookie": ""},
    "params": params,
  });
  print("request: $body");

  var response = await http.post(
    Uri.parse(base),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  var statusCode = response.statusCode;
  var result = const Utf8Decoder().convert(response.bodyBytes);
  print("response: $statusCode : $result");

  return jsonDecode(result);
}

Future<Map<String, dynamic>> detail(String url) async {

  var body = jsonEncode({
    "method": "GET",
    "url": "$url",
    "headers": {"cookie": ""},
  });
  print("request: $body");

  var response = await http.post(
    Uri.parse(base),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  var statusCode = response.statusCode;
  var result = const Utf8Decoder().convert(response.bodyBytes);
  print("response: $statusCode : $result");

  return jsonDecode(result);
}
