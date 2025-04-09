import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class GamepadPage extends StatefulWidget {
  const GamepadPage({super.key});

  @override
  State<StatefulWidget> createState() => _GamepadState2();
}

class _GamepadState2 extends State<GamepadPage>
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
                        _buildDirectionButton("↑", "UP"),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDirectionButton('←', "LEFT"),
                            SizedBox(width: 48),
                            _buildDirectionButton('→', "RIGHT"),
                          ],
                        ),
                        _buildDirectionButton("↓", "DOWN"),
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
                    Text("MQTT服务器", style: TextStyle(color: Colors.white)),
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
