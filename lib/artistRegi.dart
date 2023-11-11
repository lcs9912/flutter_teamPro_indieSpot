import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'artistInfo.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_cropper/image_cropper.dart';
import 'package:get/get.dart';

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
  final TextEditingController _position = TextEditingController();
  final TextEditingController _genreCon =
  TextEditingController(); // 직접 입력할 상세 장르

  String _genre = '음악'; // 검색에 이용될 장르
  String? _genreCheck; // 체크한 상세 장르
  bool selfCon = false; // 직접입력선택시
  String? _userId;
  @override
  void initState() {

    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
    } else {
      _userId = userModel.userId;
    }
    super.initState();
  }

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

    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1.5, ratioY: 1), // 원하는 가로세로 비율 설정
      );

      if (croppedImage != null) {
        setState(() {
          _selectedImage = File(croppedImage.path);
        });
      }
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
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("모든 정보를 입력해주세요."))
      );
      return;
    }
    _genreCheck ??= "";
    final imageUrl = await _uploadImage(_selectedImage!);

    try {
      //등록처리
      DocumentReference artistRef = await _fs.collection('artist').add(
        {
          'artistName' : _artistName.text,
          'artistInfo' : _artistInfo.text,
          'mainPlace' : _mainPlace.text,
          'createdate' : Timestamp.now(),
          'donationAmount' : 0,
          'udatetime' : Timestamp.now(),
          "followerCnt" : 0,
          "detailedGenre" : _genreCheck == "직접입력" ? _genreCon.text : _genreCheck,
          'genre': _genre,
        }
      );

      String artistID = artistRef.id;

      //서브 콜렉션에 이미지 추가
      await _fs.collection('artist').doc(artistID).collection('image').add(
          {
        'deleteYn' : 'N',
        'path' : imageUrl,
      });

      await _fs.collection('artist').doc(artistID).collection('team_members').add(
          {
            'status' : 'Y',
            'position' : _position.text,
            'userId' : _userId,
            'createtime' : Timestamp.now()
          });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록되었습니다.')),
      );

      setState(() {
        _artistName.clear();
        _artistInfo.clear();
        _mainPlace.clear();
        _position.clear();
        _selectedImage = null;
      });

      //등록 완료후 페이지 이동
      Get.off(
        () => ArtistInfo(artistID),
        transition: Transition.noTransition
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
      return Center(
        child: Image.file(_selectedImage!, height: 150),
      );
    }
    return null; // 이미지가 없을 경우// null을 반환
  }

  // 검색에 사용될 장르 라디오 버튼
  Widget _customRadioBut() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              _genreCheck = null;
              selfCon = false;
              _genre = '음악';
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (_genre == '음악') {
                return Color(0xFF233067); // 선택된 경우의 색상
              }
              return Colors.white; // 선택되지 않은 경우의 색상
            }),
          ),
          child: Text(
            '음악',
            style: TextStyle(
              color: _genre == '음악' ? Colors.white : Color(0xFF392F31),
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _genreCheck = null;
              selfCon = false;
              _genre = '댄스';
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (_genre == '댄스') {
                return Color(0xFF233067);
              }
              return Colors.white;
            }),
          ),
          child: Text(
            '댄스',
            style: TextStyle(
              color: _genre == '댄스' ? Colors.white : Color(0xFF392F31),
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            setState(() {
              selfCon = false;
              _genreCheck = null;
              _genre = '퍼포먼스';
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (_genre == '퍼포먼스') {
                return Color(0xFF233067);
              }
              return Colors.white;
            }),
          ),
          child: Text(
            '퍼포먼스',
            style: TextStyle(
              color: _genre == '퍼포먼스' ? Colors.white : Color(0xFF392F31),
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            setState(() {
              selfCon = false;
              _genreCheck = null;
              _genre = '마술';
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (_genre == '마술') {
                selfCon = false;
                return Color(0xFF233067);
              }
              return Colors.white;
            }),
          ),
          child: Text(
            '마술',
            style: TextStyle(
              color: _genre == '마술' ? Colors.white : Color(0xFF392F31),
            ),
          ),
        ),
      ],
    );
  }

  // 상세 장르 선택
  Widget? _wrapWidget(String genre) {


    Map<String, List<String>> genreButtonMap = {
      "음악": ["밴드", "발라드", "힙합", "클래식", "악기연주", "싱어송라이터", "직접입력"],
      "댄스": ["팝핀", "비보잉", "힙합", "하우스", "크럼프", "락킹", "왁킹", "직접입력"],
      "퍼포먼스": ["행위예술", "현대미술", "직접입력"],
    };

    if (genre.isEmpty) {
      return null;
    }

    final buttonList = genreButtonMap[genre];
    if (buttonList != null && buttonList.isNotEmpty) {
      return Wrap(
        spacing: 5.0,
        runSpacing: 0.1,
        children: buttonList.map((label) {
          return OutlinedButton(
            onPressed: () {
              setState(() {
                if (label == "직접입력") {
                  _genreCheck = label;
                  selfCon = true;
                } else {
                  selfCon = false;
                  _genreCheck = label;
                }
              });
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // 둥근 모서리 반경 설정
                ),
              ),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                EdgeInsets.all(8.0), // 버튼의 내부 여백 설정
              ),
              side: MaterialStateProperty.all<BorderSide>(
                BorderSide(
                  color: label == _genreCheck
                      ? Color(0xFF392F31)
                      : Colors.white, // 선택된 버튼인지 여부에 따라 테두리 색 변경
                  width: 2.0, // 테두리 두께 설정
                ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(color: Color(0xFF392F31)),
            ),
          );
        }).toList(),
      );
    } else {
      return Container();
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
          backgroundColor: Color(0xFF233067),
          title: Text(
            '아티스트 등록',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
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
                    backgroundColor: Color(0xFF233067),
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
                    backgroundColor: Color(0xFF233067),
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
            Column(
              children: [
                _customRadioBut(),
                _wrapWidget(_genre)!,
                if (selfCon)
                  TextField(
                    controller: _genreCon,
                    decoration: InputDecoration(
                        hintText: "상세 장르를 입력하시오 ex)락",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6))
                    ),
                  ),
              ],
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding if needed
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF233067), // 392F31 색상
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
