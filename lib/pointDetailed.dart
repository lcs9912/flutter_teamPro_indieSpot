import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/pointExchange.dart';
import 'package:indie_spot/pointHistory.dart';
import 'package:indie_spot/pointRecharge.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PointDetailed extends StatefulWidget {
  const PointDetailed({super.key});

  @override
  State<PointDetailed> createState() => _PointDetailedState();
}

class _PointDetailedState extends State<PointDetailed> {
  String? _userId;
  int? _pointBalance = 0;
  FirebaseFirestore fs = FirebaseFirestore.instance;

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
      backgroundColor: Colors.white,
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
        backgroundColor: Color(0xFF233067),
        centerTitle: true,
        title: Text(
          '포인트',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          // 총 포인트 섹션
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1, color: Colors.black26),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text('총 포인트', style: TextStyle(fontSize: 15)),
                ),
                RichText(
                  text: TextSpan(
                    text: NumberFormat.decimalPattern().format(_pointBalance),
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'P',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _sizedBox(),
          // 포인트 내역 섹션
          Container(
            padding: EdgeInsets.only(top: 10),
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border(top: BorderSide(width: 1, color: Colors.black26))),
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
                    children: snapshot.data ?? [Container()],
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

  SizedBox _sizedBox() {
    return SizedBox(
      height: 95,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PointRecharge(),));
              },
              child: Column(
                children: [
                  Icon(
                    Icons.monetization_on, size: 40, color: Color(0xFF392F31),),
                  SizedBox(height: 10,),
                  Text('충전',
                    style: TextStyle(fontSize: 17, color: Color(0xFF392F31)),)
                ],
              )
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PointExchange(),)).then((value) => setState((){}));
              },
              child: Column(
                children: [
                  Icon(Icons.autorenew, size: 40, color: Color(0xFF392F31),),
                  SizedBox(height: 10,),
                  Text('환전',
                    style: TextStyle(fontSize: 17, color: Color(0xFF392F31)),)
                ],
              )
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PointHistory(),));
              },
              child: Column(
                children: [
                  Icon(Icons.list_alt, size: 40, color: Color(0xFF392F31),),
                  SizedBox(height: 10,),
                  Text('내역',
                    style: TextStyle(fontSize: 17, color: Color(0xFF392F31)),)
                ],
              )
          ),
        ],
      ),
    );
  }

  Future<List<Widget>> _pointsDetails() async {
    var userDocRef = fs.collection('userList').doc(_userId);

    var querySnapshot = await userDocRef.collection('point').limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      var firstPointDocument = querySnapshot.docs.first;

      var list = <Widget>[];

      var pointsDetailsRef = firstPointDocument.reference.collection('points_details');
      var pointsDetailsQuerySnapshot = await pointsDetailsRef.orderBy('date', descending: true).limit(5).get();
      pointsDetailsQuerySnapshot.docs.forEach((pointDetailDocument) {
        var pointDetailData = pointDetailDocument.data();
        var type = pointDetailData['type'];
        var amount = pointDetailData['amount'];
        var date = pointDetailData['date'];

        var listItem = Container(
          margin: EdgeInsets.only(bottom: 20),
          child: ListTile(
            title: Text(type, style: TextStyle(color: Colors.black54),),
            subtitle: Text(NumberFormat.decimalPattern().format(amount), style: TextStyle(fontSize: 20, color: Colors.black),),
            trailing: Text(DateFormat('yyyy-MM-dd').format(date.toDate())),
            // 다른 필드 및 스타일을 추가할 수 있습니다.
          ),
        );

        list.add(listItem);
      });
      return list;
    } else {
      return [Container()];
    }
  }
}