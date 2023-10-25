import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("indieSpot"),
      leading: IconButton(
          onPressed: (){
            Scaffold.of(context).openDrawer();
          },
          icon: Icon(Icons.menu)),
    );
  }
}

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: [
                Container(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('iu.jpg'), // 프로필 이미지
                  ),
                ),
                Text("아이유", style: TextStyle(color: Colors.white, fontSize: 18),),
                Text("qwer@naver.com",style: TextStyle(color: Colors.white))
              ],
            ),
            decoration: BoxDecoration(color: Colors.lightBlue),
          ),
          ListTile(
            title: Text("1"),
          )
        ],
      ),
    );
  }
}
