import 'package:flutter/material.dart';
import 'package:indie_spot/loading.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

import 'baseBar.dart';

class UserDonationHistory extends StatefulWidget {
  const UserDonationHistory({Key? key}) : super(key: key);

  @override
  State<UserDonationHistory> createState() => _UserDonationHistoryState();
}

class _UserDonationHistoryState extends State<UserDonationHistory> {
  int _num = 30;
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
    totalPoint();
    DateTime currentDate = DateTime.now();
    _selectedItem = '${currentDate.year}년 ${currentDate.month}월';
    DateTime lastYear = currentDate.subtract(const Duration(days: 365));

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
  void totalPoint() async {
    List<Map<String, dynamic>> donationData = await getDonationData(_num, _selectedItem);
    totalDonationPoint = 0; 
    for (var data in donationData) {
      totalDonationPoint = data['total'] as int;
    }
    setState(() {
      totalDonationPoint;
    });
  }

  Future<List<Map<String, dynamic>>> getDonationData(int day, sMonth) async {
    QuerySnapshot userSnap = await fs.collection("userList").doc(_userId).collection("point").limit(1).get();
    if (userSnap.docs.isNotEmpty) {
      String userPointDocId = userSnap.docs.first.id;
      QuerySnapshot userPointSnap;
      if(_num == 30 || _num == 90) {
        totalDonationPoint = 0;
        final DateTime now = DateTime.now();
        final DateTime oneMonthAgo = now.subtract(Duration(days: day));
        userPointSnap = await fs
            .collection("userList")
            .doc(_userId).collection("point")
            .doc(userPointDocId)
            .collection("points_details")
            .orderBy('date', descending: true)
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(oneMonthAgo))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(now))
            .get();
      }else{
        totalDonationPoint = 0;
        String strippedInput = sMonth.replaceAll('년', '').replaceAll('월', '');
        List<String> parts = strippedInput.split(' ');

        int year = int.parse(parts[0]);
        int month = int.parse(parts[1]);

        DateTime selectedDate = DateTime(year, month); // 선택한 월 (예: 2023년 10월)
        DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
        DateTime lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).add(Duration(days: 1));
        userPointSnap = await fs
            .collection("userList")
            .doc(_userId).collection("point")
            .doc(userPointDocId)
            .collection("points_details")
            .orderBy('date', descending: true)
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
            .get();
      }
      if (userPointSnap.docs.isNotEmpty) {
        List<Map<String, dynamic>> data = [];
        int total = 0;
        for (int index = 0; index < userPointSnap.docs.length; index++) {
          Map<String, dynamic> _pointData = userPointSnap.docs[index].data() as Map<String, dynamic>;
          if(_pointData['type'] == "후원") {
            String artistId = _pointData['artistId'];
            DocumentSnapshot artistSnap = await fs.collection("artist").doc(
                artistId).get();
            Map<String, dynamic> artistData = artistSnap.data() as Map<
                String,
                dynamic>;
            data.add({
              'date': _pointData['date'],
              'formattedDate': DateFormat('yyyy-MM-dd').format(
                  _pointData['date'].toDate()),
              'formattedHour': DateFormat('HH:mm').format(
                  _pointData['date'].toDate()),
              'artistName': artistData['artistName'],
              'amount': _numberFormat.format(_pointData['amount']),
              'message': _pointData['message'],
              "total": total += _pointData['amount'] as int,
            });
          }
        }
        return data;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xFF233067)
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 아이콘 클릭 시 수행할 작업 추가
            },
            icon: Icon(Icons.person),
            color: Colors.white,
          ),
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu),
                color: Colors.white,
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
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          '후원 내역',
          style: TextStyle(color: Colors.white,),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: 200,
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/point2.png', height: 30, width: 30),
                            const Text(' 총 후원 포인트', style: TextStyle(color: Colors.black, fontSize: 15)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(totalDonationPoint.toString(), style: const TextStyle(color: Colors.black, fontSize: 25)),
                            const Text('P', style: TextStyle(color: Colors.black, fontSize: 25)),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              child: const Text('기간별 조회', style: TextStyle(color: Colors.black, fontSize: 15)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _num = 30;
                                    });
                                    totalPoint();
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                      side: _num == 30 ? BorderSide.none : BorderSide(color: Color(0xFF233067), width: 1),
                                    )),
                                    backgroundColor:_num == 30 ?MaterialStateProperty.all(const Color(0xFF233067)): MaterialStateProperty.all(const Color(0xFFFFFFFF)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 13, bottom: 13),
                                    child: Text('최근 1개월',style: _num == 30 ?TextStyle(color: Colors.white) : TextStyle(color: Color(0xFF233067)),),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _num = 90;
                                    });
                                    totalPoint();
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                      side: _num == 90 ? BorderSide.none : BorderSide(color: Color(0xFF233067), width: 1),
                                    )),
                                    backgroundColor:_num == 90 ? MaterialStateProperty.all(const Color(0xFF233067)) : MaterialStateProperty.all(const Color(0xFFffffff)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 13, bottom: 13),
                                    child: Text('최근 3개월', style: _num == 90 ? TextStyle(color: Colors.white) : TextStyle(color: Color(0xFF233067)),),
                                  ),
                                ),
                                Container(
                                  height: 48,
                                  padding: EdgeInsets.only(left: 13),
                                  margin: EdgeInsets.only(left: 30),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1, color: _num == 0 ? Color(0xFF233067) : Colors.black),
                                      color: _num == 0 ? Color(0xFF233067) : Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    dropdownColor: Color(_num == 0 ? 0xFF233067 : 0xFFFFFFFF),
                                    underline: Container(),
                                    icon: Icon(Icons.keyboard_arrow_down, color: Color(_num == 0 ? 0xFFFFFFFF : 0xFF233067),),
                                    value: _selectedItem,
                                    items: _items.map((item) {
                                      return DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(item, style: TextStyle(color: Color(_num == 0 ? 0xFFFFFFFF : 0xFF233067)),)
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Table(
            children: <TableRow>[
              TableRow(
                decoration: BoxDecoration(color: Color(0xFF233067)), // 헤더의 배경색 지정
                children: <Widget>[
                  Container(
                    height: 50,
                    child:  Center(child: Text('날짜', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                  Container(
                    height: 50,
                    child:  Center(child: Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                  Container(
                    height: 50,
                    child: Center(child: Text('금액', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                  Container(
                    height: 50,
                    child: Center(child: Text('메시지', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                ],
              ),
            ],
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: getDonationData(_num, _selectedItem),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                    height: 400,
                    child: LoadingWidget()
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error fetching data'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Column(
                  children: [
                    Lottie.asset(
                      'assets/empty.json',
                      fit: BoxFit.contain,
                    ),
                    Center(child: Text('후원 내역이 없습니다')),
                  ],
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Text(data['formattedDate']),
                                  Text(data['formattedHour']),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(child: Text(data['artistName'])),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(child: Text(data['amount'])),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                          elevation: 0.0,
                                          backgroundColor: Colors.white,
                                          child: SizedBox(
                                            height: 200,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("후원 메시지",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(15.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                          height: 80,
                                                          child: SingleChildScrollView(
                                                            child:
                                                            Text(data["message"]),
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: (){
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Text("닫기"),
                                                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF233067))),
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
                                  },
                                  child: const Text("보기", style: TextStyle(color: Color(0xFF233067))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}