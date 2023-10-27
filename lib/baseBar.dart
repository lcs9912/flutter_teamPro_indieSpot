import 'package:flutter/material.dart';
import 'package:indie_spot/buskingList.dart';
import 'package:indie_spot/buskingSpotList.dart';
import 'package:indie_spot/donationPage.dart';

import 'artistList.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("indieSpot"),
      backgroundColor: Colors.white,
      actions: [
        IconButton(
            onPressed: (){

            },
            icon: Icon(Icons.person),color: Colors.black54),
        IconButton(
          onPressed: (){
            Scaffold.of(context).openDrawer();
          },
          icon: Icon(Icons.menu),color: Colors.black54),
      ]
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
                    Text("아이유", style: TextStyle(color: Colors.black54, fontSize: 18,fontWeight: FontWeight.bold),),
                    Text("qwer@naver.com",style: TextStyle(color: Colors.black54))
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(color: Colors.black12),
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
                title: Text('후원 페이지'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DonationPage(),));
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
            title: Text('ARTIST MENU',style: TextStyle(fontWeight: FontWeight.bold,)),
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
              ListTile(
                title: Text('버스킹존'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => BuskingZoneList(),));
                },
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArtistList()),
              );
            },
            child: Image.asset('assets/mic.png',width: 23,),
          ),
          InkWell(
            onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BuskingList()),
                        );
                      },
            child: Icon(Icons.calendar_month_outlined,color: Colors.black54,),
          ),
          InkWell(
            /*onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ),
                        );
                      },*/
            child: Icon(Icons.home_outlined,color: Colors.black54,),
          ),
          InkWell(
            /*onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ),
                        );
                      },*/
            child: Icon(Icons.play_circle_outline,color: Colors.black54,),
          ),
          InkWell(
            /*onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ),
                        );
                      },*/
            child: Icon(Icons.person,color: Colors.black54,),
            )
          ]
        )
      )
    );
  }
}
