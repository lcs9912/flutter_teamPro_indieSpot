import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/buskingReservation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class SpotDetailed extends StatefulWidget {
  final Map<String, dynamic> _data;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _addr;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _images;
  final String _spotId;
  const SpotDetailed(this._data, this._addr, this._images, this._spotId, {super.key});

  @override
  State<SpotDetailed> createState() => _SpotDetailedState();
}

class _SpotDetailedState extends State<SpotDetailed> {
  GoogleMapController? mapController;
  LatLng? coordinates;

  Future<void> _getCoordinatesFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final coordinates = LatLng(locations.first.latitude, locations.first.longitude);
      setState(() {
        this.coordinates = coordinates;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCoordinatesFromAddress('${widget._addr[0]['addr']} ${widget._addr[0]['addr2']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: ListView(
        children: [
          Image.network(widget._images[0].data()['path'], height: 308,),
          SizedBox(height: 10,),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget._data['spotName'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: (){_launchWeb(widget._addr[0]['addr'], widget._addr[0]['addr2']);}, child: Text('길찾기'), style: ButtonStyle(elevation: MaterialStatePropertyAll(0), backgroundColor: MaterialStatePropertyAll(Color(0xFF392F31))),)
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined),
                    Text('${widget._addr[0]['addr']}\n${widget._addr[0]['addr2']}', softWrap: true,)
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.local_phone_outlined ),
                    Text(widget._data['managerContact'])
                  ],
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(border: Border(top: BorderSide(width: 2, color: Color(0xFFEEEEEE)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('상세정보', style: TextStyle(fontSize: 15, color: Colors.grey),),
                SizedBox(height: 10,),
                Text(widget._data['description'], style: TextStyle(fontSize: 15),)
              ],
            ),
          ),
          Container(
            width: 300, // 원하는 가로 크기
            height: 200, // 원하는 세로 크기
            margin: EdgeInsets.only(bottom: 100, top: 20),
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
                zoom: 15, // 줌 레벨 조정
              ),
              markers: <Marker>{
                Marker(
                  markerId: MarkerId('customMarker'),
                  position: coordinates!,
                  infoWindow: InfoWindow(title: widget._data['spotName'], snippet: widget._data['description']),
                ),
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Row(
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
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => BuskingReservation.spot(widget._spotId, widget._data['spotName']),));
              },
              child: Text('버스킹 등록', style: TextStyle(fontSize: 17),),
            ),)
          ],
        ),
      )
    );
  }
  bool _ongoing = false;
  AppBar _appBar() {
    return AppBar(
      elevation: 1,
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
      title: Text('버스킹존', style: TextStyle(color: Colors.black),),
    );
  }

  _launchWeb(addr, addr2) async {
    String encodedAddress = Uri.encodeComponent('$addr $addr2');
    String decodedAddress = utf8.decode(encodedAddress.runes.toList());

    final Uri url = Uri.parse('https://map.kakao.com/?q=$decodedAddress'); // 열고자 하는 웹 페이지 URL로 변경
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    } else {
      throw 'Could not launch $url';
    }
  }
}
