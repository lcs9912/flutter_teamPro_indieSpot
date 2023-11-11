import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';


class ArtistTeamJoin extends StatefulWidget {
  final DocumentSnapshot doc;

  ArtistTeamJoin(this.doc, {super.key}); // 아티스트 doc   doc.id 가능한 것으로

  @override
  State<ArtistTeamJoin> createState() => _ArtistTeamJoinState();
}

class _ArtistTeamJoinState extends State<ArtistTeamJoin> {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  String? _userId;
  final TextEditingController _aboutMeTitle = TextEditingController(); // 자기소개 제목
  final TextEditingController _aboutMe = TextEditingController(); // 자기소개 내용
  final TextEditingController _position = TextEditingController(); // 포지션
  final TextEditingController _career = TextEditingController(); // 경력

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
    } else {
      _userId = userModel.userId;
    }
  }

  void teamJoin() async {

    if (_anyFieldIsEmpty()) {
      inputDuplicateAlert("모든 정보를 입력하시오");
      return;
    }

    final teamJoinData = {
      "title": _aboutMeTitle.text,
      "content": _aboutMe.text,
      "position": _position.text,
      "career": _career.text,
      "userId": _userId,
    };

    // 'userId' 필드가 중복되는지 확인
    final isDuplicateUserId = await _checkDuplicateUserId(teamJoinData["userId"]!);

    if (isDuplicateUserId) {
      // 중복되는 경우 알림 표시
      showDuplicateUserIdAlert();
    } else {
      // 중복이 없으면 데이터를 Firestore에 추가
      await fs.collection('artist').doc(widget.doc.id).collection('team_join').add(teamJoinData);

      _clearTextFields();
      Navigator.of(context).pop();
    }
  }

  Future<bool> _checkDuplicateUserId(String userId) async {
    // 'team_join' 컬렉션에서 중복 userId 확인
    final teamJoinQuery = await fs.collection('artist').doc(widget.doc.id).collection('team_join').where('userId', isEqualTo: userId).get();

    return teamJoinQuery.docs.isNotEmpty;
  }

  void showDuplicateUserIdAlert() {
    inputDuplicateAlert("이미 가입신청을 완료했습니다.");
  }

  bool _anyFieldIsEmpty() {
    return _aboutMeTitle.text.isEmpty ||
        _aboutMe.text.isEmpty ||
        _position.text.isEmpty ||
        _career.text.isEmpty;
  }

  void _clearTextFields() {
    _aboutMeTitle.clear();
    _aboutMe.clear();
    _position.clear();
    _career.clear();
  }

  // 비어있으면 뜨는 엘럿
  void inputDuplicateAlert(String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop(); // 알림 창 닫기
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("가입신청"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            _TextField("제목", "10글자 이내", _aboutMeTitle),
            _TextField2("자기소개", "100글자 이내", _aboutMe),
            _TextField("포지션", "ex) 보컬, 악기", _position),
            _TextField2("경력", "무대 경험", _career),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF392F31), // 버튼의 배경색
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),  // 좌측 상단 모서리만 둥글게
                topRight: Radius.circular(20.0), // 우측 상단 모서리만 둥글게
              ),
            ),
          ),
          onPressed:  (){
            teamJoin();
          },
          child: Container(
          height: 60,
          child: Center(
              child: Text(
                "등록완료",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
              )
          ),
        ),
        ),
      ),
    );
  }

  // TextField 위젯
  Container _TextField(String title, String hint, TextEditingController control) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
        children: [
          Text(title),
          SizedBox(height: 10),
          SizedBox(
            height: 35,
            child: TextField(
              autofocus: true,
              style: TextStyle(
                  fontWeight: FontWeight.w500
              ),
              controller: control,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                hintText: hint,
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Container _TextField2(String title, String hint, TextEditingController control) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
        children: [
          Text('$title'),
          SizedBox(height: 10),
          Container(
            child: TextField(
              style: TextStyle(
                  fontWeight: FontWeight.w500
              ),
              maxLines: 3,
              controller: control,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                hintText: '$hint',
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}