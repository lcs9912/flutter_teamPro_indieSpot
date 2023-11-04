import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:indie_spot/login.dart';
import 'package:indie_spot/pointDetailed.dart';
import 'package:indie_spot/result.dart';
import 'package:indie_spot/userEdit.dart';
import 'package:indie_spot/userModel.dart';
import 'package:indie_spot/videoList.dart';
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
import 'package:flutter_image/flutter_image.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'join.dart';

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
        child: MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: [
            const Locale('ko', 'KR'), // 한국어
            const Locale('en'), // 한국어
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Noto_Serif_KR', // 폰트 패밀리 이름을 지정
          ),
          home: MyApp(),
          routes: {
            '/result': (context) => Result(), // '/result' 경로와 연결된 페이지
            '/pointDetailed': (context) => PointDetailed()
            // 다른 경로와 페이지 설정
          },
        ),
      )
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
  bool iconFlg = false; // 아이콘 리스트 플러그
  bool loginFlg = false;
  static const int maxAttempt = 3;
  static const Duration attemptTimeout = Duration(seconds: 2);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 팔로우count
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {

    } else {
      _userId = userModel.userId;
    }
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

  Future<List<Widget>> _busKinList() async {
    // 버스킹 컬렉션 호출
    final buskingQuerySnapshot = await fs.collection('busking').limit(6).get();

    List<Future<Widget>> buskingWidgetsFutures = [];

    // 호출에 성공하면 실행
    if (buskingQuerySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot buskingDoc in buskingQuerySnapshot.docs) {
        // 각 버스킹 아이템에 대한 비동기 작업 병렬화
        final buskingWidgetFuture = _buildBuskingWidget(buskingDoc);
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

      // 예시: ListTile을 사용하여 팀 멤버 정보를 보여주는 위젯을 만듭니다.
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConcertDetails(document: buskingDoc, spotName: ''),
            ),
          );
        },
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: CachedNetworkImage(
                    imageUrl: busImg, // 이미지 URL
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(), // 이미지 로딩 중에 표시될 위젯
                    errorWidget: (context, url, error) => Icon(Icons.error), // 이미지 로딩 오류 시 표시될 위젯
                  )
                ),
                SizedBox(height: 10),
                Text(buskingDoc['title']),
                Text(buskingDoc['description']),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.favorite, size: 15),
                    Text(busLikeCnt.toString()),
                    SizedBox(width: 70),
                    Text('$reviewCnt 리뷰'),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
            SizedBox(width: 20),
          ],
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: EdgeInsets.only(top: 10),
                          margin: EdgeInsets.all(20),
                          child: Row(
                            children: snapshot.data ?? [Container()],
                          ),

                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                      Text(
                                        "공연등록", style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                      ),
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
                                  Container(
                                    padding: EdgeInsets.only(top: 10),
                                    margin: EdgeInsets.all(20),
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

  Widget _iconToggle() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300), // 전환 애니메이션 지속 시간
      child: iconFlg
          ? IconButton(
        key: Key('expand_less'), // 고유한 키를 제공하여 전환 시 식별 가능
        onPressed: () {
          setState(() {
            iconFlg = false;
          });
        },
        icon: Icon(Icons.expand_less),
      )
          : IconButton(
        key: Key('expand_more'), // 고유한 키를 제공하여 전환 시 식별 가능
        onPressed: () {
          setState(() {
            iconFlg = true;
          });
        },
        icon: Icon(Icons.expand_more),
      ),
    );
  }

  // 아이콘...
  Widget _iconAni(){

    return Column(
      children: [
        Row( // 여기부터가 아이콘시작
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                IconButton(
                    onPressed: (){
                      if(_userId != null){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArtistRegi()),
                        );
                      } else {
                        _alertDialogWidget();
                      }

                    },
                    icon: Icon(Icons.person)
                ),
                Text("아티스트 등록"),
              ],
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserEdit()),
                    );
                  },
                  icon: Icon(Icons.pages),
                ),
                Text("마이페지"),
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

            _iconToggle()


          ],

        ),
        if(iconFlg)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      IconButton(
                          onPressed: (){},
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
                  SizedBox(width: 45,height: 30,),

                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          onPressed: (){},
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
                  SizedBox(width: 45,height: 30,),

                ],
              ),


            ],
          ),
      ],
    );
  }



  Future<List<Widget>> _commercialListWidget() async {
    final commerQuerySnapshot = await fs.collection('commercial_space').limit(2).get();

    if (commerQuerySnapshot.docs.isEmpty) {
      return [Container()];
    }

    List<Future<Widget>> commerWidgets = [];

    for (QueryDocumentSnapshot commerDoc in commerQuerySnapshot.docs) {
      final spaceName = commerDoc['spaceName'];
      final _id = commerDoc.id;

      final commerRentalQuerySnapshot =
      await fs.collection('commercial_space').doc(_id).collection('rental').get();

      if (commerRentalQuerySnapshot.docs.isNotEmpty) {
        final rentalDocs = commerRentalQuerySnapshot.docs;

        for (QueryDocumentSnapshot rentalDoc in rentalDocs) {
          final date = DateFormat('MM-dd').format(rentalDoc['startTime'].toDate());
          final startTime = DateFormat('HH:mm').format(rentalDoc['startTime'].toDate());
          final endTime = DateFormat('HH:mm').format(rentalDoc['endTime'].toDate());
          final artistId = rentalDoc['artistId'];

          final artistDoc = await fs.collection('artist').doc(artistId).get();

          if (artistDoc.exists) {
            final artistName = artistDoc['artistName'];

            final imageDoc = await fs
                .collection('commercial_space')
                .doc(_id)
                .collection('image')
                .get();

            if (imageDoc.docs.isNotEmpty) {
              final img = imageDoc.docs.first['path'];

              final addrDoc = await fs
                  .collection('commercial_space')
                  .doc(_id)
                  .collection('addr')
                  .get();

              if (addrDoc.docs.isNotEmpty) {
                final addr = addrDoc.docs.first['addr'];

                final listItem = ListTile(
                  contentPadding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
                                imageUrl: img, // 이미지 URL
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => CircularProgressIndicator(), // 이미지 로딩 중에 표시될 위젯
                                errorWidget: (context, url, error) => Icon(Icons.error), // 이미지 로딩 오류 시 표시될 위젯
                              )
                            ),
                          ),
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
                              Text(addr),
                              Text('공연팀: $artistName', style: TextStyle(fontSize: 13)),
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
                    // 상업공간 공연 상세페이지
                  },
                );
                commerWidgets.add(Future.value(listItem));
              }
            }
          }
        }
      }
    }

    return Future.wait(commerWidgets);
  }
}