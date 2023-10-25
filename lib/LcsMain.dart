import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
            )
          ],
        ),
      ),
      bottomNavigationBar: MyBottomBar(),
    );

  }

}
