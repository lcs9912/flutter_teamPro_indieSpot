import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/artistInfo.dart';
import 'baseBar.dart';

class RadioItem {
  final String label;
  bool isSelected;

  RadioItem({required this.label, this.isSelected = false});
}

class ArtistList extends StatefulWidget {
  const ArtistList({super.key});

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  List<RadioItem> radioItems = [
    RadioItem(label: "인기순", isSelected: true),
    RadioItem(label: "최신순"),
    RadioItem(label: "가입순"),
  ];

  // 라디오 버튼 기본 선택
  String? selectedRadio ="인기순";
  String? selectGenre; // 장르 탭바
  // 검색 컨트롤러
  final TextEditingController _search = TextEditingController();
  FocusNode _focusNode = FocusNode();
  late TextField sharedTextField;

  dynamic? _stream; // 쿼리문





  int cnt = 0; // 팔로우 갯수

  // 아티스트 리스트 출력
  Widget _artistList() {
    FirebaseFirestore fs = FirebaseFirestore.instance;
    if(selectGenre == null){
      if(selectedRadio == "가입순"){
        _stream = fs.collection("artist").orderBy('createdate', descending: true).snapshots();
      } else if(selectedRadio == "인기순"){
        _stream = fs.collection("artist").orderBy('followerCnt', descending: true).snapshots();
      } else if(selectedRadio == "최신순"){
        _stream = fs.collection("artist").orderBy('recentShow', descending: true).snapshots();
      }
    } else {
      _stream = fs.collection("artist").where('genre',isEqualTo: selectGenre)
          .orderBy('followerCnt', descending: true).snapshots();
    }

    return StreamBuilder(
      stream: _stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return Expanded(
          child: ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if(data['artistName'].contains(_search.text)){
                return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("artist")
                        .doc(doc.id)
                        .collection("image")
                        .get(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> imgSnap) {
                      if (imgSnap.hasData) {
                        var img = imgSnap.data!.docs.first;
                        if(data['followerCnt'] != null){
                          cnt = data['followerCnt'];
                        } else{
                          cnt = 0;
                        }
                        return ListTile(

                          leading: Image.network(
                            img['path'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          title: Text('${data['artistName']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${data['genre']}'),
                              Row(
                                children: [
                                  Icon(Icons.person_add_alt),
                                  Text('  $cnt')
                                ],
                              )
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            String artistImg = img['path'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistInfo(doc, artistImg),
                              ),
                            );
                          },
                        );
                      } else{
                        return Container();
                      }
                    }
                );
              }

            },
          ),
        );
      },
    );
  }

  // 장르 탭바
  final List<String> _genre = ["음악","댄스","퍼포먼스","마술"];
  Widget genreWidget(){
    return SingleChildScrollView(
      child: Column(
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

                                });

                              },

                              child: Text(genre, style: TextStyle(
                                  color: selectGenre == genre? Colors.lightBlue : Colors.black),

                              ),
                            ),
                          ),]
                    ),
                ],
              ),
            ),
          ]
      ),
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
          },
          icon: Icon(Icons.cancel_outlined),
        ),
        prefixIcon: Icon(Icons.search),
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) {
              return IconButton(
                color: Colors.black54,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
              );
            },
          ),
          title: Center(
            child: Text(
              "아티스트 목록",
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  color: Colors.black54,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.menu),
                );
              },
            )
          ],
          backgroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(text: '전체'),
              Tab(text: '장르'),
            ],
            onTap: (int index) {
              if (index == 0) {
                setState(() {
                  _search.clear();
                  _focusNode.unfocus();
                  selectGenre = null; // 장르버튼
                });
              } else if (index == 1) {
                setState(() {
                  _search.clear();
                  selectGenre = "음악";
                  _focusNode.unfocus();

                });
              }
            },
            unselectedLabelColor: Colors.black,
            labelColor: Colors.blue,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          elevation: 1,
        ),
        drawer: MyDrawer(),
        body: TabBarView(

          children: [
            Column( // 전체
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: radioItems
                      .map((item) => customRadio(item.label, item.isSelected))
                      .toList(),
                ),
                sharedTextField,
                _artistList(),

              ],
            ),
            Column( // 장르
              children: [
                genreWidget(),
                sharedTextField,
                _artistList()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customRadio(String label, bool isSelected) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          for (var item in radioItems) {
            item.isSelected = item.label == label;
          }
          selectedRadio = label; // 정렬에 사용할 라디오버튼 선택값
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(isSelected ? Color(0xFF392F31) : Colors.white),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

}
