import 'package:flutter/material.dart';
import 'package:flutter_m/common.dart';
import 'package:flutter_m/session.dart';
import '../api.dart' as api;
import './login.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<StatefulWidget> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  var _actions = ["云同步本地", "设置", "意见反馈", "支持我们"];

  var _nickname = "";
  var _email = "";

  @override
  void initState() {
    super.initState();
    if (Common.getData(Common.login_key) != "") {
      api.profile().then((t) {
        if (t.a == 0) {
          setState(() {
            var data = t.c;
            _nickname = data["nickname"] ?? "";
            _email = data["email"] ?? "";
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Center(
        child: Column(
          children: [
            if (Common.getData(Common.login_key) == "")
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text("去登录"),
                      ),
                    ),
                  ],
                ),
              )
            else if (Common.getData(Common.login_key) != "")
              Column(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            minRadius: 60.0,
                            child: Text(
                              _nickname.length > 1 ? _nickname[0] : "",
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(_nickname, style: TextStyle(fontSize: 24)),
                                Text(_email, style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(20),
                            width: MediaQuery.of(context).size.width - 10,
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: _actions.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    print("action : ${_actions[index]}");
                                  },
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 40,
                                    child: Text(
                                      _actions[index],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              SessionManager.setSession("");
                              Common.setData(Common.login_key, "");
                            },
                            child: Text("退出登录"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
