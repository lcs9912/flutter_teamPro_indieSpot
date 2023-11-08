import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indie_spot/main.dart';
import 'package:indie_spot/userModel.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'baseBar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';

class BuskingReservation extends StatefulWidget {
  BuskingReservation();
  String? _receivingSpotId;
  String? _receivingSpotName;
  BuskingReservation.spot(this._receivingSpotId, this._receivingSpotName, {super.key});

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
  String? _artisName;
  String? _userId;
  String? _artisId;

  Future<String> uploadImage(String name) async {
    // Firebase Storage에 저장할 파일의 참조 생성
    Reference storageReference = FirebaseStorage.instance.ref().child('image/$name');

    // 파일을 Firebase Storage에 업로드하고 업로드 작업 시작
    UploadTask uploadTask = storageReference.putFile(_image!);

    // 업로드 작업이 완료될 때까지 대기하고 업로드된 파일의 정보 가져오기
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    // 업로드된 파일의 Firebase Storage 다운로드 URL 가져오기
    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    // 업로드 및 다운로드가 완료된 후, 다운로드 URL을 반환
    return downloadURL;
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
    FocusScope.of(context).unfocus();
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진을 등록해주세요')));
      return; // 이미지가 없으면 업로드하지 않음
    } else if(_titleControl.text == null || _titleControl.text == ''){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('공연명을 입력해주세요')));
      return;
    } else if(_descriptionControl.text == null || _descriptionControl.text == ''){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('공연소개를 입력해주세요')));
      return;
    } else if (_selectedDate == null || _selectedTime == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('공연 시작 시간을 선택해주세요')));
      return;
    } else if (_spotId == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('공연 장소를 선택해주세요')));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoadingScreen();
      },
      barrierDismissible: false, // 사용자가 화면을 탭해서 닫는 것을 막습니다.
    );


    String name = generateUniqueFileName(_imageName!);
    _path = await uploadImage(name);

    await Firebase.initializeApp();
    FirebaseFirestore fs = FirebaseFirestore.instance;
    CollectionReference busking = fs.collection('busking');

// _selectedDate와 _selectedTime을 합쳐서 DateTime 객체를 생성
    DateTime selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    Timestamp timestamp = Timestamp.fromDate(selectedDateTime);


    await busking
      .add({
        'artistId' : _artisId,
        'buskingStart' : timestamp,
        'title' : _titleControl.text,
        'description' : _descriptionControl.text,
        'spotId' : _spotId,
        'createDate' : FieldValue.serverTimestamp(),
        'uDateTime' : FieldValue.serverTimestamp()
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
    if(!context.mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyApp(),));
  }

  Future<void> _artisNameSearch() async{
    final FirebaseFirestore fs = FirebaseFirestore.instance;

    final artistDoc = await fs.collection('artist').doc('$_artisId').get();
    if (artistDoc.exists) {
      var fieldValue = artistDoc.get('artistName');
      setState(() {
        _artisName = fieldValue;
      });
    } else {
      print('해당 아티스트 문서가 존재하지 않습니다.');
      if(!context.mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();

    _spotId = widget._receivingSpotId;
    _spotName = widget._receivingSpotName;
    _userId = Provider.of<UserModel>(context, listen: false).userId;
    _artisId = Provider.of<UserModel>(context, listen: false).artistId;
    _artisNameSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: AppBar(
          actions: [
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
        bottomNavigationBar: MyBottomBar(),
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

            if (image != null) {
              final croppedImage = await ImageCropper().cropImage(
                sourcePath: image.path,
                aspectRatio: CropAspectRatio(ratioX: 1.5, ratioY: 1), // 원하는 가로세로 비율 설정
              );

              if (croppedImage != null) {
                setState(() {
                  _image = File(croppedImage.path);
                  _imageName = image.name;
                });
              }
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
          Text('$_artisName', style: TextStyle(fontSize: 15)),
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
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      content: Text('등록하시겠습니까?'),
                      actions: [
                        TextButton(onPressed: (){
                          Navigator.of(context).pop();
                        }, child: Text('취소', style: TextStyle(color: Color(0xFF392F31)),)),
                        TextButton(onPressed: (){
                          Navigator.of(context).pop();
                          _addBusking();
                        }, child: Text('등록', style: TextStyle(color: Color(0xFF392F31)),)),
                      ],
                    );
                  },);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF392F31), // 392F31 색상
                  minimumSize: Size(double.infinity, 48), // Set button width and height
                ),
                child: Text('등록하기', style: TextStyle(fontSize: 15),),
              ),
            ),
          ),
          SizedBox(height: 40,),
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
        // ... 이전 코드 부분은 여기에 그대로 두세요 ...
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
                      future: spots.doc(document.id).collection('image').limit(1).get(),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(); // 데이터가 로딩 중이면 로딩 표시
                        }
                        if (imageSnapshot.hasError) {
                          return Text('이미지를 불러오는 중 오류가 발생했습니다.');
                        }
                        List<QueryDocumentSnapshot<Map<String, dynamic>>> image = imageSnapshot.data!.docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>;

                        // addr 서브컬렉션 데이터 가져오기
                        return FutureBuilder<QuerySnapshot>(
                          future: spots.doc(document.id).collection('addr').limit(1).get(),
                          builder: (context, addrSnapshot) {
                            if (addrSnapshot.connectionState == ConnectionState.waiting) {
                              return Container(); // 데이터가 로딩 중이면 로딩 표시
                            }
                            if (addrSnapshot.hasError) {
                              return Text('주소 데이터를 불러오는 중 오류가 발생했습니다.');
                            }
                            List<QueryDocumentSnapshot<Map<String, dynamic>>> addr = addrSnapshot.data!.docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>;

                            return Container(
                              padding: EdgeInsets.only(bottom: 5, top: 5),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: 1, color: Color(0xFFEEEEEE)),
                                ),
                              ),
                              child: ListTile(
                                title: Text(data['spotName']),
                                subtitle: Text(addr[0].data()['addr']),
                                leading: Container(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(image[0].data()['path']),
                                ),
                                onTap: () {
                                  Navigator.pop(context, document); // 선택한 항목 반환
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        ),
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


class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.7), // 배경을 반투명하게 하고 하얀색으로 설정
      body: Center(
        child: CircularProgressIndicator(), // 로딩 표시 방법을 원하는 대로 수정 가능
      ),
    );
  }
}