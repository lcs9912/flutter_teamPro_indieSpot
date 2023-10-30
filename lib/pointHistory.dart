import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PointHistory extends StatefulWidget {
  const PointHistory({super.key});

  @override
  State<PointHistory> createState() => _PointHistoryState();
}

class _PointHistoryState extends State<PointHistory> {
  String? _userId;
  int? _pointBalance = 0;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  int _totalRecharge = 0;
  List<Widget> _pointsDetailsList = [];

  Future<void> pointBalanceSearch() async {
    QuerySnapshot pointSnapshot = await fs.collection('userList').doc(_userId)
        .collection('point').limit(1)
        .get();

    if (pointSnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot firstPointDocument = pointSnapshot.docs.first;
      Map<String, dynamic> data = firstPointDocument.data() as Map<
          String,
          dynamic>;
      setState(() {
        _pointBalance = data!['pointBalance'];
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
      Navigator.pop(context);
    } else {
      _userId = userModel.userId;
      pointBalanceSearch();
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
          '포인트 내역',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          // 포인트 내역 섹션
          Container(
            color: Colors.white,
            child: Container(

              child: FutureBuilder<List<Widget>>(
                future: _pointsDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _container() ,
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          margin: EdgeInsets.all(20),
                          child: Column(
                            children: snapshot.data ?? [Container()],
                          ),
                        )
                      ]
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  Container _container() {
    return Container(
      color: Color(0xFF392F31),
      height: 180,
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
                    Text(' 총 충전 포인트', style: TextStyle(color: Colors.white, fontSize: 15),),
                  ],
                ),
                Row(
                  children: [
                    Text('$_totalRecharge', style: TextStyle(color: Colors.white, fontSize: 25),),
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
                    Text('기간별 조회', style: TextStyle(color: Colors.white, fontSize: 15),),
                    Row(
                      children: [
                        ElevatedButton(onPressed: (){}, child: Text('최근 1개월')),
                        ElevatedButton(onPressed: (){}, child: Text('최근 3개월')),
                      ],
                    )
                  ],
                )
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future<List<Widget>> _pointsDetails() async {
    var userDocRef = fs.collection('userList').doc(_userId);
    _totalRecharge = 0;
    var querySnapshot = await userDocRef.collection('point').limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      var firstPointDocument = querySnapshot.docs.first;

      var list = <Widget>[];

      var pointsDetailsRef = firstPointDocument.reference.collection('points_details');
      var pointsDetailsQuerySnapshot = await pointsDetailsRef.orderBy('date', descending: true).get();
      pointsDetailsQuerySnapshot.docs.forEach((pointDetailDocument) {
        var pointDetailData = pointDetailDocument.data();
        var type = pointDetailData['type'];
        int amount = pointDetailData['amount'].toInt();
        var date = pointDetailData['date'];

        if(type == '충전') {
          _totalRecharge += amount;
        }

        var listItem = Container(
          margin: EdgeInsets.only(bottom: 20),
          child: ListTile(
            title: Text(type, style: TextStyle(color: Colors.black54),),
            subtitle: Text(NumberFormat.decimalPattern().format(amount), style: TextStyle(fontSize: 20, color: Colors.black),),
            trailing: Text(DateFormat('yyyy-MM-dd').format(date.toDate())),
            // 다른 필드 및 스타일을 추가할 수 있습니다.
          )
        );
        list.add(listItem);
      });
      return list;
    } else {
      return [Container()];
    }
  }
}
