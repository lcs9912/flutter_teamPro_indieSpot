import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:indie_spot/boardList.dart';
import 'package:indie_spot/commercialList.dart';
import 'package:indie_spot/login.dart';
import 'package:indie_spot/pointDetailed.dart';
import 'package:indie_spot/profile.dart';
import 'package:indie_spot/result.dart';
import 'package:indie_spot/spaceInfo.dart';
import 'package:indie_spot/userModel.dart';
import 'package:indie_spot/videoList.dart';
import 'package:permission_handler/permission_handler.dart';
import 'artistRegi.dart';
import 'buskingList.dart';
import 'buskingReservation.dart';
import 'concertDetails.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'join.dart';
import 'lcsTest.dart';
import 'dart:async';
import 'package:get/get.dart';

TextEditingController _nicknameController = TextEditingController();
TextEditingController _introductionController = TextEditingController();

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
        initialRoute: '/',
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

  FirebaseFirestore fs = FirebaseFirestore.instance;

  bool loginFlg = false;

  DateTime selectedDay = DateTime.now();
  DateTime selectedDay1 = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {

    } else {
      _userId = userModel.userId;
    }
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
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Row(
                children: [
                  Text("많이찾는 서비스 👀",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        if(_userId != null){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ArtistRegi()),
                          );
                        } else {
                          _alertDialogWidget();
                        }
                      },
                      icon: Icon(Icons.person),
                    ),
                    Text("아티스트"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_userId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile(
                                userId: _userId,
                              ),
                            ),
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
                      icon: Icon(Icons.pages),
                    ),
                    Text("마이페이지"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () async {
                          if(Provider.of<UserModel>(context, listen: false).isLogin) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('로그아웃 확인'),
                                  content: Text('로그아웃 하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // 첫 번째 다이얼로그 닫기
                                      },
                                      child: Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // 두 번째 확인 다이얼로그
                                        Navigator.pop(context); // 첫 번째 다이얼로그 닫기

                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('알림'),
                                              content: Text('로그아웃 하였습니다.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    // 로그아웃 수행
                                                    Provider.of<UserModel>(context, listen: false).logout();
                                                    Navigator.pop(context); // 두 번째 다이얼로그 닫기
                                                  },
                                                  child: Text('확인'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text('확인'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) =>
                                    LoginPage()) // 상세페이지로 넘어갈것
                            );
                          }
                        },
                        icon: Icon(Icons.login)
                    ),
                    Consumer<UserModel>(
                        builder: (context, userModel, child){
                          return Text(userModel.isLogin ? "로그아웃" : "로그인");
                        }
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){
                          _commercialListWidget();
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Join())
                          );
                        },
                        icon: Icon(Icons.catching_pokemon)
                    ),
                    Text("회원가입"),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => BoardList())
                          );
                        },
                        icon: Icon(Icons.arrow_drop_down)
                    ),
                    Text("여기다"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VideoList()) // 상세페이지로 넘어갈것
                          );
                        },
                        icon: Icon(Icons.smart_display)
                    ),
                    Text("애니메이션"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.swap_vert)
                    ),
                    Text("효과"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.dangerous)
                    ),
                    Text("줘야하는데.."),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.question_mark)
                    ),
                    Text("어케"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => LcsTest())
                          );
                        },
                        icon: Icon(Icons.send)
                    ),
                    Text("주는지"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.psychology_alt)
                    ),
                    Text("모르겠다"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PointDetailed(),));
                        },
                        icon: Icon(Icons.air)
                    ),
                    Text("에혀.."),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    ).then((value) => Navigator.of(context).pop());
                  }, // 기능
                  child: Text("로그인")),
            ],
          );
        });
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
    DateTime threeMonthsAgo = selectedDay.subtract(Duration(days: 3 * 30));
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
    int reviewCnt = 0;
    int busLikeCnt = 0;

    // 버스킹 리뷰 컬렉션
    final busReviewSnapshot = await fs
        .collection('busking')
        .doc(buskingDoc.id)
        .collection('review')
        .get();


    if (busReviewSnapshot.docs.isNotEmpty) {
      reviewCnt = busReviewSnapshot.docs.length;
    }

    // 버스킹 좋아요 컬렉션
    final busLikeSnapshot = await fs
        .collection('busking')
        .doc(buskingDoc.id)
        .collection('busLike')
        .get();

    if (busLikeSnapshot.docs.isNotEmpty) {
      busLikeCnt = busLikeSnapshot.docs.length;
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConcertDetails(document: buskingDoc, spotName: ''),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(right: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Color(0xFFffffff), // 배경 색상
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: Offset(0, 3), // 그림자 효과
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                ),
                child: CachedNetworkImage(
                  imageUrl: busImg, // 이미지 URL
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(), // 이미지 로딩 중에 표시될 위젯
                  errorWidget: (context, url, error) => Icon(Icons.error), // 이미지 로딩 오류 시 표시될 위젯
                ),
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buskingDoc['title'],
                    style: TextStyle(
                      fontSize: 18, // 제목 폰트 크기
                      fontWeight: FontWeight.bold, // 볼드체
                    ),
                  ),
                  Text(
                    buskingDoc['description'],
                    style: TextStyle(
                      fontSize: 14, // 설명 폰트 크기
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, size: 15),
                          Text(
                            busLikeCnt.toString(),
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$reviewCnt 리뷰',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 20),
            ],
          ),
        ),
      );

    }
    return Container(); // 이미지가 없는 경우 빈 컨테이너 반환
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => BuskingList()) // 상세페이지로 넘어갈것
                                  );
                                }, // 버스킹 공연 일정 리스트 페이지로 넘어갈것
                                child: Text("더보기",style: TextStyle(color: Colors.black),))
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          margin: EdgeInsets.all(20),
                          child: Row(
                            children: snapshot.data ?? [Container()],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              children: [
                                ElevatedButton(
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => BuskingReservation()) // 상세페이지로 넘어갈것
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
                                      padding: EdgeInsets.zero,  // 이거 쓰면 ElevatedButton 의 파란색 배경 사라짐
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        'busking/bus_sample6.jpg',
                                        fit: BoxFit.cover,
                                        width: screenWidth * 0.45,
                                        height: 90,
                                      ),
                                    )
                                ),
                                Positioned(
                                  left: 5,
                                  bottom: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        child: Text(
                                          "공연등록", style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ),
                                       ),
                                        onPressed: (){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => BuskingReservation()) // 상세페이지로 넘어갈것
                                          );
                                        },
                                      ),
                                      Text(
                                        "나의 재능을 홍보해보세요",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                ElevatedButton(
                                    onPressed: (){},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
                                      padding: EdgeInsets.zero,  // 이거 쓰면 ElevatedButton 의 파란색 배경 사라짐
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                                      child: Image.asset(
                                        'busking/bus_sample3.jpg',
                                        fit: BoxFit.cover,
                                        width: screenWidth * 0.45,
                                        height: 90,
                                      ),
                                    )
                                ),
                                Positioned(
                                  left: 5,
                                  bottom: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        onPressed: () {  },
                                        child: Text(
                                          "후원하기", style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ), ),
                                      ),
                                      Text(
                                        "아티스트 응원하기",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text("best artist"), // 인기많은 아티스트
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    'assets/기본.jpg',
                                    width: 100, // 원 모양 이미지의 너비
                                    height: 100, // 원 모양 이미지의 높이
                                    fit: BoxFit.cover, // 이미지를 화면에 맞게 조절
                                  ),
                                ),
                                Text("루시")
                              ],
                            ),
                            
                          ],
                        ),
                      ),
                      _iconAni(),
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
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => CommercialList()) // 상세페이지로 넘어갈것
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
    int count = 0;
    for (QueryDocumentSnapshot commerDoc in commerQuerySnapshot.docs) {
      if(count == 3){
        break;
      }
      final spaceName = commerDoc['spaceName'];
      final _id = commerDoc.id;
      final startTime = Timestamp.fromDate(selectedDay);
      QuerySnapshot commerRentalQuerySnapshot = await FirebaseFirestore.instance
          .collection("commercial_space")
          .doc(_id)
          .collection("rental")
          .where('startTime', isGreaterThanOrEqualTo: startTime)
          .get();

      await Future.forEach(commerRentalQuerySnapshot.docs, (rentalDoc) async {
        final endTime = rentalDoc['endTime'].toDate();
        DateTime threeMonthsAgo = selectedDay.subtract(const Duration(days: 3 * 30));

        if (endTime.isBefore(threeMonthsAgo)) {
          print('시간이 지나 삭제됨 => ${rentalDoc.id}');
          await rentalDoc.reference.delete();
        }
      });

      if (commerRentalQuerySnapshot.docs.isNotEmpty) {
        final rentalDocs = commerRentalQuerySnapshot.docs;

        for (QueryDocumentSnapshot rentalDoc in rentalDocs) {
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SpaceInfo(_id)),
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
      count++;
    }
    return commerWidgets;
  }
}