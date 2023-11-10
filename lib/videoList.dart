import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/loading.dart';
import 'package:indie_spot/videoAdd.dart';
import 'package:indie_spot/videoDetailed.dart';
import 'package:intl/intl.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  final _searchControl = TextEditingController();
  FirebaseFirestore fs = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu, color: Colors.white,),
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
          '영상 목록',
          style: TextStyle(color: Colors.white,),
        ),
      ),
      body: Column(
        children: [
          _searchText(),
          Expanded(child: ListView(
            children: [
              _videoList()
            ],
          ))
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
      floatingActionButton: Provider.of<UserModel>(context, listen: false).isArtist ? FloatingActionButton(
        backgroundColor: Color(0xFF233067),
        onPressed: (){
          Get.to(
            YoutubeAdd(),
            transition: Transition.noTransition
          )!.then((value) => setState(() {}));
        },
        child: Icon(Icons.edit),
      ) : Container(),
    );
  }

  Padding _searchText() {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        cursorColor: Color(0xFF233067),
        decoration: InputDecoration(
          hintText: '검색',
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF233067))
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF233067))
          ),
          prefixIcon: Icon(Icons.search, color: Color(0xFF233067),),
        ),
        controller: _searchControl,
        textInputAction: TextInputAction.go,
        onSubmitted: (value) {
          FocusScope.of(context).unfocus();
          setState(() {});
        },
      ),
    );
  }

  Container _videoList() {
    return Container(
      child: FutureBuilder<List<Widget>>(
        future: _videoListSearch(),
        builder: (context, snapshot) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: snapshot.data ?? [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        ],
                      )
                    ],
                  ),
                )
              ]
          );
        },
      ),
    );
  }

  Widget _buildVideoListItem(Map<String, dynamic> videoDetailData, String id, DocumentSnapshot<Map<String, dynamic>>? artistName) {
    String title = videoDetailData['title'];
    String url = videoDetailData['url'];
    int cnt = videoDetailData['cnt'];
    var time = videoDetailData['cDateTime'];


    if (title.length > 30) {
      title = title.substring(0, 30) + "...";
    }
    return GestureDetector(
      onTap: () {
        Get.to(
          VideoDetailed(videoDetailData, id ,artistName!),
          transition: Transition.noTransition
        )!.then((value) => setState(() {}));
      },
      child: Container(
        height: 370,
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: 'https://img.youtube.com/vi/$url/0.jpg', // 이미지 URL
                  height: 270,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()), // 이미지 로딩 중에 표시될 위젯
                  errorWidget: (context, url, error) => Icon(Icons.error), // 이미지 로딩 오류 시 표시될 위젯
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(artistName?.get('artistName') ?? 'z'),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('조회수 $cnt', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      Text(DateFormat('yyyy-MM-dd').format(time.toDate()),
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Widget>> _videoListSearch() async {
    var videoDetailsQuerySnapshot = await fs.collection('video').orderBy(
        'cDateTime', descending: true).get();

    if (videoDetailsQuerySnapshot.docs.isNotEmpty) {
      var list = <Widget>[];

      for (var videoDetailDocument in videoDetailsQuerySnapshot.docs) {
        var videoDetailData = videoDetailDocument.data();
        if (_searchControl != null && _searchControl.text.isNotEmpty) {
          // 검색어가 비어 있지 않고 title에 검색어가 포함되어 있으면 리스트에 아이템 추가
          if (videoDetailData['title'].contains(_searchControl.text)) {
            var artistName = await _getArtistName(videoDetailData['artistId']);
            list.add(_buildVideoListItem(videoDetailData, videoDetailDocument.id, artistName));

          }
        } else {
          // 검색어가 비어있거나 null인 경우 모든 아이템 추가
          var artistName = await _getArtistName(videoDetailData['artistId']);
          list.add(_buildVideoListItem(videoDetailData, videoDetailDocument.id, artistName));
        }
      }
      return list;
    } else {
      var list = <Widget>[
      ];
      return list;
    }
  }
  Future<DocumentSnapshot<Map<String, dynamic>>?> _getArtistName(String artistId) async {
    var artistDoc = await fs.collection('artist').doc(artistId).get();
    if (artistDoc.exists) {
      return artistDoc;
    } else {
      return null;
    }
  }
}