import 'package:indie_spot/artistInfo.dart';
import 'package:indie_spot/loading.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'donationPage.dart';
import 'dart:async';
import 'package:get/get.dart';

class ConcertDetails extends StatefulWidget {
  final DocumentSnapshot document;

  ConcertDetails({required this.document});

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
  String updatedComment = '';
  String currentContent = ""; // 현재 댓글 내용
  String buskingId = ""; // 버스킹 ID
  String reviewId = "";
  String _spotName = '';
  
  Future<void> loadBuskingData() async {
    buskingData = null;
    DocumentSnapshot<Map<String, dynamic>> buskingSnapshot = await getBuskingDetails(widget.document.id);
    // artistId로 검색 추가
    DocumentSnapshot<Map<String, dynamic>> artistSnapshot = await getArtist(buskingSnapshot.data()?['artistId']);

    setState(() {
      buskingData = buskingSnapshot.data();
      // 추가(뿌리는 부분에서 artistData => artistData2로 변경)
      artistData2 = artistSnapshot.data();
      _artistId = buskingSnapshot.data()?['artistId'];
      getArtistImages(buskingSnapshot.data()?['artistId']);
    });
  }
  
  Future<void> _searchSpotName() async{
    var spotDocument = await fs.collection('busking_spot').doc(widget.document.get('spotId')).get();
    var data = spotDocument.data();
    setState(() {
      _spotName = data!['spotName'];
    });
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadBuskingData(),
      loadBuskingImages(),
      loadBuskingReview(),
      getNickFromFirestore(),
      fetchData(),
      _searchSpotName(),
    ]);
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

  @override
  void initState() {
    super.initState();
    if (buskingReview2 != null) {
      buskingReview2!.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    }

    _userId = Provider
        .of<UserModel>(context, listen: false)
        .userId;
    loadAllData();
  }

  _alertDialogWidget(String buskingId, String reviewId, String currentContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedContent = currentContent;
        TextEditingController textEditingController =
        TextEditingController(text: currentContent);
        return AlertDialog(
          title: Text('댓글 수정'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                updatedContent = value;
              });
            },
            controller: textEditingController,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // 수정 내용을 저장하는 로직 추가
                if (updatedContent.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('busking')
                        .doc(buskingId)
                        .collection('review')
                        .doc(reviewId)
                        .update({'content': updatedContent});
                  } catch (e) {
                    print('Error updating review content: $e');
                    // 에러 핸들링을 원하는 대로 추가하세요.
                  }
                }
                Navigator.pop(context);
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _followAdd() async {
    if (_userId == null) {
      _alertDialogWidget('', '', ''); // 빈 문자열 전달
    } else {
      CollectionReference followAdd = fs
          .collection('artist')
          .doc(_artistId)
          .collection('follower');

      await followAdd.add({'userId': _userId});
      DocumentReference artistDoc = fs.collection('artist').doc(_artistId);
      artistDoc.update({
        'followerCnt': FieldValue.increment(1), // 1을 증가시킵니다.
      });

      var myFollowingRef = fs.collection('userList').doc(_userId);
      var myFollowing = await myFollowingRef.collection('following');

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
    }

    return imageWidgets;
  }

  Future<void> submitReview(String buskingID, double userRating) async {
    if (!_isReviewEmpty) {
      await addReview(buskingID, _review.text, userRating);
      _review.clear();
      rating = 0.0;
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
      } else {
        print('해당하는 아티스트를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  Future<void> editConcert() async{

  }

  Future<void> deleteConcert() async{
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('버스킹 삭제'),
      content: Text('정말 삭제하시겠습니까?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('취소')),
        TextButton(onPressed: () async{
          var buskingDocument = fs.collection('busking').doc(widget.document.reference.id);
          var imageSnapshot = buskingDocument.collection('image').limit(1).get();
          var reviewSnapshot = buskingDocument.collection('review').get();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return LoadingWidget();
            },
            barrierDismissible: false,
          );

          // 이미지와 리뷰 데이터를 병렬로 가져오기 위해 Future.wait 사용
          List<QuerySnapshot> snapshots = await Future.wait([imageSnapshot, reviewSnapshot]);

          var imageDocs = snapshots[0].docs; // 이미지 스냅샷
          var reviewDocs = snapshots[1].docs; // 리뷰 스냅샷

          // 이미지가 있는 경우 첫 번째 이미지 문서 삭제
          if (imageDocs.isNotEmpty) {
            await imageDocs.first.reference.delete();
          }

            // 리뷰 문서들을 병렬로 삭제
          await Future.wait(reviewDocs.map((review) => review.reference.delete()));

          // 마지막으로 버스킹 문서 삭제
          await buskingDocument.delete();

          Get.back();
          Get.back();
          Get.back();
        }, child: Text('삭제'))
      ],
    ),);
  }
  
  @override
  Widget build(BuildContext context) {
    String? loginArtistId = Provider.of<UserModel>(context, listen: false).artistId;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:Color(0xFF233067), // 앱바 배경색
          actions: [
            if(_artistId == loginArtistId)
              IconButton(onPressed: () => editConcert(), icon: Icon(Icons.edit)),
            if(_artistId == loginArtistId || Provider.of<UserModel>(context, listen: false).isAdmin)
              IconButton(onPressed: () => deleteConcert(), icon: Icon(Icons.delete)),
          ],
          title: Text(
            '공연 상세 페이지',
            style: TextStyle(
              color: Colors.white, // 글자색
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white), // 뒤로가기 아이콘 색상
          bottom: TabBar(
            indicatorColor: Colors.white, // 선택된 탭 아래의 효과 색상
            labelColor: Colors.white, // 선택된 탭의 글자색
            unselectedLabelColor: Colors.white, // 선택되지 않은 탭의 글자색
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
                              Get.to(
                                DonationPage(artistId: _artistId!),
                                transition: Transition.noTransition
                              ); // null이 아님을 확신하고 사용
                            },
                            child: Image.asset(
                              'assets/nukki.png', // 추가할 이미지의 경로
                              height: 50, // 높이 조절
                              width: 50, // 너비 조절
                            ),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      width: double.infinity,
                      height: 55,
                      color: Color(0xFF233067),
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '공연 정보',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 20, 8, 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80,
                                child: Text('공연이름', style: TextStyle(fontWeight: FontWeight.w500),),
                              ),
                              Text(buskingData?['title'])
                            ],
                          ),
                          SizedBox(height: 10,),
                          Container(
                            child:Row(
                              children: [
                                Container(
                                  width: 80,
                                  child: Text('공연시간', style: TextStyle(fontWeight: FontWeight.w500),),
                                ),
                                Text(
                                  '${DateFormat('yyyy-MM-dd HH:mm').format(buskingData?['buskingStart'].toDate())}',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Container(
                                width: 80,
                                child: Text('공연장소', style: TextStyle(fontWeight: FontWeight.w500),),
                              ),
                              Text(_spotName)
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Container(
                                width: 80,
                                child: Text('공연설명', style: TextStyle(fontWeight: FontWeight.w500),),
                              ),
                              Expanded( // Using Expanded to allow the text to take available space
                                child: SingleChildScrollView(
                                  child: Text(
                                    buskingData?['description'],
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 1.0,
                      width: 320,
                      color: Colors.black.withOpacity(0.1),
                    ),
                    Container(
                      width: double.infinity,
                      height: 50,
                      color: Color(0xFF233067),
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "아티스트 정보",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                if (_followerFlg) {
                                  _followDelete();
                                  _followerFlg = false;
                                } else {
                                  _followAdd();
                                  _followerFlg = true;
                                }
                              });
                            },
                            style: ButtonStyle(
                              alignment: Alignment.center
                            ),
                            child: Center(
                              child: Text(
                                _followerFlg ? '팔로잉' : '팔로우',
                                style: TextStyle(
                                  fontSize: 16, // 텍스트 버튼의 텍스트 크기 변경
                                  fontWeight: FontWeight.w500, // 텍스트 버튼의 텍스트 굵기 변경
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ListTile(
                        onTap: ()=> Get.to(
                            () => ArtistInfo(_artistId!),
                            transition: Transition.noTransition
                        ),
                        leading: Image.network(
                          _path ?? '',
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          artistData2?['artistName'],
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${artistData2?['genre']} / ${artistData2?['detailedGenre']}'
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // 두 번째 탭 (공연 후기)--------------------------------------------------------------------------------------------
            SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    // 상단 이미지
                    for (var index = 0; index < buskingImages!.length; index++)
                      Image.network(
                        buskingImages![index]['path'],
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    Container(
                      width: double.infinity,
                      height: 55,
                      color: Color(0xFF233067),
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '리뷰',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
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
                                },
                              ),
                            ],
                          ),
                          Container(

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
                                  textInputAction: TextInputAction.go,
                                  onSubmitted: (value) async{
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
                                      await submitReview(widget.document.id, userRating).then((value) => loadBuskingReview());
                                    }
                                  },
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(onPressed: () async{
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
                                        if(_review.text != '') {
                                          double userRating = rating;
                                          await submitReview(widget.document.id, userRating).then((value) => loadBuskingReview());
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('리뷰를 입력해주세요')));
                                        }
                                      }
                                    }, icon: Icon(Icons.send)),
                                    suffixIconColor: Color(0xFF233067),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xFF233067), width: 2)
                                    )
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Container(
                                  height: 1.0,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
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
                                          fontSize: 15,
                                          fontWeight: showLatestFirst ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    InkWell(
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
                                          fontSize: 15,
                                          fontWeight: showLatestFirst ? FontWeight.normal : FontWeight.w600,
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
                                            height: 160,
                                            width: double.infinity,
                                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "${document['nick']}",
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                                                    ),
                                                    if (document['nick'] == _nick)
                                                      TextButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              TextEditingController textEditingController = TextEditingController(text: document['content']);
                                                              return AlertDialog(
                                                                title: Text('댓글 수정'),
                                                                content: TextField(
                                                                  controller: textEditingController,
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () async {
                                                                      if (updatedComment.isNotEmpty) {
                                                                        try {
                                                                          await FirebaseFirestore.instance
                                                                              .collection('busking')
                                                                              .doc(widget.document.id)
                                                                              .collection('review')
                                                                              .doc(document.reference.id)
                                                                              .update({'content': textEditingController.text});
                                                                          Navigator.pop(context);
                                                                        } catch (e) {
                                                                          print('Error updating review content: $e');
                                                                        }
                                                                      }
                                                                    },
                                                                    child: Text(
                                                                      '저장',
                                                                      style: TextStyle(color: Color(0xFF233067)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Text(
                                                          '수정하기',
                                                          style: TextStyle(color: Colors.black),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                Text(
                                                  "${document['reviewContents']}",
                                                  style: TextStyle(fontSize: 16), // Adjust font size
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
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
                                                    Text(
                                                      "${DateFormat('yyyy-MM-dd').format(document['timestamp'].toDate())}",
                                                      style: TextStyle(fontSize: 13, color: Colors.black87),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ),
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