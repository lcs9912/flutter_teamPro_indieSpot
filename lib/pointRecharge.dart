import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/payment.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PointRecharge extends StatefulWidget {
  const PointRecharge({super.key});

  @override
  State<PointRecharge> createState() => _PointRechargeState();
}

class _PointRechargeState extends State<PointRecharge> {
  String? _userId;
  int? _pointBalance = 0;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  final _rechargeControl = TextEditingController();
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();
  final List<int> _price = [1000 ,5000,10000];

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
    _rechargeControl.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
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
          '포인트 충전',
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
                  _sizedBox1(),
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
                if(_rechargeControl.text == '0' || _rechargeControl.text == '' || _rechargeControl.text == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('충전할 포인트를 입력해주세요'), behavior: SnackBarBehavior.floating,));
                } else {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(_rechargeControl.text),));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('결제 방법 선택', style: TextStyle(fontSize: 20),),
                  Icon(Icons.keyboard_arrow_right, size: 25,),
                ],
              ),
            ),
            )
          ],
        ),
      )
    );
  }

  Container _container3(){
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('인디 스팟 포인트 구매 안내', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
          Text('·구매한 인디 스팟 포인트의 유효기간은 마지막 사용일로부터 5년 까지 입니다.'),
          Text('·인디 스팟 포인트 보유/구매/사용내역은 마이페이지에서 확인하실 수 있습니다.'),
          Text('·정당한 이유 없이 반복하여 환불을 신쳥할 경우 결제수단을 남용하는 경우에 해당하여 환불이 제한될 수 있습니다.'),
          Text('·미성년자가 결제할 경우 법정대리인이 동의 하지 아니하면 본인 또는 법정대리인은 계약을 취소할 수 있습니다.'),
        ],
      ),
    );
  }

  Container _container2(){
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:MainAxisAlignment.spaceBetween,
        children: [
          for(int price in _price)
            Container(
              child: ElevatedButton(
                  onPressed: (){
                    if(_rechargeControl.text == '') _rechargeControl.text = '0';
                    setState(() {
                      _rechargeControl.text = _numberFormat.format(price + int.parse(_rechargeControl.text.replaceAll(',', '') ?? '0'));
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white),
                      elevation: MaterialStatePropertyAll(0),
                      shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: Color(0xFF392F31))
                          )
                      )
                  ),
                  child: Text("+${_numberFormat.format(price)}", style: TextStyle(color: Colors.black),)
              ),
            ),
            ElevatedButton(
              onPressed: (){
                if(_rechargeControl.text == '') _rechargeControl.text = '0';
                setState(() {
                  _rechargeControl.text = _numberFormat.format(50000 + int.parse(_rechargeControl.text.replaceAll(',', '')));
                });
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.white),
                  elevation: MaterialStatePropertyAll(0),
                  shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFF392F31))
                      )
                  )
              ),
              child: Text("+50,000", style: TextStyle(color: Colors.black),)
            ),
        ],
      ),
    );
  }

  Container _container1(){
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 10),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 130, child: Text('충전할 포인트', style: TextStyle(fontSize: 17, color: Colors.black54, fontWeight: FontWeight.bold))),
          Expanded(child: TextField(
            controller: _rechargeControl,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 25),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero
              ),
              suffix: Text('P', style: TextStyle(fontSize: 20),),
            ),
            onChanged: (value) {
              // 입력값이 변경될 때마다 서식을 적용하여 업데이트
              if (value.isNotEmpty) {
                final plainNumber = _numberFormat.parse(value);
                _rechargeControl.text = _numberFormat.format(plainNumber);
                _rechargeControl.selection = TextSelection.fromPosition(TextPosition(offset: _rechargeControl.text.length));
              }
            },
          ))
        ]
      ),
    );
  }

  Container _sizedBox1() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('현재 잔액', style: TextStyle(fontSize: 17, color: Colors.black54, fontWeight: FontWeight.bold)),
          RichText(
            text: TextSpan(
              text: NumberFormat.decimalPattern().format(_pointBalance),
              style: TextStyle(
                fontSize: 25,
                color: Colors.black54,
              ),
              children: <TextSpan>[
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
}
