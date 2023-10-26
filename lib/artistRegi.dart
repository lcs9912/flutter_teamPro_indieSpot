import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/LcsMain.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';


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


final TextEditingController _artistName = TextEditingController();

class ArtistRegi extends StatefulWidget {
  const ArtistRegi({super.key});

  @override
  State<ArtistRegi> createState() => _ArtistRegiState();
}
class _ArtistRegiState extends State<ArtistRegi> {

  bool _isNameChecked = false;

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
        _genre.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("모든 정보를 입력해주세요."))
      );
      return;
    }
    try {
      //등록처리
      await _fs.collection('artist').add(
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록되었습니다.')),
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
                  '아티스트 활동명(팀 or 솔로)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black
                  ),
                    onPressed: _checkArtistName,
                    child: Text(
                      '중복 확인'
                    )
                )
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
                      fontSize: 16,
                      letterSpacing: 2
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
