import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:intl/intl.dart';

class VideoDetailed extends StatefulWidget {
  final Map<String, dynamic> videoDetailData;
  final String videoId;
  VideoDetailed(this.videoDetailData, this.videoId, {super.key});

  @override
  State<VideoDetailed> createState() => _VideoDetailedState();
}

class _VideoDetailedState extends State<VideoDetailed> {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'YOUR_DEFAULT_VIDEO_ID', // YouTube 동영상의 ID를 여기에 입력
    flags: YoutubePlayerFlags(
      autoPlay: false, // 동영상 자동 재생 여부 설정
      mute: false, // 음소거 여부 설정
    ),
  );
  final _commentControl = TextEditingController();
  FirebaseFirestore fs = FirebaseFirestore.instance;
  
  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoDetailData['url'], // YouTube 동영상의 ID를 여기에 입력
      flags: YoutubePlayerFlags(
        autoPlay: false, // 동영상 자동 재생 여부 설정
        mute: false, // 음소거 여부 설정
      ),
    );
  }
  
  Future<void> addComment() async{
    fs.collection('video').doc(widget.videoId).collection('comment').add({

    });
  }

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
          widget.videoDetailData['title'],
          style: TextStyle(color: Colors.black,),
        ),
      ),
      body: ListView(
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true, // 동영상 진행률 표시 여부
            progressColors: ProgressBarColors(backgroundColor: Colors.amber, playedColor: Colors.red), // 진행률 바 색상 설정
            onReady: () {
              _controller.play();
            },
          ),
          Container(
            height: 300,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black26, width: 1))
                  ),
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text(widget.videoDetailData['title'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(
                      0xFF484848)),),
                ),
                Text(widget.videoDetailData['content']),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _commentControl,
              decoration: InputDecoration(
                hintText: '댓글을 남겨주세요'
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}
