import 'package:flutter/material.dart';
import 'package:flutter_m/common.dart';
import '../api.dart' as api;
import './detail.dart';

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