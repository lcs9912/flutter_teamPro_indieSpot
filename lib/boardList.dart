import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/boardView.dart';
import 'package:flutter/material.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserModel())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'NotoSansKR'),
          home: MyApp(),
          routes: {},
        ),
      )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "게시판",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1.5,
        ),
        body: BoardList(),
        bottomNavigationBar: MyBottomBar(),
        floatingActionButton: Container(
          width: 380,
          height: 50,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.black54,
            child: Text(
              '글쓰기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class BoardList extends StatefulWidget {
  @override
  _BoardListState createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = "전체";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 탭이 변경될 때마다 선택된 카테고리 업데이트
    _tabController.addListener(() {
      updateSelectedCategory(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 게시글을 필터링하는 함수
  List<DocumentSnapshot> filterPostsByCategory(List<DocumentSnapshot> posts) {
    if (selectedCategory == "전체") {
      return posts; // 전체 카테고리면 모든 게시글 반환
    } else {
      return posts.where((post) => post["CATEGORY"] == selectedCategory).toList();
    }
  }

  // 선택된 카테고리 업데이트 함수
  void updateSelectedCategory(int tabIndex) {
    setState(() {
      switch (tabIndex) {
        case 0:
          selectedCategory = "전체";
          break;
        case 1:
          selectedCategory = "자유";
          break;
        case 2:
          selectedCategory = "팀모집";
          break;
        case 3:
          selectedCategory = "함께연주";
          break;
      // 다른 카테고리에 대한 case 추가
      }
    });
  }

  Widget _listBoard() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts").orderBy("CREATEDATE", descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        List<DocumentSnapshot> filteredPosts = filterPostsByCategory(snap.data!.docs);

        return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              String? boardImg = data['PATH'];

              DateTime createdDate = (data['CREATEDATE'] as Timestamp).toDate();
              String formatDate = DateFormat('yyyy/MM/dd HH:mm').format(createdDate);

              return Column(
                children: [
                  ListTile(
                    leading: boardImg != null
                      ? ClipRRect(
                        child : Image.network(boardImg, width: 80, height: 80, fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(20)
                    )
                      : ClipRRect(
                        child: Image.asset('assets/nullimg.png', width: 80, height: 80, fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(20),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data['USER_ID']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey
                          )
                        ),
                        SizedBox(height: 1),
                        Text('${data['TITLE']}',
                            style: TextStyle(
                                fontSize: 20,
                            )
                        ),
                        SizedBox(height: 3),
                        Text(formatDate,
                        style: TextStyle(
                          fontSize: 12,
                          )
                        )
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardView(document: doc),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 2),
                  Divider(
                    color: Colors.grey[400],
                    thickness: 1,
                    height: 30,
                  )
                ]
              );
            },
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "전체"),
              Tab(text: "자유"),
              Tab(text: "팀모집"),
              Tab(text: "함께연주"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _listBoard(),
                _listBoard(),
                _listBoard(),
                _listBoard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}