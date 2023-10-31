import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:indie_spot/join.dart';
import 'package:indie_spot/login.dart';
import 'package:indie_spot/pointDetailed.dart';
import 'package:indie_spot/result.dart';
import 'package:indie_spot/userEdit.dart';
import 'package:indie_spot/userModel.dart';
import 'buskingList.dart';
import 'buskingReservation.dart';
import 'concertDetails.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  FirebaseFirestore fs = FirebaseFirestore.instance;

  bool iconFlg = false; // 아이콘 리스트 플러그
  bool loginFlg = false;





  Future<List<Widget>> _busKinList() async {
    // 버스킹 컬렉션 호출
    final buskingQuerySnapshot = await fs
        .collection('busking').limit(6).get();

    List<Widget> buskingWidgets = [];

    // 호출에 성공하면 실행
    if(buskingQuerySnapshot.docs.isNotEmpty){
      for (QueryDocumentSnapshot buskingDoc in buskingQuerySnapshot.docs)  {
        int reviewCnt;
        int busLikeCnt;
        String docId = buskingDoc.id;
        // 공연제목
        String title = buskingDoc['title'];
        // 공연설명
        String description = buskingDoc['description'];


        // 버스킹 좋아요 컬렉션
        final busLikeSnapshot = await fs
            .collection('busking')
            .doc(buskingDoc.id)
            .collection('busLike').get();

        // 버스킹 리뷰 컬렉션
        final busReviewSnapshot = await fs
            .collection('busking')
            .doc(buskingDoc.id)
            .collection('review').get();

        // 버스킹스팟 컬렉션
        final busSpotSnapshot = await fs
            .collection('busking')
            .doc(buskingDoc.id)
            .collection('review').get();
        if(busSpotSnapshot.docs.isNotEmpty){
          reviewCnt = buskingDoc['reviewCnt'];
        } else{
          reviewCnt = 0;
        }

        if(busLikeSnapshot.docs.isNotEmpty){
          busLikeCnt = buskingDoc['busLikeCnt'];
        } else{
          busLikeCnt = 0;
        }

        // busking -> image
        final buskingImg = await fs
            .collection("busking")
            .doc(buskingDoc.id)
            .collection('image')
            .get();

        if(buskingImg.docs.isNotEmpty){
          for (QueryDocumentSnapshot buskingImgDoc in buskingImg.docs){

            // 버스킹 이미지 호출
            String busImg = buskingImgDoc['path'];

            // 예시: ListTile을 사용하여 팀 멤버 정보를 보여주는 위젯을 만듭니다.
            // 이미지 busImg 제목 title 내용 description 좋아요 busLikeCnt.toString() 리뷰 reviewCnt.toString()
            Widget buskingWidget = GestureDetector(
              onTap: () {
                // 이미지를 클릭했을 때 실행할 코드를 여기에 추가
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ConcertDetails(document: buskingDoc, spotName: '',)) // 상세페이지로 이동
                );
              },
              child: Row(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect( // 이미지 테두리 둥글게 만들기
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(busImg, width: 150, height: 150, fit: BoxFit.cover)
                        ),
                        SizedBox(height: 10,),
                        Text(title),
                        Text(description),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.favorite,size: 15,), // 관심, 하트 클릭
                            Text(busLikeCnt.toString()),
                            SizedBox(width: 70,),
                            Text('${reviewCnt.toString()}리뷰')
                          ],
                        ),
                        SizedBox(height: 10,),
                      ]
                  ),
                  SizedBox(width: 20,),
                ],
              ),
            );

            buskingWidgets.add(buskingWidget);
          }


        }

      }
      print('버스킹 잘넘어오는중');
      return buskingWidgets;
    } else {
      print('버스킹 안넘어오는중');
      return [Container()];
    }



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
                                        width: 190,
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
                                        width: 190,
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
                                        "후원하기", style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                      ),
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
                      Row( // 여기부터가 아이콘시작
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                  onPressed: (){},
                                  icon: Icon(Icons.person)
                              ),
                              Text("아티스트"),
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
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(builder: (_) => Join()) // 상세페이지로 넘어갈것
                                    //);
                                  },
                                  icon: Icon(Icons.catching_pokemon)
                              ),
                              Text("회원가입"),
                            ],
                          ),

                          if(!iconFlg!)
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    iconFlg = true;
                                  });
                                },
                                icon: Icon(Icons.expand_more)
                            ),

                          if(iconFlg)
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    iconFlg = false;
                                  });
                                },
                                icon: Icon(Icons.expand_less)

                            ),


                        ],

                      ),
                      if(iconFlg)
                        _iconList(), // 여기 까지가 아이콘끝
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


  // 아이콘 리스트 출력
  Widget _iconList() {
    if(iconFlg){
      return Column(
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
                      onPressed: (){},
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
      );
    } else{
      return Container();
    }

  }

  //상업공간 리스트 위젯
  Future<List<Widget>> _commercialListWidget() async {
    String _id;
    final commerQuerySnapshot = await fs
        .collection('commercial_space').limit(3).get();

    List<Widget> commerWidgets = [];

    if(commerQuerySnapshot.docs.isNotEmpty){

      for(QueryDocumentSnapshot commerDoc in commerQuerySnapshot.docs){ // commercial_space 컬렉션 반복
        _id = commerDoc.id; // 상업공간 아이디
        String spaceName = commerDoc['spaceName'];

        // 서브커넥션 rental 접근
        final commerRentalQuerySnapshot = await fs
            .collection('commercial_space')
            .doc(_id)
            .collection('rental')
            .get();
        if(commerRentalQuerySnapshot.docs.isNotEmpty){
          for(QueryDocumentSnapshot rentalDoc in commerRentalQuerySnapshot.docs){ // rental 컬렉션 반복
            // yyyy-MM-dd HH:mm:ss

            String date = DateFormat('MM-dd').format(rentalDoc['startTime'].toDate());
            String startTime = DateFormat('HH:mm').format(rentalDoc['startTime'].toDate());
            String endTime = DateFormat('HH:mm').format(rentalDoc['endTime'].toDate());

            final artistQuerySnapshot = await fs
                .collection('artist')
                .where(FieldPath.documentId, isEqualTo: rentalDoc['artistId']).get();

            if(artistQuerySnapshot.docs.isNotEmpty){
              for(QueryDocumentSnapshot artistDoc in artistQuerySnapshot.docs){
                String artistName =  artistDoc['artistName'];

                // image 컬렉션 접근
                final commerImgQuerySnapshot = await fs
                    .collection('commercial_space')
                    .doc(_id)
                    .collection('image')
                    .get();

                if(commerImgQuerySnapshot.docs.isNotEmpty){
                  for(QueryDocumentSnapshot imageDoc in commerImgQuerySnapshot.docs) {
                    String img = imageDoc['path'];

                    // addr 컬렉션 접근
                    final commerAddrQuerySnapshot = await fs
                        .collection('commercial_space')
                        .doc(_id)
                        .collection('addr')
                        .get();

                    if(commerAddrQuerySnapshot.docs.isNotEmpty) {
                      for (QueryDocumentSnapshot addrDoc in commerAddrQuerySnapshot.docs) {
                        String addr =  addrDoc['addr'];


                        var listItem = ListTile(
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
                                        borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          child: Image.network(img),
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
                                      Text('공연팀:  $artistName',style: TextStyle(fontSize: 13),),
                                    ],
                                  ),
                                ],
                              ),

                                  Column(
                                    children: [
                                      Text(date),
                                      Text(startTime),
                                      Text(endTime), //  오버플로우 가 표시되는 부분
                                    ],
                                  ),
                            ],
                          ),

                          onTap: () {
                            // 상업공간 공연 상세페이지
                          },
                        );
                        commerWidgets.add(listItem);

                      }
                    }
                  }
                }
              }
            }

          }
        }




      }
      print("상업공간 잘넘어옴");
      return commerWidgets;
    }else{
      print("상업공간 안넘어옴");
      return [Container()];
    }



    return [Container()];
  }

  // 상업공간 리스트 출력
  _commercialList(){
    return ListView.builder(

      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            tileColor: Colors.white,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                  child: Container(
                    width: 120,
                    height: 100,

                  ),
                ),
                SizedBox(width: 16), // 이미지와 텍스트 사이의 간격 조절
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '아따맘마',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("인천 부평구"),
                    Text("공연팀: 오동동"),
                  ],
                ),
              ],
            ),
            trailing: Text(" 날짜 \n 첫순서 \n 두번째"),
            onTap: () {
              // 상업공간 공연 상세페이지
            },
          ),
        );
      },
    )
    ;
  }


}
