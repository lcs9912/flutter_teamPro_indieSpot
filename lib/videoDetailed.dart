import 'package:flutter/material.dart';
import 'package:indie_spot/artistInfo.dart';
import 'package:indie_spot/dialog.dart';
import 'package:indie_spot/login.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoDetailed extends StatefulWidget {
  final Map<String, dynamic> videoDetailData;
  final String videoId;
  final DocumentSnapshot<Map<String, dynamic>>? artistName;
  VideoDetailed(this.videoDetailData, this.videoId, this.artistName, {super.key});

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
  bool _editflg = false;
  String? _commentId;
  final FocusNode _focusNode = FocusNode();
  String img ="";
  @override
  void initState() {
    super.initState();
    _updateCnt();
    fetchData();
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

  Future<void> fetchData() async {
    QuerySnapshot imgSnap = await fs.collection("artist").doc(widget.artistName?.id).collection("image").get();
    if(imgSnap.docs.isNotEmpty){
      setState(() {
        img = imgSnap.docs.first.get("path");
      });
    }

  }
  Future<void> _updateCnt() async {
    CollectionReference videoCollection = fs.collection('video');
    DocumentReference videoDocRef = videoCollection.doc(widget.videoId);

    try {
      DocumentSnapshot document = await videoDocRef.get();
      if (document.exists) {

        var data = document.data() as Map<String, dynamic>;
        int currentCount = data?['cnt'] ?? 0;

        // 값을 1 증가시킴
        int newCount = currentCount + 1;

        // 'cnt' 필드 업데이트
        await videoDocRef.update({'cnt': newCount});
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  Future<void> addComment() async{
    final userModel = Provider.of<UserModel>(context, listen: false);
    if(!userModel.isLogin){
      DialogHelper.showUserRegistrationDialog(context);
    } else {
      if(_editflg) {
        fs.collection('video').doc(widget.videoId).collection('comment').doc(_commentId).update({
          'comment' : _commentControl.text,
          'edit' : '수정됨'
        });
      } else {
        fs.collection('video').doc(widget.videoId).collection('comment').add({
          'userId' : userModel.userId,
          'comment' : _commentControl.text,
          'cDateTime' : FieldValue.serverTimestamp()
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('댓글이 등록되었습니다.')));
      }
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
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
            color: Colors.white,
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
                  margin: EdgeInsets.only(bottom: 0),
                  padding: EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(widget.videoDetailData['title'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(
                        0xFF484848)),),
                    subtitle: Row(
                      children: [
                        Text("조회수 ${(widget.videoDetailData['cnt']).toString()}회  ",style: TextStyle(fontSize: 16),),
                        Text(DateFormat('yyyy-MM-dd HH:mm').format(widget.videoDetailData['cDateTime'].toDate()))
                      ],
                    ),
                  )
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: img ?? '', // 이미지 URL
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ) // 프로필 이미지
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ArtistInfo(widget.artistName?.id as String),));
                      },
                      style: ButtonStyle(
                        padding: MaterialStatePropertyAll(EdgeInsets.zero), // 패딩 없음
                      ),
                      child : Text(widget.artistName?.get("artistName"),style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(widget.videoDetailData['content']),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: _commentControl,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: '댓글을 남겨주세요',
                    suffixIcon: IconButton(
                      onPressed: () {
                        addComment();
                        _commentControl.clear();
                      },
                      icon: Icon(Icons.send),
                    )
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
                                      Text('댓글이 없습니다 댓글을 남겨주세요'),
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
          bool edit = pointDetailData['edit'] != null;
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
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0), // 기본 패딩을 제거합니다
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4), // leading과 title 사이의 간격을 조절
                  leading: ClipOval(
                      child: Image.network(userPath, width: 30, height: 30, fit: BoxFit.cover),
                  ),
                  title: Row(
                    children: [
                      Text('$userNick ', style: TextStyle(color: Colors.black54, fontFamily: 'Noto_Serif_KR', fontSize: 15),),
                      Text('${DateFormat('MM-dd').format(date)} ${edit ? '(수정됨)' : ''}', style: TextStyle(color: Colors.black54, fontFamily: 'Noto_Serif_KR', fontSize: 11),),
                    ],
                  ),
                  subtitle: Text(comment, style: TextStyle(color: Colors.black87, fontSize: 17),),
                  trailing: Visibility(
                    visible: _userId == id,
                    child: IconButton(
                      onPressed: (){
                        showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(27)
                            )
                          ),
                          context: context,
                          builder: (context) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10, bottom: 20),
                                    width: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 2, color: Colors.black54),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: TextButton(
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                            _editComment(pointDetailDocument.id, vedioDocRef, comment);
                                          },
                                          style: ButtonStyle(
                                            alignment: Alignment.centerLeft
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 15),
                                                child: Icon(Icons.edit, color: Color(0xFF634F52),),
                                              ),
                                              Text('수정', style: TextStyle(color: Color(0xFF634F52)),)
                                            ],
                                          )
                                        ),
                                      )
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: TextButton(
                                              onPressed: ()=> showDialog(context: context, builder: (context) {
                                                return AlertDialog(
                                                  title: Text('댓글 삭제'),
                                                  content: Text('댓글을 완전히 삭제할까요?'),
                                                  actions: [
                                                    TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('취소')),
                                                    TextButton(onPressed: (){
                                                      _deleteComment(pointDetailDocument.id, vedioDocRef);
                                                      Navigator.of(context).pop();
                                                      setState(() {
                                                      });
                                                    }, child: Text('삭제')),
                                                  ],
                                                );
                                              },).then((value) => Navigator.of(context).pop()),
                                              style: ButtonStyle(
                                                  alignment: Alignment.centerLeft
                                              ),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 15),
                                                    child: Icon(Icons.delete, color: Color(0xFF634F52),),
                                                  ),
                                                  Text('삭제', style: TextStyle(color: Color(0xFF634F52)),)
                                                ],
                                              )
                                          ),
                                        )
                                    )
                                  ],
                                )
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.more_vert, color: Colors.black54, size: 17,),
                    ),
                  ),
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

  Future<void> _deleteComment(String id, DocumentReference<Map<String, dynamic>> vedioDocRef) async {
    await vedioDocRef.collection('comment').doc(id).delete();
  }

  Future<void> _editComment(String id, DocumentReference<Map<String, dynamic>> vedioDocRef, comment) async {
    _commentControl.text = comment;
    setState(() {
      _editflg = true;
      _commentId = id;
    });
    FocusScope.of(context).requestFocus(_focusNode);
  }
}
