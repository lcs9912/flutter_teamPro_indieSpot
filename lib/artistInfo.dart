import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/artistInfo.dart';
import 'baseBar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ArtistInfo extends StatefulWidget {
  final DocumentSnapshot doc;
  final String artistImg;

  ArtistInfo(this.doc, this.artistImg, {super.key});

  @override
  State<ArtistInfo> createState() => _ArtistInfoState();
}

class _ArtistInfoState extends State<ArtistInfo> {
  FirebaseFirestore fs = FirebaseFirestore.instance;

  String? _test;

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
                    Text(widget.doc['followerCnt'].toString()),
                    IconButton(onPressed: (){}, icon: Icon(Icons.person_add_alt)),
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
            _test = userDoc['nick'];
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
      print('잘넘어오는중');
      return memberWidgets;
    } else {
      print('안넘어오는중');
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
                '${widget.doc['donationAmount']} 원',
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

    // 버스킹 일정 확인
    final buskingScheduleSnapshot = await fs
        .collection('busking')
        .where('artistId', isEqualTo: widget.doc.id).get();

    // 버스킹 일정
    if(buskingScheduleSnapshot.docs.isNotEmpty){
      for(QueryDocumentSnapshot buskingSchedule in buskingScheduleSnapshot.docs){
        String title = buskingSchedule['title'];
        // yyyy-MM-dd HH:mm:ss
        String date = DateFormat('yyyy-MM-dd(EEEE) HH:mm', 'ko_KR').format(buskingSchedule['buskingStart'].toDate());
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
                child: Column(
                  children: [
                    Image.network(img,fit: BoxFit.cover,),
                    ListTile(
                      title: Text(title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(addr),
                          Text(date),
                        ],
                      ),
                    ),
                    // 다른 정보를 표시하려면 여기에 추가하세요.
                  ],
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
              Tab(text: '클립'),
              Tab(text: '공연일정'),
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
            ///////////클립 탭/////////////
            Column( ///////////클립 탭/////////////
              children: [
                _infoTitle(),
                Text("클립"),

              ],
            ),
            //////////////공연 일정 탭////////////
            ListView(//////////////공연 일정 탭////////////
              children: [
                Container(
                  child: FutureBuilder(
                    future: _buskingSchedule(),
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
          ],
        ),
      ),
    );
  }
}
