// YouTube Data API를 통한 영상 검색 예시 (Dart)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/userModel.dart';
import 'package:indie_spot/videoList.dart';
import 'package:provider/provider.dart';
import 'baseBar.dart';

class YoutubeAdd extends StatefulWidget {

  @override
  State<YoutubeAdd> createState() => _YoutubeTestState();
}

class _YoutubeTestState extends State<YoutubeAdd> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController videoUrl = TextEditingController();
  final TextEditingController videoTitle = TextEditingController();
  final TextEditingController _videoContent = TextEditingController();
  FocusNode _focusNode = FocusNode();
  int state = 0;
  int states1 = 0;
  int states2 = 0;
  int states3 = 0;
  int state1 = 0;
  String searchText = "";
  String _artistId = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if(!userModel.isArtist){

    }else{
      _artistId = userModel.artistId!;
    }
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
            '영상 등록',
            style: TextStyle(color: Colors.black,),
          ),
        ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _search,
              focusNode: _focusNode,
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                if (_focusNode.hasFocus) {
                  setState(() {
                    searchText = _search.text;
                    state1 = 1;
                  });
                }
              },
              decoration: InputDecoration(

                hintText: "등록할 영상을 검색하세요",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  onPressed: () {
                    _search.clear();
                    setState(() {

                    });
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black38))),
            child: FutureBuilder<List<Widget>>(
              future: searchYouTubeVideos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  state = 0;
                  return Center(child: CircularProgressIndicator()); // 로딩 중 표시
                } else if (snapshot.hasError) {
                  state = 1;
                  return Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        Text("정상적인 URL이 아닙니다."),
                        Text("정상적인 URL이 입력해주세요."),
                      ],
                    ),
                  ); // 에러 발생 시 표시
                } else {
                  // 데이터가 있을 때 ListView.builder 반환
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return snapshot.data?[index]; // 반환된 ListTile 위젯 반환
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('영상 URL'),
                states1 == 1? Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text("필수 입력",style: TextStyle(color: Colors.red,fontSize: 13),),
                ) : Container()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: videoUrl,
              onTap: (){
                setState(() {
                  states1 = 0;
                  state1 = 0;
                });
              },
              onChanged: (value){
                setState(() {
                  state = 0;
                });
              },
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                String url = value;
                Uri uri = Uri.parse(url);
                String? videoId = uri.queryParameters['v'];
                setState(() {
                  _search.clear();
                  videoUrl.text = videoId!;
                });
              },

              decoration: InputDecoration(
                hintText: "등록할 영상의 URL을 입력하세요",
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: states1 == 1 ? Colors.red : Colors.black54)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // 활성 상태 보더 색상 설정
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    videoUrl.clear();
                    videoTitle.clear();
                    setState(() {

                    });
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('영상 제목'),
                states2 == 1? Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text("필수 입력",style: TextStyle(color: Colors.red,fontSize: 13),),
                ) : Container()

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: videoTitle,
              onTap: (){
                setState(() {
                  states2 = 0;
                  state1 = 0;
                });
              },
              onChanged: (value){
                setState(() {
                  states2 = 0;
                });
              },
              decoration: InputDecoration(
                hintText: "등록할 영상의 제목을 입력하세요",
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: states2 == 1 ? Colors.red : Colors.black54)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // 활성 상태 보더 색상 설정
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    videoTitle.clear();
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('영상 설명'),
                states3 == 1? Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text("필수 입력",style: TextStyle(color: Colors.red,fontSize: 13),),
                ) : Container()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _videoContent,
                  maxLines: null,
                  onTap: (){
                    setState(() {
                      states3 = 0;
                      state1 = 0;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "등록할 영상의 설명을 입력하세요",
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: states3 == 1 ? Colors.red : Colors.black54)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue, // 활성 상태 보더 색상 설정
                      ),
                    ),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 100),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            height: 50,
            child: ElevatedButton(
              onPressed: (){
                if(videoUrl.text.isEmpty || state == 1){
                  setState(() {
                    states1 = 1;
                  });
                }
                if(videoTitle.text.isEmpty){

                  setState(() {
                    states2 = 1;
                  });
                }
                if(_videoContent.text.isEmpty){

                  setState(() {
                    states3 = 1;
                  });
                }
                if(states1==0&&states2==0&&states3==0){
                  videoUpload();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VideoList(),));
                }
              },
              child: Text("등록"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 모든 모서리를 직각으로 설정
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
  void videoUpload(){
    FirebaseFirestore.instance.collection("video").add(
        {
          "cDateTime" : FieldValue.serverTimestamp(),
          "cnt" : 0,
          "content" : _videoContent.text,
          "title" : videoTitle.text,
          "url" : videoUrl.text,
          "artistId" : _artistId,
          'deleteYn' : 'N'
        }
    );
  }

  Future<List<Widget>> searchYouTubeVideos() async {
    final apiKey = 'AIzaSyDwOMeQKxhqYsWkIjf8lttVSJMWHKCis3k';
    final query = _search.text;
    final videoId = videoUrl.text;
    List<Widget> videoData = [];
    if(_search.text.isNotEmpty && state1 == 1){
      final channelResponse = await http.get(Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=$query&part=snippet&maxResults=1&type=channel'));
      videoTitle.text = "";
      if (channelResponse.statusCode == 200) {
        Map<String, dynamic> channelData = json.decode(channelResponse.body);
        String channelId = channelData['items'][0]['id']['channelId'];
        // 해당 채널의 영상 검색
        final response = await http.get(Uri.parse(
            'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=$query&part=snippet&maxResults=10&type=video'));

        if (response.statusCode == 200) {
          state = 0;
          Map<String, dynamic> data = json.decode(response.body);
          List<dynamic> videos = data['items'];
          for (var video in videos) {
            String _title = video['snippet']['title'];
            if (_title.length > 30) {
              _title = _title.substring(0, 30) + "...";
            }
            videoData.add(
              ListTile(
                title: Text(_title),
                subtitle: Text('${video['snippet']['channelTitle']}'),
                leading: Image.network(
                    video['snippet']['thumbnails']['default']['url']),
                onTap: () {
                  videoUrl.text = video['id']['videoId'];
                  videoTitle.text = video['snippet']['title'];
                },
              ),
            );
          }
        } else {
          print('Failed to fetch videos. Error: ${response.reasonPhrase}');
        }
      }
    }else if(videoUrl.text.isNotEmpty){
      final response = await http.get(Uri.parse('https://www.googleapis.com/youtube/v3/videos?key=$apiKey&id=$videoId&part=snippet'));
      if (response.statusCode == 200) {
        Map<String, dynamic> videoData1 = json.decode(response.body);

        final snippet = videoData1['items'][0]['snippet'];
        String _title = snippet['title'];
        if (_title.length > 30) {
          _title = _title.substring(0, 30) + "...";
        }
        final String title = snippet['title'];
        final String channelTitle = snippet['channelTitle'];
        final String thumbnailUrl = snippet['thumbnails']['default']['url'];
        videoTitle.text = title;
        state = 0;
        videoData.add(
          ListTile(
            title: Text(_title),
            subtitle: Text(channelTitle),
            leading: Image.network(thumbnailUrl),

          ),
        );

        // title, channelTitle, thumbnailUrl을 이용해 작업 수행
      } else {
        print('Failed to fetch video details. Error: ${response.reasonPhrase}');
      }
    }else{
      videoTitle.clear();
      videoData.add(
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('등록할 영상을 검색하거나.'),
                Text('등록할 영상의 URL을 입력하세요.'),
              ],
            ),
          )
      );
    }
    return videoData;
  }
}
