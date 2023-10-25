import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                    onPressed: (){}, // 버스킹 공연 일정 리스트 페이지로 넘어갈것
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
                                ClipRRect(
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                        onPressed: (){},
                        icon: Icon(Icons.move_down)
                    ),
                    Text("이동"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.icecream)
                    ),
                    Text("아이콘"),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add),
                  Icon(Icons.post_add),
                  Icon(Icons.post_add),
                  TextButton(
                    onPressed: (){
                      setState(() {
                        iconFlg = true;
                      });
                    },
                    child: Text("편집"),
                  ),
                ],
              ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("뭐가 들어오는게 좋을까"),
                SizedBox(width: 17,),
                Text("후원페이지 이미지 "),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("상업공간 공연일정",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                TextButton(
                    onPressed: (){}, // 상업공간 공연 일정 리스트 페이지로 넘어갈것
                    child: Text("더보기",style: TextStyle(color: Colors.black),))
              ],
            ),
            Text("여기는 ListView ListTile")
          ],
        ),
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }


}
