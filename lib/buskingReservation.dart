import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'baseBar.dart';

class BuskingReservation extends StatefulWidget {
  @override
  State<BuskingReservation> createState() => _BuskingReservationState();
}

class _BuskingReservationState extends State<BuskingReservation> {
  File? _image;
  String? _imageName;
  final _titleControl = TextEditingController();  //공연명
  final _descriptionControl = TextEditingController();  //공연 설명
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _spotId;
  String? _spotName = '';
  String? _path;

  Future<void> downloadAndSaveImage(String name) async {
    Directory dir = await getApplicationDocumentsDirectory();
    Directory buskingDir = Directory('${dir.path}/busking');

    if (!await buskingDir.exists()) {
      await buskingDir.create(); // 폴더 생성
    }

    try {
      File targetFile = File('${buskingDir.path}/$name');
      // targetFile.path 얘를 db에 저장 후 호출 때 사용
      // 보통 안드로이드 => /data/user/0/com.example.indie_spot/app_flutter
      // 아이폰 => /Users/your_user_name/Library/Developer/CoreSimulator/Devices/DEVICE_ID/data/Containers/Data/Application/APP_ID/Documents
      print('저장경로 확인 ==> ${targetFile.path}');
      _path = targetFile.path;
      // _image는 File객체
      await _image!.copy(targetFile.path);
      // 저장 후 호출 시에는 Image.file(imageFile) 형태로 사용할 것
    } catch (e) {
      print("에러메세지: $e");
    }
  }

  String generateUniqueFileName(String originalName) {
    String uuid = Uuid().v4();
    String extension = originalName.split('.').last;
    return '$uuid.$extension';
  }

  void _openBuskingZoneList() async {
    final selectedZone = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuskingZoneListScreen(),
      ),
    );

    if (selectedZone != null) {
      setState(() {
        _spotId = selectedZone.id;
        _spotName = selectedZone.data()['spotName'];
      });
    }
  }


  void _addBusking() async{
    if (_image == null) {
      return; // 이미지가 없으면 업로드하지 않음
    }

    String name = generateUniqueFileName(_imageName!);
    await downloadAndSaveImage(name);

    await Firebase.initializeApp();
    FirebaseFirestore fs = FirebaseFirestore.instance;
    CollectionReference busking = fs.collection('busking');

    await busking
      .add({
        'artistId' : '집에가고싶다',
        'buskingStart' : '${DateFormat('yyyy-MM-dd').format(_selectedDate!)} ${_selectedTime!.format(context)}',
        'title' : _titleControl.text,
        'description' : _descriptionControl.text,
        'spotId' : _spotId,
        'createDate' : FieldValue.serverTimestamp(),
        'uDateTime' : FieldValue.serverTimestamp(),
      })
      .then((DocumentReference document){
        document.collection('image')
          .add({
            'orgName' : _imageName,
            'name' : name,
            'path' : _path,
            'size' : _image!.lengthSync(),
            'deleteYn' : 'n',
            'cDateTime' : FieldValue.serverTimestamp(),
          });
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: AppBar(
          actions: [
            IconButton(
                onPressed: (){

                },
                icon: Icon(Icons.person),color: Colors.black54),
            Builder(
              builder: (context) {
                return IconButton(
                    onPressed: (){
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(Icons.menu),color: Colors.black54);
              }
            ),
          ],
          elevation: 1,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back, // 뒤로가기 아이콘
              color: Colors.black54, // 원하는 색상으로 변경
            ),
            onPressed: () {
              // 뒤로가기 버튼을 눌렀을 때 수행할 작업
              Navigator.of(context).pop(); // 이 코드는 화면을 닫는 예제입니다
            },
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            '버스킹 일정 등록',
            style: TextStyle(color: Colors.black),)
        ),
        body: ListView(
          children: [
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text('공연 이미지 등록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            SizedBox(height: 10,),
            _imageAdd(), // 이미지 변수에 저장 및 프리뷰
            SizedBox(height: 10,),
            _content(),
          ],
        ),
      );
  }
  
  Container _imageAdd(){
    return Container(
      height: 200,
      color: Color(0xffEEEEEE),
      child: Center(
        child: InkWell(
          onTap: () async{
            var picker = ImagePicker();
            var image = await picker.pickImage(source: ImageSource.gallery);
            if(image != null){
              dynamic sendData = image.path;

              setState(() {
                _image = File(image.path);
                _imageName = image.name;
              });
            }
          },
          child: _imageBox(),
        )
      ),
    );
  }

  Widget _imageBox(){
    return _image != null ?
    Image.file(_image!, width: 180, height: 180,) :
    Container(
      margin: EdgeInsets.all(10),
      color: Colors.white,
      height: 180,
      width: 180,
      child: Icon(Icons.camera_alt, color: Colors.grey),
    );
  }

  Container _content(){
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('아티스트', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 20,),
          Text('집에가고싶다', style: TextStyle(fontSize: 15)),
          SizedBox(height: 20,),
          Text('공연명', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 10,),
          TextField(
            controller: _titleControl,
            decoration: InputDecoration(
              hintText: '공연 제목을 입력해주세요',
            ),
          ),
          SizedBox(height: 20,),
          Text('공연 소개', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 10,),
          TextField(
            controller: _descriptionControl,
            decoration: InputDecoration(
              hintText: '공연 내용에 대한 간단한 소개를 입력해주세요',
            ),
          ),
          SizedBox(height: 20,),
          Text('공연 시작 시간', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          _timeTile(),
          Text('공연 장소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () async{
              _openBuskingZoneList();
            },
            title: Text(_spotId != null? _spotName.toString() : '장소를 선택해주세요'),
          ),
          SizedBox(height: 40,),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding if needed
              child: ElevatedButton(
                onPressed: (){
                  _addBusking();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF392F31), // 392F31 색상
                  minimumSize: Size(double.infinity, 48), // Set button width and height
                ),
                child: Text('등록하기', style: TextStyle(fontSize: 15),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ListTile _timeTile(){
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () async{
        final DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year, 12, 31),
        );

        if (!context.mounted) return;

        if (selectedDate != null) {
          final TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            initialEntryMode: TimePickerEntryMode.input,
          );

          if (selectedTime != null) {
            setState(() {
              _selectedDate = selectedDate;
              _selectedTime = selectedTime;
            });
          }
        }
      },
      title: Text(_selectedTime != null ? '${DateFormat('yyyy-MM-dd').format(_selectedDate!)} ${_selectedTime!.format(context)}' : '날짜 선택', style: TextStyle(fontSize: 15),),
    );
  }
}

class BuskingZoneListScreen extends StatefulWidget {
  @override
  State<BuskingZoneListScreen> createState() => _BuskingZoneListScreenState();
}

class _BuskingZoneListScreenState extends State<BuskingZoneListScreen> {
  int _currentTabIndex = 0;
  final _searchControl = TextEditingController();
  final List<String> _regions = ['전국', '서울', '부산', '인천', '강원', '경기', '경남', '경북', '광주', '대구', '대전', '울산', '전남', '전북', '제주', '충남', '충북'];


  Query getSelectedCollection(FirebaseFirestore fs) {
    if (_currentTabIndex == 0) {
      return fs.collection('busking_spot');
    } else {
      String selectedRegion = _regions[_currentTabIndex]; // -1을 해서 _regions 리스트에 맞는 값으로 선택
      return fs.collection('busking_spot').where('regions', isEqualTo: selectedRegion);
    }
  }

  Widget _spotList() {

    FirebaseFirestore fs = FirebaseFirestore.instance;
    CollectionReference spots = fs.collection('busking_spot');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '검색',
              border: OutlineInputBorder(),
            ),
            controller: _searchControl,
            textInputAction: TextInputAction.go,
            onSubmitted: (value) {
              setState(() {

              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: getSelectedCollection(fs).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = snapshot.data!.docs[index];
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  if (data['spotName'].contains(_searchControl.text)) {
                    return FutureBuilder<QuerySnapshot>(
                      future: spots.doc(document.id).collection('addr').limit(1).get(),
                      builder: (context, addrSnapshot) {
                        if (addrSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(); // 데이터가 로딩 중이면 로딩 표시
                        }
                        if (addrSnapshot.hasError) {
                          return Text('데이터를 불러오는 중 오류가 발생했습니다.');
                        }
                        List<QueryDocumentSnapshot<Map<String, dynamic>>> addr = addrSnapshot.data!.docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
                        return Container(
                          padding: EdgeInsets.only(bottom: 5, top: 5),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color(0xFFEEEEEE)))),
                          child: ListTile(
                            title: Text(data['spotName']),
                            subtitle: Text(addr[0].data()['addr']),
                            leading: Container(child: Image.asset('busking/SE-70372558-15b5-11ee-8f66-416d786acd10.jpg'), width: 100, height: 100,),
                            onTap: () {
                              Navigator.pop(context, document); // 선택한 항목 반환
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _regions.length,
      child: Scaffold(
        backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back, // 뒤로가기 아이콘
                color: Colors.black54, // 원하는 색상으로 변경
              ),
              onPressed: () {
                // 뒤로가기 버튼을 눌렀을 때 수행할 작업
                Navigator.of(context).pop(); // 이 코드는 화면을 닫는 예제입니다
              },
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text('버스킹존 목록', style: TextStyle(color: Colors.black),),
            bottom: TabBar(
                isScrollable: true,
                tabs: [
                  for(String region in _regions)
                    Tab(
                      child: Text(region, style: TextStyle(color: Colors.black),),
                    )
                ],
                unselectedLabelColor: Colors.black, // 선택되지 않은 탭의 텍스트 색상
                labelColor: Colors.blue,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, // 선택된 탭의 텍스트 굵기 설정
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal, // 선택되지 않은 탭의 텍스트 굵기 설정
                ),
                onTap: (value) {
                  setState(() {
                    _currentTabIndex = value; // 탭 선택 변경
                  });
                },
            ),
            elevation: 1,
          ),
          body: _spotList()
      )
    );
  }
}
