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


  @override
  _ProfileState createState() => _ProfileState();
}

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
        title: Text('프로필'),
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
                  child: Column(
                    children: [
                      // Text(
                      //   'Follower: $_followerCount',
                      //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      // ),
                      Text(
                        'Following: $_followingCntFromFirestore',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),

                    ],
                  ),
                )

              ],
            ),
            SizedBox(height: 20),
            Text(
              '닉네임: $_nickFromFirestore',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }
}