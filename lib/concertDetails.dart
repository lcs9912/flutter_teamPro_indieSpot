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
      return snapshot.docs;
    });
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>>? buskingImages;

  Future<void> loadBuskingImages() async {
    buskingImages = await getBuskingImages('rSGUvxgxllJ1t3qDchUU');
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
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '아티스트 아이디: ${buskingData?['aritistId']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '버스킹 설명: ${buskingData?['description']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '스팟 아이디: ${buskingData?['spotId']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10), // Add some spacing
                    for (var index = 0; index < buskingImages!.length; index++)
                      Image.asset(
                        '${buskingImages![index]['path']}',
                        height: 100,
                        width: 100,
                      ),


                  ],
                ),
              ),
            ),
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
