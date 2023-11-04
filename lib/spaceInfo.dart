import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'baseBar.dart';
import 'package:intl/intl.dart';
class SpaceInfo extends StatefulWidget {

  String spaceId;
  SpaceInfo(this.spaceId);

  @override
  State<SpaceInfo> createState() => _SpaceInfoState();
}

class _SpaceInfoState extends State<SpaceInfo> {
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  List<String> imgPath = [];
  Map<String,dynamic>? spaceMap;
  List<Map<String,dynamic>> artistList = [];
  DateTime selectedDay = DateTime.now();
  DateTime selectedDay1 = DateTime.now();
  PageController _pageController = PageController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    spaceImg();
    spaceData();
    spaceRental();
  }
  @override
  Widget build(BuildContext context) {
    final NumberFormat _numberFormat = NumberFormat.decimalPattern();
    print(selectedDay.day);
    print(selectedDay.year);
    print(selectedDay.month);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: AppBar(
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
            '상업 공간',
            style: TextStyle(color: Colors.black,),
          ),
        ),
        body: ListView(
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
              height: 50,
              child: TabBar(
                tabs: [
                 Tab(text: "소개"),
                 Tab(text: "일정"),
                 Tab(text: "교통"),
                ],
                labelColor: Colors.black54,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: spaceMap != null ? Column(
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
                      ) : Container(),
                    ), // 1번 탭바
                    Column(
                      children: [
                        calendar(),
                        for(var artist in artistList)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
                              child: ListTile(
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
                        // 다른 일정 정보 등
                      ],
                    ), //2번 탭바
                    Column(
                      children: [
                        Text('교통 정보'),
                        // 다른 교통 정보 등
                      ],
                    ), // 3번 탭바
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget calendar(){
    final bool leftChevronVisible;
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
        if (selectedDay == null) {
          return false;
        }
        return date.year == selectedDay!.year &&
            date.month == selectedDay!.month &&
            date.day == selectedDay!.day;
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
  Future<void> spaceData() async{ //상업공간
    DocumentSnapshot spaceSnap = await fs.collection("commercial_space").doc(widget.spaceId).get();
    if(spaceSnap.exists){
      setState(() {
        spaceMap = spaceSnap.data() as Map<String,dynamic>;

      });
    }
  }

  Future<void> spaceImg()async{ //상업공간 이미지
    QuerySnapshot imgSnap = await fs.collection("commercial_space").doc(widget.spaceId).collection("image").get();
    if(imgSnap.docs.isNotEmpty){
      setState(() {
        for (var element in imgSnap.docs) {
          imgPath.add(element.get("path"));
        }
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
      print(1);
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
