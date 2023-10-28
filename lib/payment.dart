import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/payment.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Payment extends StatefulWidget {
  final String payment;
  const Payment(this.payment, {super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String? _userId;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  int? _pointBalance;
  int? _amountPayment;

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
    int num = int.parse(widget.payment.replaceAll(',', ''));
    _amountPayment = (num + (num/10)).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
          '결제',
          style: TextStyle(color: Colors.black),
        ),
      ),
        body: Container(
          child: ListView(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(30, 30, 30, 50),
                child: Column(
                  children: [
                    _container1(),
                    _container2(),
                  ],
                ),
              ),
              _container3()
            ],
          ),
        ),
      bottomNavigationBar: MyBottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Row(
          children: [
            Expanded(child: ElevatedButton(
              style: ButtonStyle(
                  minimumSize: MaterialStatePropertyAll(Size(0, 58)),
                  backgroundColor: MaterialStatePropertyAll(Color(0xFF392F31)),
                  elevation: MaterialStatePropertyAll(0),
                  shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero
                      )
                  )
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start  ,
                children: [
                  Icon(Icons.keyboard_arrow_left, size: 25,),
                  Text('뒤로', style: TextStyle(fontSize: 20),),
                ],
              ),
            ),
            )
          ],
        ),
      )
    );
  }

  Container _container3() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('결제 방법 선택', style: TextStyle(fontSize: 17, color: Colors.black54,),)
          ],
        ),
      ),
    );
  }

  Container _container2() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('충전 후 잔액', style: TextStyle(fontSize: 17, color: Colors.black54, fontWeight: FontWeight.bold)),
          RichText(
            text: TextSpan(
              text: '+${widget.payment} ',
              style: TextStyle(
                fontSize: 17,
                color: Colors.black54,
              ),
              children: <InlineSpan>[
                WidgetSpan(
                  child: Icon(Icons.arrow_forward, color: Colors.black54, size: 20,),
                ),
                TextSpan(
                  text: ' ${NumberFormat.decimalPattern().format((int.parse(widget.payment.replaceAll(',', '')) + _pointBalance!))}',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black54,
                  ),
                ),
                TextSpan(
                  text: ' 포인트',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _container1() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('결제될 금액', style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold)),
          RichText(
            text: TextSpan(
              text: NumberFormat.decimalPattern().format(_amountPayment),
              style: TextStyle(
                fontSize: 25,
                color: Colors.black54,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: ' 원',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}