import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/loading.dart';
import 'package:indie_spot/pointDetailed.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'package:get/get.dart';

class ExchangeInformation extends StatefulWidget {
  final String point;
  const ExchangeInformation(this.point, {super.key});

  @override
  State<ExchangeInformation> createState() => _ExchangeInformationState();
}

class _ExchangeInformationState extends State<ExchangeInformation> {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  final _name = TextEditingController(); //이름
  final _juminbeonho = TextEditingController(); //주민번호
  final _phone = TextEditingController(); //전화번호
  final _bankName = TextEditingController(); // 은행이름
  final _accountHolder = TextEditingController(); //예금주
  final _accountNumber = TextEditingController(); //계좌번호

  bool _chackText() {
    if (_name.text == '') {
      // 이름이 공백이거나 널인 경우에 대한 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이름을 입력해주세요')));
      return false;
    }

    if (_juminbeonho.text == '') {
      // 주민번호가 공백이거나 널인 경우에 대한 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('주민번호를 입력해주세요')));
      return false;
    }

    if (_phone.text == '') {
      // 전화번호가 공백이거나 널인 경우에 대한 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('전화번호를 입력해주세요')));
      return false;
    }

    if (_bankName.text == '') {
      // 은행 이름이 공백이거나 널인 경우에 대한 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('은행 이름을 입력해주세요')));
      return false;
    }

    if (_accountHolder.text == '') {
      // 예금주 이름이 공백이거나 널인 경우에 대한 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('예금주 이름을 입력해주세요')));
      return false;
    }

    if (_accountNumber.text == '') {
      // 계좌번호가 공백이거나 널인 경우에 대한 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('계좌번호를 입력해주세요')));
      return false;
    }
    return true;
  }

  Future<void> _addExchange() async {
    var collection1 = fs.collection('userList').doc(Provider.of<UserModel>(context, listen: false).userId).collection('point');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoadingWidget();
      },
      barrierDismissible: false, // 사용자가 화면을 탭해서 닫는 것을 막습니다.
    );

    try {
      QuerySnapshot snapshot = await collection1.limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        String documentId = snapshot.docs.first.id;
        Map<String, dynamic> pointData = snapshot.docs.first.data() as Map<String, dynamic>;

        int currentPointBalance = pointData['pointBalance'] as int;
        int deductedPoint = int.tryParse(widget.point.replaceAll(',', '')) ?? 0;

        if (currentPointBalance >= deductedPoint) {
          int newPointBalance = currentPointBalance - deductedPoint;

          await collection1.doc(documentId).update({
            'pointBalance': newPointBalance,
          });

          var exchangeCollection = snapshot.docs.first.reference.collection('exchange');
          await exchangeCollection.add({
            'name': _name.text,
            'juminbeonho': _juminbeonho.text,
            'phone': _phone.text,
            'bankName': _bankName.text,
            'accountHolder': _accountHolder.text,
            'accountNumber': _accountNumber.text,
            'point': widget.point,
            'acceptYn': 'y'
          });

          var pointsDetailscollection = snapshot.docs.first.reference.collection('points_details');
          await pointsDetailscollection.add({
            'amount' : int.tryParse(widget.point.replaceAll(',', '')),
            'date' : FieldValue.serverTimestamp(),
            'type' : '출금',
          });

          if (!context.mounted) return;
          Get.off(
              () => PointDetailed(),
              transition: Transition.noTransition
          );
        } else {
          // 사용자가 교환을 위한 충분한 포인트를 가지고 있지 않을 때 처리
          print('교환을 위한 포인트가 부족합니다.');
        }
      } else {
        print('사용자 문서를 찾을 수 없습니다.');
      }
    } catch (error) {
      print('오류: $error');
      // 필요한 대로 오류를 처리하세요.
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: _appBar(),
      body: ListView(
        children: [
          _TextField('이름', '이름을 입력해주세요', _name),
          _TextField2('주민등록번호', '주민등록번호를 입력해주세요', _juminbeonho),
          _TextField3('휴대폰 번호', '휴대폰 번호를 입력해주세요', _phone),
          _TextField('은행 이름', '은행 이름을 입력해주세요', _bankName),
          _TextField('예금주 이름', '예금주 이름을 입력해주세요', _accountHolder),
          _TextField('계좌번호', '계좌번호를 입력해주세요', _accountNumber),
          SizedBox(height: 70,),
          Row(
            children: [
              Expanded(child: ElevatedButton(
                style: ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(Size(0, 48)),
                    backgroundColor: MaterialStatePropertyAll(Color(0xFF233067)),
                    elevation: MaterialStatePropertyAll(0),
                    shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero
                        )
                    )
                ),
                onPressed: () {
                  if(_chackText()){
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        title: Text('환전 신청 정보'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 120,child: Text('환전금액')),
                                Expanded(child: Text('${widget.point}원')),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 120,child: Text('이름')),
                                Expanded(child: Text('${_name.text}')),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 120,child: Text('주민등록번호')),
                                Expanded(child: Text('${_juminbeonho.text}')),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 120,child: Text('전화번호')),
                                Expanded(child: Text('${_phone.text}')),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 120,child: Text('은행 이름')),
                                Expanded(child: Text('${_bankName.text}')),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 120,child: Text('예금주 이름')),
                                Expanded(child: Text('${_accountHolder.text}')),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 120,child: Text('계좌번호')),
                                Expanded(child: Text('${_accountNumber.text}')),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소', style: TextStyle(color: Color(0xFF233067)),)),
                          TextButton(onPressed: (){
                            _addExchange();
                            Navigator.of(context).pop();
                          }, child: Text('신청', style: TextStyle(color: Color(0xFF233067)),)),
                        ],
                      );
                    },);
                  }
                },
                child: Text('환전신청 ', style: TextStyle(fontSize: 17),),
              ),)
            ],
          )
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  String _addHyphensToPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 11) {
      return phoneNumber.replaceFirstMapped(
          RegExp(r'(\d{3})(\d{4})(\d{4})'),
              (match) => '${match[1]}-${match[2]}-${match[3]}');
    } else {
      return phoneNumber; // 유효하지 않은 입력
    }
  }

  Container _TextField3(String title, String hint, TextEditingController control) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
        children: [
          Text('$title'),
          SizedBox(height: 10),
          SizedBox(
            height: 35,
            child: TextField(
              maxLength: 13,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
              controller: control,
              cursorColor: Color(0xFF233067),
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF233067)),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF233067))
                  ),
                  contentPadding: EdgeInsets.only(left: 10),
                  hintText: '$hint',
                  hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(),
                  counterText: ''
              ),
              onChanged: (value){
                _phone.text = _addHyphensToPhoneNumber(value);
              },
            ),
          )
        ],
      ),
    );
  }

  String _addHyphenToNumber(String input) {
    if (input.length == 13) {
      return input.substring(0, 6) + '-' + input.substring(6);
    } else {
      return input; // 유효하지 않은 입력
    }
  }

  Container _TextField2(String title, String hint, TextEditingController control) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
        children: [
          Text('$title'),
          SizedBox(height: 10),
          SizedBox(
            height: 35,
            child: TextField(
              maxLength: 14,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
              ),
              controller: control,
              cursorColor: Color(0xFF233067),
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF233067)),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF233067))
                  ),
                contentPadding: EdgeInsets.only(left: 10),
                hintText: '$hint',
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(),
                counterText: ''
              ),
              onChanged: (value){
                _juminbeonho.text = _addHyphenToNumber(value);
              },
            ),
          )
        ],
      ),
    );
  }

  Container _TextField(String title, String hint, TextEditingController control) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 수직 가운데 정렬 설정
        children: [
          Text('$title'),
          SizedBox(height: 10),
          Container(
            height: 35,
            child: TextField(
              style: TextStyle(
                  fontWeight: FontWeight.w500
              ),
              controller: control,
              cursorColor: Color(0xFF233067),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF233067)),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF233067))
                ),
                contentPadding: EdgeInsets.only(left: 10),
                hintText: '$hint',
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
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
        '정보입력',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
