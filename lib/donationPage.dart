import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/userModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DonationPage extends StatefulWidget {

  DocumentSnapshot document;
  DonationPage({required this.document});
  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _donationAmount = TextEditingController();
  final TextEditingController _donationMessage = TextEditingController();
  final TextEditingController _donationUser = TextEditingController();
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();
  String? _userId;
  String amount = "";
  String _hintText = "후원할 금액을 입력하세요";
  String _hintText2 = "후원과 함께 보낼 메세지를 입력하세요";
  Map<String, dynamic>? userPoint;
  final List<int> _price = [1000 ,5000,10000];
  Map<String, dynamic>? userData;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
      Navigator.pop(context);
    } else {
      _userId = userModel.userId;
      print(_userId);
      pointBalanceSearch().then((value) => _donationUser.text = userData?['nick']);
      print(widget.document.id);
    }
  }
  Future<void> pointBalanceSearch() async {
    DocumentSnapshot userSnapshot = await fs.collection('userList').doc(_userId).get();
    if (userSnapshot.exists) {
      setState(() {
        userData = userSnapshot.data() as Map<String,dynamic>;
      });
      QuerySnapshot pointSnapshot = await fs.collection('userList').doc(_userId).collection("point").get();
      if(pointSnapshot.docs.isNotEmpty){
        setState(() {
          userPoint = pointSnapshot.docs.first.data() as Map<String, dynamic>;
        });
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    print(userData?['nick']);
    print(userPoint?['pointBalance']);
    return Scaffold(
      appBar: AppBar(

      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: [
                      Text("보유 포인트 : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                      Text(_numberFormat.format((userPoint?['pointBalance']) ?? 0)),
                    ],
                  ),
                ),
                Text("후원 금액" ,style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                TextField(
                  controller: _donationAmount,
                  keyboardType: TextInputType.number,
                  onTap: (){
                    setState(() {
                      amount = "원";
                      _hintText = "";
                    });
                  },
                  onChanged: (value) {
                    // 입력값이 변경될 때마다 서식을 적용하여 업데이트
                    if (value.isNotEmpty) {
                      final plainNumber = _numberFormat.parse(value);
                      _donationAmount.text = _numberFormat.format(plainNumber);
                      _donationAmount.selection = TextSelection.fromPosition(TextPosition(offset: _donationAmount.text.length));
                    }
                  },

                  onEditingComplete: () {
                    // 텍스트 필드가 포커스를 잃은 경우
                    if (_donationAmount.text.isNotEmpty) {
                      setState(() {
                        amount = "원"; // 힌트 텍스트 다시 설정
                      });
                    }
                  },
                  decoration: InputDecoration(hintText: _hintText,suffix: Text(amount), border: OutlineInputBorder()),
                ),
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                 children: [
                   for(int price in _price)
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: ElevatedButton(
                           onPressed: (){
                             setState(() {
                               _donationAmount.text = _numberFormat.format(price);
                               amount = "원";
                             });
                           },
                           child: Text("+${_numberFormat.format(price)}")
                       ),
                     ),
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: ElevatedButton(
                         onPressed: (){},
                         child: Text("전액")
                     ),
                   )
                 ],
                ),
                Text("후원 메세지",style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: _donationMessage,
                      maxLines: null,
                      decoration: InputDecoration(
                          hintText: _hintText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black38, // 비활성 상태 보더 색상 설정
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue, // 활성 상태 보더 색상 설정
                            ),
                          ),
                          isCollapsed: true,
                          contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 100)
                      ),
                    ),
                  ),
                ),
                Text("후원자명 : ${userData?['nick']}",style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _donationUser,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          child: ElevatedButton(
            onPressed: (){

            },
            child: Text("후원하기"),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // 모서리를 없애는 부분
              ),
            ),
          ),
        ),
      ),
    );
  }
}
