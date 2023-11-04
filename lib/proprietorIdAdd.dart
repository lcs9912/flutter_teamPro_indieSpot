import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:indie_spot/artistList.dart';
import 'package:indie_spot/lsjMain.dart';
import 'donationList.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'buskingReservation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
class ProprietorAdd extends StatefulWidget {
  const ProprietorAdd({super.key});

  @override
  State<ProprietorAdd> createState() => _ProprietorAddState();
}

class _ProprietorAddState extends State<ProprietorAdd> {
  File? _selectedImage;

  final TextEditingController _proprietorName = TextEditingController(); // 상호명
  final TextEditingController _representativeName = TextEditingController(); // 대표자 명
  final TextEditingController _proprietorNum = TextEditingController(); //사업자 번호
  final TextEditingController _managerPhone = TextEditingController(); // 관리자 전화번호
  final TextEditingController _description = TextEditingController(); // 공간 소개
  final TextEditingController _equipmentComment = TextEditingController(); // 지원장비
  final TextEditingController _commerAddr = TextEditingController(); // 공간 주소
  final TextEditingController _commerDetaillAddr = TextEditingController(); // 공간 상세주소

  final TextEditingController _genreSelf = TextEditingController(); // 공연 가능한 장르 직접 입력

  String? parkingYn; // 주자 여부
  String? videoYn; // 영상촬영 여부
  List<String> genreList = []; // 공연 가능한 장르

  String? startTime; // 영업시간
  String? entTime; // 영업 시간
  List<File> _commerImageList = []; // 상업공간 이미지

  // 지도 API
  GoogleMapController? mapController;
  LatLng? coordinates;
  final _address = TextEditingController();
  final _addr2 = TextEditingController();
  int? _zip;
  String _addr= '';
  String _regions = '';

  // 이미지
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // 이미지 리스트
  Future<void> _prickImageList() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _commerImageList.add(File(pickedImage.path));
      });
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
  Widget? _commerImageListWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (_commerImageList != null) {
      // 이미지를 미리보기로 보여줄 수 있음
      List<Widget> imageContainers = _commerImageList.map((image) {
        return Container(
          child: Image.file(image, height: screenHeight * 0.1, width: screenWidth * 0.2, fit: BoxFit.fill),
        );
      }).toList();

      return Wrap(
        spacing: 5.0,  // 이미지 사이의 가로 간격
        runSpacing: 0.1, // 이미지 사이의 세로 간격
        children: imageContainers,
      );
    }
    return null; // 이미지가 없을 경우 null을 반환
  }

  @override
  void initState() {
    // TODO: implement initState
    _getCoordinatesFromAddress('서울 시청');
    
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
          _addr = address;
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
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("사업자 정보",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
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
                          });
                        }, icon: Icon(Icons.refresh,size: 25,),

                      ),
                    ],
                  ),
                  SizedBox(height: 14,),
                  Center(
                    child: _buildSelectedImage() ??
                          Container(
                              child: Container(
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
                              )
                          ),

                  ),
                ],
              ),
              SizedBox(height: 30,),
              Text("상업 공간 소개",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
              Text("상호명",style: subStyle,),
              TextField(
                maxLines: 1,
                controller: _proprietorName,
                decoration: InputDecoration(
                    hintText: "상호명 입력",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              Text("대표자명",style: subStyle,),
              TextField(
                maxLines: 1,
                controller: _representativeName,
                decoration: InputDecoration(
                    hintText: "대표자명 입력",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              Text("사업자 번호",style: subStyle,),
              TextField(
                controller: _proprietorNum,
                decoration: InputDecoration(
                    hintText: "사업자 번호 입력(-제외)",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              Text("주소",style: subStyle,),
              _maps(),
              SizedBox(height: 10,),
              _TextField('상세주소', '상세주소를 입력해주세요.', _addr2),
              Text("연락처",style: subStyle,),
              TextField(
                controller: _managerPhone,
                decoration: InputDecoration(
                    hintText: "연락처 입력(-제외)",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))
                ),
              ),
              SizedBox(height: 10,),
              Text("공간사진(첫번째 사진은 대표사진으로 설정됩니다.)", style: subStyle,),
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
                      child: Image.asset(
                        'assets/fileAdd.png',
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.1,
                      ),
                    ),
                  ),
                  _commerImageListWidget()!,
                ],
              ),
              SizedBox(height: 10,),
              Text("공간소개",style: subStyle,),
              TextField(
                maxLines: 3,
                controller: _description,
                decoration: InputDecoration(
                    hintText: "공간을 소개해주세요",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              Text("영업시간",style: subStyle,),
              Text("시간 어케 하지;;"),
              Text("버스킹 공간 정보",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
              Text("지원장비",style: subStyle,),
              TextField(
                maxLines: 3,
                controller: _equipmentComment,
                decoration: InputDecoration(
                    hintText: "가지고 계신 음향장비를 입력해주세요",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              Text("장르",style: subStyle,),
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
            ],
          ),
        ),
      ),
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

  // TextField 위젯
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


}
