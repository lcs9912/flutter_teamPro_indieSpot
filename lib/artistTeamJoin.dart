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

  bool yn = false; // 이미 등록했는지

  String? title;
  String? content;
  String? position;
  String? career;
  String? joinId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
    } else {
      _userId = userModel.userId;
      joinCheck();
    }
  }


  // 이미 등록 했는지
  void joinCheck() async {
    var artistDoc = await fs.collection('artist').doc(widget.doc.id).get();

    if (artistDoc.exists) {
      var teamJoinSnapshot = await artistDoc.reference.collection('team_join').get();

      teamJoinSnapshot.docs.forEach((teamJoinDoc) {
        // 'userId' 필드가 '_userId'와 같은 경우 이미 등록된 상태임
        if (teamJoinDoc['userId'] == _userId) {
          setState(() {
            yn = true; // 이미 등록된 경우 yn을 true로 변경
            joinId = teamJoinDoc.id;
            _aboutMeTitle.text = teamJoinDoc['title'];
            _aboutMe.text = teamJoinDoc['content'];
            _position.text = teamJoinDoc['position'];
            _career.text = teamJoinDoc['career'];
          });
        }
      });
    }
  }


  void teamJoin() async {

    if (_anyFieldIsEmpty()) {
      inputDuplicateAlert("모든 정보를 입력하시오 ");
      return;
    }
    if (yn) {

      // 이미 등록된 상태인 경우 업데이트 수행
      var artistDoc = fs.collection('artist').doc(widget.doc.id);
      var teamJoinDoc = artistDoc.collection('team_join').doc(joinId);

      await teamJoinDoc.update({
        'title': _aboutMeTitle.text,
        'content': _aboutMe.text,
        'position': _position.text,
        'career': _career.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('수정이 완료 되었습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _clearTextFields();
      Navigator.of(context).pop();

    } else {

      // 등록되지 않은 상태인 경우 새로운 문서 추가 수행
      var artistDoc = fs.collection('artist').doc(widget.doc.id);
      var teamJoinCollection = artistDoc.collection('team_join');

      await teamJoinCollection.add({
        'userId': _userId,
        'title': _aboutMeTitle.text,
        'content': _aboutMe.text,
        'position': _position.text,
        'career': _career.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('신청이 완료되었습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _clearTextFields();
      Navigator.of(context).pop();
    }
  }

  void joinDelete() async {
    var artistDoc = fs.collection('artist').doc(widget.doc.id);
    var teamJoinDoc = artistDoc.collection('team_join').doc(joinId);

    try {
      await teamJoinDoc.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제가 완료되었습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      print('삭제 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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


  void textOverAlertWidget() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('글자수를 확인하시오'),
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

  void deleteAlertWidget() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('취소 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                joinDelete();
              },
            ),
            TextButton(
              child: Text("취소"),
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
        backgroundColor: Colors.transparent, // AppBar 배경을 투명하게 설정
        elevation: 1,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xFF233067), // 원하는 배경 색상으로 변경
          ),
        ),
        title: Text("가입신청"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            _TextField("제목", "10글자 이내", _aboutMeTitle),
            _TextField2("자기소개", "50글자 이내", _aboutMe),
            _TextField("포지션", "ex) 보컬, 악기", _position),
            _TextField2("경력", "악기경력, 무대경험", _career),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: !yn
            ? ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF233067),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
          ),
          onPressed: () {
            teamJoin();
          },
          child: Container(
            height: 60,
            child: Center(
              child: Text(
                "등록완료",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        )
            : Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF233067),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                    ),
                  ),
                ),
                onPressed: () {
                  teamJoin();
                },
                child: Container(
                  height: 60,
                  child: Center(
                    child: Text(
                      "등록완료",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 1, // 세로 선의 너비
              height: 60, // 세로 선의 높이 (여기서는 버튼의 높이와 같게 설정)
              color: Colors.black, // 세로 선의 색상
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF233067),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                ),
                onPressed: () {
                  deleteAlertWidget();
                  //Navigator.of(context).pop(); // 알림 창 닫기
                },
                child: Container(
                  height: 60,
                  child: Center(
                    child: Text(
                      "가입취소",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  // TextField 위젯
  Container _TextField(String title, String hint, TextEditingController control) {
    return Container(
      child: SingleChildScrollView (
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
          children: [
            Text(title),
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: TextField(
                autofocus: true,
                style: TextStyle(
                    fontWeight: FontWeight.w500
                ),
                maxLines: 2,
                controller: control,
                maxLength: 20, // 최대 글자수 설정
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20), // 최대 글자수를 제한하는 포매터 추가
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10),
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Container _TextField2(String title, String hint, TextEditingController control) {
    return Container( 
      child: SingleChildScrollView (
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
          children: [
            Text('$title'),

            Container(
              child: TextField(
                style: TextStyle(
                    fontWeight: FontWeight.w500
                ),
                maxLines: 3,
                controller: control,
                maxLength: 50, // 최대 글자수 설정
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50), // 최대 글자수를 제한하는 포매터 추가
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10),
                  hintText: '$hint',
                  hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}