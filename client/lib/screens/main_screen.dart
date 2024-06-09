import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'my_page_screen.dart';
import 'news_screen.dart';
import 'standings_screen.dart';
import 'tournament_ops_screen.dart';
import 'package:openid_client/openid_client.dart';
import '../openid_io.dart' if (dart.library.html) '../openid_browser.dart';
import 'sign_in_screen.dart';
import 'vods_screen.dart';

class MainScreen extends StatefulWidget {
  final bool isOrganizer;
  final UserInfo userInfo;

  MainScreen({Key? key, required this.isOrganizer, required this.userInfo}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      NewsScreen(),
      SearchScreen(userId: widget.userInfo.email!),
      StandingsScreen(),
      VODsScreen(),
      MyPageScreen(userInfo: widget.userInfo, onSignOut: _signOut),
      if (widget.isOrganizer) TournamentOpsScreen(),
    ];
  }

  Future<void> _signOut() async {
    print('Sign out button pressed');
    if (credential != null) {
      print('Credential exists, signing out');
      await signOut(credential!);
    } else {
      print('No credential to sign out');
    }
    setState(() {
      credential = null;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Icon(Icons.article),
        label: 'News',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assessment),
        label: 'Standings',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.video_library),
        label: 'VODs',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'My Page',
      ),
    ];

    if (widget.isOrganizer) {
      items.add(
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Tournament Ops',
        ),
      );
    }

    return items;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OWCS Companion')),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _buildBottomNavBarItems(),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 16,
        onTap: _onItemTapped,
      ),
    );
  }
}
