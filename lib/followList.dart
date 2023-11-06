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

      // artistId를 사용하여 artist 컬렉션에서 정보 가져오기
      DocumentSnapshot artistSnapshot = await FirebaseFirestore.instance
          .collection('artist')
          .doc(artistId)
          .get();

      if (artistSnapshot.exists) {
        var artistInfo = artistSnapshot['artistInfo'] as String?;
        var artistName = artistSnapshot['artistName'] as String?;

        // artist 정보를 리스트에 추가
        _followingArtists.add({
          'artistInfo': artistInfo,
          'artistName': artistName,
          'artistId': artistId, // 추가된 부분: artistId를 _followingArtists 리스트에 추가
        });

        // artist 컬렉션의 image 서브컬렉션에서 필드값 path 가져오기
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

    // 화면을 갱신하기 위해 setState 호출
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userId = Provider
        .of<UserModel>(context)
        .userId;
    _artistId = Provider
        .of<UserModel>(context)
        .artistId;

    print('_userId: $_userId');
    getFollowingArtistIds();
  }

  @override
  Widget build(BuildContext context) {
    print(_artistId);
    return Scaffold(
      appBar: AppBar(
        title: Text('Following Artists'),
      ),
      body: Column(
        children: [
          // 추가된 텍스트 위젯
          Text(
            '팔로우 목록',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20,),

          // ListView.builder
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
                    // artistId를 사용하여 해당 문서를 가져옵니다.
                    DocumentSnapshot artistDoc = await FirebaseFirestore.instance
                        .collection('artist')
                        .doc(artistId)
                        .get();

                    // 가져온 문서를 사용하여 ArtistInfo 페이지로 이동합니다.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArtistInfo(
                          artistDoc, // 가져온 DocumentSnapshot을 전달
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
    );
  }



}