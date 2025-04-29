import 'package:flutter/material.dart';
import '../common.dart';
import '../session.dart';
import '../api.dart' as api;
import './reg.dart';
import './main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("登录")),
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: '用户名',
                      hintText: "请输入用户名或邮箱",
                    ),
                    validator: (v) {
                      if (v == null || v.toString().trim() == "") {
                        return "请输入用户名或邮箱";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Handle login logic here
                      if (_formKey.currentState!.validate()) {
                        var email = _emailController.text;
                        var password = _passwordController.text;
                        var t = await api.login(email, password);
                        if (t.a != 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(t.b),
                            ),
                          );
                          return;
                        }
                        var session = t.c;
                        SessionManager.setSession(session);
                        Common.setData(Common.login_key, session);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return MainNavigatorWidget();
                            },
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: Text('登录'),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegPage()),
                      );
                    },
                    child: Text(
                      "还没有账号，去注册",
                      style: TextStyle(color: Colors.blue),
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
