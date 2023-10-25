import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
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
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Container(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('iu.jpg'), // 프로필 이미지
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("아이유", style: TextStyle(color: Colors.white, fontSize: 18),),
                    Text("qwer@naver.com",style: TextStyle(color: Colors.white))
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(color: Colors.lightBlue),
          ),

          ExpansionTile(
            title: Text('MENU',style: TextStyle(fontWeight: FontWeight.bold),),
            children: <Widget>[
              ListTile(
                title: Text('공지사항'),
                onTap: () {

                },
              ),
              ListTile(
                title: Text('공연일정'),
                onTap: () {

                },
              ),
              ListTile(
                title: Text('후원내역조회'),
                onTap: () {

                },
              ),
              ListTile(
                title: Text('아티스트 등록'),
                onTap: () {

                },
              ),
              ListTile(
                title: Text('사업자 등록'),
                onTap: () {

                },
              ),
            ],
          ),
          ExpansionTile(
            title: Text('ARTIST MENU',style: TextStyle(fontWeight: FontWeight.bold)),
            children: <Widget>[
              ListTile(
                title: Text('공지사항'),
                onTap: () {

                },
              ),
              ListTile(
                title: Text('팀·솔로 등록/관리'),
                onTap: () {

                },
              ),
              ExpansionTile(
                  title: Text("지하철역 버스킹존"),
                  children: [
                    ListTile(
                      title: Text("이용 신청"),
                      onTap: () {

                      },
                    ),
                    ListTile(
                      title: Text("내 공연 일정"),
                      onTap: () {

                      },
                    ),
                    ListTile(
                      title: Text("위치 안내"),
                      onTap: () {

                      },
                    ),
                  ],
                ),
              ExpansionTile(
                title: Text("지자체 버스킹존"),
                children: [
                  ListTile(
                    title: Text("이용 신청"),
                    onTap: () {

                    },
                  ),
                  ListTile(
                    title: Text("내 공연 일정"),
                    onTap: () {

                    },
                  ),
                  ListTile(
                    title: Text("위치 안내"),
                    onTap: () {

                    },
                  ),
                ],
              ),
              ListTile(
                title: Text('공연 신청'),
                onTap: () {

                },
              ),
              ListTile(
                title: Text('공연 신청 관리'),
                onTap: () {

                },
              ),
              ListTile(
                title: Text('아티스트 정보 수정'),
                onTap: () {

                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class MyBottomBar extends StatefulWidget {
  const MyBottomBar({super.key});

  @override
  State<MyBottomBar> createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
      height: 70,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            /*onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ),
                        );
                      },*/
            child: Image.asset('assets/mic.png',width: 23,),
          ),
          InkWell(
            /*onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ),
                        );
                      },*/
            child: Icon(Icons.calendar_month_outlined,color: Colors.black54,),
          ),
          InkWell(
            /*onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ),
                        );
                      },*/
            child: Icon(Icons.home_outlined),
          ),
          InkWell(
            /*onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ),
                        );
                      },*/
            child: Icon(Icons.play_circle_outline),
          ),
          InkWell(
            /*onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ),
                        );
                      },*/
            child: Icon(Icons.person),
            )
          ]
        )
      )
    );
  }
}
