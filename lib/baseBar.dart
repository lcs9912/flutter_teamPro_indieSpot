import 'package:flutter/material.dart';
import 'package:indie_spot/adminInquiry.dart';
import 'package:indie_spot/adminMain.dart';
import 'package:indie_spot/announcementList.dart';
import 'package:indie_spot/artistInfo.dart';
import 'package:indie_spot/artistRegi.dart';
import 'package:indie_spot/buskingList.dart';
import 'package:indie_spot/buskingSpotList.dart';
import 'package:indie_spot/dialog.dart';
import 'package:indie_spot/donationArtistList.dart';
import 'package:indie_spot/donationList.dart';
import 'package:indie_spot/login.dart';
import 'package:indie_spot/main.dart';
import 'package:indie_spot/profile.dart';
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
import 'package:get/get.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {

  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text("IndieSpot", style: TextStyle(color: Color(0xFFFFFFFF)),),
        elevation: 0,
        backgroundColor: Color(0xFF233067),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: (){
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu),color: Colors.white),
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
          imageProvider = NetworkImage(imgData?['PATH']);
        });
      }else{imageProvider = NetworkImage(imgData?['PATH']);}
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
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyApp(),));
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
                  Get.to(
                    AnnouncementList(),
                    preventDuplicates: true,
                    transition: Transition.noTransition
                  );
                },
              ),
              ListTile(
                title: Text('공연일정'),
                onTap: () {
                  Get.to(
                    BuskingList(),
                    preventDuplicates: true,
                    transition: Transition.noTransition
                  );
                },
              ),
              ListTile(
                title: Text('후원하기'),
                onTap: () {
                  if(_userId != null){
                    Get.to(
                      DonationArtistList(), //이동하려는 페이지
                      preventDuplicates: true, //중복 페이지 이동 방지
                      transition: Transition.noTransition //이동애니메이션off
                    );
                  }else{
                    DialogHelper.showUserRegistrationDialog(context);
                  }
                },
              ),
              ListTile(
                title: Text('후원내역조회'),
                onTap: () {
                  if(_userId != null){
                    Get.to(
                      UserDonationHistory(),
                      preventDuplicates: true,
                      transition: Transition.noTransition
                    );
                  }else{
                    DialogHelper.showUserRegistrationDialog(context);
                  }
                },
              ),
              ListTile(
                title: Text('받은 후원 내역'),
                onTap: () {
                  if(_artistId != null){
                    Get.to(
                      DonationList(artistId: _artistId!,),
                      preventDuplicates: true,
                      transition: Transition.noTransition
                    );
                  }else{
                    DialogHelper.showArtistRegistrationDialog(context);
                  }
                },
              ),
              ListTile(
                title: Text('아티스트 등록'),
                onTap: () {
                  var user = Provider.of<UserModel>(context, listen: false);
                  if(user.isArtist){
                    Get.to(
                      ArtistInfo(user.artistId!),
                      preventDuplicates: true,
                      transition: Transition.noTransition
                    );
                  } else {
                    Get.to(
                      ArtistRegi(),
                      preventDuplicates: true,
                      transition: Transition.noTransition
                    );
                  }
                },
              ),
              ListTile(
                title: Text('사업자 등록'),
                onTap: () {
                  if(_userId != null) {
                     Get.to(
                       ProprietorAdd(),
                       preventDuplicates: true,
                       transition: Transition.noTransition
                     );
                  }else{
                    DialogHelper.showUserRegistrationDialog(context);
                  }
                },
              ),
              ListTile(
                title: Text('고객센터'),
                onTap: () {
                  Get.to(
                    Support(),
                    preventDuplicates: true,
                    transition: Transition.noTransition
                  );
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
                  Get.to(
                    AdminMain(),
                    preventDuplicates: true,
                    transition: Transition.noTransition
                  );
                },
              ),
              ListTile(
                title: Text('팀·솔로 관리'),
                onTap: () {
                  // Get.to(
                  //   ArtistInfo(doc, artistImg)
                  // );
                },
              ),
              ListTile(
                title: Text('버스킹존'),
                onTap: () {
                  Get.to(
                    BuskingZoneList(),
                    preventDuplicates: true,
                    transition: Transition.noTransition
                  );
                },
              ),
              ListTile(
                title: Text('상업 공간'),
                onTap: () {
                  Get.to(
                    CommercialList(),
                    preventDuplicates: true,
                    transition: Transition.noTransition
                  );
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
                      Get.to(
                        RenTalHistory(),
                        preventDuplicates: true,
                        transition: Transition.noTransition
                      );
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
                      Get.to(
                        ArtistList(),
                        preventDuplicates: true,
                        transition: Transition.noTransition
                      );
                    },
                    child: Image.asset('assets/mic.png',width: 23,),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(
                        BuskingList(),
                        preventDuplicates: true,
                        transition: Transition.noTransition
                      );
                    },
                    child: Icon(Icons.calendar_month_outlined,color: Colors.black54,),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(
                          MyApp(),
                          preventDuplicates: true,
                          transition: Transition.noTransition
                      );
                    },
                    child: Icon(Icons.home_outlined,color: Colors.black54,),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(
                        VideoList(),
                        preventDuplicates: true,
                        transition: Transition.noTransition
                      );
                    },
                    child: Icon(Icons.play_circle_outline,color: Colors.black54,),
                  ),
                  InkWell(
                    onTap: () {
                      var user = Provider.of<UserModel>(context, listen: false);
                      if(user.isLogin) {
                        Get.to(
                          Profile(
                              userId: user.userId,
                          ),
                          preventDuplicates: true,
                          transition: Transition.noTransition
                        );
                      } else{
                        DialogHelper.showUserRegistrationDialog(context);
                      }
                    },
                    child: Icon(Icons.person,color: Colors.black54,),
                  )
                ]
            )
        )
    );
  }
}