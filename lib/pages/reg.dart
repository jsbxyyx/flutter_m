import 'package:flutter/material.dart';
import 'package:flutter_m/common.dart';
import '../api.dart' as api;
import './login.dart';
import './forget.dart';

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("注册")),
      body: SingleChildScrollView(
        child: Card(
          margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '用户名',
                      hintText: "请输入邮箱",
                    ),
                    validator: (v) {
                      if (v == null || v.toString().trim() == "") {
                        return "请输入邮箱";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '昵称',
                      hintText: "请输入昵称",
                    ),
                    validator: (v) {
                      if (v == null || v.toString().trim() == "") {
                        return "请输入昵称";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '密码',
                      hintText: "请输入密码",
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.toString().trim() == "") {
                        return "请输入密码";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: '验证码',
                            hintText: "请输入验证码",
                          ),
                          validator: (v) {
                            if (v == null || v.toString().trim() == "") {
                              return "请输入验证码";
                            }
                            return null;
                          },
                        ),
                      ),
                      ElevatedButton(onPressed: () {}, child: Text("获取验证码")),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {

                      }
                    },
                    child: Text('注册'),
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
                      "有账号，去登录",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgetPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      "忘记密码",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}