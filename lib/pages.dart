import 'package:flutter/material.dart';
import 'package:flutter_m/common.dart';
import './api.dart' as api;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
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
    api.search(_keyword, _page, [], []).then((Tuple tuple) {
      _hasLoading = false;
      if (tuple.a != 0) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(tuple.b ?? "未搜索到结果"),
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
        List<dynamic> list = tuple.c;
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
  var _actions = ["云同步本地", "设置", "意见反馈", "支持我们"];
  var _userController = TextEditingController();

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
                              "T",
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text("test", style: TextStyle(fontSize: 24)),
                                Text(
                                  "test@qq.com",
                                  style: TextStyle(fontSize: 16),
                                ),
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
    api.detail(arg['detailUrl']).then((Tuple tuple) {
      if (tuple.a != 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: tuple.b ?? "未找到结果"));
        return;
      }
      setState(() {
        data = tuple.c;
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

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
                    onPressed: () {
                      // Handle login logic here
                      if (!_formKey.currentState!.validate()) {}
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
