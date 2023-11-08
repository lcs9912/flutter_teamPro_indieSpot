import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/boardView.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'boardAdd.dart';

class BoardList extends StatefulWidget {
  const BoardList();

  @override
  State<BoardList> createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> with SingleTickerProviderStateMixin{
  FirebaseFirestore fs = FirebaseFirestore.instance;
  late TabController _tabController;
  String subcollection = "free_board";
  List<String> userId = [];
  late TextEditingController _searchController;
  bool _isSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      updateSelectedCategory(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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

  List<DocumentSnapshot> filterPostsByKeyword(List<DocumentSnapshot> posts, String keyword) {
    return posts.where((post) {
      Map<String, dynamic> postMap = post.data() as Map<String, dynamic>;
      return postMap['title'].toString().toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  Widget _listboard() {

    return StreamBuilder(
      stream: fs.collection("posts")
          .doc("3QjunO69Eb2OroMNJKWU")
          .collection(subcollection)
          .orderBy("createDate", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting || snap.hasError) {
          // 로딩 중이면 여기서 CircularProgressIndicator를 반환
          return Center(child: CircularProgressIndicator());
        }

        // 스냅샷이 데이터를 가지고 있지 않다면 특정 메시지를 반환
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Text("게시글이 없습니다.");
        }

        String keyword = _searchController.text;
        List<DocumentSnapshot> filteredPosts = filterPostsByCategory(snap.data!.docs, subcollection);
        if (keyword.isNotEmpty) {
          filteredPosts = filterPostsByKeyword(filteredPosts, keyword);
        }

        return ListView.builder(
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) {
            if (index < filteredPosts.length) {
              Map<String, dynamic> post = filteredPosts[index].data() as Map<String, dynamic>;
              String postDoc = filteredPosts[index].id;
              DocumentSnapshot doc = filteredPosts[index];

              String? userData = post['userId'];

              if (userData == null) {
                return Container(
                  child: Text("Unknown User"),
                );
              }

              return StreamBuilder(
                stream: fs.collection("userList").doc(userData).snapshots(),
                builder: (context, userSnap) {
                  if (userSnap.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (userSnap.hasError) {
                    return Text('Error: ${userSnap.error}');
                  }

                  if (userSnap.data == null || !userSnap.data!.exists) {
                    return Text("사용자 정보가 없습니다.");
                  }

                  // Check if the user document exists
                  if (userSnap.data == null || !userSnap.data!.exists) {
                    return Container();
                  }

                  DocumentSnapshot<Map<String, dynamic>> querySnapshot = userSnap.data as DocumentSnapshot<Map<String, dynamic>>;

                  return StreamBuilder(
                    stream: fs.collection("posts")
                        .doc("3QjunO69Eb2OroMNJKWU")
                        .collection(subcollection)
                        .doc(postDoc)
                        .collection("image")
                        .snapshots(),
                    builder: (context, imageSnap) {
                      if (imageSnap.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (imageSnap.hasError) {
                        return Text('Error: ${imageSnap.error}');
                      }

                      Map<String, dynamic>? imageData = imageSnap.data?.docs.isNotEmpty ?? false
                          ? imageSnap.data!.docs.first.data() as Map<String, dynamic>?
                          : null;

                      int commentCount = 0;

                      return Column(
                        children: [
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${querySnapshot.get('nick') as String? ?? "Unknown User"}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),

                                    Text(
                                      '${post['title'].length > 12 ? post['title'].substring(0, 12)+'···' : post['title']}',
                                      style: TextStyle(
                                        fontSize: 16
                                      ),
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${post['createDate'].toDate().toString().substring(0, 16)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                            '조회 : ${post['cnt']}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("posts")
                                          .doc("3QjunO69Eb2OroMNJKWU")
                                          .collection(subcollection)
                                          .doc(postDoc)
                                          .collection('comments')
                                          .snapshots(),
                                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
                                        if (!snap.hasData) {
                                          return Text(
                                            '0',
                                            style: TextStyle(
                                              fontSize: 12
                                            ),
                                          );
                                        }
                                        commentCount = snap.data!.docs.length;
                                        return Row(
                                          children: [
                                            Transform(
                                              transform: Matrix4.rotationY(0.3),
                                              child : Icon(Icons.mode_comment_outlined, size: 18),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              commentCount.toString(),
                                              style: TextStyle(
                                                  fontSize: 12
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                            leading: imageData != null && imageData.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    imageData['PATH'],
                                    width: 80,
                                    fit: BoxFit.fitWidth,
                            ),
                                )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                  child: Image.asset(
                                    'assets/nullimg.png',
                                    width: 80,
                                    fit: BoxFit.fitWidth,
                            ),
                                ),
                            onTap: () {
                              _incrementViewCount(postDoc);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BoardView(document: doc),
                                ),
                              );
                            },
                          ),
                          Divider(
                            color: Colors.grey[400],
                            thickness: 1,
                            height: 30,
                          ),

                        ],
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
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: (){
              _toggleSearch();
            },
          )
        ],
      ),
      body: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: "자유"),
                Tab(text: "팀모집"),
                Tab(text: "함께공연")
              ],
              labelColor: Colors.black,
              indicatorColor: Colors.black,
            ),
            SizedBox(height: 2),
            _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabViews,
              ),
            ),
          ],
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

  void _incrementViewCount(String postId) async {
    try {
      DocumentReference postRef = fs.collection("posts")
          .doc("3QjunO69Eb2OroMNJKWU")
          .collection(subcollection)
          .doc(postId);

      DocumentSnapshot postSnapshot = await postRef.get();
      int currentCount = postSnapshot.get('cnt') ?? 0;

      postRef.update({
        'cnt': currentCount + 1,
      });
    } catch (e) {
      print('Error updating view count: $e');
    }
  }

  Widget _buildSearchBar() {
    return _isSearch ? Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '제목으로 검색하기',
            contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 14), // 패딩 설정
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        SizedBox(height: 4),
      ],
    ) : Container();
  }


  void _toggleSearch() {
    setState(() {
      _isSearch = !_isSearch;
      if (!_isSearch) {
        _searchController.clear();
        updateSelectedCategory(_tabController.index);
      }
    });
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
