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


  var _nickname = "";
  var _email = "";

  var _isLogin = false;

  var _actions = {
    "云同步本地": () => {},
    "设置": () => {},
    "意见反馈": () => {},
    "支持我们": () => {}
  };


  void _cloudSync() {

  }

  void _settings() {

  }

  @override
  void initState() {
    super.initState();
    if (Common.getData(Common.login_key) != "") {
      if (Common.getData(Common.profile_email_key) != "" &&
          Common.getData(Common.profile_nickname_key) != "") {
        setState(() {
          _nickname = Common.getData(Common.profile_nickname_key);
          _email = Common.getData(Common.profile_email_key);
        });
      } else {
        api.profile().then((t) {
          if (t.a == 0) {
            var data = t.c;
            setState(() {
              _nickname = data["nickname"] ?? "";
              _email = data["email"] ?? "";
            });
            Common.setData(Common.profile_nickname_key, data["nickname"] ?? "");
            Common.setData(Common.profile_email_key, data["email"] ?? "");
          }
        });
      }
    }
    setState(() {
      _isLogin = (Common.getData(Common.login_key) != "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Center(
        child: Column(
          children: [
            if (!_isLogin)
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
            else if (_isLogin)
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
                              itemCount: _actions.keys.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    print("action : ${_actions.keys.map((e) => e).toList()[index]}");
                                  },
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 40,
                                    child: Text(
                                      _actions.keys.map((e) => e).toList()[index],
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
                              setState(() {
                                _isLogin = false;
                              });
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
