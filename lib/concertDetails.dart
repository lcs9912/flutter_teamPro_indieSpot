import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConcertDetails extends StatefulWidget {
  @override
  _ConcertDetailsState createState() => _ConcertDetailsState();
}

class _ConcertDetailsState extends State<ConcertDetails> {
  Map<String, dynamic>? buskingData; // 받아온 버스킹 데이터를 저장할 변수


  Future<DocumentSnapshot<Map<String, dynamic>>> getBuskingDetails(String buskingID) async {
    return await FirebaseFirestore.instance.collection('busking').doc(buskingID).get();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getBuskingImages(String buskingID) async {
    return await FirebaseFirestore.instance.collection('busking').doc(buskingID).collection('image').get().then((snapshot) {
      print('스냅샷 ${snapshot.docs}');
      return snapshot.docs;
    });
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>>? buskingImages;

  Future<void> loadBuskingImages() async {
    buskingImages = await getBuskingImages('v395OaqYv58fY7ewS7lV');
    setState(() {});

    // 각 이미지의 NAME 필드 값을 출력합니다.
    if (buskingImages != null) {
      for (var image in buskingImages!) {
        print('이미지 이름: ${image['path']}');
      }
    }
  }


  Future<void> loadBuskingData() async {
    buskingData = null;
    DocumentSnapshot<Map<String, dynamic>> buskingSnapshot = await getBuskingDetails('v395OaqYv58fY7ewS7lV');
    setState(() {
      buskingData = buskingSnapshot.data();
    });

    await loadBuskingImages(); // loadBuskingImages를 호출합니다.
  }

  @override
  void initState() {
    super.initState();
    loadBuskingData();
    loadBuskingImages();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('공연 상세 페이지'),
          bottom: TabBar(
            tabs: [
              Tab(text: '상세 정보'),
              Tab(text: '공연 후기'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 첫 번째 탭 (상세 정보)
            SingleChildScrollView(
              child: Container(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 상단 이미지
                    for (var index = 0; index < buskingImages!.length; index++)
                      Image.asset(
                        '${buskingImages![index]['path']}',

                        height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 30), // 간격 추가
                    Text(
                      ' ${buskingData?['description']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 10), // 간격 추가
                    Container(
                      height: 1.0,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.1),
                    ),
                    SizedBox(height: 10), // 간격 추가
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "기본정보",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(

                      color: Color(0xFFdcdcdc),
                      height: 250,
                      width: 400,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Image.asset(
                                'assets/기본.jpg',
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ' ${buskingData?['aritistId']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 30),
                                Container(
                                  height: 1.0,
                                  width: 200,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  '장소 ${buskingData?['spotId']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  '버스킹 시간 ${buskingData?['buskingStart']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),


                                Text(
                                  "출연          musision",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "장르          rock",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "댓글",
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              // Add your refresh logic here
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: Icon(Icons.mode_comment),
                        ),
                        maxLines: null, // Allow multiple lines for the comment
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 두 번째 탭 (공연 후기)
            SingleChildScrollView(
              child: Center(
                child: Text('여기에 공연 후기가 들어갑니다.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}