import 'package:flutter/material.dart';
import './login.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<StatefulWidget> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("忘记密码")),
      body: Container(
        child: Card(
          margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: '用户名',
                    hintText: "请输入邮箱",
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: '验证码',
                          hintText: "请输入验证码",
                        ),
                      ),
                    ),
                    ElevatedButton(onPressed: () {}, child: Text("获取验证码")),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: "请输入密码",
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle login logic here
                  },
                  child: Text('重置密码'),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "去登录",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
