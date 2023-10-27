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
    RadioItem(label: "활동순"),
    RadioItem(label: "최신순"),
  ];

  String selectedRadio = "활동순";
  final TextEditingController _search = TextEditingController();
  FocusNode _focusNode = FocusNode();
  late TextField sharedTextField;
  int likeCnt = 0;

  @override
  void initState() {
    super.initState();
    _LikeCnt();
  }

  Widget _LikeCnt() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("artist").orderBy('createdate', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("artist")
                    .doc(doc.id)
                    .collection("artist_like")
                    .get(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot2) {
                  if (snapshot2.hasData) {
                    likeCnt = snapshot2.data!.docs.length;
                    print('$likeCnt');
                    return Container();
                  } else {
                    setState(() {
                      likeCnt = 0;
                    });
                    return Container();
                  }
                },
              );
            },
          );

      },
    );
  }

  Widget _artistList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("artist").orderBy('createdate', descending: true).snapshots(),
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

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("artist")
                    .doc(doc.id)
                    .collection("image")
                    .get(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    var img = snapshot.data!.docs.first;
                    return ListTile(
                      leading: Image.asset(
                        'artist/${img['path']}'
                        ,fit: BoxFit.cover,
                        width: 100.0, // 이미지의 가로 크기 설정
                        height: 100.0, // 이미지의 세로 크기 설정
                      ),
                      title: Text('${data['artistName']}'),
                      subtitle: Text('${data['genre']}\n$likeCnt'),
                      isThreeLine: true,
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtistInfo(doc: doc),
                          ),
                        );
                      },
                    );

                  }
                  return Container();
                },
              );
            },
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
        // drawer: MyDrawer(),
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
          for (var item in radioItems) {
            item.isSelected = item.label == label;
          }
          selectedRadio = "활동순";
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
