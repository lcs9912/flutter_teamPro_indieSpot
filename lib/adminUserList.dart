import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/adminUserInfo.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:get/get.dart';

class AdminUserList extends StatefulWidget {
  const AdminUserList({super.key});

  @override
  State<AdminUserList> createState() => _AdminUserListState();
}

class _AdminUserListState extends State<AdminUserList> {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  final _search = TextEditingController();

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
          '계정 관리',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: '아이디 & 닉네임 검색',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF233067))
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF233067))
                ),
                prefixIcon: Icon(Icons.search, color: Color(0xFF233067),),
                suffixIcon: IconButton(
                  onPressed: () {
                    _search.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.cancel_outlined, color: Color(0xFF233067),),
                  highlightColor: Colors.transparent, // 클릭 시 하이라이트 효과를 제거
                  splashColor: Colors.transparent,
                ),
              ),
              textInputAction: TextInputAction.go,
              onSubmitted: (value){setState(() {}); FocusScope.of(context).unfocus();},
            ),
          ),
          Container(
            child: FutureBuilder<List<Widget>?>(
              future: _adminUserListDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ); // Display a loading indicator if the future is not resolved yet.
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data == null) {
                  return Text('유저가 없습니다.'); // Handle the case where the data is null.
                } else {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Column(
                            children: snapshot.data!, // Use snapshot.data with the non-null assertion operator.
                          ),
                        )
                      ]
                  );
                }
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  Future<List<Widget>?> _adminUserListDetails() async {
    var userListQuerySnapshot = await fs.collection('userList')
        .get(GetOptions(source: Source.server));

    List<Widget> userItems = [];

    for (var userDocument in userListQuerySnapshot.docs) {
      Map<String, dynamic> data = userDocument.data();
      if (_search != null && _search.text.isNotEmpty) {
        if (data['nick'].contains(_search.text) || data['email'].contains(_search.text)) {
          userItems.add(_addUser(data, userDocument.id));
        }
      } else {
        userItems.add(_addUser(data, userDocument.id));
      }
    }

    if (userItems.isEmpty) {
      return null; // or an empty list: return [];
    }

    return userItems;
  }
  
  Widget _addUser(Map<String, dynamic> data, String id){
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black12)
      ),
      child: ListTile(
        onTap: () => Get.to(
          AdminUserInfo(id),
          transition: Transition.noTransition
        ),
        title: Text(data['nick']),
        subtitle: Text(data['email']),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
