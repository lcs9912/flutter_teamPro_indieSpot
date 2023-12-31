
import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/loading.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'concertDetails.dart';
import 'package:get/get.dart';

class BuskingList extends StatefulWidget{
  const BuskingList({super.key});

  @override
  State<BuskingList> createState() => _BuskingListState();
}

class _BuskingListState extends State<BuskingList> with SingleTickerProviderStateMixin{
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  FocusNode _focusNode = FocusNode();
  late TextField sharedTextField;
  String selectRegions = "";
  String selectGenre = "";
  List<Map<String,dynamic>> busKingList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  Future<List<Map<String, dynamic>>> _fetchBuskingData(QuerySnapshot snapshot) async {
    List<Map<String, dynamic>> buskingData = [];
    List<Future> futures = [];

    for (var element in snapshot.docs) {
      futures.add(_processElement(element, buskingData));
    }

    await Future.wait(futures);

    return buskingData;
  }

  Future<void> _processElement(QueryDocumentSnapshot element, List<Map<String, dynamic>> buskingData) async {
    String spotId = element.get('spotId');
    String artistId = element.get('artistId');

    QuerySnapshot artistSnap;
    QuerySnapshot spotSnap;

    if (selectGenre == "") {
      artistSnap = await fs.collection("artist").where(FieldPath.documentId, isEqualTo: artistId).get();
    } else {
      artistSnap = await fs.collection("artist")
          .where(FieldPath.documentId, isEqualTo: artistId)
          .where("genre", isEqualTo: selectGenre)
          .get();
    }

    if (artistSnap.docs.isNotEmpty) {
      if (artistSnap.docs.first.get("artistName").contains(_search.text)) {
        if (selectRegions == "") {
          spotSnap = await fs.collection('busking_spot')
              .where(FieldPath.documentId, isEqualTo: spotId)
              .get();
        } else {
          spotSnap = await fs.collection('busking_spot')
              .where(FieldPath.documentId, isEqualTo: spotId)
              .where("regions", isEqualTo: selectRegions)
              .get();
        }
        if (spotSnap.docs.isNotEmpty) {
          QuerySnapshot imgSnap = await fs.collection("busking").doc(element.id).collection("image").get();
          Map<String, dynamic> data = element.data() as Map<String, dynamic>;
          Timestamp timeStamp = data['buskingStart'];
          DateTime date = timeStamp.toDate();
          String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
          data["path"] = imgSnap.docs.first.get("path");
          data["buskingStart"] = formattedDate;
          data["startTime"] = date;
          data["spotName"] = spotSnap.docs.first.get("spotName");
          data["doc"] = element;
          buskingData.add(data);
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> _buskingList2() async {
    busKingList.clear();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    QuerySnapshot buskingSnap = await fs.collection("busking")
        .where('buskingStart', isGreaterThan: Timestamp.fromDate(today))
        .orderBy("buskingStart")
        .get();

    List<Map<String, dynamic>> buskingData = await _fetchBuskingData(buskingSnap);
    buskingData.sort((a, b) {
      DateTime dateTimeA = b['startTime'];
      DateTime dateTimeB = a['startTime'];
      return dateTimeB.compareTo(dateTimeA);
    });
    QuerySnapshot pastBuskingSnap = await fs.collection("busking")
        .where('buskingStart', isLessThan: Timestamp.fromDate(today))
        .orderBy("buskingStart")
        .get();

    List<Map<String, dynamic>> pastBuskingData = await _fetchBuskingData(pastBuskingSnap);
    pastBuskingData.sort((a, b) {
      DateTime dateTimeA = a['startTime'];
      DateTime dateTimeB = b['startTime'];
      return dateTimeB.compareTo(dateTimeA);
    });
    return [...buskingData, ...pastBuskingData];
  }
  Widget _buskingList() {
    return FutureBuilder(
      future: _buskingList2(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Expanded(
            child: ListView(
              children: [
                SizedBox(
                    height : 400,
                    child: LoadingWidget()),
              ],
            ),
          );
        }else{
          if (snapshot.hasData && snapshot.data!.isNotEmpty){
            return Expanded(
              child:ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data?[index]["title"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("일시 : ${snapshot.data?[index]["buskingStart"]}"),
                        Text("장소 : ${snapshot.data?[index]["spotName"]}")
                      ],
                    ),
                    leading:DateTime.now().isBefore(snapshot.data?[index]["startTime"]) ? Container(
                        width: 100,
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data?[index]['path'], // 이미지 URL
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()), // 이미지 로딩 중에 표시될 위젯
                          errorWidget: (context, url, error) => Icon(Icons.error), // 이미지 로딩 오류 시 표시될 위젯
                        ),
                    ):Stack(
                      children: [
                        Container(
                            width: 100,
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data?[index]['path'], // 이미지 URL
                              fit: BoxFit.fill,
                              placeholder: (context, url) => CircularProgressIndicator(), // 이미지 로딩 중에 표시될 위젯
                              errorWidget: (context, url, error) => Icon(Icons.error), // 이미지 로딩 오류 시 표시될 위젯
                            ),
                        ),
                        Container(
                          width: 100,
                          height: 60,
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          child: Center(child: Text("종료",style: TextStyle(
                              color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),)
                          ),
                        ),
                      ],
                    ) ,
                    onTap: () {
                      Get.to(
                        ConcertDetails(document: snapshot.data?[index]["doc"]),
                        transition: Transition.noTransition
                      )!.then((value) => setState((){}));
                    },
                  );
                },
              )
            );
          }else{
            return Container();
          }
        }
      },
    );
  }
  final List<String> _regions = ['서울', '부산', '인천', '강원', '경기', '경남', '경북', '광주', '대구', '대전', '울산', '전남', '전북', '제주', '충남', '충북'];
  Widget regiosWidget(){
    return Column(
        children: [
          Container(
            color: Colors.white,
            height: 50.0, // 높이 조절
            child: ListView(
              scrollDirection: Axis.horizontal, // 수평 스크롤
              children: [
                for (String region in _regions)
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[ TextButton(
                        onPressed: () {
                          setState(() {
                            selectRegions = region;
                            _buskingList2();
                          });
                        },
                        child: Text(region, style: TextStyle(
                            color: selectRegions == region? Color(0xFF233067) : Colors.black),
                        ),
                      ),]
                  ),
              ],
            ),
          ),
          sharedTextField,
          _buskingList(),
        ]
    );
  }
  final List<String> _genre = ["음악","댄스","퍼포먼스","마술"];
  Widget genreWidget(){
    return Column(
        children: [
          Container(
            color: Colors.white,
            height: 50.0, // 높이 조절
            child: ListView(
              scrollDirection: Axis.horizontal, // 수평 스크롤
              children: [
                for (String genre in _genre)
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children:[
                        Container(
                        margin: EdgeInsets.symmetric(horizontal: 17.0),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              selectGenre = genre;
                              _buskingList2();
                            });
                          },
                          child: Text(genre, style: TextStyle(
                              color: selectGenre == genre? Color(0xFF233067) : Colors.black),
                          ),
                        ),
                      ),]
                  ),
              ],
            ),
          ),
          sharedTextField,
          _buskingList(),
        ]
    );
  }
  @override
  Widget build(BuildContext context) {
    sharedTextField = TextField(
      controller: _search,
      focusNode: _focusNode,
      textInputAction: TextInputAction.go,
      onSubmitted: (value){
        setState(() {
          _buskingList2();
        });
      },
      decoration: InputDecoration(

        hintText: "팀명으로 검색하기",
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          onPressed: () {
            _focusNode.unfocus();
            _search.clear();
            _buskingList2();
            setState(() {

            });
          },
          icon: Icon(Icons.cancel_outlined),
        ),
        prefixIcon: Icon(Icons.search),
      ),
    );

    return DefaultTabController(
      length: 3,
      animationDuration: Duration.zero,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF233067),
          leading: Builder(
              builder: (context) {
                return IconButton(
                    color: Colors.white,
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back)
                );
              }
          ),
          title: Center(child: Text("공연 일정", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
          actions: [
            Builder(
                builder: (context) {
                  return IconButton(
                      color: Colors.white,
                      onPressed: (){
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(Icons.menu)

                  );
                }
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
              onTap: (int index) {
                if (index == 0) {
                  setState(() {
                    _search.clear();
                    selectRegions = "";
                    selectGenre = "";
                    _focusNode.unfocus();
                    _buskingList2();
                  });
                } else if (index == 1) {
                  setState(() {
                    _search.clear();
                    selectRegions = "서울";
                    selectGenre = "";
                    _focusNode.unfocus();
                    _buskingList2();
                  });
                } else if (index == 2) {
                  setState(() {
                    _search.clear();
                    selectRegions = "";
                    selectGenre = "음악";
                    _focusNode.unfocus();
                    _buskingList2();
                  });
                }
              },
              tabs: [
                Tab(text: '전체'),
                Tab(text: '지역'),
                Tab(text: '장르'),
              ],
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.white, // 선택되지 않은 탭의 텍스트 색상
              labelColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold, // 선택된 탭의 텍스트 굵기 설정
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal, // 선택되지 않은 탭의 텍스트 굵기 설정
              ),
            ),
          ),
          elevation: 1,
        ),
        drawer: MyDrawer(),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: sharedTextField,
                ),
                _buskingList(),
              ],
            ),
            regiosWidget(),
            genreWidget(),
          ],
        ),
        bottomNavigationBar: MyBottomBar(),
      ),
    );
  }
}
