import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/login.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'donationPage.dart';
import 'dart:async';

class ConcertDetails extends StatefulWidget {
  final DocumentSnapshot document;
  final String spotName;

  ConcertDetails({required this.document, required this.spotName});

  @override
  _ConcertDetailsState createState() => _ConcertDetailsState();
}


class _ConcertDetailsState extends State<ConcertDetails> {
  bool isLoading = true;
  Map<String, dynamic>? buskingData;
  // 변수 추가( 기존에 artistData 있어서 2붙임 일단)
  Map<String, dynamic>? artistData2;
  FirebaseFirestore fs = FirebaseFirestore.instance;

  bool _followerFlg = false; // 팔로우 했는지!
  bool showLatestFirst = true;
  bool scheduleFlg = false;
  int? folCnt; // 팔로워
  List<Map<String, dynamic>>? buskingReview2;

  List<QueryDocumentSnapshot<Map<String, dynamic>>>? artistImages;

  TextEditingController _review = TextEditingController();
  double rating = 0.0;
  String? _userId;
  String? _artistId;
  String? _path;
  String? _nick;

  Future<void> loadBuskingData() async {
    buskingData = null;
    DocumentSnapshot<Map<String, dynamic>> buskingSnapshot = await getBuskingDetails(widget.document.id);
    // artistId로 검색 추가
    DocumentSnapshot<Map<String, dynamic>> artistSnapshot = await getArtist(buskingSnapshot.data()?['artistId']);

    setState(() {
      buskingData = buskingSnapshot.data();
      // 추가(뿌리는 부분에서 artistData => artistData2로 변경)
      artistData2 = artistSnapshot.data();
      print(artistData2);
      _artistId = buskingSnapshot.data()?['artistId'];
      getArtistImages(buskingSnapshot.data()?['artistId']);
    });
  }

  Future<void> main() async {

    List<Map<String, dynamic>> reviewList = await getBuskingReviewNick(widget.document.id);

    print('Busking Reviews:');
    for (var review in reviewList) {
      print('Nick: ${review['nick']}');
    }
  }
  @override
  void initState() {
    super.initState();
    if (buskingReview2 != null) {
      buskingReview2!.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    }

    _userId = Provider
        .of<UserModel>(context, listen: false)
        .userId;
    loadBuskingData();
    loadBuskingImages();
    loadBuskingReview();
    getNickFromFirestore();
    fetchData();

  }
  Future<void> fetchData() async {
    try {
      // 여기서 데이터를 불러오는 비동기 작업을 수행합니다.
      await Future.delayed(Duration(seconds: 2)); // 예시로 2초 동안 대기
      setState(() {
        isLoading = false; // 데이터 불러오기 완료 후 isLoading을 false로 변경
      });
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      setState(() {
        isLoading = false; // 오류가 발생해도 isLoading을 false로 변경
      });
    }
  }

  Future<void> getNickFromFirestore() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('userList')
          .doc(_userId)
          .get();

      if (documentSnapshot.exists) {
        String nick = documentSnapshot.data()!['nick'];
        print('nick: $nick');
        setState(() {
          _nick = nick;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching email: $e');
    }
  }
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
  void _followAdd() async {
    if (_userId == null) {
      _alertDialogWidget();
    } else {
      CollectionReference followAdd =
      fs.collection('artist').doc(_artistId).collection('follower');

      await followAdd.add({'userId': _userId});
      DocumentReference artistDoc = fs.collection('artist').doc(_artistId);
      artistDoc.update({
        'followerCnt': FieldValue.increment(1), // 1을 증가시킵니다.
      });
      // 유저
      var myFollowingRef = fs.collection('userList').doc(_userId);
      var myFollowing = await myFollowingRef.collection('following');
      print(_userId);
      await myFollowing.add({"artistId": _artistId});
      myFollowingRef.update({
        'followingCnt': FieldValue.increment(1),
      });

      _followCheck();
    }
  }
  void _followCheck() async {
    final followYnSnapshot = await fs
        .collection('artist')
        .doc(_artistId)
        .collection('follower')
        .where('userId', isEqualTo: _userId)
        .get(); // 데이터를 검색하기 위해 get()를 사용합니다.
    setState(() {
      if (followYnSnapshot.docs.isNotEmpty) {
        _followerFlg = true;
      } else {
        _followerFlg = false;
      }
      _followerCount(); // 팔로우count
    });
  }
  void _followerCount() async {
    final CollectionReference artistCollection =
    FirebaseFirestore.instance.collection('artist');
    final DocumentReference artistDocument =
    artistCollection.doc(_artistId);

    artistDocument.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // 문서가 존재하는 경우 필드 가져오기
        folCnt = documentSnapshot['followerCnt'];
      } else {
        folCnt = 0;
      }
    }).catchError((error) {
      print('데이터 가져오기 중 오류 발생: $error');
    });
  }
  // 팔로우 취소
  void _followDelete() async {
    CollectionReference followDelete =
    fs.collection('artist').doc(_artistId).collection('follower');

    var myFollowingRef = fs.collection('userList').doc(_userId);

    // 팔로우 관계를 삭제합니다.
    QuerySnapshot querySnapshot =
    await followDelete.where('userId', isEqualTo: _userId).get();
    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        // 해당 사용자와 관련된 문서를 삭제합니다.
        await document.reference.delete();

        DocumentReference artistDoc =
        fs.collection('artist').doc(_artistId);
        artistDoc.update({
          'followerCnt': FieldValue.increment(-1), // 1을 감소시킵니다.
        });
      }

      await myFollowingRef
          .collection('following')
          .where('artistId', isEqualTo: _artistId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      await myFollowingRef.update({
        'followingCnt': FieldValue.increment(-1),
      });
      _followCheck();
    }
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
        'nick': _nick,
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

  // artistData2
  List<Widget> getImageWidgets() {
    List<Widget> imageWidgets = [];

    for (var index = 0; index < buskingImages!.length; index++) {
      var imagePath = buskingImages![index]['path'];

      // 이미지 URL이 유효한지 확인
      if (Uri.parse(imagePath).isAbsolute) {
        // 유효한 URL일 경우 Image.network 사용
        imageWidgets.add(
          Image.network(
            imagePath,
            height: 190,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } else {
        // 잘못된 URL이면 에러 핸들링 또는 대체 이미지를 사용할 수 있습니다.
        imageWidgets.add(
          Placeholder(
            fallbackHeight: 130,
            fallbackWidth: double.infinity,
          ),
        );
      }
    }

    return imageWidgets;
  }

  Future<void> getArtistImages(String artistId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('artist')
        .doc(artistId)
        .collection('image')
        .limit(1)
        .get();

    String path = '';

    if(snapshot.docs.isNotEmpty){
      var firstImageDocument = snapshot.docs.first;
      var data = firstImageDocument.data();
      print('111111111');
      print('${data['path']}');
      path = data['path'];
    }
    setState(() {
      _path = path;
    });
  }

  List<Widget> getArtistImageWidgets() {
    List<Widget> imageWidgets = [];
    if (artistImages != null) { // artistImages가 null인지 확인합니다.
      for (var index = 0; index < artistImages!.length; index++) {
        var imagePath = artistImages![index]['path'];

        // 이미지 URL이 유효한지 확인
        if (Uri.parse(imagePath).isAbsolute) {
          // 유효한 URL일 경우 Image.network 사용
          imageWidgets.add(
            Image.network(
              imagePath,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,

            ),
          );
          print(artistImages![index]['path']);
        } else {
          // 잘못된 URL이면 에러 핸들링 또는 대체 이미지를 사용할 수 있습니다.
          imageWidgets.add(
            Placeholder(
              fallbackHeight: 130,
              fallbackWidth: double.infinity,
            ),
          );
          print(artistImages![index]['path']);
        }
      }
    }

    return imageWidgets;
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


    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, // 앱바 배경색
          title: Text(
            '공연 상세 페이지',
            style: TextStyle(
              color: Colors.black, // 글자색
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black), // 뒤로가기 아이콘 색상
          bottom: TabBar(
            indicatorColor: Colors.black, // 선택된 탭 아래의 효과 색상
            labelColor: Colors.black, // 선택된 탭의 글자색
            unselectedLabelColor: Colors.grey, // 선택되지 않은 탭의 글자색
            tabs: [
              Tab(text: '상세 정보'),
              Tab(text: '공연 후기'),
            ],
          ),
        ),

        body: isLoading
            ? Center(
          child: CircularProgressIndicator(), // 로딩 중에 표시될 위젯
        )
            : TabBarView(

          children: [
            // 첫 번째 탭 (상세 정보)
            SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 상단 이미지
                    Stack(
                      children: [
                        // 기존 이미지 위젯들
                        ...getImageWidgets(),

                        // 새로운 이미지
                        Positioned(
                          top: 140, // 위치 조절
                          left: 340, // 위치 조절
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DonationPage(
                                    artistId: _artistId!, // null이 아님을 확신하고 사용
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/nukki.png', // 추가할 이미지의 경로
                              height: 50, // 높이 조절
                              width: 50, // 너비 조절
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Positioned(
                              top: 135, // 위치 조절
                              left: 280, // 위치 조절
                              child: Image.asset(
                                'assets/nheart.png', // 추가할 이미지의 경로
                                height: 70, // 높이 조절
                                width: 70, // 너비 조절
                              ),
                            ),
                            Positioned(
                              right: 1,
                              top: 1,
                              child: Text(folCnt != null ? folCnt.toString() : ''), // 데이터가 null이 아닌 경우에만 출력
                            ),
                            if (_followerFlg)
                              IconButton(
                                onPressed: () {
                                  _followDelete();
                                  setState(() {});
                                },
                                icon: Icon(Icons.person_add),
                              ),
                            if (!_followerFlg)
                              IconButton(
                                onPressed: () {
                                  _followAdd();
                                  setState(() {});
                                },
                                icon: Icon(Icons.person_add_alt),
                              ),
                          ],
                        )

                      ],
                    ),
                    SizedBox(height: 30), // 간격 추가
                    Container(
                      width: 600,
                      height: 40,
                      color: Color(0xFF3E2007),
                      padding: EdgeInsets.all(8.0), // 내부 여백 설정
                      child: Text(
                        ' ${buskingData?['description']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ),



                    Container(
                      width: 600,
                      height: 50,
                      color: Color(0xFF3E2007),
                      padding: EdgeInsets.all(8.0), // 내부 여백 설정
                      child: Text(
                        "  기본정보",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ),

                    Container(
                      color: Colors.grey[200],
                      height: 210,
                      width: 400,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),



                              ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Text(
                                  '이름: ${artistData2?['artistName']}',
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
                                  '장소: ${widget.spotName}', // widget을 사용하여 spotName에 접근합니다.
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  '버스킹시간: ${DateFormat('yyyy-MM-dd').format(buskingData?['buskingStart'].toDate())}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '장르: ${artistData2?['genre']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                             ClipRRect(
                              borderRadius: BorderRadius.circular(8.0), // 네모 모양을 위한 BorderRadius 설정
                              child: Image.network(
                                _path ?? '',
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],

                        ),
                      ),
                    ),
                    SizedBox(height: 20),

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
                      Image.network(
                        buskingImages![index]['path'],
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    SizedBox(height: 30), // 간격 추가

                    Padding(
                      padding: EdgeInsets.only(right:250 ), // 왼쪽 간격을 10으로 지정
                      child: RatingBar.builder(
                        initialRating: rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 20.0,
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
                    ),



                    Container(
                      height: 1050,
                      width: 350,
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
                                _nick ?? '게스트', // nick 값이 null이면 '게스트'를 출력
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),

                              Spacer(),

                              ElevatedButton(
                                onPressed: () {
                                  if (_nick == null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('로그인 후 리뷰 작성이 가능합니다'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('확인'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    double userRating = rating;
                                    submitReview(widget.document.id, userRating);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF392F31), // 배경색을 392F31로 설정
                                ),
                                child: Text('댓글작성'),
                              ),

                              SizedBox(height: 20,),
                            ],
                          ),
                          // Text("후기글 (총${buskingReview?[0]['reviewCnt']}개)"),
                          SizedBox(height: 20,),
                          Container(
                            height: 1.0,
                            width: 400,
                            color: Colors.black.withOpacity(0.1),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 300), // 오른쪽 간격 조절
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (buskingReview != null) {
                                        buskingReview!.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
                                        showLatestFirst = true;
                                      }
                                    });
                                  },
                                  child: Text(
                                    "최신순",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: showLatestFirst ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 290), // 왼쪽 간격 조절
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (buskingReview != null) {
                                        buskingReview!.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
                                        showLatestFirst = false;
                                      }
                                    });
                                  },
                                  child: Text(
                                    "오래된순",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: showLatestFirst ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),


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
                                        color: Colors.white60, // 흰색 배경색으로 설정
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: Offset(0, 2), // 그림자의 위치 조정
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            "${document['nick']}",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Adjust font size and weight
                                          ),
                                          Text(
                                            "${document['reviewContents']}",
                                            style: TextStyle(fontSize: 16), // Adjust font size
                                          ),
                                          SizedBox(height: 10,),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: RatingBarIndicator(
                                              rating: double.parse(document['rating'].toString()),
                                              itemBuilder: (context, index) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 20.0,
                                              direction: Axis.horizontal,
                                            ),
                                          ),

                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "${DateFormat('yyyy-MM-dd').format(document['timestamp'].toDate())}",
                                              style: TextStyle(fontSize: 13, color: Colors.black87),
                                            ),
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