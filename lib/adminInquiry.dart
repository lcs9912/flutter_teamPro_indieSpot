import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class AdminInquiry extends StatefulWidget {
  const AdminInquiry({super.key});

  @override
  State<AdminInquiry> createState() => _AdminInquiryState();
}

class _AdminInquiryState extends State<AdminInquiry> {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  String _selectedValue = '전체';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          '문의 관리',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.center,
            height: 50,
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black), // 보더 스타일 설정
//              borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: Container(),
              items: <String>[
                '전체',
                '미답변',
                '답변완료',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  alignment: Alignment.center,
                  child: Text(value),
                );
              }).toList(),
              value: _selectedValue,
              alignment: Alignment.center,
              onChanged: (value) {
                if(value != _selectedValue){
                  setState(() {
                    _selectedValue = value!;
                  });
                }
              },
            ),
          ),
          Container(
            child: FutureBuilder<List<Widget>?>(
              future: _adminInquiryDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ); // Display a loading indicator if the future is not resolved yet.
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data == null) {
                  return Text('문의가 없습니다.'); // Handle the case where the data is null.
                } else {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Column(
                            children: snapshot.data!, // Use snapshot.data with the non-null assertion operator.
                          ),
                        )
                      ]
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  Future<List<Widget>?> _adminInquiryDetails() async {
    var userListQuerySnapshot = await fs.collection('userList').get();

    // Create a list to store the results of each user's inquiries
    List<Widget> inquiryItems = [];

    for (var userDetailDocument in userListQuerySnapshot.docs) {
      var inquiryQuerySnapshot = await userDetailDocument.reference.collection('inquiry').orderBy('cDateTime', descending: true).get();
      if (inquiryQuerySnapshot.docs.isNotEmpty) {
        inquiryItems.addAll(inquiryQuerySnapshot.docs.map((inquiryDocument) {
          var inquiryData = inquiryDocument.data();
          if (_selectedValue == '전체' ||
              (_selectedValue == '미답변' && inquiryData['reply'] == null) ||
              (_selectedValue == '답변완료' && inquiryData['reply'] != null)) {
            return Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1, color: Colors.black12))
              ),
              padding: EdgeInsets.all(10),
              child: ListTile(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => InquiryReply(inquiryDocument),)).then((value) => setState((){})),
                leading: SizedBox(
                  width: 30,
                  child: Text(inquiryData['category']),
                ),
                title: SizedBox(
                  child: Text(
                    inquiryData['content'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(inquiryData['cDateTime'].toDate())),
                trailing: Container(
                  width: 70,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.lightBlue),
                    // /borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: inquiryData['reply'] != null ? Colors.white : Colors.lightBlue,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    inquiryData['reply'] != null ? '답변완료' : '미답변',
                    style: TextStyle(
                      color: inquiryData['reply'] != null ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }
          return SizedBox.shrink(); // 선택된 값과 일치하지 않는 경우 아무것도 표시하지 않음
        }));
      }
    }

    if (inquiryItems.isEmpty) {
      return null; // or an empty list: return [];
    }

    return inquiryItems;
  }
}

class InquiryReply extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> inquiryDocument;
  const InquiryReply(this.inquiryDocument, {super.key});

  @override
  State<InquiryReply> createState() => _InquiryReplyState();
}

class _InquiryReplyState extends State<InquiryReply> {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  late Map<String, dynamic> data;
  final _reply = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    data = widget.inquiryDocument.data();
    if(data['reply'] != null) {
      _reply.text = data['reply'];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          '문의 상세',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('문의 유형'),
                Text(data['category'])
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('문의 날짜'),
                Text(DateFormat('yyyy-MM-dd hh:mm').format(data['cDateTime'].toDate()))
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('답변 상태'),
                Text(data['reply'] != null ? '답변 완료' : '미답변')
              ],
            ),
            SizedBox(height: 10),
            if(data['reply'] != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('답변 시간'),
                  Text(DateFormat('yyyy-MM-dd hh:mm').format(data['rDateTime'].toDate()))
                ],
              ),
            SizedBox(height: 10),
            Text('문의 내용'),
            SizedBox(height: 10),
            Container(
              height: 100,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black26),
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: Text(data['content'])
            ),
            SizedBox(height: 10),
            Text('문의 답변'),
            TextField(
              controller: _reply,
              focusNode: _replyFocusNode,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: '문의 답변내용을 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () => _addReply(),
              child: Text(data['reply'] != null ? '답변 수정' : '답변 등록')
            )
          ],
        )
      ),
    );
  }

  Future<void> _addReply() async{
    _replyFocusNode.unfocus();
    await widget.inquiryDocument.reference.update({
      'reply' : _reply.text,
      'rDateTime' : FieldValue.serverTimestamp()
    });
    final updatedSnapshot = await widget.inquiryDocument.reference.get();

    setState(() {
      data = updatedSnapshot.data()!;
    });
  }
}
