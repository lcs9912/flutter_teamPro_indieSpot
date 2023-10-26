

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
class ConcertDetails extends StatefulWidget {
  @override
  _ConcertDetailsState createState() => _ConcertDetailsState();
}

TextEditingController _review = TextEditingController();
double rating = 0.0;
@override
void initState() {
  initState();
  _review.text = 'Initial text'; // Set your initial text here
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
    buskingImages = await getBuskingImages('RNy4zfYiBdHOcQwvt0pR');
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
    DocumentSnapshot<Map<String, dynamic>> buskingSnapshot = await getBuskingDetails('RNy4zfYiBdHOcQwvt0pR');
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
    loadBuskingReview();
  }
  //----------------------------------------------------두번째 탭 영역--------------------------------------------------------------------
  double rating = 0.0; // 필요한 경우 초기값 설정

  void onRatingChanged(double newRating) {
    setState(() {
      rating = newRating;
    });
  }

  Future<void> addReview(String buskingID, String review, [String? rating]) async {
    try {
      Map<String, dynamic> reviewData = {
        'nick': '사용자 닉네임',

        'content': review,
        'reviewContents': review, // 리뷰 내용을 reviewContents 필드에 저장합니다.
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (rating != null) {
        reviewData['rating'] = rating;
      }

      await FirebaseFirestore.instance
          .collection('busking')
          .doc(buskingID)
          .collection('review')
          .add(reviewData);
    } catch (e) {
      print('리뷰 추가 중 오류 발생: $e');
    }
  }

  Future<void> submitReview() async {
    if (!_isReviewEmpty) {
      await addReview('RNy4zfYiBdHOcQwvt0pR', _review.text, rating.toString());
      _review.clear(); // 댓글 작성이 완료되면 TextField를 초기화합니다.
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getBuskingReview(String buskingID) async {
    return await FirebaseFirestore.instance.collection('busking').doc(buskingID).collection('review').get().then((snapshot) {
      print('리뷰 스냅샷 ${snapshot.docs}');
      return snapshot.docs;
    });
  }


  Future<void> loadBuskingReview() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> review = await getBuskingReview('RNy4zfYiBdHOcQwvt0pR');
    setState(() {
      buskingReview = review;
    });
  }
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? buskingReview;

  TextEditingController _review = TextEditingController();
  bool _isReviewEmpty = true;

  Future<List<Map<String, dynamic>>> getBuskingReviewNick(String buskingID) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('busking')
        .doc(buskingID)
        .collection('review')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
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
                                  '버스킹시간 ${buskingData?['buskingStart']}',
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

                    RatingBar.builder(
                      initialRating: rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 50.0,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),


                    SizedBox(height: 20,),
                    Container(
                      height: 550,
                      width: 300,
                      child: Column(
                        children: [
                          TextField(
                            controller: _review,
                            maxLines: null,
                            onChanged: (value) {
                              setState(() {
                                _isReviewEmpty = value.isEmpty;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: '리뷰를 작성하세요...',
                              errorText: _isReviewEmpty ? '리뷰를 입력해주세요' : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 10), // Add some space between TextField and other elements
                          Row(
                            children: [
                              SizedBox(width: 10), // Add some space between avatar and nickname
                              Text(
                                ' ${buskingReview?[0]['nick']}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Spacer(), // Push the button to the right
                              ElevatedButton(
                                onPressed: () {
                                  submitReview();
                                  addReview('HNkRaJfMyHYdAD2NVBeE', _review.text, rating.toString());
                                },
                                child: Text('댓글작성'),
                              ),
                              SizedBox(height: 20,),
                            ],
                          ),
                         // Text("후기글 (총${buskingReview?[0]['reviewCnt']}개)"),
                          SizedBox(height: 20,),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    // 최신순으로 리뷰 정렬 및 UI 업데이트
                                    buskingReview?.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
                                  });
                                },
                                child: Text("최신순                 "),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    // 별점 높은 순으로 리뷰 정렬 및 UI 업데이트
                                    buskingReview?.sort((a, b) => b['rating'].compareTo(a['rating']));
                                  });
                                },
                                child: Text("별점높은순                  "),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    // 별점 낮은 순으로 리뷰 정렬 및 UI 업데이트
                                    buskingReview?.sort((a, b) => a['rating'].compareTo(b['rating']));
                                  });
                                },
                                child: Text("별점낮은순"),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Container(
                            height: 1.0,
                            width: 400,
                            color: Colors.black.withOpacity(0.1),
                          ),

                          Text("${buskingReview?[0]['reviewContents']}"),

                          if (buskingReview != null && buskingReview!.isNotEmpty)
                            for (var document in buskingReview!)
                              if (document['rating'] != null)
                              // Text(document['rating'].toString()),
                                RatingBarIndicator(
                                  rating: double.parse(document['rating']!.toString()),
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  direction: Axis.horizontal,
                                ),
                          Row(
                            children: [
                              Text("${buskingReview?[0]['nick']}"),
                              Text("${buskingData?['buskingStart']}"),
                            ],

                          ),
                        ],
                      ),
                    )




                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}