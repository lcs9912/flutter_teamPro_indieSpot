import 'package:flutter/material.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDonationHistory extends StatefulWidget {
  const UserDonationHistory({super.key});

  @override
  State<UserDonationHistory> createState() => _UserDonationHistoryState();
}

class _UserDonationHistoryState extends State<UserDonationHistory> {
  int _num = 0;
  String? _selectedItem;
  List<String> _items = [];
  String? _userId;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  int totalDonationPoint = 0;
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();
  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
      Navigator.pop(context);
    } else {
      _userId = userModel.userId;
    }

    DateTime currentDate = DateTime.now();
    _selectedItem = '${currentDate.year}년 ${currentDate.month}월';
    DateTime lastYear = currentDate.subtract(Duration(days: 365));

// 중복 항목을 방지하기 위한 Set을 사용합니다.
    Set<String> uniqueMonths = {};

    while (currentDate.isAfter(lastYear)) {
      String month = '${currentDate.year}년 ${currentDate.month}월';
      uniqueMonths.add(month);
      currentDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day);
    }

// Set을 리스트로 변환합니다.
    _items = uniqueMonths.toList();
  }

  Future<Widget> _donationList() async {
    QuerySnapshot userSnap =
    await fs.collection("userList").doc(_userId).collection("point").get();
    String userPointDocId = userSnap.docs.first.id;
    QuerySnapshot userPointSnap =
    await fs.collection("userList")
        .doc(_userId).collection("point")
        .doc(userPointDocId)
        .collection("points_details")
        .where("type", isEqualTo: "후원")
        .get();
    List<TableRow> tableRows = [];
    print(userPointSnap.docs.length);
    int total = 0;
    for (int index = 0; index < userPointSnap.docs.length; index++) {
      Map<String, dynamic> _pointData = userPointSnap.docs[index].data() as Map<String, dynamic>;
        print(userPointSnap.docs.length);

      total += _pointData['amount'] as int;
      String artistId = _pointData['artistId'];
      DocumentSnapshot artistSnap = await fs.collection("artist").doc(artistId).get();
      Map<String,dynamic> artistData = artistSnap.data() as Map<String, dynamic>;

      Timestamp timeStamp = _pointData['date'];
      DateTime date = timeStamp.toDate();
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      String formattedHour = DateFormat('HH:mm').format(date);

      tableRows.add(
        TableRow(
          children: [
            TableCell(child: Container(
              height: 50,
              child: Center(child: Container(
                height: 40,
                child: Column(
                  children: [
                    Text(formattedDate),
                    Text(formattedHour)
                  ],
                ),
              )),
            )),
            TableCell(child: Container(height : 40 ,child: Center(child: Text(artistData['artistName'])))),
            TableCell(child: Container(height : 40 ,child: Center(child: Text(_numberFormat.format(_pointData['amount']))))),
            TableCell(child: Container(
              height: 40,
              child: Center(
                child: TextButton(onPressed: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 0.0,
                        backgroundColor: Colors.white,
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 330,
                                height: 45,
                                color: Colors.black12,
                                child:Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 13, 0, 0),
                                  child: Text("알림",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 20, 20, 0),
                                child: Text(_pointData['message']),
                              ),

                              Container(
                                color: Colors.black12,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 5, 4, 5),
                                      child: ElevatedButton(
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("닫기")
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }, child: Text("보기")),
              ),
            )),
          ],
        ),
      );
    }
    setState(() {
      totalDonationPoint = total;
    });
    return Expanded(
      child: ListView(
        children: [Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder(bottom: BorderSide(color: Colors.black12)),
            children: tableRows,
          ),
        ),],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            color: Color(0xFF392F31),
            height: 200,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/point2.png', height: 30, width: 30,),
                          Text(' 총 후원 포인트', style: TextStyle(color: Colors.white, fontSize: 15),),
                        ],
                      ),
                      Row(
                        children: [
                          Text((totalDonationPoint).toString(), style: TextStyle(color: Colors.white, fontSize: 25),),
                          Text('P', style: TextStyle(color: Colors.white, fontSize: 17),)
                        ],
                      )
                    ],
                  )),
                  Expanded(child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text('기간별 조회', style: TextStyle(color: Colors.white, fontSize: 15),)
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 15),
                                child: ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        _num = 30;
                                      });
                                    },
                                    style: ButtonStyle(
                                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero),side: _num == 30 ? BorderSide(color: Colors.white, width: 1) : BorderSide())),
                                        backgroundColor: MaterialStatePropertyAll(Color(0xFF634F52))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 13, bottom: 13),
                                      child: Text('최근 1개월'),
                                    )
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      _num = 90;
                                    });
                                  },
                                  style: ButtonStyle(
                                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero), side: _num == 90 ? BorderSide(color: Colors.white, width: 1) : BorderSide())),
                                      backgroundColor: MaterialStatePropertyAll(Color(0xFF634F52))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 13, bottom: 13),
                                    child: Text('최근 3개월'),
                                  )
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                height: 46,
                                padding: EdgeInsets.only(left: 13),
                                decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: _num == 0 ? Colors.white : Colors.black),
                                    color: Color(0xFF634F52)
                                ),
                                child: DropdownButton<String>(
                                  underline: Container(
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.white60,),
                                  value: _selectedItem,
                                  items: _items.map((item) {
                                    return DropdownMenuItem<String>(
                                        value: item,
                                        child: Container(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Text(item)
                                        )
                                    );
                                  }).toList(),
                                  onChanged:(value) {
                                    setState(() {
                                      _selectedItem = value!;
                                      _num = 0;
                                    });
                                  },
                                ),
                              )

                            ],
                          ),
                        ],
                      )
                    ],
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
                children: <TableRow>[
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]), // 헤더의 배경색 지정
                    children: <Widget>[
                      Container(
                          height: 50,
                          child: Center(child: Text('날짜', style: TextStyle(fontWeight: FontWeight.bold)))
                      ),
                      Container(
                          height: 50,
                          child: Center(child: Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold)))
                      ),
                      Container(
                          height: 50,
                          child: Center(child: Text('금액', style: TextStyle(fontWeight: FontWeight.bold)))
                      ),
                      Container(
                          height: 50,
                          child: Center(child: Text('메시지', style: TextStyle(fontWeight: FontWeight.bold)))
                      ),
                    ],
                  ),
                ]
            ),
          ),
          FutureBuilder(
              future: _donationList(), builder: (context, snapshot) => snapshot.data ?? Container()
          )
        ],
      ),
    );
  }
}
