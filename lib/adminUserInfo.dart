import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/boardView.dart';
import 'package:indie_spot/spaceInfo.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';

class AdminUserInfo extends StatefulWidget {
  final String id;
  AdminUserInfo(this.id, {super.key});

  @override
  State<AdminUserInfo> createState() => _AdminUserInfoState();
}

class _AdminUserInfoState extends State<AdminUserInfo> {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  int _currentTabIndex = 0;
  String? _banYn;

  Future<void> _ban() async{
    var qs = await fs.collection('userList').doc(widget.id).get();
    setState(() {
      _banYn = qs.data()!['banYn'] ?? 'N';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ban();
  }

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
          '회원정보',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Container(
          child: FutureBuilder<List<Widget>?>(
            future: _adminUserInfoDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data!,
                  ),
                );
              } else if (snapshot.hasError) {
                // Handle error case
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              ); // Display a loading indicator while waiting for data.
            },
          )
        ),
      ),
      bottomNavigationBar: MyBottomBar(),
      floatingActionButton: floatingButtons(),
    );
  }

  // 스피드 다이얼로그
  Widget? floatingButtons() {
      return SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        visible: true,
        curve: Curves.bounceIn,
        backgroundColor: Color(0xFF392F31),
        children: [
          if(_banYn == 'N' || _banYn == null)
            ...[
              SpeedDialChild(
                  child: const Icon(Icons.block, color: Colors.white),
                  label: "정지",
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 13.0),
                  backgroundColor: Color(0xFF392F31),
                  labelBackgroundColor: Color(0xFF392F31),
                  onTap: () => _blockUser()
              ),
            ]
          else
            ...[
              SpeedDialChild(
                  child: const Icon(Icons.manage_accounts, color: Colors.white),
                  label: "정지 해제",
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 13.0),
                  backgroundColor: Color(0xFF392F31),
                  labelBackgroundColor: Color(0xFF392F31),
                  onTap: () => _unBlockUser()
              ),
            ],
          SpeedDialChild(
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              label: "비밀번호 변경",
              backgroundColor: Color(0xFF392F31),
              labelBackgroundColor: Color(0xFF392F31),
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 13.0),
              onTap: () => _removePwd()
              ),
          SpeedDialChild(
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              label: "사진 삭제",
              backgroundColor: Color(0xFF392F31),
              labelBackgroundColor: Color(0xFF392F31),
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 13.0),
              onTap: () => _removeImage()
              ),
        ],
      );
  }

  Future<List<Map<String, dynamic>>> fetchAllData() async {
    String userId = widget.id;

    var concertBoardQuery = await fs.collection('posts')
        .doc('3QjunO69Eb2OroMNJKWU')
        .collection('concert_board')
        .where('userId', isEqualTo: userId)
        .get();

    var freeBoardQuery = await fs.collection('posts')
        .doc('3QjunO69Eb2OroMNJKWU')
        .collection('free_board')
        .where('userId', isEqualTo: userId)
        .get();

    var teamBoardQuery = await fs.collection('posts')
        .doc('3QjunO69Eb2OroMNJKWU')
        .collection('team_board')
        .where('userId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> allData = [];

    for (var querySnapshot in [concertBoardQuery, freeBoardQuery, teamBoardQuery]) {
      for (var document in querySnapshot.docs) {
        // 각 데이터와 문서(document)를 함께 맵에 담습니다.
        Map<String, dynamic> dataWithDocument = {
          'data': document.data(),
          'document': document,
        };
        allData.add(dataWithDocument);
      }
    }

    return allData;
  }

  Future<void> _unBlockUser() async{
    String userId = widget.id;
    final pwdControl = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('회원 정지 해제'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('관리자 비밀번호를 입력해주세요'),
          TextField(
            controller: pwdControl,
            decoration: InputDecoration(
                hintText: '비밀번호'
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소')),
        TextButton(onPressed: () async{
          if(pwdControl.text == 'test123'){
            await fs.collection('userList').doc(userId).update({
              'banYn' : 'N',
            });
            if(!context.mounted) return;
            Navigator.of(context).pop();
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('관리자 비밀번호가 다릅니다.')));
          }
        }, child: Text('정지 해제')),
      ],
    ),);
  }


  Future<void> _blockUser() async{
    String userId = widget.id;
    final pwdControl = TextEditingController();
    final reasonControl = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('회원 정지'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('관리자 비밀번호를 입력해주세요'),
          TextField(
            controller: pwdControl,
            decoration: InputDecoration(
                hintText: '비밀번호'
            ),
          ),
          SizedBox(height: 15,),
          Text('정지 이유를 입력해주세요'),
          TextField(
            controller: reasonControl,
            decoration: InputDecoration(
                hintText: '정지 이유'
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소')),
        TextButton(onPressed: () async{
          if(pwdControl.text == 'test123'){
            await fs.collection('userList').doc(userId).update({
              'banYn' : 'Y',
              'banReason' : reasonControl.text
            });
            if(!context.mounted) return;
            Navigator.of(context).pop();
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('관리자 비밀번호가 다릅니다.')));
          }
        }, child: Text('정지')),
      ],
    ),);
  }

  Future<DocumentSnapshot?> getArtistsWithMatchingTeamMember(String userId) async {
    DocumentSnapshot? matchingArtist;

    QuerySnapshot artistQuerySnapshot = await fs.collection('artist').get();

    for (QueryDocumentSnapshot artistDocument in artistQuerySnapshot.docs) {
      QuerySnapshot teamMembersQuerySnapshot = await fs
          .collection('artist')
          .doc(artistDocument.id)
          .collection('team_members')
          .where('userId', isEqualTo: userId)
          .get();

      if (teamMembersQuerySnapshot.docs.isNotEmpty) {
        matchingArtist = artistDocument;
      }
    }

    return matchingArtist;
  }

  Future<List<Widget>?> _adminUserInfoDetails() async {
    String userId = widget.id;

    var userQuerySnapshot = await fs.collection('userList').doc(userId).get();

    var allData = await fetchAllData();

    var csQuerySnapshot = await fs.collection('commercial_space').where('proprietorId', isEqualTo: userId).get();
    var artistQuerySnapshot = await getArtistsWithMatchingTeamMember(userId);

    List<Map<String, dynamic>> csList = [];

    for (var document in csQuerySnapshot.docs) {
      Map<String, dynamic> data = document.data();
      data['id'] = document.id; // id를 Map에 추가
      csList.add(data);
    }

    if (userQuerySnapshot.exists) {
      var userdata = userQuerySnapshot.data();
      String nick = userdata!['nick'];
      String email = userdata!['email'];
      String gender = userdata!['gender'];
      String name = userdata!['name'];
      var userImageSnapshot = await userQuerySnapshot.reference.collection('image').limit(1).get();
      List<Widget> userItems = [];

      if (userImageSnapshot.docs.isNotEmpty) {
        String image = userImageSnapshot.docs.first.data()['PATH'];

        userItems.add(
          Column(
            children: [
              Container(
                height: 200,
                color: Color(0xFF392F31),
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: Image.network(image, fit: BoxFit.cover,)
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 50,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 130,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('이름  ', style: TextStyle(color: Colors.white),),
                                  Text(name, style: TextStyle(color: Colors.white),),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('닉네임  ', style: TextStyle(color: Colors.white),),
                                  Text(nick, style: TextStyle(color: Colors.white),),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('이메일  ', style: TextStyle(color: Colors.white),),
                                  Text(email, style: TextStyle(color: Colors.white),),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('성별  ', style: TextStyle(color: Colors.white),),
                                  Text(gender, style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              TabBar(
                tabs: [
                  Tab(child: Text('게시판', style: TextStyle(color: Colors.black),)),
                  Tab(child: Text('상업공간', style: TextStyle(color: Colors.black),)),
                ], onTap: (value) => setState(() {
                _currentTabIndex = value;
              }),),
              if (_currentTabIndex == 0)
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: allData.map((data){
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1, color: Colors.black12))
                        ),
                        child: ListTile(
                          onTap: () => _editPosts(data['document']),
                          title: Text(data['data']['title']),
                        ),
                      );
                    }).toList(),
                  ),
                )
              else if (_currentTabIndex == 1)
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: csList.map((data){
                        return Container(
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1, color: Colors.black12))
                          ),
                          child: ListTile(
                            onTap: () => _editCs(data['id']),
                            title: Text(data['spaceName']),
                          ),
                        );
                      }).toList(),
                    ),
                  )
            ],
          )
        );
      }

      return userItems; // 수정: 반환 값을 설정합니다.
    }

    return null; // 사용자가 존재하지 않을 경우 null을 반환합니다.
  }
  
  Future<void> _editCs(String id) async {
    final pwdControl = TextEditingController();

    showModalBottomSheet(context: context, builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: (){
            Get.to(
              SpaceInfo(id),
              transition: Transition.noTransition
            );
          }, child: Text('상세보기')),
          TextButton(onPressed: () async{
            showDialog(context: context, builder: (context) => AlertDialog(
              title: Text('게시글 삭제'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('관리자 비밀번호를 입력해주세요'),
                  TextField(
                    controller: pwdControl,
                    decoration: InputDecoration(
                        hintText: '비밀번호'
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소')),
                TextButton(onPressed: () async{
                  if(pwdControl.text == 'test123'){
                    var document = await fs.collection('commercial_space').doc(id).get();
                    await fs.collection('commercial_space').doc(id).delete();

                    var subcollections1 = await document.reference.collection('rental').get();
                    if(subcollections1.docs.isNotEmpty){
                      for (var collection in subcollections1.docs) {
                        await collection.reference.delete();
                      }
                    }
                    var subcollections2 = await document.reference.collection('image').get();
                    if(subcollections2.docs.isNotEmpty){
                      await subcollections2.docs.first.reference.delete();
                    }
                    var subcollections3 = await document.reference.collection('addr').get();
                    if(subcollections3.docs.isNotEmpty){
                      await subcollections3.docs.first.reference.delete();
                    }
                    if(!context.mounted) return;
                    Navigator.of(context).pop();
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('관리자 비밀번호가 다릅니다.')));
                  }
                }, child: Text('삭제')),
              ],
            ),).then((value) => Navigator.of(context).pop());
          },child: Text('삭제'))
        ],
      );
    },);
  }

  Future<void> _editPosts(DocumentSnapshot document) async{
    final pwdControl = TextEditingController();

    showModalBottomSheet(context: context, builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: (){
            Get.to(
              BoardView(document: document),
              transition: Transition.noTransition
            );
          }, child: Text('상세보기')),
          TextButton(onPressed: () async{
            showDialog(context: context, builder: (context) => AlertDialog(
              title: Text('게시글 삭제'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('관리자 비밀번호를 입력해주세요'),
                  TextField(
                    controller: pwdControl,
                    decoration: InputDecoration(
                        hintText: '비밀번호'
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소')),
                TextButton(onPressed: () async{
                  if(pwdControl.text == 'test123'){
                    await document.reference.delete();
                    var subcollections1 = await document.reference.collection('comments').get();
                    if(subcollections1.docs.isNotEmpty){
                      for (var collection in subcollections1.docs) {
                        await collection.reference.delete();
                      }
                    }
                    var subcollections2 = await document.reference.collection('image').get();
                    if(subcollections2.docs.isNotEmpty){
                      subcollections2.docs.first.reference.delete();
                    }
                    if(!context.mounted) return;
                    Navigator.of(context).pop();
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('관리자 비밀번호가 다릅니다.')));
                  }
                }, child: Text('삭제')),
              ],
            ),).then((value) => Navigator.of(context).pop());
          },child: Text('삭제'))
        ],
      );
    },);
  }


  Future<void> _removePwd() async{
    final pwdControl = TextEditingController();

    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('비밀번호 변경'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('관리자 비밀번호를 입력해주세요'),
          TextField(
            controller: pwdControl,
            decoration: InputDecoration(
                hintText: '비밀번호'
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소')),
        TextButton(onPressed: () async{
          if(pwdControl.text == 'test123'){

            const uniqueKey = 'Indie_spot'; // 비밀번호 추가 암호화를 위해 유니크 키 추가
            final bytes = utf8.encode('test123$uniqueKey'); // 비밀번호와 유니크 키를 바이트로 변환
            final hash = sha512.convert(bytes); // 비밀번호를 sha256을 통해 해시 코드로 변환
            String password = hash.toString();

            await fs.collection('userList').doc(widget.id).update({
              'pwd' : password
            });

            if(!context.mounted) return;
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('관리자 비밀번호가 다릅니다.')));
            Navigator.of(context).pop();
          }
        }, child: Text('초기화')),
      ],
    ),);
  }
  
  Future<void> _removeImage() async{
    final pwdControl = TextEditingController();

    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('이미지 삭제'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('관리자 비밀번호를 입력해주세요'),
          TextField(
            controller: pwdControl,
            decoration: InputDecoration(
              hintText: '비밀번호'
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소')),
        TextButton(onPressed: () async{
          if(pwdControl.text == 'test123'){
            QuerySnapshot imageQuerySnapshot = await fs.collection('userList').doc(widget.id).collection('image').get();
            if(imageQuerySnapshot.docs.isNotEmpty){
              imageQuerySnapshot.docs.first.reference.update({
                'PATH' : 'https://firebasestorage.googleapis.com/v0/b/indiespot-7d691.appspot.com/o/image%2FBasicImage.jpg?alt=media&token=bfe12916-8e3e-42be-bfa6-0974babb55fb'
              });
            }
            if(!context.mounted) return;
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('관리자 비밀번호가 다릅니다.')));
            Navigator.of(context).pop();
          }
        }, child: Text('삭제')),
      ],
    ),);
  }
}
