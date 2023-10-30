import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class DonationList extends StatefulWidget {

  DocumentSnapshot artistDoc;

  DonationList({required this.artistDoc});
  @override
  State<DonationList> createState() => _DonationListState();
}

class _DonationListState extends State<DonationList> {
  @override
  Widget build(BuildContext context) {
    print("id : ${widget.artistDoc.id}");
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            child: Center(
              child: Column(
                children: [
                  Text("정산 가능 금액", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/point.png"),
                      Text("40000")
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
