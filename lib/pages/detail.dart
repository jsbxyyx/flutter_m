import 'package:flutter/material.dart';
import 'package:flutter_m/common.dart';
import '../api.dart' as api;

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