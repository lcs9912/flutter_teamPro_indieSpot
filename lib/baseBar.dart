import 'package:flutter/material.dart';
import 'package:indie_spot/adminInquiry.dart';
import 'package:indie_spot/adminMain.dart';
import 'package:indie_spot/announcementList.dart';
import 'package:indie_spot/buskingList.dart';
import 'package:indie_spot/buskingSpotList.dart';
import 'package:indie_spot/dialog.dart';
import 'package:indie_spot/donationArtistList.dart';
import 'package:indie_spot/donationList.dart';
import 'package:indie_spot/login.dart';
import 'package:indie_spot/main.dart';
import 'package:indie_spot/proprietorIdAdd.dart';
import 'package:indie_spot/rentalHistory.dart';
import 'package:indie_spot/support.dart';
import 'package:indie_spot/userDonationHistory.dart';
import 'package:indie_spot/userModel.dart';
import 'package:indie_spot/videoAdd.dart';
import 'package:indie_spot/videoList.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'artistEdit.dart';
import 'artistList.dart';
import 'commercialList.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {

  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text("indieSpot"),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
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

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String? _userId;
  Map<String,dynamic>? userData;
  Map<String,dynamic>? imgData;
  ImageProvider<Object>? imageProvider;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  String? _artistId = "";
  bool _artistLeader = false;
  DocumentSnapshot? doc;
  DocumentSnapshot? artistDoc;
  String? artistImg;
  @override
  void initState(){
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {

    } else {
      _userId = userModel.userId;
      userInfo();
      if(!userModel.isArtist){
        _artistId = userModel.artistId;
      }
    }
  }
  void userInfo() async{
    DocumentSnapshot user = await fs.collection("userList").doc(_userId).get();
    if(user.exists){
      setState(() {
        userData = user.data() as Map<String,dynamic>;
      });
      QuerySnapshot userImg = await fs.collection("userList").doc(_userId).collection("image").get();
      if(userImg.docs.isNotEmpty){
        setState(() {
          imgData = userImg.docs.first.data() as Map<String,dynamic>;
          imageProvider = NetworkImage(imgData?['PATH']) as ImageProvider<Object>?;
        });
      }else{imageProvider = NetworkImage(imgData?['PATH']) as ImageProvider<Object>?;}
    }
  }

  Widget _userInfo(){
    if(_userId==null){
      return DrawerHeader(
        decoration: BoxDecoration(color: Colors.black12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: Container(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/기본.jpg'), // 프로필 이미지
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("로그인을 해주세요.", style: TextStyle(color: Colors.black54, fontSize: 18,fontWeight: FontWeight.bold),),
                Row(
                  children: [
                    Icon(Icons.lock_outline,size: 20),
                    TextButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                        },
                        child: Text("로그인")
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      );
    }
    return DrawerHeader(
      decoration: BoxDecoration(color: Colors.black12),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Container(
              child: CircleAvatar(
                radius: 40,
                backgroundImage:imageProvider, // 프로필 이미지
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${userData?['nick']}", style: TextStyle(color: Colors.black54, fontSize: 18,fontWeight: FontWeight.bold),),
              Row(
                children: [
                  Icon(Icons.logout,size: 20),
                  TextButton(
                      onPressed: (){
                        setState(() {
                          Provider.of<UserModel>(context, listen: false).logout();
                          Navigator.pop(context);
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // 패딩 조정
                        // 다른 스타일 속성들도 추가할 수 있습니다.
                      ),
                      child: Text("로그아웃")),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          _userInfo(),

          ExpansionTile(
            title: Text('MENU',style: TextStyle(fontWeight: FontWeight.bold),),
            children: <Widget>[
              ListTile(
                title: Text('공지사항'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AnnouncementList(),));
                },
              ),
              ListTile(
                title: Text('공연일정'),
                onTap: () {

                },
              ),
              ListTile(
                title: Text('후원하기'),
                onTap: () {
                  if(_userId != null){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DonationArtistList(),));
                  }else{
                    DialogHelper.showUserRegistrationDialog(context);
                  }
                },
              ),
              ListTile(
                title: Text('후원내역조회'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserDonationHistory(),));
                },
              ),
              ListTile(
                title: Text('받은 후원 내역'),
                onTap: () {
                  if(_artistId != null){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DonationList(artistDoc : doc!),));
                  }else {
                    DialogHelper.showArtistRegistrationDialog(context);
                  }// 아티스트 권한
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
                  if(_userId != null) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ProprietorAdd()));
                  }else{
                    DialogHelper.showUserRegistrationDialog(context);
                  }
                },
              ),
              ListTile(
                title: Text('고객센터'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Support(),)); // Support 클래스로 이동
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdminMain(),));
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => CommercialList(),));
                },
              ),
              ListTile(
                title: Text('공연 신청 관리'),
                onTap: () {

                },
              ),
              ListTile(
                title: Text('장소 예약 내역'),
                onTap: () {
                  if(_userId == null){
                    DialogHelper.showUserRegistrationDialog(context);
                  }else{
                    if(_artistId == null){
                      DialogHelper.showArtistRegistrationDialog(context);
                    }else{
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RenTalHistory(),));
                    }
                  }
                },
              ),
              if(_artistLeader)
                ListTile(
                  title: Text('아티스트 정보 수정'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ArtistEdit(_artistId as DocumentSnapshot<Object?>, artistImg!),)).then((value) => setState(() {}));
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
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(); // 현재 페이지를 제거
                      }

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return MyApp(); // 새 페이지로 이동
                        },
                      ));
                    },
                    child: Icon(Icons.home_outlined,color: Colors.black54,),
                  ),
                  InkWell(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(); // 현재 페이지를 제거
                      }

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return VideoList(); // 새 페이지로 이동
                        },
                      ));
                    },
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