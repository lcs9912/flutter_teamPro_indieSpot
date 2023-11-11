import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:indie_spot/boardList.dart';
import 'package:indie_spot/commercialList.dart';
import 'package:indie_spot/donationArtistList.dart';
import 'package:indie_spot/login.dart';
import 'package:indie_spot/pointDetailed.dart';
import 'package:indie_spot/profile.dart';
import 'package:indie_spot/result.dart';
import 'package:indie_spot/spaceInfo.dart';
import 'package:indie_spot/userModel.dart';
import 'package:indie_spot/videoList.dart';
import 'artistInfo.dart';
import 'artistRegi.dart';
import 'buskingList.dart';
import 'buskingReservation.dart';
import 'buskingSpotList.dart';
import 'concertDetails.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'join.dart';
import 'dart:async';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel())
      ],
      child: GetMaterialApp( // GetMaterialApp 사용
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [
          const Locale('ko', 'KR'), // 한국어
          const Locale('en'), // 한국어
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFFffffff), // 전체 페이지의 배경 색상
          fontFamily: 'Noto_Serif_KR', // 폰트 패밀리 이름을 지정
        ),
        getPages: [
          GetPage(name: '/result', page: () => Result()), // GetX에서의 페이지 설정
          GetPage(name: '/pointDetailed', page: () => PointDetailed()),
          GetPage(name: '/', page: () => MyApp()),
          // 다른 경로와 페이지 설정
        ],
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _userId; // 유저 세션
  String? _artistId;
  FirebaseFirestore fs = FirebaseFirestore.instance;

  bool loginFlg = false;

  DateTime selectedDay = DateTime.now();
  DateTime selectedDay1 = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel.isLogin) {
      _userId = userModel.userId;
    }
    if (userModel.isArtist) {
      _artistId = userModel.artistId;
    }
    if (userModel.isLeader) {
    }
  }

  void artistCheck(){



  }

  Widget _iconAni() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        padding: EdgeInsets.only(top: 15,bottom: 15),
        decoration: BoxDecoration(
          color: Color(0xFFffffff), // 백그라운드 색상
          border: Border.all(
            color: Color(0xFF392F31), // 보더 색상
            width: 0.5, // 보더 두께
          ),
          borderRadius: BorderRadius.circular(10.0), // 모서리 라운드

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton(
                    onPressed: (){
                      if (_userId != null) {
                        Get.to(
                            Profile(
                              userId: _userId,
                            ),
                            transition: Transition.noTransition
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('로그인 필요'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('로그인 후에 이용해주세요.'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('확인'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 다이얼로그 닫기
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text("임시 마이페이지 "),
                ),
                TextButton(
                  onPressed: (){
                    Get.to(
                        Join(),
                        transition: Transition.noTransition
                    );
                  },
                  child: Text("임시 회원가입"),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25.0,bottom: 10),
              child: Text("많이찾는 서비스 👀",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
              ),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8,left: 5,right: 5),

                      child: Column(
                        children: [
                          InkWell(
                            onTap: (){
                              if(_artistId == null || _artistId == ""){
                                if(_userId != null){
                                  Get.to(
                                    ArtistRegi(),
                                    transition: Transition.noTransition
                                  );
                                } else {
                                  _alertDialogWidget();
                                }
                              } else {
                                Get.to(
                                  ArtistInfo(_artistId!),
                                  transition: Transition.noTransition
                                );
                              }

                            },
                            child: Image.asset('assets/artistRegi.png',width: 40,height: 40,),
                          ),
                          SizedBox(height: 10,),
                          _artistId == null ? Text("아티스트등록",style: TextStyle(fontSize: 12),)
                           : Text("나의 팀/솔로",style: TextStyle(fontSize: 12),)
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8,left: 5,right: 5),

                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                                Get.to(
                                    BuskingZoneList(),
                                  transition: Transition.noTransition
                                );
                            },
                            child: Image.asset('assets/spot.png',width: 40,height: 40,),
                          ),
                          SizedBox(height: 10,),
                          Text("스팟",style: TextStyle(fontSize: 12),),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8,left: 5,right: 5),

                      child: Column(
                        children: [
                          InkWell(
                              onTap: () async {
                                Get.to(
                                  BuskingReservation(),
                                  transition: Transition.noTransition
                                );
                              },
                              child: Image.asset('assets/busking.png',width: 40,height: 40,),

                          ),
                          SizedBox(height: 10,),
                          Text("공연등록",style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8,left: 5,right: 5),
                      child: Column(
                        children: [
                          InkWell(
                              onTap: (){
                                Get.to(
                                    CommercialList(),
                                  transition: Transition.noTransition
                                );
                              },
                              child: Image.asset('assets/commer.png',width: 40,height: 40,),
                          ),
                          SizedBox(height: 10,),
                          Text("상업공간",style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                 SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8,left: 5,right: 5),

                      child: Column(
                        children: [
                          InkWell(
                            onTap: (){
                              Get.to(
                                BoardList(),
                                transition: Transition.noTransition
                              );
                            },
                            child: Image.asset('assets/community2.png',width: 40,height: 40,),
                          ),
                          SizedBox(height: 10,),
                          Text("커뮤니티",style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8,left: 5,right: 5),


                      child: Column(
                        children: [
                          InkWell(
                              onTap: (){
                                Get.to(
                                  VideoList(),
                                  transition: Transition.noTransition
                                );
                              },
                              child: Image.asset('assets/start.png',width: 40,height: 40,),
                          ),
                          SizedBox(height: 10,),
                          Text("영상목록",style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8,left: 5,right: 5),

                      child: Column(
                        children: [
                          InkWell(
                              onTap: (){
                                Get.to(
                                  DonationArtistList(),
                                  transition: Transition.noTransition
                                );
                              },
                              child: Image.asset('assets/donation.png',width: 40,height: 40,),
                          ),
                          SizedBox(height: 10,),
                          Text("후원하기",style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8,left: 5,right: 5),

                      child: Column(
                        children: [
                          InkWell(
                              onTap: (){
                                Get.to(
                                  PointDetailed(),
                                  transition: Transition.noTransition
                                );
                              },
                              child: Image.asset('assets/coin.png',width: 40,height: 40,),
                          ),
                          SizedBox(height: 10,),
                          Text("보유 포인트",style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }



  // 로그인 해라
  _alertDialogWidget() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("로그인이후 이용 가능합니다."),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  }, // 기능
                  child: Text("취소")),
              ElevatedButton(
                  onPressed: () {
                    Get.to(
                      LoginPage(),
                      transition: Transition.noTransition
                    )!.then((value) => Navigator.of(context).pop());
                  }, // 기능
                  child: Text("로그인")),
            ],
          );
        });
  }


  //best artist
  Future<List<Widget>> _bestArtist() async {
    List<Future<Widget>> artistWidgetsFutures = [];
    QuerySnapshot artistSnapshot = await fs.collection('artist').orderBy('followerCnt', descending: true).limit(10).get();

    artistWidgetsFutures = artistSnapshot.docs.map((doc) async {
      String artistName = doc['artistName'];
      String artistId = doc.id;
      QuerySnapshot imageSnapshot = await doc.reference.collection('image').get();


      List<String> artistImages = imageSnapshot.docs.map((imgDoc) => imgDoc['path'] as String).toList();

      return _bestArtistWidget(artistName, artistImages, artistId);
    }).toList();

    return Future.wait(artistWidgetsFutures);
  }

  Future<Widget> _bestArtistWidget(String artistName, List<String> artistImages, String artistId) async {
    // 원하는 내용으로 Widget을 생성
    return Container(
      margin: EdgeInsets.only(right: 15),
      child: GestureDetector(
        onTap: () {
          Get.to(
            ArtistInfo(artistId),
            transition: Transition.noTransition
          );
        },
        child: Column(
          children: [
            ClipOval(
              child: artistImages.isNotEmpty
                  ? Image.network(
                artistImages[0],
                width: 130,
                height: 130,
                fit: BoxFit.cover,
              ) : ClipOval(child: Container(width: 100, height: 100, color: Colors.grey),),
            ),
            SizedBox(height: 10,),
            Text(artistName),
          ],
        ),
      ),
    );
  }



  // 버스킹일정 버스킹 일정
  Future<List<Widget>> _busKinList() async {

    // 버스킹 컬렉션 호출
    final buskingQuerySnapshot = await fs
        .collection('busking')
        .orderBy('buskingStart', descending: false)  // ascending: true로 변경하면 오름차순 정렬 가능
        .where('buskingStart', isGreaterThan: Timestamp.fromDate(selectedDay))
        .get();
    // Firestore 쿼리를 생성하여 "busking" 컬렉션에서 현재 날짜를 지난 문서를 삭제합니다.
    DateTime threeMonthsAgo = selectedDay1.subtract(Duration(days: 3 * 30));
    fs.collection('busking').where('buskingStart', isLessThan: Timestamp.fromDate(threeMonthsAgo)).get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        // "image" 서브컬렉션 삭제
        QuerySnapshot imageSubcollection = await doc.reference.collection('image').get();
        imageSubcollection.docs.forEach((subDoc) async {
          await subDoc.reference.delete();
        });

        // "busLike" 서브컬렉션 삭제
        QuerySnapshot busLikeSubcollection = await doc.reference.collection('busLike').get();
        busLikeSubcollection.docs.forEach((subDoc) async {
          await subDoc.reference.delete();
        });

        // "review" 서브컬렉션 삭제
        QuerySnapshot reviewSubcollection = await doc.reference.collection('review').get();
        reviewSubcollection.docs.forEach((subDoc) async {
          await subDoc.reference.delete();
        });

        // 해당 "busking" 문서를 삭제합니다.
        await doc.reference.delete();
      });
    });

    List<Future<Widget>> buskingWidgetsFutures = [];
    int maxItemsToShow = 6; // 보여줄 아이템 수를 설정
    // 호출에 성공하면 실행
    if (buskingQuerySnapshot.docs.isNotEmpty) {
      for (int i = 0; i < buskingQuerySnapshot.docs.length && i < maxItemsToShow; i++) {
        // 각 버스킹 아이템에 대한 비동기 작업 병렬화
        final buskingWidgetFuture = _buildBuskingWidget(buskingQuerySnapshot.docs[i]);
        buskingWidgetsFutures.add(buskingWidgetFuture);
      }
      // 병렬로 모든 위젯 작업을 기다린 다음 반환
      final buskingWidgets = await Future.wait(buskingWidgetsFutures);
      return buskingWidgets;
    } else {
      return [Container()];
    }
  }



  Future<Widget> _buildBuskingWidget(QueryDocumentSnapshot buskingDoc) async {
    // 필요한 데이터를 비동기로 가져오는 함수

    // 버스킹 리뷰 컬렉션
    final busReviewSnapshot = await fs
        .collection('busking')
        .doc(buskingDoc.id)
        .collection('review')
        .get();


    if (busReviewSnapshot.docs.isNotEmpty) {
    }

    // 버스킹 좋아요 컬렉션
    final busLikeSnapshot = await fs
        .collection('busking')
        .doc(buskingDoc.id)
        .collection('busLike')
        .get();

    if (busLikeSnapshot.docs.isNotEmpty) {
    }

    // 버스킹 이미지 호출
    final buskingImg = await fs
        .collection("busking")
        .doc(buskingDoc.id)
        .collection('image')
        .get();

    if (buskingImg.docs.isNotEmpty) {
      String busImg = buskingImg.docs[0]['path'];


      return GestureDetector(
        onTap: () {
          Get.to(
            ConcertDetails(document: buskingDoc),
            transition: Transition.noTransition
          )!.then((value) => setState((){}));
        },
        child: Container(
          width: 200,
          margin: EdgeInsets.only(right: 30),
          decoration: BoxDecoration(
            color: Color(0xFFffffff), // 배경 색상
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: CachedNetworkImage(
                  imageUrl: busImg, // 이미지 URL
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => CircularProgressIndicator(), // 이미지 로딩 중에 표시될 위젯
                  errorWidget: (context, url, error) => Icon(Icons.error), // 이미지 로딩 오류 시 표시될 위젯
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 10,),
                  Text(
                    buskingDoc['title'],
                    style: TextStyle(
                      fontSize: 15, // 제목 폰트 크기
                      fontWeight: FontWeight.bold, // 볼드체
                    ),
                    overflow: TextOverflow.ellipsis, // 텍스트가 너무 길 경우 줄임표(...)로 표시
                  ),
                  Text(
                    buskingDoc['description'],
                    style: TextStyle(
                      fontSize: 14, // 설명 폰트 크기
                    ),
                    overflow: TextOverflow.ellipsis, // 텍스트가 너무 길 경우 줄임표(...)로 표시
                  ),
                ],
              ),
            ],
          ),
        ),
      );

    }
    return Container(); // 이미지가 없는 경우 빈 컨테이너 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(),
      body: ListView(
        children: [
          Container(
            child: FutureBuilder(
              future: _busKinList(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),

                        ),
                        padding: const EdgeInsets.only(left: 20,right: 15,top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("공연일정",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                            TextButton(
                                onPressed: (){
                                  Get.to(
                                    BuskingList(),
                                    transition: Transition.noTransition
                                  );
                                }, // 버스킹 공연 일정 리스트 페이지로 넘어갈것
                                child: Text("더보기",style: TextStyle(color: Colors.black),))
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          margin: EdgeInsets.only(left: 20,right: 20,bottom: 20),
                          child: Row(
                            children: snapshot.data ?? [Container()],
                          ),
                        ),
                      ),
                      _iconAni(),
                      Text("best artist",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),), // 인기많은 아티스트

                      Container(
                        margin: EdgeInsets.all(10),
                        child: FutureBuilder(
                          future: _bestArtist(),
                          builder : (BuildContext context, AsyncSnapshot<dynamic> bestArtistsnapshot) {
                            if(bestArtistsnapshot.connectionState == ConnectionState.waiting){
                              return Container();
                            } else if (bestArtistsnapshot.hasError) {
                              return Text('Error: ${bestArtistsnapshot.error}');
                            } else {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: bestArtistsnapshot.data ?? [Container()],
                                ),
                              );
                            }
                          }
                        ),
                      ),
                      Container(
                        child: FutureBuilder(
                          future: _commercialListWidget(),
                          builder: (BuildContext context, AsyncSnapshot<dynamic> commersnapshot) {
                            if (commersnapshot.connectionState == ConnectionState.waiting) {
                              return Container();
                            } else if (commersnapshot.hasError) {
                              return Text('Error: ${commersnapshot.error}');
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15,right: 15,top: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("상업공간 일정",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                        TextButton(
                                            onPressed: (){
                                              //_bestArtist();
                                              Get.to(
                                                  () => CommercialList(),
                                                transition: Transition.noTransition
                                              );
                                            },
                                            child: Text("더보기",style: TextStyle(color: Colors.black),)
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(
                                      children: commersnapshot.data ?? [Container()],
                                    ),
                                  ),
                                ],
                              );
                            }
                          },

                        ),
                      )
                    ],

                  );
                }
              },
            ),

          )
        ],
      ),

      bottomNavigationBar: MyBottomBar(),
    );
  }


  Future<List<Widget>> _commercialListWidget() async {
    final commerQuerySnapshot = await FirebaseFirestore.instance.collection('commercial_space').get();

    if (commerQuerySnapshot.docs.isEmpty) {
      return [Text("상업공간에 내용이 없음")];
    }

    List<Widget> commerWidgets = [];

    for (QueryDocumentSnapshot commerDoc in commerQuerySnapshot.docs) {
      final spaceName = commerDoc['spaceName'];
      final _id = commerDoc.id;
      final nowTime = Timestamp.fromDate(selectedDay);

      QuerySnapshot commerRentalQuerySnapshot = await FirebaseFirestore.instance
          .collection("commercial_space")
          .doc(_id)
          .collection("rental")
          .where('startTime', isGreaterThanOrEqualTo: nowTime)
          .orderBy('startTime', descending: false)
          .get();

      await Future.forEach(commerRentalQuerySnapshot.docs, (rentalDoc) async {
        final endTime = rentalDoc['endTime'].toDate();
        DateTime threeMonthsAgo = selectedDay1.subtract(const Duration(days: 3 * 30));

        if (endTime.isBefore(threeMonthsAgo)) {
          await rentalDoc.reference.delete();
        }
      });

      if (commerRentalQuerySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot rentalDoc in commerRentalQuerySnapshot.docs) {
          final date = DateFormat('MM-dd').format(rentalDoc['startTime'].toDate());
          final startTime = DateFormat('HH:mm').format(rentalDoc['startTime'].toDate());
          final endTime = DateFormat('HH:mm').format(rentalDoc['endTime'].toDate());
          final artistId = rentalDoc['artistId'];

          final artistDoc = await FirebaseFirestore.instance.collection('artist').doc(artistId).get();

          if (artistDoc.exists) {
            final artistName = artistDoc['artistName'];

            final imageDoc = await FirebaseFirestore.instance
                .collection('commercial_space')
                .doc(_id)
                .collection('image')
                .get();

            if (imageDoc.docs.isNotEmpty) {
              final List<dynamic> img = imageDoc.docs.first['path'];

              final addrDoc = await FirebaseFirestore.instance
                  .collection('commercial_space')
                  .doc(_id)
                  .collection('addr')
                  .get();

              if (addrDoc.docs.isNotEmpty) {
                final addr = addrDoc.docs.first['addr'];
                final listItem = Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Color(0xFFffffff), // 배경 색상
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    visualDensity: VisualDensity(vertical: 4),
                    contentPadding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    tileColor: Colors.white,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 100,
                                height: 100,
                                child: CachedNetworkImage(
                                  imageUrl: img[0], // 이미지 URL
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  spaceName,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('공연팀: $artistName'),
                                Container(
                                  width: 200,
                                  child: Text(
                                    addr,
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(date),
                            Text(startTime),
                            Text(endTime),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.to(
                          SpaceInfo(_id),
                          transition: Transition.noTransition
                      );
                    },
                  ),
                );
                commerWidgets.add(listItem);
              }
            }
          }
        }
      }
    }
    return commerWidgets;
  }


}