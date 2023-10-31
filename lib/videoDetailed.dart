import 'package:flutter/material.dart';
import 'package:indie_spot/login.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
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
  String? _userId;

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

    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
    } else {
      _userId = userModel.userId;
    }
  }
  
  Future<void> addComment() async{
    final userModel = Provider.of<UserModel>(context, listen: false);
    if(!userModel.isLogin){
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text('로그인 하세요'),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text('취소')),
            TextButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage(),));
            }, child: Text('로그인'))
          ],
        );
      },);
    } else {
      fs.collection('video').doc(widget.videoId).collection('comment').add({
        'userId' : userModel.userId,
        'comment' : _commentControl.text,
        'cDateTime' : FieldValue.serverTimestamp()
      });
      setState(() {
      });
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
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: _commentControl,
                  decoration: InputDecoration(
                      hintText: '댓글을 남겨주세요',
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) {
                    addComment();
                    _commentControl.clear();
                  },
                ),
                Container(
                  child: FutureBuilder<List<Widget>>(
                    future: _commentDetails(),
                    builder: (context, snapshot) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Column(
                                children: snapshot.data ?? [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('해당 기간에 충전한 내역이 없습니다.'),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ]
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  Future<List<Widget>> _commentDetails() async {
    var vedioDocRef = fs.collection('video').doc(widget.videoId);

    try {
      var vedioDocSnapshot = await vedioDocRef.get();

      if (vedioDocSnapshot.exists) {
        var list = <Widget>[];
        var DetailsQuerySnapshot = await vedioDocRef.collection('comment').orderBy('cDateTime', descending: true).get();

        for (var pointDetailDocument in DetailsQuerySnapshot.docs) {
          var pointDetailData = pointDetailDocument.data();
          var date = pointDetailData['cDateTime'].toDate();
          var comment = pointDetailData['comment'];
          var id = pointDetailData['userId'];
          var userDocRef = fs.collection('userList').doc(id);
          var userSnapshot = await userDocRef.get();
          var userNick = userSnapshot.data()!['nick'];
          
          if (userSnapshot.exists) {
            var querySnapshot = await userDocRef.collection('image').limit(1).get();
            if (querySnapshot.docs.isNotEmpty) {
              var userDate = userSnapshot.data();
              var firstImageDocument = querySnapshot.docs.first;
              String userPath = firstImageDocument.data()['PATH'];

              var listItem = Container(
                margin: EdgeInsets.only(bottom: 20),
                child: ListTile(
                  leading: ClipOval(
                    child: Image.network(userPath, width: 50, height: 50, fit: BoxFit.cover,)
                  ),
                  title: Text(userNick, style: TextStyle(color: Colors.black54, fontFamily: 'Noto_Serif_KR',),),
                  subtitle: Text(comment, style: TextStyle(color: Colors.black, fontSize: 17),),
                  trailing: Text(DateFormat('yyyy-MM-dd').format(date)),
                  // 다른 필드 및 스타일을 추가할 수 있습니다.
                ),
              );
              list.add(listItem);
            }
          }
        }

        return list;
      } else {
        return <Widget>[];
      }
    } catch (e) {
      print('Error fetching data: $e');
      return <Widget>[];
    }
  }
}
