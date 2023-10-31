import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/boardAdd.dart';
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
          home: BoardList(),
          routes: {},
        ),
      )
  );
}

class BoardList extends StatefulWidget {
  @override
  _BoardListState createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = "전체";
  FirebaseFirestore fs = FirebaseFirestore.instance;

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
          .collection("posts")
          .orderBy("CREATEDATE", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> filteredPosts =
        filterPostsByCategory(snap.data!.docs, selectedCategory);

        return ListView.builder(
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
              future: _buildListItem(context, filteredPosts[index]),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return snapshot.data ?? SizedBox.shrink();
                }
              },
            );
          },
        );
      },
    );
  }

  Future<Widget> _buildListItem(BuildContext context, DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    QuerySnapshot imgDataSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(doc.id)
        .collection('image')
        .get();

    DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
      .collection('userList').doc(data['USER_ID']).get();

    userDataSnapshot.data();


    List<QueryDocumentSnapshot> imgDocs = imgDataSnapshot.docs;

    String? boardImg;
    if (imgDocs.isNotEmpty) {
      boardImg = imgDocs[0]['PATH'];
    }


    DateTime createdDate = (data['CREATEDATE'] as Timestamp).toDate();
    String formatDate = DateFormat('yyyy/MM/dd HH:mm').format(createdDate);

    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.all(0),
          leading: boardImg != null
              ? ClipRRect(
              child: Image.network(boardImg, width: 80, height: 80, fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(20))
              : ClipRRect(
                child: Image.asset('assets/nullimg.png', width: 80, height: 80, fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data['USER_ID']}',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              SizedBox(height: 1),
              Row(
                children: [
                  Text(
                    "[" + '${data['CATEGORY']}' + "]",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${data['TITLE']}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Text(
                formatDate,
                style: TextStyle(
                  fontSize: 13,
                ),
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
      ],
    );
  }


  // 게시글을 필터링하는 함수
  List<DocumentSnapshot> filterPostsByCategory(List<DocumentSnapshot> posts, String selectedCategory) {
    if (selectedCategory == "전체") {
      return posts; // 전체 카테고리면 모든 게시글 반환
    } else {
      return posts.where((post) => post["CATEGORY"] == selectedCategory).toList();
    }
  }


  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
    String? userId = userModel.userId;

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
        ),
        body: Padding(
          padding: EdgeInsets.all(4.0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: "전체"),
                  Tab(text: "자유"),
                  Tab(text: "팀모집"),
                  Tab(text: "함께연주"),
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
        ),
        bottomNavigationBar: MyBottomBar(),
        floatingActionButton: Container(
          width: 380,
          height: 50,
          child: FloatingActionButton(
            onPressed: () {
              if(userId == null){
                _showLoginAlert(context);
              }else {
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
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

  }
  void _showLoginAlert(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("로그인 필요"),
            content: Text("게시글을 작성하려면 로그인이 필요합니다"),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text("확인")
              )
            ],
          );
        }
    );

  }


}

