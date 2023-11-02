import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:intl/intl.dart';

class AnnouncementDetailed extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> announcementDocument;
  const AnnouncementDetailed(this.announcementDocument, {super.key});

  @override
  State<AnnouncementDetailed> createState() => _AnnouncementDetailedState();
}

class _AnnouncementDetailedState extends State<AnnouncementDetailed> {
  late Map<String, dynamic> announcementData;
  FirebaseFirestore fs = FirebaseFirestore.instance;

  Future<void> editCnt() async {
    var documents = await FirebaseFirestore.instance.collection('posts').limit(1).get();
    if (documents.docs.isNotEmpty) {
      var firstDocument = documents.docs.first;
      await firstDocument.reference.collection('announcement').doc(widget.announcementDocument.id).update({
        'cnt': widget.announcementDocument.data()['cnt'] + 1,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    editCnt();
    setState(() {
      announcementData = widget.announcementDocument.data();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          '공지사항',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))
            ),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(announcementData['title'], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(DateFormat('yyyy-MM-dd hh:mm').format(announcementData['createDate'].toDate()), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),),
                  SizedBox(width: 30,),
                  Text('조회수:${announcementData['cnt'] + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),),
                ],
              )
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: Text(announcementData['content']),
          )

        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}
