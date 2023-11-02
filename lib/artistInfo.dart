import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/artistInfo.dart';
import 'baseBar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'userModel.dart';
import 'package:provider/provider.dart';

class ArtistInfo extends StatefulWidget {
  final DocumentSnapshot doc;
  final String artistImg;

  ArtistInfo(this.doc, this.artistImg, {super.key});

  @override
  State<ArtistInfo> createState() => _ArtistInfoState();
}

class _ArtistInfoState extends State<ArtistInfo> {
  FirebaseFirestore fs = FirebaseFirestore.instance;

  bool _followerFlg = false; // 팔로우 했는지!
  String? _userId;
  bool scheduleFlg = false;
  int? folCnt; // 팔로워
  //////////////세션 확인//////////
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _followerCount(); // 팔로우count
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {

    } else {
      print("dpdpdpdp");
      _userId = userModel.userId;
      _followCheck();
    }
  }

  // 팔로우COUNT 불러오기
  void _followerCount() async {
    print("여기?");
    final CollectionReference artistCollection = FirebaseFirestore.instance.collection('artist');
    final DocumentReference artistDocument = artistCollection.doc(widget.doc.id);

    artistDocument.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // 문서가 존재하는 경우 필드 가져오기
        folCnt = documentSnapshot['followerCnt'];
      } else {
        folCnt = 0;
      }
    }).catchError((error) {
      print('데이터 가져오기 중 오류 발생: $error');
    });

  }

  //////////////팔로우 확인/////////////
  void _followCheck() async {
    final followYnSnapshot = await fs
        .collection('artist')
        .doc(widget.doc.id)
        .collection('follower')
        .where('userId',isEqualTo: _userId)
        .get(); // 데이터를 검색하기 위해 get()를 사용합니다.

    if(followYnSnapshot.docs.isNotEmpty){
      _followerFlg = true;
    } else {
      _followerFlg = false;
    }
    _followerCount(); // 팔로우count
  }
  
  ///// 팔로우 하기
  void _followAdd() async{
    CollectionReference followAdd = fs
        .collection('artist')
        .doc(widget.doc.id)
        .collection('follower');


    await followAdd.add({
      'userId' : _userId,
    });

    DocumentReference artistDoc = fs.collection('artist').doc(widget.doc.id);
    artistDoc.update({
      'followerCnt': FieldValue.increment(1), // 1을 증가시킵니다.
    });

    _followCheck();

  }

  // 팔로우 취소
  void _followDelete() async {
    CollectionReference followDelete = fs
        .collection('artist')
        .doc(widget.doc.id)
        .collection('follower');

    // 팔로우 관계를 삭제합니다.
    QuerySnapshot querySnapshot = await followDelete
        .where('userId', isEqualTo: _userId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        // 해당 사용자와 관련된 문서를 삭제합니다.
        await document.reference.delete();
      }
    }

    DocumentReference artistDoc = fs.collection('artist').doc(widget.doc.id);
    artistDoc.update({
      'followerCnt': FieldValue.increment(-1), // 1을 감소시킵니다.
    });

    _followCheck();
  }



  /////////////////상세 타이틀///////////////
  Widget _infoTitle(){
    return Stack( // 이부분만 따로 묶어서 관리하기
      children: [
        Image.network(
          widget.artistImg,
          width: double.infinity, // 화면에 가로로 꽉 차게 하려면 width를 화면 너비로 설정합니다.
          height: 300, // 원하는 높이로 설정합니다.
          fit: BoxFit.fill, // 이미지를 화면에 맞게 채우도록 설정합니다.
        ),
        Positioned(
            left: 5,
            bottom: 5,
            child: Column(
              children: [
                Text('${widget.doc['artistName']}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                Text('${widget.doc['genre']}'),
              ],
            )
        ),
        Positioned(
            right: 5,
            bottom: 5,
            child: Row(
              children: [
                Stack(
                  children: [
                    if(_followerFlg)
                      IconButton(
                          onPressed: (){
                            setState(() {
                              _followDelete();
                            });
                          },

                          icon: Icon(Icons.person_add)
                      ),

                    if(!_followerFlg)
                      IconButton(
                          onPressed: (){
                            setState(() {
                              _followAdd();
                            });
                          },

                          icon: Icon(Icons.person_add_alt)
                      ),
                    Positioned(
                      right: 1,
                      top: 1,
                        child: Text(folCnt.toString())
                    ),
                  ],
                )
              ],
            )
        ),
      ],
    );
  }


////////////////////////////////아이스트 소개/////////////////////////////////////////
  // 아티스트 소개 데이터호출 위젯
  Future<List<Widget>> _artistDetails() async {
    final membersQuerySnapshot = await fs
        .collection('artist')
        .doc(widget.doc.id)
        .collection('team_members')
        .get(); // 데이터를 검색하기 위해 get()를 사용합니다.

    List<Widget> memberWidgets = [];


    if(membersQuerySnapshot.docs.isNotEmpty){
      for (QueryDocumentSnapshot membersDoc in membersQuerySnapshot.docs)  {

        String memberPosition = membersDoc['position']; // 팀 포지션

        // userList 접근하는 쿼리문
        final userListJoin = await fs
            .collection("userList")
            .where(FieldPath.documentId, isEqualTo: membersDoc['userId']).get();

        if(userListJoin.docs.isNotEmpty){
          for(QueryDocumentSnapshot userDoc in userListJoin.docs){
            String userName = userDoc['name']; // 이름
            final userImage = await fs
                .collection('userList')
                .doc(userDoc.id)
                .collection('image').get();

            if(userImage.docs.isNotEmpty){
              for(QueryDocumentSnapshot userImg in userImage.docs){
                String userImage = userImg['PATH'];

                // 예시: ListTile을 사용하여 팀 멤버 정보를 보여주는 위젯을 만듭니다.
                Widget memberWidget = ListTile(
                  leading: Image.network(userImage),
                  title: Text(userName),
                  subtitle: Text(memberPosition),
                  // 다른 정보를 표시하려면 여기에 추가하세요.
                );

                memberWidgets.add(memberWidget);
              }
            }
          }
        }
      }
      return memberWidgets;
    } else {
      return [Container()];
    }

  }

  // 아티스트 소개 탭
  Widget tab1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.doc['artistInfo']),
        ),
        SizedBox(height: 50,),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '기본공연비(공연시간 30분기준)',
                style: TextStyle(fontSize: 15),
              ),
              Text(
                '${widget.doc['basicPrice']} 원',
                style: TextStyle(fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
        Divider(thickness: 1, height: 1,color: Colors.grey),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("멤버",style: TextStyle(fontSize: 20),),
        ),

      ],

    );
  }


  ////////////////////////////////아티스트 클립////////////////////////////////




//////////////////////////////아티스트 공연 일정//////////////////////////////////

  // 버스킹 공연일정
  Future<List<Widget>> _buskingSchedule() async {
    List<Widget> buskingScheduleWidgets = []; // 출력한 위젯 담을 변수
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // 버스킹 일정 확인
    final buskingScheduleSnapshot = await fs
        .collection('busking')
        .where('artistId', isEqualTo: widget.doc.id).get();

    // 버스킹 일정
    if(buskingScheduleSnapshot.docs.isNotEmpty){
      for(QueryDocumentSnapshot buskingSchedule in buskingScheduleSnapshot.docs){
        String title = buskingSchedule['title'];
        // yyyy-MM-dd HH:mm:ss
        String date = DateFormat('MM-dd(EEEE) HH:mm', 'ko_KR').format(buskingSchedule['buskingStart'].toDate());
        final buskingImage = await fs
            .collection('busking')
            .doc(buskingSchedule.id)
            .collection('image').get();
        if(buskingImage.docs.isNotEmpty){
          for(QueryDocumentSnapshot buskingImg in buskingImage.docs){
            String img = buskingImg['path'];
            
            final buskingSpotSnapshot = await fs
                .collection('busking_spot')
                .where(FieldPath.documentId, isEqualTo: buskingSchedule['spotId']).get();
            for(QueryDocumentSnapshot buskingSpot in buskingSpotSnapshot.docs){
              String addr = buskingSpot['spotName'];



              Widget buskingScheduleWidget = Card(
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(img, width: screenWidth * 0.2, height: screenHeight * 0.1, fit: BoxFit.cover),
                      SizedBox(width: 10),
                      Container(

                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                addr,
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                date,
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              );

              buskingScheduleWidgets.add(buskingScheduleWidget);
            }

          }
        }

      }
      
      return buskingScheduleWidgets; // 출력할 위젯
    } else {
      return [Container(child: Text("공연일정이 없습니다."),)];
    }
  }


  //상업공간 공연 일정
  Future<List<Widget>> _commerSchedule() async {
    List<Widget> buskingScheduleWidgets = []; // 출력한 위젯 담을 변수
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 상업공간 컬렉션 접근
    final commerSnapshot = await fs
        .collection('commercial_space')
        .get();
    if(commerSnapshot.docs.isNotEmpty){
      for(QueryDocumentSnapshot commerDoc in commerSnapshot.docs){

        final commerScheduleSnapshot = await fs
            .collection('commercial_space')
            .doc(commerDoc.id)
            .collection('rental')
            .where('artistId', isEqualTo: widget.doc.id).get();

        if(commerScheduleSnapshot.docs.isNotEmpty){
          for(QueryDocumentSnapshot commerScheduleDoc in commerScheduleSnapshot.docs){

            if(commerScheduleDoc['acceptYn'] == "y"){
              String startDate = DateFormat('MM-dd(EEEE) HH:mm', 'ko_KR').format(commerScheduleDoc['startTime'].toDate());
              String endDate = DateFormat(' ~ HH:mm').format(commerScheduleDoc['endTime'].toDate());
              String spaceName = commerDoc['spaceName'];
              
              final commerImageSnapshot = await fs
                  .collection('commercial_space')
                  .doc(commerDoc.id)
                  .collection('image').get();

              if(commerImageSnapshot.docs.isNotEmpty){
                for(QueryDocumentSnapshot commerImageDoc in commerImageSnapshot.docs){
                  String cmmerImg = commerImageDoc['path'];

                  final commerAddrSnapshot = await fs
                      .collection('commercial_space')
                      .doc(commerDoc.id)
                      .collection('addr').get();
                  if(commerAddrSnapshot.docs.isNotEmpty){
                    for(QueryDocumentSnapshot commerAddrDoc in commerAddrSnapshot.docs){
                      String addr = commerAddrDoc['addr'];

                      Widget buskingScheduleWidget = Card(
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(cmmerImg, width: screenWidth * 0.2, height: screenHeight * 0.1, fit: BoxFit.cover),
                              SizedBox(width: 10),
                              Container(

                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          spaceName,
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10,),
                                        Text(
                                          addr,
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          startDate + endDate,
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                              ),

                            ],
                          ),
                        ),
                      );


                      buskingScheduleWidgets.add(buskingScheduleWidget);


                    }
                  }

                }
              }

              return buskingScheduleWidgets;
            } else{
              return [Container()];
            }
          }
        }
      }
    }

    return [Container()];
  }


  /////////////////////클립///////////////////////////
  Future<List<Widget>> _artistCLips() async {
    List<Widget> artistClipsWidget = []; // 출력한 위젯 담을 변수
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 아티스트 클립이미지
    final artistImagesSnapshot = await fs
        .collection('artist')
        .doc(widget.doc.id)
        .collection('images')
        .get();
    if(artistImagesSnapshot.docs.isNotEmpty){
      for(QueryDocumentSnapshot artistImagesDoc in artistImagesSnapshot.docs) {
        String images = artistImagesDoc['path'];


      }
      return [Container()];
    }
    return [Container()];
  }
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) {
              return IconButton(
                color: Colors.black54,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
              );
            },
          ),
          title: Center(
            child: Text(
              "${widget.doc['artistName']}",
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  color: Colors.black54,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.menu),
                );
              },
            )
          ],
          backgroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(text: '소개'),
              Tab(text: '공연일정'),
              Tab(text: '클립'),
            ],
            onTap: (int index) {
              if (index == 0) {
                setState(() {

                });
              } else if (index == 1) {
                setState(() {


                });
              }
            },
            unselectedLabelColor: Colors.black,
            labelColor: Colors.blue,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          elevation: 1,
        ),
        drawer: MyDrawer(),
        body: TabBarView(

          children: [
            ListView( // 소개 탭
              children: [
                Container(
                  child: FutureBuilder(
                    future: _artistDetails(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Column(
                          children: [
                            _infoTitle(),
                            tab1(),
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              margin: EdgeInsets.all(20),
                              child: Column(
                                children: snapshot.data ?? [Container()],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                )
              ],
            ),
            //////////////공연 일정 탭////////////
            ListView(//////////////공연 일정 탭////////////
              children: [
                Container(
                  child: FutureBuilder(
                    future: scheduleFlg ? _buskingSchedule() : _commerSchedule(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> scheduleSnap) {
                      if (scheduleSnap.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (scheduleSnap.hasError) {
                        return Text('Error: ${scheduleSnap.error}');
                      } else {
                        return Column(
                          children: [
                            _infoTitle(),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    child:Center(
                                      child: TextButton(
                                        onPressed: (){
                                          setState(() {
                                            scheduleFlg = true;
                                          });
                                        },
                                        child: Text("버스킹",style: TextStyle(color: Colors.grey),),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    child:Center(
                                      child: TextButton(
                                        onPressed: (){
                                          setState(() {
                                            scheduleFlg = false;
                                          });
                                        },
                                        child: Text("상업공간",style: TextStyle(color: Colors.grey),),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              margin: EdgeInsets.all(20),
                              child: Column(
                                children: scheduleSnap.data ?? [Container()],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                )
              ],
            ),
            ///////////클립 탭/////////////
            Column( ///////////클립 탭/////////////
              children: [

                Text("클립"),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
