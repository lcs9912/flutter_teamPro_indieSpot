import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/boardView.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';

import 'boardAdd.dart';

class BoardList extends StatefulWidget {
  const BoardList({super.key});

  @override
  State<BoardList> createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> with SingleTickerProviderStateMixin{
  FirebaseFirestore fs = FirebaseFirestore.instance;
  late TabController _tabController;
  String subcollection = "all";
  List<String> userId = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      print("Tab index changed: ${_tabController.index}");
      updateSelectedCategory(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void updateSelectedCategory(int tabIndex) {
    setState(() {
      switch (tabIndex) {
        case 0:
          subcollection = "free_board";
          break;
        case 1:
          subcollection = "team_board";
          break;
        case 2:
          subcollection = "concert_board";
          break;
      }
    });
  }


  List<DocumentSnapshot> filterPostsByCategory(List<DocumentSnapshot> posts, String selectedCategory) {
    if (selectedCategory == "free_board") {
      return posts.where((post) {
        String path = post.reference.path;
        return path.contains("free_board");
      }).toList();
    } else if (selectedCategory == "concert_board") {
      return posts.where((post) {
        String path = post.reference.path;
        return path.contains("concert_board");
      }).toList();
    } else {
      return posts.where((post) {
        String path = post.reference.path;
        return path.contains("team_board");
      }).toList();
    }
  }

  Widget _nick() {
    return StreamBuilder(
      stream: fs.collection('userList').doc('LgCiFESZ5JQ65f7S4qDJ').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        Map<String, dynamic>? data = snap.data?.data() as Map<String, dynamic>?;

        return ListTile(
          title: Text(
            '${data?['nick'] ?? "닉네임 없음"}',
          ),
        );
      },
    );
  }


  Widget _listboard() {
    return StreamBuilder(
      stream: fs.collection("posts")
          .doc("3QjunO69Eb2OroMNJKWU")
          .collection(subcollection)
          .orderBy("createDate", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Check if there are any documents
        if (snap.data?.docs.isEmpty ?? true) {
          return Text("게시글이 없습니다.");
        }

        List<DocumentSnapshot> filteredPosts = filterPostsByCategory(snap.data!.docs, subcollection);

        return ListView.builder(
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) {
            if (index < filteredPosts.length) {
              Map<String, dynamic> post = filteredPosts[index].data() as Map<String, dynamic>;
              String postDoc = filteredPosts[index].id;
              DocumentSnapshot doc = filteredPosts[index];

              // 사용자 정보 가져오기
              String? userData = post['userId'];

              return StreamBuilder(
                stream: fs.collection("userList").doc(userData).snapshots(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Check if the user document exists
                  if (!userSnap.data!.exists) {
                    return Text("사용자 정보가 없습니다.");
                  }

                  DocumentSnapshot<Map<String, dynamic>> querySnapshot = userSnap.data as DocumentSnapshot<Map<String, dynamic>>;

                  return StreamBuilder(
                    stream: fs.collection("posts")
                        .doc("3QjunO69Eb2OroMNJKWU")
                        .collection(subcollection)
                        .doc(postDoc)
                        .collection("image")  // 이미지 서브컬렉션
                        .snapshots(),
                    builder: (context, imageSnap) {
                      if (!imageSnap.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      // 이미지 정보 가져오기
                      Map<String, dynamic>? imageData = imageSnap.data?.docs.first.data() as Map<String, dynamic>?;
                      Map<String, dynamic>? subData = post['image'];
                      String? boardImg = subData?['PATH'];

                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${querySnapshot.get('nick')}'),
                            Row(
                              children: [
                                Text('${post['title']}'),
                              ],
                            ),
                            Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                              height: 30,
                            )
                          ],
                        ),
                        leading: imageData != null
                            ? Image.network(imageData!['PATH'])
                            : Image.asset('assets/nullimg.png'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BoardView(document: doc),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }
            return Text("게시글이 없습니다.");
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
    String? userId = userModel.userId;
    List<Widget> _tabViews = List.generate(3, (index) => _listboard());

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "게시판",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1.5,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: "자유"),
                Tab(text: "팀모집"),
                Tab(text: "함께공연")
              ],
              labelColor: Colors.black,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black, // 경계의 색상을 설정
                    width: 2.0, // 경계의 두께를 설정
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabViews,
              ),
            ),
          ],
        )
      ),
      bottomNavigationBar: MyBottomBar(),
      floatingActionButton: Container(
        width: 380,
        height: 50,
        child: FloatingActionButton(
          onPressed: () {
            if (userId == null) {
              _showLoginAlert(context);
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BoardAdd())
              );
            }
          },
          backgroundColor: Colors.black54,
          child: Text(
            '글쓰기',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
          ),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("로그인 필요"),
          content: Text("게시글을 작성하려면 로그인이 필요합니다"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("확인"),
            )
          ],
        );
      },
    );
  }
}
