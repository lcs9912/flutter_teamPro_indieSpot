import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/join.dart';
import 'package:indie_spot/login.dart';
import 'buskingList.dart';
import 'buskingReservation.dart';
import 'concertDetails.dart';
import 'firebase_options.dart';
import 'baseBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool iconFlg = false;

  List<String> imgList = [
    'busking/bus_sample1.jpg',
    'busking/bus_sample2.jpg',
    'busking/bus_sample3.jpg',
    'busking/bus_sample4.jpg',
    'busking/bus_sample5.jpg',
    'busking/bus_sample6.jpg',
  ];

  List<String> commList = [
    'commercialimg/commercial_sample1.jpg',
    'commercialimg/commercial_sample2.jpg',
    'commercialimg/commercial_sample3.jpg',
    'commercialimg/commercial_sample4.jpg',
    'commercialimg/commercial_sample5.jpg',
  ];

  List<String> titleList = [
    '샘플1',
    '샘플2',
    '샘플3',
    '샘플4',
    '샘플5',
    '샘플6',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
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

                child: Row(
                  children: [
                    for(int i= 0; i<6; i++ )
                      GestureDetector(
                        onTap: () {
                          // 이미지를 클릭했을 때 실행할 코드를 여기에 추가
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ConcertDetails()) // 상세페이지로 넘어갈것
                          );
                        },
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect( // 이미지 테두리 둥글게 만들기
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Image.asset(imgList[i], width: 150, height: 150, fit: BoxFit.cover)
                                ),
                                SizedBox(height: 10,),
                                Text(titleList[i]),
                                Text("간략 장소"),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.favorite,size: 15,), // 관심, 하트 클릭
                                    Text("(${i})"),  // i == 카운트
                                    SizedBox(width: 70,),
                                    Text("후기(${i})")
                                  ],
                                ),
                                SizedBox(height: 10,),
                              ]
                            ),
                            SizedBox(width: 20,),
                          ],
                        ),
                      ),
                  ],
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.person)
                    ),
                    Text("여기다"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.pages)
                    ),
                    Text("페이지"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()) // 상세페이지로 넘어갈것
                          );
                        },
                        icon: Icon(Icons.login)
                    ),
                    Text("로그인"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Join()) // 상세페이지로 넘어갈것
                          );
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
              _iconList(),

            SizedBox(height: 20,),
            Row(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("상업공간 공연일정",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                TextButton(
                    onPressed: (){  // 상업공간 공연 일정 리스트 페이지로 넘어갈것

                    },
                    child: Text("더보기",style: TextStyle(color: Colors.black),))
              ],
            ),
            Expanded(
                child: _commercialList()
            ),
          ],

        ),
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  // 아이콘 리스트 출력
  Widget _iconList() {
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
                      onPressed: (){},
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
  }

  // 상업공간 리스트 출력
  _commercialList(){
    return ListView.builder(
      itemCount: commList.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.0), // 각 ListTile 사이의 간격을 조절
          child: ListTile(
            contentPadding: EdgeInsets.all(16.0), // ListTile 내부 컨텐츠와 가장자리 간격 조절
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // ListTile의 둥근 테두리 조절
            ),
            tileColor: Colors.grey[200], // ListTile의 배경색 조절
            leading: Image.asset(commList[index], width: 80, height: 80, fit: BoxFit.cover),
            title: Text('아따맘마', style: TextStyle(fontSize: 18.0)), // 제목 텍스트 스타일 조절
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("인천 부평구"),
                Text("공연팀: 오동동"),
              ],
            ),
            trailing: Text(" 날짜 \n 첫순서 \n 두번째"),
            onTap: (){ // 상업공간 공연 상세페이지
              
            },
          ),
        );
      },
    );
  }
}
