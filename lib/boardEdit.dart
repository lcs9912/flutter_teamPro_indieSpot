import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/boardList.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';

class BoardEdit extends StatefulWidget {
  final DocumentSnapshot document;
  BoardEdit({required this.document});

  @override
  State<BoardEdit> createState() => _BoardEditState();
}

class _BoardEditState extends State<BoardEdit> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();
  bool showError = false;

  @override
  void initState(){
    super.initState();
    _title.text = widget.document['title'];
    _content.text = widget.document['content'];
  }

  void _editBoard() async {

    if (_title.text.length > 20) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('제목은 20자 이하로 입력해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_title.text.isEmpty || _content.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('제목과 내용을 입력해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      QuerySnapshot firstDocumentSnapshot = await _fs.collection('posts').limit(1).get();
      String firstDocumentId = firstDocumentSnapshot.docs.isNotEmpty ? firstDocumentSnapshot.docs.first.id : '3QjunO69Eb2OroMNJKWU';

      DocumentReference boardRef = _fs.collection('posts').doc(firstDocumentId).collection(widget.document.reference.parent.id).doc(widget.document.id);
      await boardRef.update(
        {
          'title': _title.text,
          'content': _content.text,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("수정되었습니다")),
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BoardList()
          )
      );
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        title: Text(
          "게시물 수정",
          style: TextStyle(
              color: Colors.white
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF233067),
        elevation: 1.5,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                color: Colors.white,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu),
              );
            },
          )
        ],
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                '게시글 수정',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18
                ),
              ),
              SizedBox(height: 20),
              Text(
                '제목',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  hintText : "제목을 입력해주세요",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4)
                  ),
                  errorText: showError ? "20자 이하로 입력하세요." : null,
                ),
                onChanged: (value) {
                  setState(() {
                    showError = value.length > 20;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                '내용',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18
                ),
              ),
              SizedBox(height: 10),
              TextField(
                maxLines: 3,
                controller: _content,
                decoration: InputDecoration(
                    hintText: "내용을 입력해주세요",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)
                    )
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editBoard,
                child: Text(
                  "게시물 수정",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(380, 50),
                    backgroundColor: Color(0xFF233067),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}