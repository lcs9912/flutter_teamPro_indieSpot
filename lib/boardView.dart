import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
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
  final TextEditingController _comment = TextEditingController();
  int commentCount = 0;
  bool TextFlg = false;

  void _addComment() async {
    String? userId = Provider.of<UserModel>(context, listen: false).userId;

    if (_comment.text.isNotEmpty) {
      CollectionReference comments = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.document.id)
          .collection('comments');

      await comments.add({
        'USER_ID' : userId,
        'COMMENT': _comment.text,
        'CREATEDATE': FieldValue.serverTimestamp(),
      });

      _comment.clear();
      setState(() {
        TextFlg = false;
      });
    }else if(_comment.text.isEmpty){
      setState(() {
        TextFlg = false;
      });
    }
  }

  void _regiComment(){
    setState(() {
      TextFlg = true;
    });
  }

  void _updateComment(DocumentSnapshot doc) async {
    await doc.reference.update({
      'COMMENT': _comment.text,
    });
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;

    return Scaffold(
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(height: 60),
                    Text(
                      "[" + data['CATEGORY'] + "] ",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      data['TITLE'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                    '${data['USER_ID']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                  ),
                ),
                SizedBox(height: 2),
                Text(
                    '${data['CREATEDATE'].toDate().toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                  ),
                ),
                Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                  height: 30,
                ),
                SizedBox(height: 8),
                Container(
                  constraints: BoxConstraints(
                    minHeight: 80,
                    maxHeight: 180,
                  ),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Text(
                      '${data['CONTENT']}',
                      style: TextStyle(
                          fontSize: 16
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14),
                Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                  height: 30,
                ),
                SizedBox(
                  child: Row(
                    children: [
                      Text('댓글 '),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("posts")
                            .doc(widget.document.id)
                            .collection("comments")
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
                          if (!snap.hasData) {
                            return Text('0개');
                          }
                          commentCount = snap.data!.docs.length;
                          return Text(commentCount.toString() + "개");
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
                ),
                Expanded(
                    child: _listComments()
                ),
                TextFlg ? Container(
                  height: 180,
                    child : TextField(
                  maxLines: 4,
                  controller: _comment,
                  decoration: InputDecoration(
                    labelText: "댓글 입력",
                    border: OutlineInputBorder(),
                  ),
                    )
                ) : Container(height: 60)
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: TextFlg ? _commentAdd() : _commentRegi(),
      bottomNavigationBar: MyBottomBar(),
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

  Widget _commentRegi(){
    return  Container(
      width: 380,
      height: 50,
      child: FloatingActionButton(
        onPressed:  _regiComment,
        backgroundColor: Colors.black54,
        child: Text(
          "댓글 쓰기",
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

  Widget _listComments() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.document.id)
          .collection("comments")
          .orderBy("CREATEDATE", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;

            // DateTime createdDate = (commentData['CREATEDATE'] as Timestamp).toDate();
            // String formatDate = DateFormat('yyyy/MM/dd HH:mm').format(createdDate);

            Timestamp? createdDateTimestamp = commentData['CREATEDATE'];
            DateTime? createdDate;
            if (createdDateTimestamp != null) {
              createdDate = createdDateTimestamp.toDate();
            }

            String formatDate = createdDate != null
                ? DateFormat('yyyy/MM/dd HH:mm').format(createdDate!)
                : "Unknown Date";

            return Column(
              children: [
                ListTile(
                  title: Text(
                      commentData['USER_ID'] ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commentData['COMMENT'],
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black
                        ),
                      ),
                      Text(
                        formatDate,
                      ),
                    ],
                  ),
                  trailing: Column(
                      children:[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditDialog(doc),
                              iconSize: 18,
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => _showDeleteDialog(doc),
                              iconSize: 18,
                            ),
                          ],
                        ),
                      ]
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.grey[300],
                  width: 800,
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteDialog(DocumentSnapshot doc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('댓글 삭제'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('이 댓글을 삭제하시겠습니까?'),
              ],
            ),
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

    _comment.text = commentData['COMMENT'];

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
}