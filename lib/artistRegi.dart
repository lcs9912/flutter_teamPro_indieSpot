import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/lsjMain.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserModel())
        ],
        child: MaterialApp(
            theme: ThemeData(fontFamily: 'Pretendard'),
            themeMode: ThemeMode.system,
            home: ArtistRegi()
        ),
      )
  );
}


class ArtistRegi extends StatefulWidget {
  const ArtistRegi({super.key});

  @override
  State<ArtistRegi> createState() => _ArtistRegiState();
}
class _ArtistRegiState extends State<ArtistRegi> {

  bool _isNameChecked = false;
  File? _selectedImage;

  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final TextEditingController _artistName = TextEditingController();
  final TextEditingController _artistInfo = TextEditingController();
  final TextEditingController _mainPlace = TextEditingController();
  final TextEditingController _genre = TextEditingController();

  void _checkArtistName() async {
    // 활동명이 비어있는지 확인
    if (_artistName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아티스트 활동명을 입력해주세요.')),
      );
      return;
    }
    // Firestore에서 중복 닉네임 체크
    final checkArtistName = await _fs.collection('artist')
        .where('artistName', isEqualTo: _artistName.text).get();
    if (checkArtistName.docs.isNotEmpty) {
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if(pickedImage != null){
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _change(){
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

  void _register() async {
    if(!_isNameChecked){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("중복 확인 필요"),
            content: Text("아티스트 활동명 중복을 확인해주세요."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("확인"),
              ),
            ],
          );
        },
      );
      return;
    }

    if(_artistName.text.isEmpty ||
        _artistInfo.text.isEmpty ||
        _mainPlace.text.isEmpty ||
        _genre.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("모든 정보를 입력해주세요."))
      );
      return;
    }
    final imageUrl = await _uploadImage(_selectedImage!);

    try {
      //등록처리
      DocumentReference artistRef = await _fs.collection('artist').add(
        {
          'artistName' : _artistName.text,
          'artistInfo' : _artistInfo.text,
          'genre' : _genre.text,
          'mainPlace' : _mainPlace.text,
          'createdate' : Timestamp.now(),
          'donationAmount' : 0,
          'udatetime' : " "

        }
      );

      String artistID = artistRef.id;

      //서브 콜렉션에 이미지 추가
      await _fs.collection('artist').doc(artistID).collection('image').add(
          {
        'deleteYn' : 'N',
        'path' : imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록되었습니다.')),
      );

      setState(() {
        _artistName.clear();
        _artistInfo.clear();
        _mainPlace.clear();
        _genre.clear();
        _selectedImage = null;
      });

      //등록 완료후 페이지 이동
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage())
      );


    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget? _buildSelectedImage() {
    if (_selectedImage != null) {
      // 이미지를 미리보기로 보여줄 수 있음
      return Image.file(
          _selectedImage!,
          height: 150
      );
    }
    return null; // 이미지가 없을 경우 null을 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            '아티스트 등록',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
        child : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              '아티스트 정보 입력',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22
              ),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Text(
                  '아티스트 이미지',
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
            SizedBox(height: 14),
            _buildSelectedImage() ?? Container(
              alignment: Alignment.center,
              child: Image.asset(
                  'assets/imgPick.png',
                width: 360,

              ),
            ),
            SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '아티스트 활동명(팀 or 솔로)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(width: 10),
                if(_isNameChecked)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black
                    ),
                      onPressed: _change,
                      child: Text('수정')
                  )
                else if(!_isNameChecked)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black
                  ),
                    onPressed: _checkArtistName,
                    child: Text(
                      '중복 확인'
                    )
                ),
                SizedBox(width: 10),

              ],
            ),
            SizedBox(height: 14), 
            TextField(
              controller: _artistName,
              decoration: InputDecoration(
                hintText: '활동명을 입력해주세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6)
                )
              ),
              enabled: !_isNameChecked,
            ),
            SizedBox(height: 40),
            Text(
              '소개',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 14),
            TextField(
              maxLines: 4,
              controller: _artistInfo,
              decoration: InputDecoration(
                  hintText: '소개를 입력해주세요.',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)
                  )
              ),
            ),
            SizedBox(height: 40),
            Text(
              '주활동 지역',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 14),
            TextField(
              controller: _mainPlace,
              decoration: InputDecoration(
                  hintText: '주로 활동하는 지역을 입력해주세요.(ex. 서울 홍대)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)
                  )
              ),
            ),
            SizedBox(height: 40),
            Text(
              '장르',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 14),
            TextField(
              controller: _genre,
              decoration: InputDecoration(
                  hintText: '음악 장르를 입력해주세요. (ex. 락발라드)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)
                  )
              ),
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding if needed
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF392F31), // 392F31 색상
                    minimumSize: Size(double.infinity, 48), // Set button width and height
                  ),
                  child: Text(
                    '등록하기',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 3
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        )
      );
  }

}
