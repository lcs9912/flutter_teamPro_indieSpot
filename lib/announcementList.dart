import 'package:flutter/material.dart';
import 'package:indie_spot/addAnnouncement.dart';
import 'package:indie_spot/announcementDetailed.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class AnnouncementList extends StatefulWidget {
  const AnnouncementList({super.key});

  @override
  State<AnnouncementList> createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  FirebaseFirestore fs = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Get.back();
          },
        ),
        backgroundColor: Color(0xFF233067),
        centerTitle: true,
        title: Text(
          '공지사항',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            child: Container(
              child: FutureBuilder<List<Widget>>(
                future: _announcementList(),
                builder: (context, snapshot) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          children: snapshot.data ??
                              [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('로딩중'),
                                  ],
                                )
                              ],
                        ),
                      )
                    ]);
                },
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF233067),
        onPressed: (){
          Get.to(
              AddAnnouncement(), //이동하려는 페이지
              preventDuplicates: true, //중복 페이지 이동 방지
              transition: Transition.noTransition //이동애니메이션off
          )?.then((value) => setState(() {}));
        },
        child: Icon(Icons.edit),
      ),
    );
  }

  Future<List<Widget>> _announcementList() async {
    
    var postsSnapshot =  await fs.collection('posts').limit(1).get();
    List<Widget> list = <Widget>[];

    if(postsSnapshot.docs.isNotEmpty){
      var firstAnnouncement = postsSnapshot.docs.first;
      
      var announcementQuerySnapshot = await firstAnnouncement.reference.collection('announcement').orderBy('createDate', descending: true).get();

      if(announcementQuerySnapshot.docs.isNotEmpty) {
        announcementQuerySnapshot.docs.forEach((announcementDocument) {
          var announcementData = announcementDocument.data();
          String title = announcementData['title'];
          String content = announcementData['content'];
          int cnt = announcementData['cnt'];
          var createDate = announcementData['createDate'];

          var listItem = Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.black26))
            ),
              child: ListTile(
                onTap: () {
                  Get.to(
                      AnnouncementDetailed(announcementDocument), //이동하려는 페이지
                      preventDuplicates: true, //중복 페이지 이동 방지
                      transition: Transition.noTransition //이동애니메이션off
                  );
                },
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(title, style: TextStyle(color: Colors.black, fontFamily: 'Noto_Serif_KR', fontSize: 15, fontWeight: FontWeight.w500),),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('조회수:$cnt', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),),
                    Text(DateFormat('yyyy-MM-dd hh:mm').format(createDate.toDate()), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),),
                  ],
                )
              )
          );
          list.add(listItem);
        });
      }
    }
    return list;
  }
}
