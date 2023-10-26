import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    RadioItem(label: "활동순", isSelected: true), // "활동순"을 초기 선택 상태로 설정
    RadioItem(label: "좋아요순"),
    RadioItem(label: "최신순"),
  ];

  String selectedRadio = "활동순"; // 선택된 라디오 버튼의 라벨

  // 지역
  final List<String> _regions = ['전국', '서울', '부산', '인천', '강원', '경기', '경남', '경북', '광주', '대구', '대전', '울산', '전남', '전북', '제주', '충남', '충북'];

  // 검색
  final TextEditingController _search = TextEditingController();
  FocusNode _focusNode = FocusNode();
  late TextField sharedTextField;

  int _currentTabIndex = 0; // 센세꺼 훔쳐옴
  
  // 뭔지모르지만 훔쳐옴..
  Query getSelectedCollection(FirebaseFirestore fs) {
    if (_currentTabIndex == 0) {
      return fs.collection('busking_spot');
    } else {
      String selectedRegion = _regions[_currentTabIndex]; // -1을 해서 _regions 리스트에 맞는 값으로 선택
      return fs.collection('busking_spot').where('regions', isEqualTo: selectedRegion);
    }
  }

  // 센세 리스트 코드 훔쳐옴
  Widget _artistList() {

    FirebaseFirestore fs = FirebaseFirestore.instance;
    CollectionReference spots = fs.collection('busking_spot');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '검색',
              border: OutlineInputBorder(),
            ),
            controller: _search,
            textInputAction: TextInputAction.go,
            onSubmitted: (value) {
              setState(() {

              });
            },
          ),
        ),
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
                    if (data['spotName'].contains(_search.text)) {
                      return FutureBuilder<QuerySnapshot>(
                        future: spots.doc(document.id).collection('addr').limit(1).get(),
                        builder: (context, addrSnapshot) {
                          if (addrSnapshot.connectionState == ConnectionState.waiting) {
                            return Container(); // 데이터가 로딩 중이면 로딩 표시
                          }
                          if (addrSnapshot.hasError) {
                            return Text('데이터를 불러오는 중 오류가 발생했습니다.');
                          }
                          List<QueryDocumentSnapshot<Map<String, dynamic>>> addr = addrSnapshot.data!.docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
                          return Container(
                            padding: EdgeInsets.only(bottom: 5, top: 5),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color(0xFFEEEEEE)))),
                            child: ListTile(
                              title: Text(data['spotName']),
                              subtitle: Text(addr[0].data()['addr']),
                              leading: Container(child: Image.asset('busking/SE-70372558-15b5-11ee-8f66-416d786acd10.jpg'), width: 100, height: 100,),
                              onTap: () {
                                Navigator.pop(context, document); // 선택한 항목 반환
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              },
            )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    sharedTextField = TextField(
      controller: _search,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: "팀명으로 검색하기",
        border: UnderlineInputBorder(),
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
      length: 3,
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
              Tab(text: '지역'),
              Tab(text: '장르'),
            ],
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
          physics: NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: radioItems
                      .map((item) => customRadio(item.label, item.isSelected))
                      .toList(),
                ),
                sharedTextField,
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("artist").orderBy("createdate", descending: true).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
                      if (!snap.hasData) {
                        return Center(
                          child: Stack(
                            children: [
                              CircularProgressIndicator(strokeWidth: 5),
                              Text("로딩중"),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: snap.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = snap.data!.docs[index];
                          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text("${data['artistName']}"),
                            onTap: () {
                              // 상세페이지로 이동
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: radioItems
                      .map((item) => customRadio(item.label, item.isSelected))
                      .toList(),
                ),
                sharedTextField,
                Padding(
                  padding: EdgeInsets.all(12),
                  /*child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {

                    },
                ),*/
                )
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: radioItems
                      .map((item) => customRadio(item.label, item.isSelected))
                      .toList(),
                ),
                sharedTextField,
                Padding(
                  padding: EdgeInsets.all(12),
                  /*child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {

                    },
                ),*/
                )
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
          // 라디오 버튼이 선택되었을 때 상태를 업데이트합니다.
          for (var item in radioItems) {
            item.isSelected = item.label == label;
          }
          selectedRadio = "활동순"; // 클릭 시 항상 "활동순"으로 설정합니다.
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(isSelected ? Color(0xFF392F31) : Colors.white),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black, // isSelected 값에 따라 텍스트의 색상을 변경합니다.
        ),
      ),
    );
  }
}
