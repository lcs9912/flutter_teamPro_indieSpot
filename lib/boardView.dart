import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/boardEdit.dart';
import 'package:indie_spot/userModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BoardView extends StatefulWidget {
  final DocumentSnapshot document;

  BoardView({required this.document});

  @override
  _BoardViewState createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  final TextEditingController _comment = TextEditingController();
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
  }

  void _addComment() async {
    String? userId = Provider
        .of<UserModel>(context, listen: false)
        .userId;
    if (userId == null) {
      _showLoginAlert(context);
    } else{

    if (_comment.text.isNotEmpty) {
      CollectionReference commentAdd = fs.collection('posts')
          .doc("3QjunO69Eb2OroMNJKWU")
          .collection(widget.document.reference.parent.id)
          .doc(widget.document.id)
          .collection('comments');

      await commentAdd.add({
        'userId': userId,
        'comment': _comment.text,
        'createDate': FieldValue.serverTimestamp(),
      });

      _comment.clear();
    }
    }
  }

  void _updateComment(DocumentSnapshot doc) async {
    await doc.reference.update({
      'comment': _comment.text,
    });
    Navigator.of(context).pop();
    _comment.clear();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    String userData = data['userId'];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('내용보기',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          if (Provider.of<UserModel>(context, listen: false).userId == data['userId'])
            IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoardEdit(document: widget.document),
                    ),
                  );
                },
                icon: Icon(Icons.edit)
            ),
          if (Provider.of<UserModel>(context, listen: false).userId == data['userId'])
            IconButton(
                onPressed: () => _showDeletePage(widget.document),
                icon: Icon(Icons.delete)
            ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(height: 60),
                        Text(
                          '${data['title'].length > 18 ? data['title'].substring(0, 18)+'···' : data['title']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder( //작성자 닉네임 표시
                        stream: fs.collection('userList').doc(userData).snapshots(),
                        builder: (context, userSnap) {
                          if (userSnap.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          DocumentSnapshot<Map<String, dynamic>> querySnapshot = userSnap.data as DocumentSnapshot<Map<String, dynamic>>;
                          return Text('${querySnapshot.get('nick') as String}');
                        }
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${data['createDate'].toDate().toString().substring(0, 16)}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '조회수 : ${data['cnt']}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: Colors.grey[400],
                      thickness: 1,
                      height: 30,
                    ),
                    SizedBox(height: 8),
                    Container(
                      child: StreamBuilder(
                            stream: fs
                                .collection("posts")
                                .doc("3QjunO69Eb2OroMNJKWU")
                                .collection(widget.document.reference.parent.id)
                                .doc(widget.document.id)
                                .collection('image')
                                .snapshots(),
                            builder: (context,  imgSnap) {
                              if (imgSnap.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (imgSnap.hasError) {
                                return Text('Error: ${imgSnap.error}');
                              }

                              Map<String, dynamic>? imgData = imgSnap.data?.docs.isNotEmpty ?? false
                              ? imgSnap.data!.docs.first.data() as Map<String, dynamic>?
                              : null;
                              return imgData != null && imgData.isNotEmpty
                                  ? Align(
                                alignment: Alignment.center,
                                    child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                    imgData['PATH'],
                                    height: 160,
                                    fit: BoxFit.fitHeight,
                                ),
                              ),
                                  )
                                  : Container();
                            }
                        ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 80,
                        maxHeight: 180,
                      ),
                      child: Text(
                        '${data['content']}',
                        style: TextStyle(
                            fontSize: 16
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                    Divider(
                      color: Colors.grey[400],
                      thickness: 1,
                      height: 30,
                    ),
                    Row(
                        children: [
                          Text('댓글 '),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("posts")
                                .doc("3QjunO69Eb2OroMNJKWU")
                                .collection(widget.document.reference.parent.id)
                                .doc(widget.document.id)
                                .collection('comments')
                                .snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
                              if (!snap.hasData) {
                                return Text('0');
                              }
                              commentCount = snap.data!.docs.length;
                              return Text(commentCount.toString());
                            },
                          ),
                          Divider(
                            color: Colors.grey[400],
                            thickness: 1,
                            height: 30,
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    TextField(
                      maxLines: 1,
                      controller: _comment,
                      decoration: InputDecoration(
                          hintText: "댓글 입력",
                          suffixIcon: IconButton(
                            onPressed: (){
                              _addComment();
                              _comment.clear();
                            },
                            icon: Icon(Icons.send, color: Color(0xFF233067)),
                          )
                      ),
                    ),
                    SizedBox(height: 16),
                    _listComments(),
                  ],
                ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  Widget _listComments() {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .doc("3QjunO69Eb2OroMNJKWU")
            .collection(widget.document.reference.parent.id)
            .doc(widget.document.id)
            .collection("comments")
            .orderBy("createDate", descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          String? _userId = Provider.of<UserModel>(context, listen: false).userId;

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;
              String commentUserData = commentData['userId'];

              Timestamp? createdDateTimestamp = commentData['createDate'];
              DateTime? createdDate;
              if (createdDateTimestamp != null) {
                createdDate = createdDateTimestamp.toDate();
              }
              String formatDate = createdDate != null
                  ? DateFormat('yyyy/MM/dd HH:mm').format(createdDate!)
                  : 'Unknown Date';

              return Column(
                children: [
                  ListTile(
                    title: StreamBuilder(
                      stream: fs.collection('userList').doc(commentUserData).snapshots(),
                      builder: (context, userSnap) {
                        if (userSnap.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        DocumentSnapshot<Map<String, dynamic>> querySnapshot = userSnap.data as DocumentSnapshot<Map<String, dynamic>>;

                        return Text(
                          '${querySnapshot.get('nick') as String}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commentData['comment'],
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          formatDate,
                        ),
                      ],
                    ),
                    trailing: _userId == commentData['userId']
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditDialog(doc),
                              iconSize: 16,
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => _showDeleteDialog(doc),
                              iconSize: 16,
                            ),
                          ],
                        ),
                      ],
                    )
                        : SizedBox(width: 1),
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                    width: 800,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }



  Widget _commentAdd(){
    return  Container(
      width: 380,
      height: 50,
      child: FloatingActionButton(
        onPressed:  _addComment,
        backgroundColor: Colors.black54,
        child: Text(
          "댓글 등록",
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
    );
  }




  Future<void> _showDeleteDialog(DocumentSnapshot doc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('댓글 삭제'),
          content: Container(
              child: Text('이 댓글을 삭제하시겠습니까?'),
            ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                doc.reference.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _showDeletePage(DocumentSnapshot doc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('게시글 삭제'),
          content: Container(
              child: Text('게시글을 정말 삭제하시겠습니까?'),
            ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                doc.reference.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(DocumentSnapshot doc) async {
    Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;

    _comment.text = commentData['comment'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('댓글 수정'),
          content: TextField(
            controller: _comment,
            decoration: InputDecoration(labelText: "댓글 수정하기"),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('수정하기'),
              onPressed: () => _updateComment(doc),
            ),
          ],
        );
      },
    );
  }
  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("로그인 필요"),
          content: Text("댓글을 작성하려면 로그인이 필요합니다"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("확인"),
            )
          ],
        );
      },
    );
  }
}