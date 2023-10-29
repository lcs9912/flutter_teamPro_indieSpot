import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/join.dart';
import 'package:indie_spot/login.dart';
import 'package:indie_spot/pointDetailed.dart';
import 'package:indie_spot/result.dart';
import 'package:indie_spot/userModel.dart';
import 'buskingList.dart';
import 'buskingReservation.dart';
import 'concertDetails.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'baseBar.dart';
import 'package:indie_spot/userModel.dart';

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
          theme: ThemeData(fontFamily: 'NotoSansKR'),
          home: lcsMyApp(),
          routes: {
            '/result': (context) => Result(), // '/result' 경로와 연결된 페이지
            // 다른 경로와 페이지 설정
          },
        ),
      )
  );
}

class lcsMyApp extends StatefulWidget {
  const lcsMyApp({super.key});

  @override
  State<lcsMyApp> createState() => _MyAppState();
}

class _MyAppState extends State<lcsMyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(),
      body: Container(
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
            BusKingList(), // 버스킹 리스트
            Row(
              children: [
                Text("공연요청 공연등록"),
              ],
            ),
            Row(
              children: [
                Text("아이콘들"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("상업공간 공연일정",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
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
            CommList(), // 상업공간 리스트


          ],
        )
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}


class BusKingList extends StatefulWidget {
  const BusKingList({super.key});

  @override
  State<BusKingList> createState() => _BusKingListState();
}

class _BusKingListState extends State<BusKingList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("busking").snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
              if (!snap.hasData) {
                return Container();
              }
              return ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snap.data!.docs[index];
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  String spotId = data['spotId'];
                  String artistId = data['artistId'];

                  return FutureBuilder(
                    future: FirebaseFirestore.instance.collection("artist")
                        .where(FieldPath.documentId, isEqualTo: artistId).get(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> artistSnapshot) {
                      QueryDocumentSnapshot artistDoc = artistSnapshot.data!.docs.first;
                      Map<String, dynamic> artistData = artistDoc.data() as Map<String,dynamic>;

                      return FutureBuilder(
                        future: FirebaseFirestore.instance.collection('busking').doc(doc.id).collection('image').get(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return Container();
                          }
                          if (imageSnapshot.hasData) {
                            var firstImage = imageSnapshot.data!.docs.first ;
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ListTile(
                                title: Text(
                                    '${artistData['artistName']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('일시 : ${data['buskingStart']}'),
                                    Text('장소: ${artistData['artistName']}')
                                  ],
                                ),
                                /*leading: Image.asset('assets/기본.jpg'),*/
                                leading: Image.network(firstImage['path'],width: 100,),
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                        builder: (context) =>ConcertDetails(document: doc),));
                                },
                              ),
                            );
                          } else{
                            return Container();
                          }
                        }
                      );
                    }

                  );
                }

              );
            },
          )
      ),
    );
  }
}



class CommList extends StatefulWidget {
  const CommList({super.key});

  @override
  State<CommList> createState() => _CommListState();
}

class _CommListState extends State<CommList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("상업공간"),
    );
  }
}

