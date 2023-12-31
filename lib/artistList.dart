import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/artistInfo.dart';
import 'baseBar.dart';
import 'userModel.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

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
  FirebaseFirestore fs = FirebaseFirestore.instance;
  String? _userId; // 세션 아이디
  String? artistId;
  List<RadioItem> radioItems = [
    RadioItem(label: "인기순", isSelected: true),
    RadioItem(label: "최신순"),
    RadioItem(label: "가입순"),
  ];

  // 라디오 버튼 기본 선택
  String? selectedRadio = "인기순";
  String? selectGenre; // 장르 탭바

  // 검색 컨트롤러
  final TextEditingController _search = TextEditingController();
  FocusNode _focusNode = FocusNode();
  late TextField sharedTextField;

  dynamic _stream; // 쿼리문

  int cnt = 0; // 팔로우 갯수

  Icon? icon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
    } else {
      _userId = userModel.userId;
    }
  }

  Future<Widget> _followImg() async {
    if(_userId != null){
      final followYnSnapshot = await fs
          .collection('artist')
          .doc(artistId)
          .collection('follower')
          .where('userId', isEqualTo: _userId)
          .get(); // 데이터를 검색하기 위해 get()를 사용합니다.

      if (followYnSnapshot.docs.isEmpty || _userId == null) {
        return Icon(Icons.person_add_alt);
      } else {
        return Icon(Icons.person);
      }
    } else{
      return Icon(Icons.person_add_alt);
    }

  }

  // 아티스트 리스트 출력
  Widget _artistList() {
    if (selectGenre == null) {
      if (selectedRadio == "가입순") {
        _stream = fs
            .collection("artist")
            .orderBy('createdate', descending: true)
            .snapshots();
      } else if (selectedRadio == "인기순") {
        _stream = fs
            .collection("artist")
            .orderBy('followerCnt', descending: true)
            .snapshots();
      } else if (selectedRadio == "최신순") {
        _stream = fs
            .collection("artist")
            .orderBy('udatetime', descending: true)
            .snapshots();
      }
    } else {
      _stream = fs
          .collection("artist")
          .where('genre', isEqualTo: selectGenre)
          .orderBy('followerCnt', descending: true)
          .snapshots();
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

              if (data['artistName'].contains(_search.text)) {
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("artist")
                      .doc(doc.id)
                      .collection("image")
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> imgSnap) {
                    if (imgSnap.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (imgSnap.hasError) {
                      return Text('Error: ${imgSnap.error}');
                    } else if (imgSnap.hasData && imgSnap.data!.docs.isNotEmpty) {
                      String genreText;
                      if(data['detailedGenre'] == null || data['detailedGenre'] == ""){
                        genreText =  data['genre'];
                      } else {
                        genreText = '${data['genre']} / ${data['detailedGenre']}';
                      }

                      artistId = doc.id;
                      var img = imgSnap.data!.docs.first;
                      if (data['followerCnt'] != null) {
                        cnt = data['followerCnt'];
                      } else {
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
                            Text(genreText),
                            Row(
                              children: [
                                FutureBuilder(
                                  future: _followImg(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<dynamic> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return snapshot.data ?? Container();
                                    }
                                  },
                                ),
                                Text('  $cnt'),
                              ],
                            )
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Get.to(
                            ArtistInfo(doc.id),
                            preventDuplicates: true,
                            transition: Transition.noTransition,
                          )?.then((value) => setState(() {}));
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              }
              return Container(); // 불필요한 코드인 경우 Container 대신 null을 반환해도 됨
            },
          ),
        );
      },
    );

  }

  // 장르 탭바
  final List<String> _genre = ["음악", "댄스", "퍼포먼스", "마술"];

  Widget genreWidget() {
    return SingleChildScrollView(
      child: Column(children: [
        Container(
          color: Colors.white,
          height: 50.0, // 높이 조절
          child: ListView(
            scrollDirection: Axis.horizontal, // 수평 스크롤
            children: [
              for (String genre in _genre)
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 17.0),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              selectGenre = genre;
                            });
                          },
                          child: Text(
                            genre,
                            style: TextStyle(
                                color: selectGenre == genre
                                    ? Color(0xFF233067)
                                    : Colors.black,
                            fontWeight: selectGenre == genre
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                        ),
                      ),
                    ]),
            ],
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    sharedTextField = TextField(
      controller: _search,
      focusNode: _focusNode,
      textInputAction: TextInputAction.go,
      onSubmitted: (value) {
        setState(() {});
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
                color: Color(0xFF233067),
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
              style:
                  TextStyle(color: Color(0xFF233067), fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  color: Color(0xFF233067),
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
            indicatorColor:Color(0xFF233067),
            unselectedLabelColor: Colors.black,
            labelColor: Color(0xFF233067),
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
            ),
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
          ),
          elevation: 1,
        ),
        drawer: MyDrawer(),
        body: TabBarView(
          children: [
            Column(
              // 전체
              children: [
                sharedTextField,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: radioItems
                      .map((item) => customRadio(item.label, item.isSelected))
                      .toList(),
                ),
                _artistList(),
              ],
            ),
            Column(
              // 장르
              children: [genreWidget(), sharedTextField, _artistList()],
            ),
          ],
        ),
        bottomNavigationBar: MyBottomBar(),
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
        backgroundColor: MaterialStateProperty.all(
            isSelected ? Color(0xFF233067) : Colors.white),
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
