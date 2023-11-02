import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'baseBar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class AddBuskingSpot extends StatefulWidget {
  const AddBuskingSpot({super.key});

  @override
  State<AddBuskingSpot> createState() => _AddBuskingSpotState();
}

class _AddBuskingSpotState extends State<AddBuskingSpot> {
  final _spotName = TextEditingController();
  final _address = TextEditingController();
  File? _image;
  String? _imageName;
  GoogleMapController? mapController;
  LatLng? coordinates;

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
        _address.text = address; // 이 부분에서 주소를 상태에 저장
      });
    }
  }

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark firstPlacemark = placemarks.first;
        String address = "${firstPlacemark.street}, ${firstPlacemark.locality}, ${firstPlacemark.administrativeArea}, ${firstPlacemark.country}";
        return address;
      }
    } catch (e) {
      print("Error: $e");
    }
    return "주소를 찾을 수 없음";
  }

  @override
  void initState() {
    // TODO: implement initState
    _getCoordinatesFromAddress('서울 시청');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: _appBar(),
      body: ListView(
        children: [
          _spotNameTextField(),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text('공연 이미지 등록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          SizedBox(height: 10,),
          _imageAdd(),
          SizedBox(height: 10,),
          _maps(),
        ],
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
          SizedBox(height: 10),
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
          SizedBox(height: 10),
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

  Container _spotNameTextField() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
        children: [
          Text('버스킹존 이름'),
          SizedBox(height: 10),
          Container(
            height: 35,
            child: TextField(
              style: TextStyle(
                  fontWeight: FontWeight.w500
              ),
              controller: _spotName,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                hintText: '버스킹존의 장소명을 입력해주세요',
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

  Container _imageAdd(){
    return Container(
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
      color: Colors.white,
      height: 180,
      width: 180,
      child: Icon(Icons.camera_alt, color: Colors.grey),
    );
  }
}
