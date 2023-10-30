import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/userEdit.dart';

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
  String? _nickFromFirestore; // Firestore에서 가져온 'nick' 값을 저장할 변수
  String? _introductionFromFirestore;
  String? _followerCount = '0'; // 기본값으로 0 설정
  String? _followingCount = '0'; // 기본값으로 0 설정
  @override
  void initState() {
    super.initState();
    getNickFromFirestore(widget.userId);
    getIntroductionFromFirestore();
  }

  Future<void> getNickFromFirestore(String? userId) async {
    try {
      if (userId != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('userList')
            .doc(userId)
            .get();

        if (snapshot.exists) {
          var nick = snapshot.data()!['nick'];
          var introduction = snapshot.data()!['introduction'];
          setState(() {
            _nickFromFirestore = nick;
            _introductionFromFirestore = introduction;
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
        DocumentSnapshot<Map<String, dynamic>> followerSnapshot = await FirebaseFirestore.instance
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
        DocumentSnapshot<Map<String, dynamic>> followingSnapshot = await FirebaseFirestore.instance
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
  Future<void> updateFirestore(BuildContext context) async {
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('userList')
          .doc(widget.userId);

      Map<String, dynamic> updatedData = {};

      if (widget.nicknameController.text.isNotEmpty) {
        updatedData['nick'] = widget.nicknameController.text;
      }

      if (widget.introductionController.text.isNotEmpty) {
        updatedData['introduction'] = widget.introductionController.text;
      }

      if (updatedData.isNotEmpty) {
        await documentReference.update(updatedData);

        print('Data Updated: $updatedData');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('수정 완료'),
              content: Text('정보가 업데이트되었습니다.'),
              actions: [
                TextButton(
                  child: Text('확인'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    getNickFromFirestore(widget.userId);
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('문서 업데이트 중 오류 발생: $e');
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
                  backgroundImage: AssetImage('assets/기본.jpg'),
                ),
                Text(
                  '   Follower: $_followerCount    ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Following: $_followingCount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // When the edit icon is tapped, show a dialog to edit the introduction
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            TextEditingController introductionController = TextEditingController();
                            introductionController.text = _introductionFromFirestore ?? '';
                            return AlertDialog(
                              title: Text('자기소개 수정'),
                              content: TextField(
                                controller: introductionController,
                                decoration: InputDecoration(
                                  hintText: '새로운 자기소개를 입력하세요',
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('취소'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('저장'),
                                  onPressed: () {
                                    // Update the introduction
                                    setState(() {
                                      _introductionFromFirestore = introductionController.text;
                                    });
                                    Navigator.of(context).pop();

                                    // Update Firestore
                                    updateFirestore(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(Icons.edit),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '자기소개',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                Text(
                  _introductionFromFirestore ?? '외않돼',
                  style: TextStyle(fontSize: 16),
                ),



                SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to userEdit.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserEdit()),
                );
              },
              child: Text(
                'Edit User',
                style: TextStyle(color: Colors.white), // Set text color to blue
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF392F31), // Set button color to your custom color
              ),
            ),

          ],
        ),
     ]
      ),
    )
    );
  }
}