import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import './api.dart' as api;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _GamepadState2();
}

class _GamepadState2 extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  var _hostController = TextEditingController.fromValue(
    TextEditingValue(text: "broker.emqx.io:1883"),
  );
  var _authController = TextEditingController.fromValue(
    TextEditingValue(text: "emqx:public"),
  );
  var _deviceIDController = TextEditingController.fromValue(
    TextEditingValue(text: "mqttx_123456"),
  );

  late MqttServerClient _mqttClient;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.11,
            ),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255.0 * 0.5).round()),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDirectionButton("上", "UP"),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDirectionButton('左', "LEFT"),
                            SizedBox(width: 48),
                            _buildDirectionButton('右', "RIGHT"),
                          ],
                        ),
                        _buildDirectionButton("下", "DOWN"),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextFormField(
                        controller: _deviceIDController,
                        decoration: InputDecoration(
                          hintText: "请输入连接设备ID",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRoundButton(Colors.green, "B"),
                        SizedBox(width: 30, height: 24),
                        _buildRoundButton(Colors.red, "A"),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("服务器", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _hostController,
                        decoration: InputDecoration(
                          hintText: "MQTT地址 host:port",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _authController,
                        decoration: InputDecoration(
                          hintText: "账号:密码",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          var host = _hostController.text;
                          var auth = _authController.text;

                          List<String> splitHost = host.split(":");
                          List<String> splitAuth = auth.split(":");

                          var clientId =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          print("clientId: $clientId");
                          _mqttClient = MqttServerClient.withPort(
                            splitHost[0],
                            clientId,
                            int.parse(splitHost[1]),
                          );
                          _mqttClient.keepAlivePeriod = 60;
                          _mqttClient.logging(on: true);
                          final connMessage = MqttConnectMessage()
                              .authenticateAs(splitAuth[0], splitAuth[1]);
                          _mqttClient.connectionMessage = connMessage;
                          _mqttClient.onConnected = () {
                            print("clientId:$clientId connected");
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text("连接成功"),
                                ),
                              );
                            });
                          };
                          _mqttClient.connect();
                        },
                        child: Text("连接"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundButton(Color color, String action) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(56, 56),
          shape: const CircleBorder(),
          elevation: 4,
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          _handleAction(action);
        },
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Text(
            color == Colors.red ? 'A' : 'B',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionButton(String label, String action) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          _handleAction(action);
        },
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleAction(String action) {
    print("press $action");
    var builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode({"action": action}));
    var deviceID = _deviceIDController.text;
    _mqttClient.publishMessage(
      "mycar/action/$deviceID",
      MqttQos.exactlyOnce,
      builder.payload!,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final _list = [];
  var _search = false;

  var _hint = "金瓶梅";
  var _keyword = "";

  var _hasNext = false;
  var _hasLoading = false;
  var _page = 1;

  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                decoration: InputDecoration(hintText: _hint),
                onChanged: (str) {
                  setState(() {
                    _keyword = str;
                  });
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _page = 1;
                  _search = true;
                  if (_keyword.trim() == "") {
                    _keyword = _hint;
                  }
                  _refresh();
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _list.length,
              controller: _controller,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    print("index: $index");
                    var item = _list[index];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(arg: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.network(
                          _list[index]["coverImage"]!,
                          width: 100,
                          height: 100,
                          errorBuilder: (
                            BuildContext context,
                            Object exception,
                            StackTrace? trace,
                          ) {
                            return Image.asset(
                              "assets/p404.png",
                              width: 100,
                              height: 100,
                            );
                          },
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_list[index]["title"]!),
                                Text(_list[index]["publisher"]!),
                                Text(_list[index]["file"]!),
                                Text(_list[index]["year"]!),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loadMore() {
    if (_hasNext && !_hasLoading && _controller.position.extentAfter < 50) {
      print("load more...");
      _page += 1;
      _refresh();
    }
  }

  void _refresh() {
    _hasLoading = true;
    api.search(_keyword, _page, [], []).then((response) {
      _hasLoading = false;
      var status = response['status'];
      if (status != 200) {
        var message = response['headers']['X-message'];
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(message ?? "未搜索到结果 $status"),
            ),
          );
        });
        return;
      }
      setState(() {
        if (_search) {
          _list.clear();
          _search = false;
        }
        List<dynamic> list = response["data"]["list"];
        if (list.isNotEmpty) {
          _list.addAll(list);
          _hasNext = true;
        } else {
          _hasNext = false;
        }
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<StatefulWidget> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Mine")));
  }
}

class DetailPage extends StatefulWidget {
  Map<String, dynamic> arg;

  DetailPage({super.key, required this.arg});

  @override
  State<StatefulWidget> createState() => _DetailPageState(arg: this.arg);
}

class _DetailPageState extends State<DetailPage> {
  var arg = <String, dynamic>{};
  var data = <String, dynamic>{
    "bid": "",
    "isbn": "",
    "author": "",
    "title": "",
    "coverImage": "",
    "year": "",
    "publisher": "",
    "language": "",
    "file": "",
    "downloadUrl": "",
  };

  _DetailPageState({required this.arg}) {
    print("arg: $arg");
  }

  @override
  void initState() {
    super.initState();
    api.detail(arg['detailUrl']).then((response) {
      var status = response['status'];
      if (status != 200) {
        var message = response['headers']['X-message'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: message ?? "未找到结果"));
        return;
      }
      setState(() {
        data = response['data'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Column(children: [Text("详情")])),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(5),
          child: Column(
            children: [
              Text(
                data['title'] ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  height: 1.0,
                ),
              ),
              Center(
                child: Image.network(
                  data['coverImage'] ?? "",
                  width: 300,
                  height: 400,
                  errorBuilder: (
                    BuildContext context,
                    Object exception,
                    StackTrace? trace,
                  ) {
                    return Text("图片");
                  },
                ),
              ),
              Text(data['year'] ?? ""),
              Text(data['publisher'] ?? ""),
              Text(data['language'] ?? ""),
              Text(data['isbn'] ?? ""),
              Text(data['file'] ?? ""),
              TextButton(
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(
                    Size(MediaQuery.of(context).size.width * 0.5, 10),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.purple),
                ),
                child: Text("下载", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  if (data['downloadUrl'].toString().trim() == '') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text("请登录后下载"),
                      ),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text("开始下载"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
