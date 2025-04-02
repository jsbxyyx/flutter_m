import 'package:flutter/material.dart';
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
                  _search = true;
                  if (_keyword.trim() == "") {
                    _keyword = _hint;
                  }
                  api.search(_keyword, 1, [], []).then((response) {
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
                      _list.addAll(response["data"]["list"]);
                    });
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _list.length,
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
                      )
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
                  fontSize: 24.0,
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
