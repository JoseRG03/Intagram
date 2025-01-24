import 'package:flutter/material.dart';
import 'package:intec_social_app/views/screens/app/camera/camera-page.dart';
import 'package:intec_social_app/views/screens/app/home/home-app.dart';
import 'package:intec_social_app/views/screens/app/profile/profile.dart';

class HomePageWrapper extends StatefulWidget {
  const HomePageWrapper({super.key});

  @override
  State<HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  int currentPage = 0;

  List<Widget> allPages = [
    FeedPage(),
    UploadPostScreen(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Intagram'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).pushNamed('/chat');

          }, icon: Icon(Icons.chat))
        ],
      ),
      body: allPages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (index) {
            setState(() {
              currentPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Home",
            ),
          ]),
    );
  }
}
