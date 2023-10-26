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

  // 검색
  final TextEditingController _search = TextEditingController();
  FocusNode _focusNode = FocusNode();
  late TextField sharedTextField;


  Widget _artistList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("artist").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return Expanded(
            child: ListView.builder(
              itemCount: snap.data!.docs.length,
              itemBuilder: (context, index){
                DocumentSnapshot doc = snap.data!.docs[index]; // artist 컬렉션의 모든필드를 순차적으로 대입
                Map<String,dynamic> data= doc.data() as Map<String, dynamic>;

                return FutureBuilder(
                  future: FirebaseFirestore.instance.collection("artist").doc(doc.id).collection("image").get(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(snapshot.hasData){ // hasData : 데이터가 있는지 없는지
                      var img = snapshot.data!.docs.first;
                      print('이미지 ${img['path'].toString()}');
                      return ListTile(
                        leading: Image.asset('artist/${img['path']}'),
                        title: Text('${img['path'].toString()}'),
                      );
                    }
                    return Container();
                  },
                );
              }
            ),
        );
      },
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
                _artistList(),
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
