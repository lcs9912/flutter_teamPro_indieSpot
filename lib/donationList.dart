import 'package:flutter/material.dart';

class DonationList extends StatefulWidget {

  @override
  State<DonationList> createState() => _DonationListState();
}

class _DonationListState extends State<DonationList> {
  @override
  Widget build(BuildContext context) {
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
                      Image.asset("assets/coin.png",width: 20,),
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
