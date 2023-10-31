import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DonationList extends StatefulWidget {

  DocumentSnapshot artistDoc;

  DonationList({required this.artistDoc});
  @override
  State<DonationList> createState() => _DonationListState();
}

class _DonationListState extends State<DonationList> {
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();
  FirebaseFirestore fs = FirebaseFirestore.instance;
  Map<String,dynamic>? artistData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _artistDonationList();
  }

  void _artistDonationList() async{
    DocumentSnapshot artistSnap = await fs.collection("artist").doc(widget.artistDoc.id).get();
    if(artistSnap.exists){
      artistData = artistSnap.data() as Map<String,dynamic>;
    }else{
      artistData = {};
    }
  }

  Future<Widget> _donationList() async {
    QuerySnapshot artistSnap =
    await fs.collection("artist").doc(widget.artistDoc.id).collection("donation_details").get();

    List<TableRow> tableRows = [];

    for (int index = 0; index < artistSnap.docs.length; index++) {
      Map<String, dynamic> _artistData = artistSnap.docs[index].data() as Map<String, dynamic>;
      var userId = _artistData['user'];

      var userSnap = await fs.collection("userList").doc(userId).get();
      Map<String, dynamic> userData = userSnap.data() as Map<String, dynamic>;

      var imgSnap = await fs.collection("userList").doc(userId).collection("image").get();
      var imgData = imgSnap.docs.first;

      Timestamp timeStamp = _artistData['date'];
      DateTime date = timeStamp.toDate();
      String formattedDate = DateFormat('yyyy-MM-dd').format(date) + '\n' + DateFormat('HH:mm').format(date);

      tableRows.add(
        TableRow(
          children: [
            Center(child: TableCell(child: Text(formattedDate))),
            Center(child: TableCell(child: Text(userData['nick']))),
            Center(child: TableCell(child: Text(_numberFormat.format(_artistData['amount'])))),
            TableCell(child: Text(_artistData['message'])),
          ],
        ),
      );
    }

    return Table(
      border: TableBorder(bottom: BorderSide(color: Colors.black12)),
      children: tableRows,
    );
  }
  @override
  Widget build(BuildContext context) {
    print(artistData?['artistName']);
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
                      Image.asset("assets/point.png",width: 20,),
                      Text(artistData != null? _numberFormat.format(artistData!['donationAmount']) : "0"),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("내역",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                        Text("(유효기간 5년)",style: TextStyle(fontSize: 13),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Table(
              children: <TableRow>[
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]), // 헤더의 배경색 지정
                  children: <Widget>[
                    Center(child: Text('날짜', style: TextStyle(fontWeight: FontWeight.bold))),
                    Center(child: Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold))),
                    Center(child: Text('금액', style: TextStyle(fontWeight: FontWeight.bold))),
                    Center(child: Text('메시지', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ]
          ),
          FutureBuilder(
              future: _donationList(), builder: (context, snapshot) => snapshot.data ?? Container()
          )
        ],
      ),
    );
  }
}
