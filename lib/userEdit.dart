import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/services.dart';
import 'package:indie_spot/profile.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // ImagePicker를 import 해주세요.
import 'package:firebase_storage/firebase_storage.dart';
class UserEdit extends StatefulWidget {


  @override
  State<UserEdit> createState() => _UserEditState();
}
List<String> imagePaths = []; // Add this line to define imagePaths

class _UserEditState extends State<UserEdit> {
  TextEditingController _userIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _introductionController = TextEditingController();

  File? _selectedImage; // _selectedImage 변수를 정의합니다.
  bool _isNameChecked = false; // _isNameChecked 변수를 정의합니다.
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = Provider
        .of<UserModel>(context, listen: false)
        .userId;
    if (_userId != null) {
      _userIdController.text = _userId!;
    }

    // Firestore에서 이메일 값을 가져오는 함수 호출
    getEmailFromFirestore();

  }


  Future<void> showLoginDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부를 터치해도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 필요'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('로그인 후 이용해주세요.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
  void updateFirestore() async {
    try {
      // Firestore에서 'userList' 컬렉션의 문서를 가져옵니다.
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('userList')
          .doc(_userId); // 아이디를 사용하여 문서를 가져옵니다.

      // 업데이트할 데이터를 Map 형태로 만듭니다.
      Map<String, dynamic> updatedData = {};

      // 이메일 값이 비어 있지 않다면 업데이트합니다.
      if (_userIdController.text.isNotEmpty) {
        updatedData['email'] = _userIdController.text;
      }

      if (_introductionController.text.isNotEmpty) {
        updatedData['introduction'] = _introductionController.text;
      }


      // 생일 값이 비어 있지 않다면 업데이트합니다.
      if (_birthdayController.text.isNotEmpty) {
        updatedData['birthday'] = _userIdController.text;
      }

      // 비밀번호 값이 비어 있지 않다면 업데이트합니다.
      if (_passwordController.text.isNotEmpty) {
        updatedData['pwd'] = _passwordController.text;
      }

      // 닉네임 값이 비어 있지 않다면 업데이트합니다.
      if (_nicknameController.text.isNotEmpty) {
        updatedData['nick'] = _nicknameController.text;
      }

      // 업데이트할 데이터가 있을 때만 Firestore에 업데이트를 수행합니다.
      if (updatedData.isNotEmpty) {
        await documentReference.update(updatedData);

        // 업데이트가 성공하면 사용자에게 알림을 띄워줍니다.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('수정 완료'),
              content: Text('정보가 업데이트되었습니다.'),
              actions: [
                TextButton(
                  child: Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // 업데이트 중 에러가 발생하면 처리할 내용을 여기에 추가하세요.
      print('문서 업데이트 중 오류 발생: $e');
    }
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _change() {
    setState(() {
      _isNameChecked = false;
    });
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
  Future<void> getEmailFromFirestore() async {
    try {
      // Firestore에서 'userList' 컬렉션의 문서를 가져옵니다.
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('userList')
          .doc(_userId) // 아이디를 사용하여 문서를 가져옵니다.
          .get();

      // 문서가 존재하면
      if (documentSnapshot.exists) {
        // 이메일 값을 가져옵니다.
        String email = documentSnapshot.data()!['email'];

        // 가져온 이메일 값을 사용하거나 출력합니다.
        print('Email: $email');

        // 만약 화면에 표시하려면 setState()를 사용하여 상태를 갱신하세요.
        setState(() {
          _userIdController.text = email;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching email: $e');
    }
  }

  Future<void> _changeProfileImage() async {
    try {
      // 1. 새 이미지 선택
      await _pickImage();

      if (_selectedImage != null) {
        // 2. Firebase Storage에 이미지 업로드
        String imageUrl = await _uploadImage(_selectedImage!);

        if (imageUrl.isNotEmpty) {
          // 3. 이미지 다운로드 URL 얻기 성공
          // 4. 사용자 정보 업데이트
          await updateProfileImage(imageUrl);
        } else {
          print('Image upload failed');
        }
      }
    } catch (e) {
      print('Error changing profile image: $e');
    }
  }


  Future<void> updateProfileImage(String imageUrl) async {
    try {
      // Firestore에서 'userList' 컬렉션의 문서를 가져옵니다.
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('userList')
          .doc(_userId); // 아이디를 사용하여 문서를 가져옵니다.

      // 사용자 정보를 업데이트합니다.
      await documentReference.update({'profileImage': imageUrl});

      // 'image' 서브컬렉션에 대한 참조 가져오기
      CollectionReference imageCollection = documentReference.collection('image');

      // 'image' 서브컬렉션에서 문서를 가져옵니다. 이 문서는 하나뿐일 것이라고 가정합니다.
      QuerySnapshot<Object?> imageSnapshot =
      await imageCollection.get();

      if (imageSnapshot.docs.isNotEmpty) {
        String imageDocumentId = imageSnapshot.docs[0].id;

        // 'image' 서브컬렉션의 문서를 업데이트합니다.
        await imageCollection.doc(imageDocumentId).update({'path': imageUrl});
      }

      // 업데이트가 성공하면 사용자에게 알림을 띄워줍니다.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('프로필 이미지 변경 완료'),
            content: Text('프로필 이미지가 성공적으로 변경되었습니다.'),
            actions: [
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('프로필 이미지 변경 중 오류 발생: $e');
    }
  }


  // Widget _buildSelectedImage() {
  //   if (_selectedImage != null) {
  //     return Center(
  //       child: Image.file(_selectedImage!, height: 150),
  //     );
  //   }
  //   return Container(); // 이미지가 없을 경우 빈 Container 반환
  // }
  Future<List<String>> getImageData() async {
    try {
      if (_userId != null) {
        // Get image paths
        QuerySnapshot<Map<String, dynamic>> imageSnapshot = await FirebaseFirestore
            .instance
            .collection('userList')
            .doc(_userId)
            .collection('image')
            .get();

        // Process the image paths
        imagePaths =
            imageSnapshot.docs.map((doc) => doc.data()['path'].toString()).toList();
      }

      return imagePaths;
    } catch (e) {
      print('Error fetching image paths: $e');
      return []; // Return an empty list in case of an error
    }
  }



  @override
  Widget build(BuildContext context) {
    return Material(

      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // Align children to the start (left)
          crossAxisAlignment: CrossAxisAlignment.start,
          // Align children to the start (left)

          children: [

            SizedBox(height: 30),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context); // This will navigate back
                  },
                ),
                Text("기본정보 수정",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),

              ],
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: imagePaths.isNotEmpty
                  ? AssetImage(
                  imagePaths[0]) // Assuming you want to use the first image from the list
                  : AssetImage('assets/기본.jpg'),
            ),
            SizedBox(height: 30),
            Column(
              children: [
                // _buildSelectedImage(),
                ElevatedButton(
                  onPressed: _changeProfileImage,
                  child: Text('프로필 이미지 변경'),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF392F31),
                  ),
                ),
              ],
            ),

            Text("이메일", style: TextStyle(fontSize: 16),),
            SizedBox(height: 20),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text("비밀번호", style: TextStyle(fontSize: 16),),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),
            Text("닉네임", style: TextStyle(fontSize: 16),),
            SizedBox(height: 20),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Text("생일", style: TextStyle(fontSize: 16),),
            SizedBox(height: 20),
            TextField(
              controller: _birthdayController,
              keyboardType: TextInputType.number, // 숫자 키패드를 띄웁니다.
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 숫자만 허용합니다.
              ],
              decoration: InputDecoration(
                labelText: 'YYYY-MM-DD',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            SizedBox(height: 30),
            Text("자기소개", style: TextStyle(fontSize: 16),),
            SizedBox(height: 20),
            TextField(
              controller: _introductionController,
              decoration: InputDecoration(
                labelText: '소개',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      userId: _userId,
                    ),
                  ),
                );
              },
              child: Text('프로필 페이지로 이동'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF392F31),
              ),
            ),

            SizedBox(height: 30),
            Center(
              child: Container(
                width: 200, //




              ),
            ),
            Center(
              child: Container(
                width: 200, //


                child: ElevatedButton(


                  onPressed: () {
                    // 버튼이 눌렸을 때 수행될 동작을 여기에 추가하세요.
                    updateFirestore();
                  },
                  child: Text(
                    '저장',
                    style: TextStyle(fontSize: 20), // Adjust the font size
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16), // Adjust the vertical padding
                    primary: Color(0xFF392F31), // Set the button color here
                  ),
                ),


              ),
            ),







          ],
      ),
        ),
      )
    );
  }
}