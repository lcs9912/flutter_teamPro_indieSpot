import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/spaceRental.dart';
import 'package:table_calendar/table_calendar.dart';
import 'baseBar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'package:get/get.dart';
import 'dialog.dart';


class SpaceInfo extends StatefulWidget {

  final String spaceId;
  SpaceInfo(this.spaceId);

  @override
  State<SpaceInfo> createState() => _SpaceInfoState();
}

class _SpaceInfoState extends State<SpaceInfo> {
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  List<dynamic> imgPath = [];
  Map<String,dynamic>? spaceMap;
  List<Map<String,dynamic>> artistList = [];
  DateTime selectedDay = DateTime.now();
  DateTime selectedDay1 = DateTime.now();
  PageController _pageController = PageController();
  GoogleMapController? mapController;
  LatLng? coordinates;
  Map<String,dynamic> addrData = {};
  DocumentSnapshot? doc;
  String? artistId = "";
  String? userId = "";
  double _height = 0.45;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    spaceImg();
    spaceData();
    spaceRental();
    spaceAddr();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if(!userModel.isLogin){

    }else{
      userId = userModel.userId;
      if(!userModel.isArtist){

      }else{
        artistId = userModel.artistId;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final NumberFormat _numberFormat = NumberFormat.decimalPattern();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: AppBar(
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.menu),
                  color: Colors.white,
                );
              },
            ),
          ],
          elevation: 1,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              // 뒤로가기 버튼을 눌렀을 때 수행할 작업
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Color(0xFF233067),
          centerTitle: true,
          title: Text(
            '상업 공간',
            style: TextStyle(color: Colors.white,),
          ),
        ),
        body: ListView(
          controller: _scrollController,
          children: [
            imgPath.isNotEmpty?
            SizedBox(
              width: double.infinity,
              height: 200,
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                children:[
                 for(int i=0; i< imgPath.length; i++)
                    Image.network(imgPath[i])
                ]
              ),
            ) : Container(),
            Container(
              height: 70,
              color: Colors.grey[100],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spaceMap != null ?
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text((spaceMap?["spaceName"]).toString(),style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  ) : Container(),
                ],
              ),
            ),
            Container(
              color: Color(0xFF233067),
              height: 50,
              child: TabBar(
                tabs: [
                 Tab(text: "소개"),
                 Tab(text: "일정"),
                 Tab(text: "교통"),
                ],
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                onTap: (index) {
                  if(index == 0){
                    setState(() {
                      _height = 0.45;
                    });
                  }else if(index == 1){
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent + 200,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      _height = 0.7;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*_height,
              child: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: spaceMap != null ? Column(
                        children: [
                          Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10,bottom: 20),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("공간 소개",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 35),
                                          child: Text("소개글"),
                                        ),
                                        Container(
                                          child: Flexible(
                                              child: RichText(
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                                strutStyle: StrutStyle(fontSize: 16.0),
                                                text: TextSpan(
                                                    text: spaceMap?["description"],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      height: 1.4,
                                                      fontSize: 16.0,
                                                    )
                                                ),
                                              )
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 20),
                                            child: Text("지원장비"),
                                          ),
                                          Container(
                                            child: Flexible(
                                                child: RichText(
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 5,
                                                  strutStyle: StrutStyle(fontSize: 16.0),
                                                  text: TextSpan(
                                                      text: spaceMap?["equipmentYn"],
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        height: 1.4,
                                                        fontSize: 16.0,
                                                      )
                                                  ),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 32),
                                            child: Text("대여비"),
                                          ),
                                          Container(
                                            child: Text("시간당 ${_numberFormat.format(spaceMap?["rentalfee"])}원",style: TextStyle(
                                              color: Colors.black,
                                              height: 1.4,
                                              fontSize: 16.0,
                                            )),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 45),
                                            child: Text("주차"),
                                          ),
                                          Container(
                                            child: Text("가능",style: TextStyle(
                                              color: Colors.black,
                                              height: 1.4,
                                              fontSize: 16.0,
                                            )),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 16),
                                            child: Text("영상촬영"),
                                          ),
                                          Container(
                                            child: Text("가능",style: TextStyle(
                                              color: Colors.black,
                                              height: 1.4,
                                              fontSize: 16.0,
                                            )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          )
                        ],
                      ) : Container(),
                    ), // 1번 탭바
                    Column(
                      children: [
                        Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  calendar(),
                                  if(artistList.isNotEmpty)
                                  for(var artist in artistList)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 50),
                                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
                                        child:ListTile(
                                          title: Text(artist['artistName']),
                                          subtitle: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Text(DateFormat('MM-dd').format(artist["startTime"].toDate())),
                                              ),
                                              Text("${DateFormat('HH:mm').format(artist['startTime'].toDate())}~${DateFormat('HH:mm').format(artist['endTime'].toDate())}"),
                                            ],
                                          ),
                                          leading: Container(
                                            width: 40,
                                            child: CircleAvatar(
                                              radius: 40,
                                              backgroundImage: NetworkImage(artist["artistImg"]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: Center(
                                        child: Text("등록된 일정이 없습니다."),
                                      ),
                                    )
                                ],
                              ),
                            )
                        )
                      ],
                    ), //2번 탭바
                    Column(
                      children: [
                        Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20,top: 10),
                                        child: Text('교통 정보',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 20),
                                        child: ElevatedButton(onPressed: () async {
                                          List<Location> locations = await locationFromAddress(addrData['addr']);
                                          openDirectionsInGoogleMaps(locations.first.latitude,locations.first.longitude);
                                        },child: Text("길찾기")),
                                      )
                                    ],
                                  ),
                                  Container(
                                    width: 350, // 원하는 가로 크기
                                    height: 200, // 원하는 세로 크기
                                    margin: EdgeInsets.only(bottom:0, top: 20),
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
                                          infoWindow: InfoWindow(title: spaceMap?['spotName'], snippet: spaceMap?['description']),
                                        ),
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child: Text("주소"),
                                        ),
                                        Container(
                                          child: Flexible(
                                              child: RichText(
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                                strutStyle: StrutStyle(fontSize: 16.0),
                                                text: TextSpan(
                                                    text: addrData["addr"],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      height: 1.4,
                                                      fontSize: 16.0,
                                                    )
                                                ),
                                              )
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child: Text("장소"),
                                        ),
                                        Container(
                                          child: Flexible(
                                              child: RichText(
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                                strutStyle: StrutStyle(fontSize: 16.0),
                                                text: TextSpan(
                                                    text: addrData["addr2"],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      height: 1.4,
                                                      fontSize: 16.0,
                                                    )
                                                ),
                                              )
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        )
                      ],
                    ), // 3번 탭바
                  ],
                ),
            ),
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
                      backgroundColor: MaterialStatePropertyAll(Color(0xFF233067)),
                      elevation: MaterialStatePropertyAll(0),
                      shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero
                          )
                      )
                  ),
                  onPressed: () {
                    if(userId == ""){
                      DialogHelper.showUserRegistrationDialog(context);
                    }else{
                      if(artistId == ""){
                        DialogHelper.showArtistRegistrationDialog(context);
                      }else{
                        Get.to(
                          () => SpaceRental(document : doc!),
                          transition: Transition.noTransition
                        );
                      }
                    }
                  },
                  child: Text('예약', style: TextStyle(fontSize: 17),),
                ),)
              ],
            ),
          )
      ),
    );
  }

  Widget calendar(){
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: DateTime.now(),
      firstDay: DateTime.now(),
      lastDay: DateTime(3000),
      headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronVisible: false,
          rightChevronVisible: false,
          headerPadding: EdgeInsets.only(top: 20,bottom: 10),
          titleTextStyle: TextStyle(fontWeight: FontWeight.w700)),

      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {

        if (selectedDay.isBefore(DateTime.now())) {
          return;
        }
        setState(() {
          this.selectedDay = selectedDay;
          selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
          spaceRental();
        });
      },
      
      selectedDayPredicate: (DateTime date) {
        if (date.isBefore(DateTime.now())) {
          return false; // 오늘 이전의 날짜는 비활성화
        }
        return date.year == selectedDay.year &&
            date.month == selectedDay.month &&
            date.day == selectedDay.day;
      },
      calendarBuilders: CalendarBuilders(
        disabledBuilder: (context, date, _) {
          if (date.isBefore(DateTime.now())) {
            return Container(
              margin: const EdgeInsets.all(2.0),
              alignment: Alignment.center,
              child: Text(
              date.day.toString(),
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
      return null;
      },
    ),
    );
  }
  void openDirectionsInGoogleMaps(double destinationLatitude, double destinationLongitude) async {
    Uri googleUri = Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': '$destinationLatitude,$destinationLongitude'});

    if (await canLaunchUrl(googleUri)) {
      await launchUrl(googleUri);
    } else {
      throw 'Could not launch $googleUri';
    }
  }

  Future<void> spaceData() async{ //상업공간
    DocumentSnapshot spaceSnap = await fs.collection("commercial_space").doc(widget.spaceId).get();
    if(spaceSnap.exists){
      setState(() {
        spaceMap = spaceSnap.data() as Map<String,dynamic>;
        doc = spaceSnap;
      });
    }
  }
  Future<void> spaceAddr() async{
    QuerySnapshot addrSnap = await fs.collection("commercial_space").doc(widget.spaceId).collection("addr").get();
    if(addrSnap.docs.isNotEmpty){
      Map<String, dynamic> addrMap = addrSnap.docs.first.data() as Map<String,dynamic>;
      _getCoordinatesFromAddress('${addrMap['addr']} ${addrMap['addr2']}');
      searchNearbyPlaces('${addrMap['addr']} ${addrMap['addr2']}');
      setState(() {
        addrData = addrMap;
      });
    }
  }
  Future<void> _getCoordinatesFromAddress(String address) async { // 상업 공간 주소 구글맵
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final coordinates = LatLng(locations.first.latitude, locations.first.longitude);
      setState(() {
        this.coordinates = coordinates;
      });
    }
  }
  Future<void> searchNearbyPlaces(String addr) async {
    final String apiUrl = 'https://places.googleapis.com/v1/places:searchNearby';
    final String apiKey = 'AIzaSyAo72hnij2zaCRszQEvikOavWMDWnQAX_c';
    List<Location> locations = await locationFromAddress(addr);
    final Map<String, dynamic> requestData = {
      "includedTypes": ["train_station","subway_station"],
      "maxResultCount": 10,
      "locationRestriction": {
        "circle": {
          "center": {
            "latitude": locations.first.latitude,
            "longitude": locations.first.longitude,
          },
          "radius": 1000.0,
        },
      },
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.displayName',
    };
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      // 여기에서 responseData를 처리하십시오.
    } else {
      throw Exception('Failed to fetch data');
    }
  }
  Future<void> spaceImg()async{ //상업공간 이미지
    QuerySnapshot imgSnap = await fs.collection("commercial_space").doc(widget.spaceId).collection("image").get();
    if(imgSnap.docs.isNotEmpty){
      setState(() {
          imgPath = imgSnap.docs.first.get("path");
      });
    }
  }

  Future<void> spaceRental()async{ //장소 예약한 아티스트 목록
    DateTime selectedDayPlusOne = selectedDay.add(Duration(days: 1));
    QuerySnapshot rentalSnap = await fs
        .collection("commercial_space")
        .doc(widget.spaceId)
        .collection("rental")
        .orderBy("startTime", descending: true)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDay))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(selectedDayPlusOne))
        .get();
    if(rentalSnap.docs.isNotEmpty){
      List<Map<String, dynamic>> tempList = [];
      for(int i=0; i < rentalSnap.docs.length; i++){
        DocumentSnapshot artistSnap = await fs.collection("artist").doc(rentalSnap.docs[i].get("artistId")).get();
        if(artistSnap.exists){
          QuerySnapshot artistImgSnap = await artistSnap.reference.collection("image").get();
          if(artistImgSnap.docs.isNotEmpty){
            tempList.add({
             "startTime" : rentalSnap.docs[i]["startTime"],
              "endTime" : rentalSnap.docs[i]["endTime"],
              "artistImg" : artistImgSnap.docs[0]["path"],
              "artistName" : artistSnap.get("artistName"),
            });
          }
        }
      }
      setState(() {
        artistList = tempList;
      });
    }else{
      setState(() {
        artistList = [];
      });
    }
  }

}
