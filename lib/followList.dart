import 'package:flutter/material.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'artistInfo.dart';

class FollowList extends StatefulWidget {
  const FollowList({Key? key});

  @override
  State<FollowList> createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {
  String? _userId;
  String? _artistId;
  List<Map<String, dynamic>> _followingArtists = [];
  Map<String, String?> _imagePaths = {}; // 이미지 경로를 저장하는 맵

  void getFollowingArtistIds() async {
    String? userId = _userId;
    QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
        .collection('userList')
        .doc(userId)
        .collection('following')
        .get();

    List<DocumentSnapshot> followingDocuments = followingSnapshot.docs;

    for (var document in followingDocuments) {
      var data = document.data() as Map<String, dynamic>;
      var artistId = data['artistId'];

      DocumentSnapshot artistSnapshot = await FirebaseFirestore.instance
          .collection('artist')
          .doc(artistId)
          .get();

      if (artistSnapshot.exists) {
        var artistInfo = artistSnapshot['artistInfo'] as String?;
        var artistName = artistSnapshot['artistName'] as String?;

        _followingArtists.add({
          'artistInfo': artistInfo,
          'artistName': artistName,
          'artistId': artistId,
        });

        QuerySnapshot imageSnapshot = await FirebaseFirestore.instance
            .collection('artist')
            .doc(artistId)
            .collection('image')
            .get();

        if (imageSnapshot.docs.isNotEmpty) {
          var imagePath = imageSnapshot.docs[0]['path'] as String?;
          _imagePaths[artistId] = imagePath;
        }
      }
    }

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userId = Provider.of<UserModel>(context).userId;
    _artistId = Provider.of<UserModel>(context).artistId;

    print('_userId: $_userId');
    getFollowingArtistIds();
  }

  @override
  Widget build(BuildContext context) {
    print(_artistId);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar:AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black, // 뒤로가기 아이콘의 색을 검정색으로 설정
            ),
            onPressed: () {
              Navigator.pop(context); // This will navigate back
            },
          ),
          title: Text(
            '회원가입',
            style: TextStyle(color: Colors.black), // 텍스트 색을 검은색으로 설정
          ),
          backgroundColor: Colors.white, // AppBar 배경색을 흰색으로 설정
        ),

        body: TabBarView(
          children: [
            Column(
              children: [
                Text(
                  '팔로우 목록',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20,),
                Expanded(
                  child: ListView.builder(
                    itemCount: _followingArtists.length,
                    itemBuilder: (BuildContext context, int index) {
                      var artistInfo = _followingArtists[index]['artistInfo'] as String?;
                      var artistName = _followingArtists[index]['artistName'] as String?;
                      var artistId = _followingArtists[index]['artistId'] as String?;

                      return ListTile(
                        leading: _imagePaths[artistId] != null
                            ? Image.network(_imagePaths[artistId]!)
                            : Placeholder(),
                        title: Text(artistName ?? ''),
                        subtitle: Text(artistInfo ?? ''),
                        onTap: () async {
                          DocumentSnapshot artistDoc = await FirebaseFirestore.instance
                              .collection('artist')
                              .doc(artistId)
                              .get();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistInfo(
                                artistDoc,
                                _imagePaths[artistId]!,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            // 두 번째 탭 (팔로워) - 이 부분에 팔로워 목록을 추가해야 합니다.
            Center(
              child: Text('팔로워 목록을 여기에 추가하세요.'),
            ),
          ],
        ),
      ),
    );
  }
}
