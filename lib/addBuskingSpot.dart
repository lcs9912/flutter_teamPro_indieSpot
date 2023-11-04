import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'baseBar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';

import 'buskingReservation.dart';

class AddBuskingSpot extends StatefulWidget {
  const AddBuskingSpot({super.key});

  @override
  State<AddBuskingSpot> createState() => _AddBuskingSpotState();
}

class _AddBuskingSpotState extends State<AddBuskingSpot> {
  final _spotName = TextEditingController();
  final _address = TextEditingController();
  final _addr2 = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  int? _zip;
  String _addr= '';
  String _regions = '';
  File? _image;
  String? _imageName;
  GoogleMapController? mapController;
  LatLng? coordinates;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  String? _userId;

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
          _addr = address;
        }
      });
    }
  }

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark firstPlacemark = placemarks.first;
        print(firstPlacemark);
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

  Future<void> _addBuskingSpot() async{
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진을 등록해주세요')));
      return; // 이미지가 없으면 업로드하지 않음
    } else if(_spotName.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('버스킹존 이름을 입력해주세요')));
      return; // 이미지가 없으면 업로드하지 않음
    } else if(_addr == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('주소를 입력해주세요')));
      return; // 이미지가 없으면 업로드하지 않음
    } else if(_addr2.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상세주소를 입력해주세요')));
      return; // 이미지가 없으면 업로드하지 않음
    } else if(_description.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상세정보를 입력해주세요')));
      return; // 이미지가 없으면 업로드하지 않음
    }

    String regions = formatCity(_regions);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoadingScreen();
      },
      barrierDismissible: false, // 사용자가 화면을 탭해서 닫는 것을 막습니다.
    );


    String name = generateUniqueFileName(_imageName!);
    String _path = await uploadImage(name);
    
    await fs.collection('busking_spot').add({
      'spotName' : _spotName.text,
      'description' : _description.text,
      'createDate' : FieldValue.serverTimestamp(),
      'uDateTime' : FieldValue.serverTimestamp(),
      'managerContact' : _phone.text != '' ? _phone.text : '해당사항 없음',
      'regions' : regions
    })
    .then((DocumentReference document) async{
      await document.collection('image')
          .add({
        'orgName' : _imageName,
        'name' : name,
        'path' : _path,
        'size' : _image!.lengthSync(),
        'deleteYn' : 'n',
        'cDateTime' : FieldValue.serverTimestamp(),
      });
      await document.collection('addr').add({
        'addr' : _addr,
        'addr2' : _addr2.text,
        'zipcode' : _zip ?? 0
      });
    });

    if(!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    // TODO: implement initState
    _getCoordinatesFromAddress('서울 시청');

    _userId = Provider.of<UserModel>(context, listen: false).userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        drawer: MyDrawer(),
        appBar: _appBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _TextField('버스킹존 이름', '버스킹존의 장소명을 입력하세요', _spotName),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text('공연 이미지 등록'),
              ),
              SizedBox(height: 10,),
              _imageAdd(),
              SizedBox(height: 10,),
              _maps(),
              SizedBox(height: 10,),
              _TextField('상세주소', '상세주소를 입력해주세요.', _addr2),
              SizedBox(height: 10,),
              _TextField('전화번호 (선택사항)', '해당 버스킹존의 전화번호(고객센터)를 입력해주세요.', _phone),
              SizedBox(height: 10,),
              _TextField2('상세정보', '주의사항 등 버스킹존의 상세정보를 입력해주세요.', _description),
              SizedBox(height: 30,),
              Row(
                children: [
                  Expanded(child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStatePropertyAll(Size(0, 48)),
                        backgroundColor: MaterialStatePropertyAll(Color(0xFF392F31)),
                        elevation: MaterialStatePropertyAll(0),
                        shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero
                            )
                        )
                    ),
                    onPressed: () {
                      showDialog(context: context, builder: (context) {
                        return AlertDialog(
                          title: Text('버스킹존 등록'),
                          content: Text('버스킹존을 등록하시겠습니까?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소')),
                            TextButton(onPressed: (){
                              _addBuskingSpot();
                              Navigator.of(context).pop();
                            }, child: Text('등록')),
                          ],
                        );
                      },);
                    },
                    child: Text('등록하기 ', style: TextStyle(fontSize: 17),),
                  ),)
                ],
              )
            ],
          ),
        ),
        bottomNavigationBar: MyBottomBar(),

    );
  }


  Container _maps() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('주소'),
          SizedBox(height: 20),
          Container(
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
          Container(
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
          )
        ],
      ),
    );
  }

  Container _TextField2(String title, String hint, TextEditingController control) {
    return Container(
      padding: EdgeInsets.all(15),
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
              maxLines: 5,
              controller: control,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                hintText: '$hint',
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container _TextField(String title, String hint, TextEditingController control) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
        children: [
          Text('$title'),
          SizedBox(height: 10),
          Container(
            height: 35,
            child: TextField(
              style: TextStyle(
                  fontWeight: FontWeight.w500
              ),
              controller: control,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                hintText: '$hint',
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      actions: [
        IconButton(
          onPressed: () {
            // 아이콘 클릭 시 수행할 작업 추가
          },
          icon: Icon(Icons.person),
          color: Colors.black54,
        ),
        Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu),
              color: Colors.black54,
            );
          },
        ),
      ],
      elevation: 1,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black54,
        ),
        onPressed: () {
          // 뒤로가기 버튼을 눌렀을 때 수행할 작업
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        '버스킹존 등록',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  SizedBox _imageAdd(){
    return SizedBox(
      height: 200,
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
      color: Colors.black12,
      height: 180,
      width: 180,
      child: Icon(Icons.camera_alt, color: Colors.grey),
    );
  }
}
