import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:indie_spot/commercialList.dart';
import 'package:indie_spot/spaceInfo.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import 'concertDetails.dart';

class ProprietorAdd extends StatefulWidget {
  const ProprietorAdd({super.key});

  @override
  State<ProprietorAdd> createState() => _ProprietorAddState();
}

class _ProprietorAddState extends State<ProprietorAdd> {
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  String? _userId;
  File? _selectedImage; // 사업자 등록증
  bool imageYn = false;
  bool allYn = false;

  final TextEditingController _proprietorName = TextEditingController(); // 상호명
  final TextEditingController _representativeName = TextEditingController(); // 대표자 명
  final TextEditingController _proprietorNum = TextEditingController(); //사업자 번호
  final TextEditingController _managerPhone = TextEditingController(); // 관리자 전화번호
  final TextEditingController _description = TextEditingController(); // 공간 소개
  final TextEditingController _equipmentComment = TextEditingController(); // 지원장비
  final TextEditingController _headCount  = TextEditingController(); // 가용인원
  final TextEditingController _rentalfee  = TextEditingController(); // 렌탈비용


  String? parkingYn = "가능"; // 주자 여부
  String? videoYn = "가능"; // 영상촬영 여부
  String? termsYn; // 약관동의
  String _genre ="";
  List<String> genreList = []; // 공연 가능한 장르


  String? startTime; // 영업시간
  String? entTime; // 영업 시간
  final List<File> _commerImageList = []; // 상업공간 이미지

  // 지도 API
  GoogleMapController? mapController;
  LatLng? coordinates;
  final _address = TextEditingController();
  final _addr2 = TextEditingController();
  int? _zip;
  String _regions = '';
  String? commerId;
  String startTimeHour = '00'; // 영업시작 시간
  String startTimeMinute = '00'; // 영업시작 분
  String endTimeHour = '00'; // 영업 종료 시작
  String endTimeMinute = '00'; // 영업 종료 분
  List<String> hourItem = [
    '00', '01', '02', '03', '04',
    '05', '06', '07', '08', '09',
    '10', '11', '12', '13', '14',
    '15', '16', '17', '18', '19',
    '20', '21', '22', '23', '24',
  ];
  List<String> minuteItem = [
    '00', '10', '20', '30', '40', '50'
  ];

  String? _genreList;


  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    _getCoordinatesFromAddress('서울 시청'); // 지도 기본선택
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
    } else {
      _userId = userModel.userId;
    }
  }


  void allnNullCheck(){
    if(!imageYn){
      inputDuplicateAlert('사업자 등록증은 필수입니다');
      return;
    }
    if(_proprietorName.text.isEmpty){
      inputDuplicateAlert('상호명은 필수입니다');
      return;
    }
    if(_representativeName.text.isEmpty){
      inputDuplicateAlert('대표자명은 필수입니다');
      return;
    }
    if(_proprietorNum.text.isEmpty){
      inputDuplicateAlert('사업자번호는 필수입니다');
      return;
    }
    if(_address.text.isEmpty){
      inputDuplicateAlert('주소선택은 필수입니다');
      return;
    }
    if(_managerPhone .text.isEmpty){
      inputDuplicateAlert('관리자연락처는 필수입니다');
      return;
    }
    if(_commerImageList.isEmpty){
      inputDuplicateAlert('상업공간 이미지은 필수입니다');
      return;
    }
    if(_genreList == null || _genreList == ""){
      inputDuplicateAlert('공연가능장르는 필수입니다');
      return;
    }
    if(_headCount.text.isEmpty){
      inputDuplicateAlert('가용인원은 필수입니다');
      return;
    }
    setState(() {
      allYn = true;
    });
  }

  // 사업자 입력 쿼리문
  void addGenresToFirestore() async {

    allnNullCheck();
    if(allYn){
      final collectionReference = fs.collection('userList').doc(_userId).collection('proprietor');

      final imageUrl = await _uploadImage(_selectedImage!);


      String inputProprietorNum = _proprietorNum.text; // 사업자 번호 입력
      String formattedProprietorNum = ''; // 사업자 번호 가공
      formattedProprietorNum = '${inputProprietorNum.substring(0, 3)}-${inputProprietorNum.substring(3, 5)}-${inputProprietorNum.substring(5)}';
      // 중복 체크를 위한 쿼리
      final querySnapshot = await collectionReference.where('proprietorNum', isEqualTo: formattedProprietorNum).get();
      if (querySnapshot.docs.isEmpty) {
        // 중복되지 않을 때만 데이터를 추가
        collectionReference.add({
          "businessImage": imageUrl,
          "representativeName": _representativeName.text,
          "proprietorNum": formattedProprietorNum,
          "termsYn" : termsYn
        }).then((value) => commerAdd());
      } else {
        showDuplicateAlert("중복안내", "이미등록된 사업자 번호입니다.");
        // 포커스 주고 테두리 빨간색 밑에 텍스트
      }
    }

  }

  // 사업자 번호 중복체크
  void showDuplicateAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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

  // 상업공간 입력 쿼리문
  void commerAdd() async {
    final availableTimeslots = '$startTimeHour:$startTimeMinute ~ $endTimeHour:$endTimeMinute'; // 사용 가능 시간
    String regions = formatCity(_regions);
    final imageListUrl = await _uploadListImages(_commerImageList);

    int startHour = int.parse(startTimeHour);
    int startMinute = int.parse(startTimeMinute);
    int endHour = int.parse(endTimeHour);
    int endMinute = int.parse(endTimeMinute);

    DateTime startTime = DateTime(2023, 1, 1, startHour, startMinute);
    DateTime endTime = DateTime(2023, 1, 1, endHour, endMinute);
    int rentalfee = 0;
    if(_rentalfee.text.isEmpty){
      rentalfee = 0;
    } else{
      rentalfee = int.parse(_rentalfee.text);
    }
    try{
      DocumentReference commerCollection = await fs.collection('commercial_space').add({
        "availableTimeslots" : availableTimeslots,
        "createdate" : Timestamp.now(),
        "description" : _description.text != "" ? _description.text : "저장된 소개메세지가 없습니다.",
        "equipmentYn" : _equipmentComment.text != "" ? _equipmentComment.text : "제공되는 음향기기가 없습니다.",
        "headcount" : int.parse(_headCount.text),
        "managerContact" : _managerPhone.text,
        "proprietorId" : _userId,
        "rentalfee" : rentalfee,
        "spaceName" : _proprietorName.text,
        "updatetime" : Timestamp.now(),
        "spaceType" : _genreList,
        "regions" : regions,
        "parkingYn" : parkingYn,
        "videoYn" : videoYn,
        "startTime" : startTime,
        "endTime" : endTime
      }); // 상업공간 컬렉션

      commerId = commerCollection.id;

      //서브 컬렉션 addr 추가
      await fs.collection('commercial_space').doc(commerId).collection('addr').add(
          {
            'addr': _address.text,
            'addr2': _addr2.text != "" ? _addr2.text : "저장된 상세주소가 없습니다.",
            'zipcode': _zip,
          });

      await fs.collection('commercial_space').doc(commerId).collection('image').add({
        'cDateTime' : Timestamp.now(),
        'path' : imageListUrl
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록이 완료되었습니다.'),
            dismissDirection: DismissDirection.up,
            behavior: SnackBarBehavior.floating,
          )
      );

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SpaceInfo(commerId!), // HomeScreen은 대상 화면의 위젯입니다.
      ));

    }catch (e){
      print('에러에러에러$e');
    }
  }

  // 파이어페이스 이미지 업로드
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

  // 파이어베이스 이미지리스트 업로드
  Future<List<String>> _uploadListImages(List<File> imageFiles) async {
    List<String> downloadUrls = [];

    for (File imageFile in imageFiles) {
      try {
        String fileName = path.basename(imageFile.path);
        Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('image/$fileName');

        UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return downloadUrls;
  }


  // 이미지
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        imageYn = true;
      });
    }
  }

  // 이미지 리스트
  Future<void> _prickImageList() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (_commerImageList.length < 5) {
        setState(() {
          _commerImageList.add(File(pickedImage.path));
        });
      } else {
        showDuplicateAlert("멈춰!", "공간이미지는 5장을 초과할 수 없습니다.");
        print("이미지는 최대 5개까지만 선택할 수 있습니다.");
      }
    }
  }
  

  // 이미지 미리보기
  Widget? _buildSelectedImage() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (_selectedImage != null) {
      // 이미지를 미리보기로 보여줄 수 있음
      return Stack(
        children: [
          Image.file(_selectedImage!, height: screenHeight * 0.25, width: screenWidth * 0.5,fit: BoxFit.fill,),
        ],
      );


    }
    return null; // 이미지가 없을 경우// null을 반환
  }

  // 공간 이미지 미리보기
  Widget _commerImageListWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (_commerImageList.isNotEmpty) {
      // 이미지를 미리보기로 보여줄 수 있음
      List<Widget> imageContainers = [];

      for (int index = 0; index < _commerImageList.length; index++) {
        final image = _commerImageList[index];
        imageContainers.add(
          Stack(
            children: [
              Image.file(image, height: screenHeight * 0.1, width: screenWidth * 0.2, fit: BoxFit.fill),
              Positioned(
                right: -13,
                top: -13,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _commerImageList.removeAt(index);
                    });
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      }
      return Wrap(
        spacing: 5.0,  // 이미지 사이의 가로 간격
        runSpacing: 0.1, // 이미지 사이의 세로 간격
        children: imageContainers,
      );
    }
    return SizedBox.shrink(); // 이미지가 없을 경우 빈 SizedBox를 반환
  }




  // 구글 지도 APi
  Future<void> _getCoordinatesFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final coordinates = LatLng(locations.first.latitude, locations.first.longitude);

      // 주소를 기반으로 좌표를 얻은 후에 카메라 위치를 업데이트
      final newCameraPosition = CameraPosition(target: coordinates, zoom: 15);
      mapController?.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));

      // 좌표에서 주소를 가져오기
      final address = await getAddressFromCoordinates(coordinates.latitude, coordinates.longitude);

      setState(() {
        this.coordinates = coordinates;
        if(_address.text != ''){
          _address.text = address; // 이 부분에서 주소를 상태에 저장
        }
      });
    }
  }

  // 구글 지도 API
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark firstPlacemark = placemarks.first;
        _zip = int.parse(firstPlacemark.postalCode as String);
        _regions = firstPlacemark.administrativeArea as String;
        String address = "${firstPlacemark.street}";
        return address;
      }
    } catch (e) {
      print("Error: $e");
    }
    return "주소를 찾을 수 없음";
  }

  String formatCity(String city) {
    Map<String, String> cityMap = {
      '서울특별시': '서울',
      '인천광역시': '인천',
      '부산광역시': '부산',
      '강원도': '강원',
      '경기도': '경기',
      '경상남도': '경남',
      '경상북도': '경북',
      '광주광역시': '광주',
      '대구광역시': '대구',
      '대전광역시': '대전',
      '울산광역시': '울산',
      '전라남도': '전남',
      '전라북도': '전북',
      '제주특별자치도': '제주',
      '충청남도': '충남',
      '충청북도': '충북',
    };

    return cityMap[city] ?? city;
  }

  // 검색에 사용될 장르 라디오 버튼
  Widget _customRadioBut() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              _genre = '음악';
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (_genre == '음악') {
                return Color(0xFF392F31); // 선택된 경우의 색상
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
              _genre = '댄스';
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (_genre == '댄스') {
                return Color(0xFF392F31);
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
              _genre = '퍼포먼스';
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (_genre == '퍼포먼스') {
                return Color(0xFF392F31);
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
              _genre = '마술';
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (_genre == '마술') {
                return Color(0xFF392F31);
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
  Widget _wrapWidget(String genre) {
    Map<String, List<String>> genreButtonMap = {
      "음악": ["밴드", "발라드", "힙합", "클래식", "악기연주", "싱어송라이터"],
      "댄스": ["팝핀", "비보잉", "힙합댄스", "하우스", "크럼프", "락킹", "왁킹"],
      "퍼포먼스": ["행위예술", "현대미술"],
    };

    final buttonList = genreButtonMap[genre];
    if (buttonList != null) {
      return Wrap(
        spacing: 5.0,
        runSpacing: 0.1,
        children: buttonList.map((label) {
          bool isSelected = genreList.contains(label);
          return OutlinedButton(
            onPressed: () {
              setState(() {
                if (isSelected) {
                  genreList.remove(label); // 이미 선택된 요소를 다시 클릭하면 리스트에서 제외
                } else {
                  genreList.add(label); // 새로운 요소를 선택
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
                  color: isSelected ? Color(0xFF392F31) : Colors.white, // 선택된 버튼인지 여부에 따라 테두리 색 변경
                  width: 2.0, // 테두리 두께 설정
                ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(color: isSelected ? Color(0xFF392F31) : Colors.black), // 선택된 버튼일 때 텍스트 색상 변경
            ),
          );
        }).toList(),

      );
    } else {
      return Container();
    }
  }

  Widget genreListWidget() {
    Map<String, List<String>> selectedGenres = {}; // 장르 중복 선택 확인
    Map<String, List<String>> genreButtonMap = {
      "음악": ["밴드", "발라드", "힙합", "클래식", "악기연주", "싱어송라이터"],
      "댄스": ["팝핀", "비보잉", "힙합댄스", "하우스", "크럼프", "락킹", "왁킹"],
      "퍼포먼스": ["행위예술", "현대미술"],
    };

    // 그룹화된 장르 목록 작성
    for (String selectedGenre in genreList) {
      for (String category in genreButtonMap.keys) {
        if (genreButtonMap[category]!.contains(selectedGenre)) {
          if (selectedGenres.containsKey(category)) {
            selectedGenres[category]!.add(selectedGenre);
          } else {
            selectedGenres[category] = [selectedGenre];
          }
        }
      }
    }

    _genreList = selectedGenres.keys.map((category) {
      return '$category - ${selectedGenres[category]!.join("/")}';
    }).join(", "); // 카테고리를 쉼표로 연결

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            _genreList!,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    var subStyle = TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black54);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            '상업공간 등록',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("사업자 정보(필수*)",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("사업자등록증 사진 첨부",style: subStyle,),
                      if(_selectedImage != null)
                      IconButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: (){
                          setState(() {
                            _selectedImage = null;
                            imageYn = false;
                          });
                        }, icon: Icon(Icons.refresh,size: 25,),

                      ),
                    ],
                  ),
                  SizedBox(height: 14,),
                  Center(
                    child: _buildSelectedImage() ??
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Colors.black54,  // 테두리 색상 설정
                                width: 2.0,           // 테두리 두께 설정
                              ),
                            ),
                            height: screenHeight * 0.25, width: screenWidth * 0.5,
                            child: OutlinedButton(
                              onPressed: _pickImage,
                              child: Image.asset(
                                'assets/fileAdd.png',
                                width: screenWidth * 0.2,
                                height: screenHeight * 0.1,
                              ),
                            ),
                          ),

                  ),
                ],
              ),
              SizedBox(height: 30,),
              _TextField('상호명', '상호명을 입력해주세요.',  _proprietorName),
              _TextField('대표자명', '대표자명 입력', _representativeName),
              _TextField('사업자 번호', '사업자 번호 입력(-제외)',  _proprietorNum),
              SizedBox(height: 30,),
              Text("상업공간 소개",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
              SizedBox(height: 30,),
              _maps(),
              SizedBox(height: 10,),
              _TextField('상세주소', '상세주소를 입력해주세요.',  _addr2),
              SizedBox(height: 10,),
              _TextField('연락처(필수*)', '연락처 입력(-제외)', _managerPhone),
              SizedBox(height: 20,),
              Text("공간사진(첫번째 사진은 대표사진으로 설정됩니다. 필수*)", style: subStyle,),
              SizedBox(height: 10,),
              Wrap(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.black54,  // 테두리 색상 설정
                        width: 2.0,           // 테두리 두께 설정
                      ),
                    ),
                    height: screenHeight * 0.1, width: screenWidth * 0.2,
                    child: OutlinedButton(
                      onPressed: _prickImageList,
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/fileAdd.png',
                            width: screenWidth * 0.2,
                            height: screenHeight * 0.1,
                          ),
                          Positioned(
                            top: 1,
                              right: 10,
                              child: Text(
                                '${_commerImageList.length} / 5',
                                style: _commerImageList.length == 5 ? TextStyle(color: Colors.red) : TextStyle(color: Colors.black),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                  _commerImageListWidget()!,
                ],
              ),
              SizedBox(height: 10,),
              _TextField2("공간소개", '공간을 소개해주세요', _description),
              Text("영업시간(필수*)",style: subStyle,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: startTimeHour,
                    items: hourItem.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        startTimeHour = newValue!;
                      });
                    },
                  ),
                  SizedBox(width: 10,),
                  Text(":"),
                  SizedBox(width: 10,),
                  DropdownButton<String>(
                    value: startTimeMinute,
                    items: minuteItem.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        startTimeMinute = newValue!;
                      });
                    },
                  ),
                  Text("  ~  "),
                  DropdownButton<String>(
                    value: endTimeHour,
                    items: hourItem.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        endTimeHour = newValue!;
                      });
                    },
                  ),
                  SizedBox(width: 10,),
                  Text(":"),
                  SizedBox(width: 10,),
                  DropdownButton<String>(
                    value: endTimeMinute,
                    items: minuteItem.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        endTimeMinute = newValue!;
                      });
                    },
                  ),
                ],
              ),
              Text("버스킹 공간 정보",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
              _TextField2('지원장비', '가지고 계신 음향장비를 입력해주세요',  _equipmentComment),
              Text("장르(필수*)",style: subStyle,),
              Column(
                children: [
                  _customRadioBut(),
                  _wrapWidget(_genre),
                  genreListWidget()
                ],
              ),
              _TextField('가용인원(필수*)', '공연가능 인원(숫자만)', _headCount),
              _TextField('렌탈비용(공백시 0원)', '장소대여 비용을 입력해주세요(시간당,)', _rentalfee),
              Text("주차",style: subStyle,),
              Row(
                children: [
                  Radio(
                    value: "가능",
                    groupValue: parkingYn,
                    onChanged: (value) {
                      setState(() {
                        parkingYn = value;
                      });
                    }

                  ),
                  Text("가능"),
                  SizedBox(width: 15,),
                  Radio(
                    value: "불가능",
                    groupValue: parkingYn,
                    onChanged: (value) {
                      setState(() {
                        parkingYn = value;
                      });
                    }
                  ),
                  Text("불가능"),
                ],
              ),
              Text("영상촬영",style: subStyle,),
              Row(
                children: [
                  Radio(
                      value: "가능",
                      groupValue: videoYn,
                      onChanged: (value) {
                        setState(() {
                          videoYn = value;
                        });
                      }

                  ),
                  Text("가능"),
                  SizedBox(width: 15,),
                  Radio(
                      value: "불가능",
                      groupValue: videoYn,
                      onChanged: (value) {
                        setState(() {
                          videoYn = value;
                        });
                      }
                  ),
                  Text("불가능"),
                ],
              ),
              Text("약관동의",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
              Row(
                children: [
                  Radio(
                      value: "Y",
                      groupValue: termsYn,
                      onChanged: (value) {
                        setState(() {
                          termsYn = value;
                        });
                      }
                  ),
                  Text("사업주 이용약관(필수)")
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: termsYn != null ? Color(0xFF392F31) : Colors.grey, // 버튼의 배경색
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),  // 좌측 상단 모서리만 둥글게
                topRight: Radius.circular(20.0), // 우측 상단 모서리만 둥글게
              ),
            ),
          ),
          onPressed:  termsYn != null ? (){
            addGenresToFirestore();
          } : null,
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

  Container _maps() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('주소(필수*)'),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: coordinates == null
                ? Container()
                : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: coordinates!,
                zoom: 15,
              ),
              markers: coordinates == null
                  ? Set<Marker>()
                  : <Marker>{
                Marker(
                  markerId: MarkerId('customMarker'),
                  position: coordinates!,
                  infoWindow: InfoWindow(title: '버스킹존'),
                ),
              },
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 35,
            child: TextField(
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
              controller: _address,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                hintText: '주소를 입력해주세요.',
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                _getCoordinatesFromAddress(value);
              },
            ),
          ),
        ],
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
