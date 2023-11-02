import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddAnnouncement extends StatefulWidget {
  const AddAnnouncement({super.key});

  @override
  State<AddAnnouncement> createState() => _AddAnnouncementState();
}

class _AddAnnouncementState extends State<AddAnnouncement> {
  final _titleControl = TextEditingController();
  final _contentControl = TextEditingController();

  FirebaseFirestore fs = FirebaseFirestore.instance;

  Future<void> _addAnnouncement() async{
    var postsSnapshot =  await fs.collection('posts').limit(1).get();

    if(postsSnapshot.docs.isNotEmpty) {
      var firstAnnouncement = postsSnapshot.docs.first;

      await firstAnnouncement.reference.collection('announcement').add({
        'title' : _titleControl.text,
        'content' : _contentControl.text,
        'createDate' : FieldValue.serverTimestamp(),
        'uDateTime' : FieldValue.serverTimestamp(),
        'cnt' : 0
      });
    }

    if(!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          '공지사항 등록',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: [
          _titleContainer(),
          _contentContainer(),
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Row(
          children: [
            Expanded(child: ElevatedButton(
              style: ButtonStyle(
                  minimumSize: MaterialStatePropertyAll(Size(0, 48)),
                  backgroundColor: MaterialStatePropertyAll(Color(0xFF392F31)),
                  elevation: MaterialStatePropertyAll(0),
                  shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero
                      )
                  )
              ),
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text('공지사항 등록'),
                    content: Text('공지사항을 등록하시겠습니까?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소')),
                      TextButton(onPressed: (){
                        _addAnnouncement();
                        Navigator.of(context).pop();
                      }, child: Text('등록')),
                    ],
                  );
                },);
              },
              child: Text('등록하기 ', style: TextStyle(fontSize: 17),),
            ),)
          ],
        ),
      )
    );
  }

  Container _contentContainer(){
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
        children: [
          Text('공지사항 제목'),
          SizedBox(height: 10),
          Container(
            child: TextField(
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400
              ),
              controller: _contentControl,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: '공지사항 내용을 입력해주세요',
                hintStyle: TextStyle(fontSize: 15),
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }


  Container _titleContainer(){
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
        children: [
          Text('공지사항 제목'),
          SizedBox(height: 10),
          Container(
            height: 35,
            child: TextField(
              style: TextStyle(
                fontWeight: FontWeight.w500
              ),
              controller: _titleControl,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                hintText: '공지사항 제목을 입력해주세요',
                hintStyle: TextStyle(fontSize: 15),
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
