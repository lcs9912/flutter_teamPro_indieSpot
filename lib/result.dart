import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/concertDetails.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Result extends StatelessWidget {
  bool getIsSuccessed(Map<String, String> result) {
    if (result['imp_success'] == 'true') {
      return true;
    }
    if (result['success'] == 'true') {
      return true;
    }
    return false;
  }

  Future<void> updatePoint(Map<String, String> result, context) async{
    FirebaseFirestore fs = FirebaseFirestore.instance;
    String? userId = Provider.of<UserModel>(context, listen: false).userId;
    QuerySnapshot querySnapshot = await fs.collection('userList').doc(userId).collection('point').limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      // 첫 번째 문서 참조 가져오기
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      int pointBalance = data!['pointBalance'];
      // 업데이트할 데이터
      Map<String, dynamic> updateData = {
        'pointBalance': pointBalance + int.parse(result['paid_amount']!), // 업데이트할 필드 이름과 값
      };

      fs.collection('userList').doc(userId).collection('point').doc(documentSnapshot.id).collection('points_details').add({
        'amount': int.parse(result['paid_amount']!),
        'date': FieldValue.serverTimestamp(),
        'type': '충전',
        'merchantUid': result['merchant_uid'],
      });
      
      await documentSnapshot.reference.update(updateData);
    } else {
    }
  }


  @override
  Widget build(BuildContext context) {
    Map<String, String> result = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    bool isSuccessed = getIsSuccessed(result);
    print(result);

    if(isSuccessed) {
      updatePoint(result, context);
    }

    return Scaffold(
      appBar: new AppBar(
        title: Text('아임포트 결과'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isSuccessed ? '결제 성공' : '결제 실패',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 50.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 4,
                          child: Text('결제 금액', style: TextStyle(color: Colors.grey))
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(NumberFormat.decimalPattern().format(int.parse(result['paid_amount'] ?? '0')) ?? '-'),
                      ),
                    ],
                  ),
                ),
                isSuccessed ? Container(
                  padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 4,
                          child: Text('주문 번호', style: TextStyle(color: Colors.grey))
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(result['merchant_uid'] ?? '-'),
                      ),
                    ],
                  ),
                ) : Container(
                  padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text('에러 메시지', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(result['error_msg'] ?? '-'),
                      ),
                    ],
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

