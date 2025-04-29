import 'package:flutter/material.dart';
import './home.dart';
import './mine.dart';

class MainNavigatorWidget extends StatefulWidget {
  const MainNavigatorWidget({super.key});

  @override
  State<StatefulWidget> createState() => _MainNavigatorWidgetState();
}

class _MainNavigatorWidgetState extends State<MainNavigatorWidget> {
  int _currentIndex = 0;

  final _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [HomePage(), MinePage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        items:
        datas.map((data) {
          return BottomNavigationBarItem(
            icon: Icon(data.icon, color: Colors.grey),
            activeIcon: Icon(data.icon, color: Colors.purple),
            label: data.title,
            backgroundColor:
            _currentIndex == data.index ? Colors.purple : Colors.grey,
          );
        }).toList(),
      ),
    );
  }
}

class TabData {
  const TabData({required this.index, required this.title, required this.icon});

  final String title;
  final IconData icon;
  final int index;
}

const List<TabData> datas = <TabData>[
  TabData(index: 0, title: '首页', icon: Icons.home),
  TabData(index: 1, title: '我的', icon: Icons.person),
];