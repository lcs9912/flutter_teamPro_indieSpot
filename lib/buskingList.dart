
import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'concertDetails.dart';
class BuskingList extends StatefulWidget{
  const BuskingList({super.key});

  @override
  State<BuskingList> createState() => _BuskingListState();
}

class _BuskingListState extends State<BuskingList> with SingleTickerProviderStateMixin{
  final TextEditingController _search = TextEditingController();
  FocusNode _focusNode = FocusNode();
  late TextField sharedTextField;
  String selectRegions = "서울";
  Widget _buskingList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("busking").snapshots(),
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
              String spotId = data['spotId'];

              return FutureBuilder(
                future: FirebaseFirestore.instance.collection('busking_spot').doc(spotId).get(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> spotSnapshot) {
                  if (spotSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text('Loading...'),
                    );
                  }
                  if (spotSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error'),
                      subtitle: Text('Error'),
                    );
                  }
                  if (spotSnapshot.hasData && spotSnapshot.data!.exists) {
                    Map<String, dynamic> spotData = spotSnapshot.data!.data() as Map<String, dynamic>;

                    return FutureBuilder(
                      future: FirebaseFirestore.instance.collection('busking_spot').doc(spotId).collection('image').get(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> imageSnapshot) {
                        if (imageSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text('${data['artistId']}'),
                            subtitle: Text('일시 : ${data['buskingStart']}'),
                            trailing: Text('Spot 정보: ${spotData['spotName']}'),
                          );
                        }
                        if (imageSnapshot.hasError) {
                          return ListTile(
                            title: Text('Error'),
                            subtitle: Text('Error'),
                          );
                        }
                        if (imageSnapshot.hasData) {
                          /*var firstImage = imageSnapshot.data!.docs.first;*/

                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListTile(
                              title: Text('${data['artistId']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('일시 : ${data['buskingStart']}'),
                                  Text('장소: ${spotData['spotName']}')
                                ],
                              ),
                              leading: Image.asset('assets/기본.jpg'),
                              /*leading: Image.network(firstImage['imageUrl']),*/
                              onTap: () {

                              },
                            ),
                          );
                        } else {
                          return ListTile(
                            title: Text('${data['artistId']}'),
                            subtitle: Column(
                              children: [
                                Text('일시 : ${data['buskingStart']}'),
                                Text('장소: ${spotData['spotName']}')
                              ],
                            ),
                          );
                        }
                      },
                    );
                  } else {
                    return ListTile(
                      title: Text('${data['artistId']}'),
                      subtitle: Text('Spot not found'),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget regionsList(){
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("busking_spot").where('regions',isEqualTo: selectRegions).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return Expanded(
            child:ListView.builder(
              itemCount: snap.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = snap.data!.docs[index];
                Map<String, dynamic> spotData = doc.data() as Map<String, dynamic>;
                String spotId = doc.id;
                return FutureBuilder(
                    future: FirebaseFirestore.instance.collection("busking").where('spotId',isEqualTo: spotId).get(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> spotSnapshot) {
                      DocumentSnapshot doc2 = spotSnapshot.data!.docs[index];
                      print(doc2.id);
                      if (spotSnapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                          subtitle: Text('Loading...'),
                        );
                      }
                      if (spotSnapshot.hasError) {
                        return ListTile(
                          title: Text('Error'),
                          subtitle: Text('Error'),
                        );
                      }
                      if (spotSnapshot.hasData) {
                        QueryDocumentSnapshot spotDocument = spotSnapshot.data!.docs[0];
                        Map<String, dynamic> data = spotDocument.data() as Map<String, dynamic>;
                        return FutureBuilder(
                          future: FirebaseFirestore.instance.collection('busking_spot').doc(spotId).collection('image').get(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> imageSnapshot) {
                            if (imageSnapshot.connectionState == ConnectionState.waiting) {
                              return ListTile(
                                title: Text('${data['artistId']}'),
                                subtitle: Text('일시 : ${data['buskingStart']}'),
                                trailing: Text('Spot 정보: ${spotData['spotName']}'),
                              );
                            }
                            if (imageSnapshot.hasError) {
                              return ListTile(
                                title: Text('Error'),
                                subtitle: Text('Error'),
                              );
                            }
                            if (imageSnapshot.hasData) {
                              /*var firstImage = imageSnapshot.data!.docs.first;*/

                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ListTile(
                                  title: Text('${data['artistId']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('일시 : ${data['buskingStart']}'),
                                      Text('장소: ${spotData['spotName']}')
                                    ],
                                  ),
                                  leading: Image.asset('assets/기본.jpg'),
                                  /*leading: Image.network(firstImage['imageUrl']),*/
                                  onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ConcertDetails(document : doc2),));
                                  },
                                ),
                              );
                            } else {
                              return ListTile(
                                title: Text('${data['artistId']}'),
                                subtitle: Column(
                                  children: [
                                    Text('일시 : ${data['buskingStart']}'),
                                    Text('장소: ${spotData['spotName']}')
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        return ListTile(
                          subtitle: Text('Spot not found'),
                        );
                      }
                    },
                );
              },
            )
        );
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
                          });
                        },
                        child: Text(region, style: TextStyle(color: Colors.black),),
                      ),]
                  ),
              ],
            ),
          ),
          sharedTextField,
          regionsList()
        ]
    );
  }
  @override
  Widget build(BuildContext context) {
    sharedTextField = TextField(
      controller: _search,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: "팀명으로 검색하기",
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
      length: 3,
      animationDuration: Duration.zero,
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
              builder: (context) {
                return IconButton(
                    color: Colors.black54,
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back)
                );
              }
          ),
          title: Center(child: Text("공연 일정", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),)),
          actions: [
            Builder(
                builder: (context) {
                  return IconButton(
                      color: Colors.black54,
                      onPressed: (){
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(Icons.menu)

                  );
                }
            )
          ],
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
              tabs: [
                Tab(text: '전체'),
                Tab(text: '지역'),
                Tab(text: '장르'),
              ],
              unselectedLabelColor: Colors.black, // 선택되지 않은 탭의 텍스트 색상
              labelColor: Colors.blue,
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
                sharedTextField,
                _buskingList()
              ],
            ),
            regiosWidget(),
            Column(
              children: [
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
}
