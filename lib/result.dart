import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/concertDetails.dart';
import 'package:indie_spot/pointDetailed.dart';
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

  Future<void> updatePoint(Map<String, String> result, Map<String, String> info, context) async{
    FirebaseFirestore fs = FirebaseFirestore.instance;
    String? userId = Provider.of<UserModel>(context, listen: false).userId;
    QuerySnapshot querySnapshot = await fs.collection('userList').doc(userId).collection('point').limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      // 첫 번째 문서 참조 가져오기
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      int pointBalance = data!['pointBalance'];
      // 업데이트할 데이터
      int point = int.parse(info['point']!.replaceAll(',', ''));

      Map<String, dynamic> updateData = {
        'pointBalance': pointBalance + point, // 업데이트할 필드 이름과 값
      };

      fs.collection('userList').doc(userId).collection('point').doc(documentSnapshot.id).collection('points_details').add({
        'amount': point,
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
    List<Map<String, String>> results = ModalRoute.of(context)?.settings.arguments as List<Map<String, String>>;
    Map<String, String> result = results[0];
    Map<String, String> info = results[1];
    bool isSuccessed = getIsSuccessed(result);
    print(info);

    if(isSuccessed && info['point'] != null) {
      updatePoint(result, info, context);
    }

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
        backgroundColor: Colors.white,
        centerTitle: true,
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
        title: Text(
          '',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          _container(context, isSuccessed),
          if(isSuccessed)
            _container2(result, info)
        ],
      )
    );
  }

  Container _container2(result, info) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 20, bottom: 10),
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: Colors.black)),
                    ),
                    child: Text('결제정보', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  )
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 30, bottom: 15, right: 30),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: Colors.black26)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('결제방법', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
                        Text('결제방법', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54))
                      ],
                    )
                  )
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: 30, bottom: 15, right: 30),
                      margin: EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1, color: Colors.black26)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('주문번호', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
                          Text(result['merchant_uid'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54))
                        ]
                      )
                  )
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: 30, bottom: 15, right: 30),
                      margin: EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1, color: Colors.black26)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('결제금액', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
                          Text("${NumberFormat.decimalPattern().format(int.parse(info['paid_amount']))}원", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54))
                        ],
                      )
                  )
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: 30, bottom: 15, right: 30),
                      margin: EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1, color: Colors.black26)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('충전 포인트', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
                          Text("${info['point']}P", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54))
                        ],
                      )
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container _container(BuildContext context, bool isSuccessed){
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 20),
       padding: EdgeInsets.fromLTRB(40, 60, 40, 40),
       child: Column(
         children: [
           Container(
             padding: EdgeInsets.only(bottom: 30, left: 50, right: 50),
             decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 1))),
             margin: EdgeInsets.only(bottom: 40),
             child: Column(
               children: [
                 Text(isSuccessed ? '결제가 완료되었습니다.' : '결제가 실패되었습니다.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                 Text(isSuccessed ? '이용해주셔서 감사합니다.' : '다시 시도해주세요', style: TextStyle(fontSize: 20)),
               ],
             ),
           ),
           ElevatedButton(
             style: ButtonStyle(
               backgroundColor: MaterialStatePropertyAll(Color(0xFF392F31)),
               shape: MaterialStatePropertyAll(
                 RoundedRectangleBorder(
                   borderRadius: BorderRadius.zero
                 )
               ),
             ),
             onPressed: (){
               Navigator.of(context).push(MaterialPageRoute(builder: (context) => PointDetailed(),));
             },
             child: Container( padding: EdgeInsets.all(15),child: Text('마이포인트 바로가기'))
           )
         ],
       ),
    );
  }
}

