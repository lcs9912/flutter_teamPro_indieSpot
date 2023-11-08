import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:indie_spot/boardView.dart';
import 'package:http/http.dart' as http;

class BoardEdit extends StatefulWidget {
  final DocumentSnapshot document;
  BoardEdit({required this.document});

  @override
  State<BoardEdit> createState() => _BoardEditState();
}

class _BoardEditState extends State<BoardEdit> {
  File? _selectedImage;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();
  bool showError = false;

  @override
  void initState(){
    super.initState();
    _loadImage();
    _title.text = widget.document['title'];
    _content.text = widget.document['content'];
  }

  void _loadImage() async {
    try {
      QuerySnapshot imageSnapshot = await widget.document.reference.collection('image').get();
      if (imageSnapshot.docs.isNotEmpty) {
        String imageUrl = imageSnapshot.docs[0]['PATH'];
        var response = await http.get(Uri.parse(imageUrl));
        setState(() {
          _selectedImage = File(path.basename(imageUrl))
            ..writeAsBytesSync(response.bodyBytes);
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if(pickedImage != null){
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = path.basename(imageFile.path);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('image/$fileName');

      UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  void _editBoard() async {
    String? _userId = Provider.of<UserModel>(context, listen: false).userId;

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

    final imageUrl = _selectedImage != null ? await _uploadImage(_selectedImage!) : null;
    // final imageUrl = await _uploadImage(_selectedImage!);

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


      DocumentReference userRef = _fs.collection('userList').doc(_userId).collection('board').doc(widget.document.id);
      await userRef.update(
        {
          'title': _title.text,
          'content': _content.text,
        },
      );


      //서브 콜렉션에 이미지 수정
      if (imageUrl != null) {
        await boardRef.collection('image').doc().update(
            {
              'DELETE_YN' : 'N',
              'PATH' : imageUrl,
            }
        );
        await userRef.collection('image').doc(widget.document.id).update(
            {
              'DELETE_YN' : 'N',
              'PATH' : imageUrl,
            }
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("등록되었습니다")),
      );

      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BoardView(document: widget.document)
          )
      );
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget? _buildSelectedImage(){
    if (_selectedImage != null) {
      return Row(
        children: [
          Image.file(
            _selectedImage!,
            height: 150,
          ),
          SizedBox(width: 10),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
            },
            style: OutlinedButton.styleFrom(
                fixedSize: Size(100, 30),
                backgroundColor: Colors.grey[700]
            ),
            child: Text(
              '선택 취소',
              style: TextStyle(
                  color: Colors.white
              ),

            ), // X 아이콘
          ),
        ],
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "게시물 수정",
          style: TextStyle(
              color: Colors.black
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 1.5,
      ),
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
              Row(
                children: [
                  Text(
                    '이미지 올리기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: _pickImage,
                    child: Text('이미지 선택'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildSelectedImage() ?? Container(),
              SizedBox(height: 16),
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
                  "게시물 등록",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(380, 50),
                    backgroundColor: Colors.grey[600]
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}