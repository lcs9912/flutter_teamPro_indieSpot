import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/login.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class ConcertDetails extends StatefulWidget {
  final DocumentSnapshot document;
  final String artistId;


  ConcertDetails({required this.document, required this.artistId});

  @override
  _ConcertDetailsState createState() => _ConcertDetailsState();
}

class _ConcertDetailsState extends State<ConcertDetails> {
  Map<String, dynamic>? buskingData;
  // 변수 추가( 기존에 artistData 있어서 2붙임 일단)
  Map<String, dynamic>? artistData2;


  TextEditingController _review = TextEditingController();
  double rating = 0.0;
  String? _userId;

  Future<void> loadBuskingData() async {
    buskingData = null;
    DocumentSnapshot<Map<String, dynamic>> buskingSnapshot = await getBuskingDetails(widget.document.id);
    // artistId로 검색 추가
    DocumentSnapshot<Map<String, dynamic>> artistSnapshot = await getArtist(buskingSnapshot.data()?['artistId']);
    setState(() {
      buskingData = buskingSnapshot.data();
      // 추가(뿌리는 부분에서 artistData => artistData2로 변경)
      artistData2 = artistSnapshot.data();
    });
  }



  @override
  void initState() {
    super.initState();
    loadBuskingData();
    loadBuskingImages();
    loadBuskingReview();


    _userId = Provider.of<UserModel>(context, listen: false).userId;
    print('real  ${_userId}');

  }
  //----------------------------------------------------두번째 탭 영역--------------------------------------------------------------------
 // 필요한 경우 초기값 설정

  void onRatingChanged(double newRating) {
    setState(() {
      rating = newRating;
    });
  }
  Future<void> addReview(String buskingID, String review, double rating) async {
    try {
      Map<String, dynamic> reviewData = {
        'nick': 'test2',
        'content': review,
        'reviewContents': review,
        'timestamp': FieldValue.serverTimestamp(),
        'rating': rating,
      };

      await FirebaseFirestore.instance
          .collection('busking')
          .doc(buskingID) // 기존 문서를 참조합니다.
          .collection('review')
          .add(reviewData);
    } catch (e) {

    }
  }

  Future<void> submitReview(String buskingID, double userRating) async {
    if (!_isReviewEmpty) {
      await addReview(buskingID, _review.text, userRating);
      _review.clear();
    }
  }


  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getBuskingReview(String buskingID) async {
    return await FirebaseFirestore.instance.collection('busking').doc(buskingID).collection('review').get().then((snapshot) {

      return snapshot.docs;
    });
  }
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? buskingImages;
  Future<void> loadBuskingImages() async {
    buskingImages = await getBuskingImages(widget.document.id);
    setState(() {});

    // 각 이미지의 NAME 필드 값을 출력합니다.
    if (buskingImages != null) {
      for (var image in buskingImages!) {

      }
    }
  }

  Future<void> loadBuskingReview() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> review = await getBuskingReview(widget.document.id);
    setState(() {
      buskingReview = review;
    });
  }
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? buskingReview;


  bool _isReviewEmpty = true;

  Future<List<Map<String, dynamic>>> getBuskingReviewNick(String buskingID) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('busking')
        .doc(buskingID)
        .collection('review')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getBuskingDetails(String buskingID) async {
    return await FirebaseFirestore.instance.collection('busking').doc(buskingID).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getArtist(String artistId) async {
    return await FirebaseFirestore.instance.collection('artist').doc(artistId).get();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getBuskingImages(String buskingID) async {
    return await FirebaseFirestore.instance.collection('busking').doc(buskingID).collection('image').get().then((snapshot) {
      return snapshot.docs;
    });
  }

  DocumentSnapshot<Object?>? artistData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Object? artistIdObject = ModalRoute.of(context)?.settings.arguments;
    String artistId = artistIdObject?.toString() ?? '';

    // 다음에 해당 데이터를 불러옵니ㄴㄴ다.
    loadArtistDataByArtistId(artistId);
  }

  Future<void> loadArtistDataByArtistId(String artistId) async {
    try {
      DocumentSnapshot artistDoc = await FirebaseFirestore.instance
          .collection('artist')
          .doc(buskingData?['artistId'])
          .get();

       artistId = buskingData?['artistId'];

      if (artistDoc.exists) {
        artistData = artistDoc; // 데이터를 artistData에 할당합니다.
        print(artistDoc.data());
      } else {
        print('해당하는 아티스트를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  Future<void> getArtistData(String artistId) async {
    print("아티스트 아이디 ===> $artistId");

    try {
      QuerySnapshot artistDocs = await FirebaseFirestore.instance
          .collection('artist')
          .where('artistId', isEqualTo: artistId)
          .get();

      if (artistDocs.docs.isNotEmpty) {
        DocumentSnapshot artistDoc = artistDocs.docs[0];
        Map<String, dynamic>? artistData = artistDoc.data() as Map<String, dynamic>;

        if (artistData != null) {
          print(artistData);
        } else {
          print('해당하는 아티스트를 찾을 수 없습니다.');
        }
      } else {
        print('해당하는 아티스트를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    print(buskingData?['artistId']);
  print(widget.document.id);
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
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '아티스트 ${artistData2?['artistName']}',
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
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  "장르          rock",
                                  style: TextStyle(fontSize: 15),
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


                        ],
                      ),
                    ),
                    SizedBox(height: 10),

                  ],
                ),
              ),
            ),
            // 두 번째 탭 (공연 후기)--------------------------------------------------------------------------------------------
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
                      itemSize: 30.0,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) {
                        setState(() {
                          rating = value;
                        });
                        // rating 값을 여기서 활용하거나 필요한 곳으로 전달할 수 있습니다.
                        // 예를 들어, submitReview 함수 호출 등을 여기서 할 수 있습니다.
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
                                ' $_userId', // 사용자의 ID를 텍스트로 표시
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),

                              Spacer(),

                              ElevatedButton(
                                onPressed: () {
                                  double userRating = rating;
                                  submitReview(widget.document.id, userRating);
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

                          Column(
                            children: [
                              // 리뷰 출력 부분
                              if (buskingReview != null && buskingReview!.isNotEmpty)
                                for (var document in buskingReview!)
                                  if (document['rating'] != null)
                                    Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                      padding: EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200], // Adjust background color as needed
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${DateFormat('yyyy-MM-dd').format(document['timestamp'].toDate())}",
                                            style: TextStyle(fontSize: 14, color: Colors.black87), // Adjust font size and color
                                          ),
                                          Text(
                                            "${document['nick']}",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Adjust font size and weight
                                          ),
                                          Text(
                                            "${document['reviewContents']}",
                                            style: TextStyle(fontSize: 16), // Adjust font size
                                          ),
                                          RatingBarIndicator(
                                            rating: double.parse(document['rating'].toString()),
                                            itemBuilder: (context, index) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 20.0,
                                            direction: Axis.horizontal,
                                          ),
                                        ],
                                      ),
                                    ),
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