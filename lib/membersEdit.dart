import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MembersEdit extends StatefulWidget {
  final DocumentSnapshot doc;

  MembersEdit(this.doc, {super.key});

  @override
  State<MembersEdit> createState() => _MembersEditState();
}

class _MembersEditState extends State<MembersEdit> {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  final TextEditingController _position = TextEditingController(); // 포지션 변경
  final TextEditingController _artistNick = TextEditingController(); // 아티스트 닉네임 변경
  bool _isNameChecked = false;
  String? _status; // 리더가 변경할 권한
//

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _status = widget.doc['status']; // 리더가 변경할 권한
    
  }

  void _checkArtistName() async {
    // 활동명이 비어있는지 확인
    if (_artistNick.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아티스트 활동명을 입력해주세요.')),
      );
      return;
    }
    // Firestore에서 중복 닉네임 체크
    final checkArtistName = await fs
        .collection('artist')
        .where('artistName', isEqualTo: _artistNick.text)
        .get();

    if (_artistNick.text == widget.doc['artistNick']) {
      setState(() {
        _isNameChecked = true; //
      });
    } else if (checkArtistName.docs.isNotEmpty &&
        _artistNick.text != widget.doc.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 사용 중인 활동명 입니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용 가능한 활동명 입니다.')),
      );
      setState(() {
        _isNameChecked = true; //
      });
    }
  }

  void _change() { // 다시입력
    setState(() {
      _isNameChecked = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("정보수정"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text(
                '활동 닉네임',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 10),
              //if (_isNameChecked)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black),
                    onPressed: _change,
                    child: Text('수정')),
              //else if (!_isNameChecked)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black),
                    onPressed: _checkArtistName,
                    child: Text('중복 확인')),
              SizedBox(width: 10),
              SizedBox(height: 14),

            ],
          ),
          TextField(
            controller: _artistNick,
            decoration: InputDecoration(
                //hintText: widget.doc['artistName'] ?? "활동명",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6))),
            enabled: !_isNameChecked,
          ),
          Text(
            '활동 닉네임',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          TextField(
            controller: _position,
            decoration: InputDecoration(
              //hintText: widget.doc['artistName'] ?? "활동명",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6))),
          ),
          // 여기다 리더 일때 조건
          Column(
            children: [
              Text(
                '권한 변경',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              RadioListTile(
                title: Text('운영진'),
                value: 'A',
                groupValue: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value as String;
                  });
                },
              ),
              RadioListTile(
                title: Text('일반'),
                value: 'N',
                groupValue: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value as String;
                  });
                },
              ),
              RadioListTile(
                title: Text('정지'),
                value: 'B',
                groupValue: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value as String;
                  });
                },
              ),
              Text('선택된 옵션: $_status'),
            ],
          ),
        ],
      )
    );
  }
}
