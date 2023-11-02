import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/videoAdd.dart';
import 'package:indie_spot/videoDetailed.dart';
import 'package:intl/intl.dart';

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
          IconButton(
            onPressed: () {
              // 아이콘 클릭 시 수행할 작업 추가
            },
            icon: Icon(Icons.person),
            color: Colors.black54,
          ),
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu),
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
            color: Colors.black54,
          ),
          onPressed: () {
            // 뒤로가기 버튼을 눌렀을 때 수행할 작업
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          '영상 목록',
          style: TextStyle(color: Colors.black,),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF392F31),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => YoutubeAdd(),)).then((value) => setState(() {}));
        },
        child: Icon(Icons.edit),
      ),
    );
  }

  Padding _searchText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: '검색',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {
              _searchControl.clear();
              setState(() {});
            },
            icon: Icon(Icons.cancel_outlined),
            highlightColor: Colors.transparent, // 클릭 시 하이라이트 효과를 제거
            splashColor: Colors.transparent,
          ),
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
                          Text(''),
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

  Widget _buildVideoListItem(Map<String, dynamic> videoDetailData, String id) {
    String title = videoDetailData['title'];
    String url = videoDetailData['url'];
    int cnt = videoDetailData['cnt'];
    var time = videoDetailData['cDateTime'];
    if (title.length > 30) {
      title = title.substring(0, 30) + "...";
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => VideoDetailed(videoDetailData, id),)).then((value) => setState(() {}));
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
                child: Image.network(
                  'https://img.youtube.com/vi/$url/0.jpg', height: 270,),
              ),
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
                      Text('조회수 $cnt', style: TextStyle(fontSize: 12)),
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
      videoDetailsQuerySnapshot.docs.forEach((videoDetailDocument) {
        var videoDetailData = videoDetailDocument.data();
        if (_searchControl != null && _searchControl.text.isNotEmpty) {
          // 검색어가 비어 있지 않고 title에 검색어가 포함되어 있으면 리스트에 아이템 추가
          if (videoDetailData['title'].contains(_searchControl.text)) {
            list.add(_buildVideoListItem(videoDetailData, videoDetailDocument.id));
          }
        } else {
          // 검색어가 비어있거나 null인 경우 모든 아이템 추가
          list.add(_buildVideoListItem(videoDetailData, videoDetailDocument.id));
        }
      });
      return list;
    } else {
      var list = <Widget>[];
      return list;
    }
  }
}