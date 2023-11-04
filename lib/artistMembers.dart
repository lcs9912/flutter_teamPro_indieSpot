import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/artistInfo.dart';
import 'package:indie_spot/artistMembers.dart';
import 'package:indie_spot/login.dart';
import 'package:indie_spot/membersEdit.dart';
import 'package:indie_spot/videoDetailed.dart';
import 'artistEdit.dart';
import 'baseBar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'donationList.dart';
import 'donationPage.dart';
import 'userModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ArtistMembers extends StatefulWidget {
  final DocumentSnapshot doc;
  final String artistImg;

  ArtistMembers(this.doc, this.artistImg, {super.key});

  @override 
  State<ArtistMembers> createState() => _ArtistMembersStatus();
}

class _ArtistMembersStatus extends State<ArtistMembers> {
  FirebaseFirestore fs = FirebaseFirestore.instance;

  String? _artistId;
  String? _userId;

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


  ////////////////////////////////탭1 멤버 리스트/////////////////////////////////////////
  // 탭1 멤버 리스트 멤버관리 수정
  Future<List<Widget>> _artistDetails() async {
    final membersQuerySnapshot = await fs
        .collection('artist')
        .doc(widget.doc.id)
        .collection('team_members')
        .get();

    if (membersQuerySnapshot.docs.isNotEmpty) {
      List<QueryDocumentSnapshot> membersList = membersQuerySnapshot.docs;

      // 'status' 값이 'Y'인 요소들을 추출
      List<QueryDocumentSnapshot> membersWithStatusY = membersList
          .where((member) => member['status'] == 'Y')
          .toList();

      // 'status' 값이 'Y'인 요소들을 맨 위로 위치시키기
      membersList.removeWhere((member) => member['status'] == 'Y');
      membersList.insertAll(0, membersWithStatusY);

      List<Widget> memberWidgets = [];

      for (QueryDocumentSnapshot membersDoc in membersList) {
        String memberPosition = membersDoc['position'];
        String userId = membersDoc['userId'];

        final userDocSnapshot = await fs.collection("userList").doc(userId).get();

        if (userDocSnapshot.exists) {
          String userName = userDocSnapshot['name'];
          String userNick = userDocSnapshot['nick'];
          final userImageCollection =
          await fs.collection('userList').doc(userId).collection('image').get();

          if (userImageCollection.docs.isNotEmpty) {
            String userImage = userImageCollection.docs.first['PATH'];

            Widget memberWidget = ListTile(
              leading: Image.network(userImage),
              title: Row(
                children: [
                  Text(userName),
                  Text(userNick, style: TextStyle(fontSize: 12)),
                ],
              ),
              subtitle: Text(memberPosition),
              trailing: Visibility(
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
                      ),
                      context: context,
                      builder: (context) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10, bottom: 20),
                                width: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: Colors.black54),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => MembersEdit(membersDoc),
                                        ))
                                            .then((value) => Navigator.of(context).pop());
                                      },
                                      style: ButtonStyle(
                                        alignment: Alignment.centerLeft,
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 15),
                                            child: Icon(
                                              Icons.edit,
                                              color: Color(0xFF634F52),
                                            ),
                                          ),
                                          Text(
                                            '수정',
                                            style: TextStyle(color: Color(0xFF634F52)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: TextButton(
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('멤버 탈퇴'),
                                            content: Text('멤버를 팀에서 탈퇴시키겠습니까?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: Text('탈퇴'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  //_deleteComment(pointDetailDocument.id, vedioDocRef);
                                                  Navigator.of(context).pop();
                                                  setState(() {});
                                                },
                                                child: Text('삭제'),
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((value) => Navigator.of(context).pop()),
                                      style: ButtonStyle(
                                        alignment: Alignment.centerLeft,
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 15),
                                            child: Icon(
                                              Icons.delete,
                                              color: Color(0xFF634F52),
                                            ),
                                          ),
                                          Text(
                                            '삭제',
                                            style: TextStyle(color: Color(0xFF634F52)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.more_vert, color: Colors.black54, size: 17),
                ),
              ),
            );

            memberWidgets.add(memberWidget);
          }
        }
      }

      return memberWidgets;
    } else {
      return [Container()];
    }
  }





  @override
  Widget build(BuildContext context) {
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
              "팀 관리",
              style:
              TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
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
              Tab(text: '멤버'),
              Tab(text: '신청내역'),
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
            children: [
              ListView(
                // 소개 탭
                children: [
                  Container(
                    child: FutureBuilder(
                      future: _artistDetails(),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                margin: EdgeInsets.all(20),
                                child: Column(
                                  children: snapshot.data ?? [Container()],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
              Text("가입 신청한 유저 리스트"),
            ]
        ),
      ),
    );
  }
}
