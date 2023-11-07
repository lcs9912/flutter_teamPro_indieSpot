import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/pointDetailed.dart';
import 'package:indie_spot/userEdit.dart';

import 'followList.dart';

class Profile extends StatefulWidget {
  final TextEditingController nicknameController;
  final TextEditingController introductionController;
  final String? userId;

  Profile({
    required this.nicknameController,
    required this.introductionController,
    required this.userId,
  });

  void main() {
    String postId = '3QjunO69Eb2OroMNJKWU';
    getPostsData(postId);
  }
  @override
  _ProfileState createState() => _ProfileState();

  void getPostsData(String postId) {}
}
List<Map<String, dynamic>> _postsData = [];

class _ProfileState extends State<Profile> {

  List<String> imagePaths = []; // Define the list of image paths
  String? _nickFromFirestore; // Firestore에서 가져온 'nick' 값을 저장할 변수
  String? _introductionFromFirestore;
  String? _followerCount = '0'; // 기본값으로 0 설정
  String? _followerCntFromFirestore;
  String? _followingCntFromFirestore;
  String? _followingCount;
  String? _followingCnt;


  @override
  void initState() {
    super.initState();
    getNickFromFirestore(widget.userId);
    getIntroductionFromFirestore();
    getPostsData(widget.userId!);
  }

  Future<void> getPostsData(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> concertBoardSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc('3QjunO69Eb2OroMNJKWU')
          .collection('concert_board')
          .where('userId', isEqualTo: userId)
          .get();

      QuerySnapshot<Map<String, dynamic>> freeBoardSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc('3QjunO69Eb2OroMNJKWU')
          .collection('free_board')
          .where('userId', isEqualTo: userId)
          .get();

      QuerySnapshot<Map<String, dynamic>> teamBoardSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc('3QjunO69Eb2OroMNJKWU')
          .collection('team_board')
          .where('userId', isEqualTo: userId)
          .get();

      QuerySnapshot<Map<String, dynamic>> imageSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc('3QjunO69Eb2OroMNJKWU')
          .collection('image')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> concertBoardDataList = concertBoardSnapshot.docs.map((doc) => doc.data()!).toList();
      List<Map<String, dynamic>> freeBoardDataList = freeBoardSnapshot.docs.map((doc) => doc.data()!).toList();
      List<Map<String, dynamic>> teamBoardDataList = teamBoardSnapshot.docs.map((doc) => doc.data()!).toList();
      List<Map<String, dynamic>> imageDataList = imageSnapshot.docs.map((doc) => doc.data()!).toList();

      setState(() {
        _postsData = [...concertBoardDataList, ...freeBoardDataList, ...teamBoardDataList, ...imageDataList];
      });

      // 포스트 데이터를 콘솔에 출력합니다.
      print('포스트 데이터: $_postsData');

    } catch (e) {
      print('포스트 데이터를 가져오는 중 오류 발생: $e');
    }
  }



  Future<void> getNickFromFirestore(String? userId) async {
    try {
      if (userId != null) {
        DocumentSnapshot<
            Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('userList')
            .doc(userId)
            .get();

        if (snapshot.exists) {
          var nick = snapshot.data()!['nick'];
          var introduction = snapshot.data()!['introduction'];
          var followingCnt = snapshot.data()!['followingCnt'];
          var followerCnt = snapshot.data()!['followerCnt'];
          setState(() {
            _nickFromFirestore = nick;
            _introductionFromFirestore = introduction;
            _followingCntFromFirestore = followingCnt.toString();
            _followerCntFromFirestore = followerCnt.toString();
          });

        }
      }
    } catch (e) {
      print('Error fetching nick from Firestore: $e');
    }
  }

  Future<void> getAllSubcollections(String postId, String userId) async {
    try {
      // 'posts' 컬렉션 내의 특정 문서에 대한 참조를 가져옵니다.
      DocumentReference<Map<String, dynamic>> postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId);

      // 해당 문서에 연결된 서브컬렉션의 이름을 가져옵니다.
      CollectionReference<Map<String, dynamic>> subcollectionsRef = postRef.collection(postId);

      // 해당 서브컬렉션 내의 문서들을 가져옵니다.
      QuerySnapshot<Map<String, dynamic>> subcollectionDocumentsSnapshot = await subcollectionsRef
          .where('userId', isEqualTo: userId) // userId와 같은 값을 가진 문서들만 가져옵니다.
          .get();

      List<Map<String, dynamic>> subcollectionDataList = subcollectionDocumentsSnapshot.docs
          .map((doc) => doc.data()!)
          .toList();

      print('해당 사용자의 데이터: $subcollectionDataList');
    } catch (e) {
      print('데이터를 가져오는 중 오류 발생: $e');
    }
  }


  Future<void> getFollowerFollowingCounts() async {
    try {
      if (widget.userId != null) {
        // Get follower count
        DocumentSnapshot<

            Map<String, dynamic>> followerSnapshot = await FirebaseFirestore
            .instance
            .collection('userList')
            .doc(widget.userId)
            .collection('follower')
            .doc('counts')
            .get();

        if (followerSnapshot.exists) {
          setState(() {
            _followerCount = followerSnapshot.data()!['count'].toString();
          });
        }


        // Get following count
        DocumentSnapshot<
            Map<String, dynamic>> followingSnapshot = await FirebaseFirestore
            .instance
            .collection('userList')
            .doc(widget.userId)
            .collection('following')
            .doc('counts')
            .get();

        if (followingSnapshot.exists) {
          setState(() {
            _followingCount = followingSnapshot.data()!['count'].toString();
          });
        }
      }
    } catch (e) {
      print('Error fetching follower and following counts: $e');
    }
  }
  Future<void> getFollowerFollowingCnt() async {
    try {
      if (widget.userId != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore
            .instance
            .collection('userList')
            .doc(widget.userId)
            .get();

        if (userSnapshot.exists) {
          var followingCnt = userSnapshot.data()!['followingCnt'];

          if (followingCnt != null) {
            print('Following count is: $followingCnt'); // 올바른 값이 출력될 것입니다.
            setState(() {
              _followingCnt = followingCnt.toString();
            });
          } else {
            print('followingCnt is null'); // 만약 null일 경우 출력됩니다.
          }
        }
      }
    } catch (e) {
      print('Error fetching follower and following counts: $e');
    }
  }

  Future<void> getBoardDocumentIds(String? userId) async {
    try {
      if (userId != null) {
        QuerySnapshot<Map<String, dynamic>> boardSnapshot = await FirebaseFirestore.instance
            .collection('userList')
            .doc(userId)
            .collection('board')
            .get();

        List<String> documentIds = boardSnapshot.docs.map((doc) => doc.id).toList();

        // 이제 'board' 서브컬렉션에서 문서의 아이디 목록을 얻었습니다.
        print('board 서브컬렉션에서의 문서 아이디들: $documentIds');
      }
    } catch (e) {
      print('board 서브컬렉션에서 문서 아이디를 가져오는 중 오류 발생: $e');
    }
  }
  //3QjunO69Eb2OroMNJKWU

  Future<List<String>> getImageData() async {
    try {
      List<String> imagePaths = [];

      if (widget.userId != null) {
        // Get image paths
        QuerySnapshot<
            Map<String, dynamic>> imageSnapshot = await FirebaseFirestore
            .instance
            .collection('userList')
            .doc(widget.userId)
            .collection('image')
            .get();

        // Process the image paths
        imagePaths =
            imageSnapshot.docs.map((doc) => doc.data()['path'].toString())
                .toList();
      }

      return imagePaths;
    } catch (e) {
      print('Error fetching image paths: $e');
      return []; // Return an empty list in case of an error
    }
  }


  Future<void> getIntroductionFromFirestore() async {
    try {
      if (widget.userId != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('userList')
            .doc(widget.userId)
            .get();

        if (snapshot.exists) {
          var introduction = snapshot.data()!['introduction']; // 필드 이름을 소문자로 수정
          setState(() {
            _introductionFromFirestore = introduction;
          });
          print('Introduction from Firestore: $_introductionFromFirestore');
        }
      }
    } catch (e) {
      print('Error fetching introduction from Firestore: $e');
    }
  }

  List<Widget> generateIntroductionWidgets(String introductionText) {
    const int maxCharactersPerLine = 25;

    List<Widget> widgets = [];
    for (int i = 0; i < introductionText.length; i += maxCharactersPerLine) {
      int endIndex = i + maxCharactersPerLine;
      if (endIndex > introductionText.length) {
        endIndex = introductionText.length;
      }
      String line = introductionText.substring(i, endIndex);
      widgets.add(Text(line, style: TextStyle(fontSize: 16)));
    }
    return widgets;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경색을 흰색으로 설정
        title: Text(
          '프로필',
          style: TextStyle(color: Colors.black), // 텍스트 색을 검은색으로 설정
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black, // 뒤로가기 아이콘 색을 검은색으로 설정
          ),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 기능 추가
          },
        ),
      ),
        body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: imagePaths.isNotEmpty
                      ? AssetImage(
                      imagePaths[0]) // Assuming you want to use the first image from the list
                      : AssetImage('assets/기본.jpg'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) => FollowList()),
                    );
                  },
                  child: Container(

                    child: Column(
                      children: [
                        // Text(
                        //   'Follower: $_followerCount',
                        //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        // ),
                        Text(
                          '$_nickFromFirestore',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          '   Following: $_followingCntFromFirestore',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),

                      ],
                    ),
                  ),
                )

              ],
            ),
            SizedBox(height: 20),
            Divider( // 이 부분이 추가된 부분입니다.
              color: Colors.grey[300], // 회색 줄의 색상을 지정합니다.
              thickness: 1, // 회색 줄의 두께를 조절합니다.
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3, // 텍스트가 차지할 비율
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: generateIntroductionWidgets(
                        _introductionFromFirestore ?? '외않돼'),
                  ),
                ),

                Expanded(
                  flex: 1, // 버튼이 차지할 비율
                  child: Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to userEdit.dart
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserEdit()),
                        );
                      },

                      child: Text(
                        '계정 수정',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF392F31),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PointDetailed()),
                );

              },

              child: Text(
                '포인트 상세',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF392F31), // 버튼 배경색
                fixedSize: Size.fromWidth(500), // 가로로 꽉 차도록 설정
              ),
            ),
            SizedBox(height: 21,),
            Text(
              "post",
              style: TextStyle(
                fontSize: 25, // 폰트 크기 조절
                fontWeight: FontWeight.bold, // 볼드 효과 적용
              ),

            ),
            Divider( // 이 부분이 추가된 부분입니다.
              color: Colors.grey[300], // 회색 줄의 색상을 지정합니다.
              thickness: 1, // 회색 줄의 두께를 조절합니다.
            ),
            SizedBox(height: 21,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _postsData.map((postData) {
                return Card(
                  elevation: 5, // 그림자 추가
                  margin: EdgeInsets.all(10), // 카드 주위의 간격
                  child: Padding(
                    padding: EdgeInsets.all(10), // 내부 내용의 간격
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '제목:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${postData['title']}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10), // 간격 추가

                        Text(
                          '${postData['content']}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        // 다른 정보들도 원하는대로 추가하세요.
                      ],
                    ),
                  ),
                );
              }).toList(),
            )

          ],
        ),
      ),
    );
  }
}