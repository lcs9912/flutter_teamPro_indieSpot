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
  QueryDocumentSnapshot? artistImg;
  String? _selectedItem;
  int _num = 30;
  List<String> _items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _artistDonationList();
    DateTime currentDate = DateTime.now();
    _selectedItem = '      전체';
    DateTime lastYear = currentDate.subtract(const Duration(days: 365));

    // 중복 항목을 방지하기 위한 Set을 사용합니다.
    Set<String> uniqueMonths = {};

    while (currentDate.isAfter(lastYear)) {
      String all = "      전체";
      uniqueMonths.add(all);
      String month = '${currentDate.year}년 ${currentDate.month}월';
      uniqueMonths.add(month);
      currentDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day);
    }

    // Set을 리스트로 변환합니다.
    _items = uniqueMonths.toList();
  }

  void _artistDonationList() async{
    DocumentSnapshot artistSnap = await fs.collection("artist").doc(widget.artistDoc.id).get();
    if(artistSnap.exists){
      setState(() {
        artistData = artistSnap.data() as Map<String,dynamic>;
      });
      QuerySnapshot artistImgSnap = await fs.collection("artist").doc(widget.artistDoc.id).collection("image").get();
      if(artistImgSnap.docs.isNotEmpty){
        setState(() {
          artistImg = artistImgSnap.docs.first;
        });
      }
    }else{
      artistData = {};
    }
  }

  Future<Widget> _donationList(sMonth) async {
    QuerySnapshot artistSnap;
    if(sMonth == "      전체") {
      artistSnap =
      await fs
          .collection("artist")
          .doc(widget.artistDoc.id)
          .collection("donation_details")
          .orderBy("date", descending: true)
          .get();
    }else{
      String strippedInput = sMonth.replaceAll('년', '').replaceAll('월', '');
      List<String> parts = strippedInput.split(' ');

      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);

      DateTime selectedDate = DateTime(year, month); // 선택한 월 (예: 2023년 10월)
      DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      DateTime lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).add(Duration(days: 1));

      artistSnap =
      await fs
          .collection("artist")
          .doc(widget.artistDoc.id)
          .collection("donation_details")
          .orderBy("date", descending: true)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
          .get();
    }
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
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      String formattedHour = DateFormat('HH:mm').format(date);

      tableRows.add(
        TableRow(
          children: [
            TableCell(child: Container(
              height: 50,
              child: Center(child: Container(
                height: 50,
                child: Column(
                  children: [
                    Text(formattedDate),
                    Text(formattedHour)
                  ],
                ),
              )),
            )),
            TableCell(child: Container(height : 50 ,child: Center(child: Text(userData['nick'])))),
            TableCell(child: Container(height : 50 ,child: Center(child: Text(_numberFormat.format(_artistData['amount']))))),
            TableCell(child: Container(
              height: 50,
              child: Center(
                child: TextButton(onPressed: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 0.0,
                        backgroundColor: Colors.white,
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 330,
                                height: 45,
                                color: Colors.black12,
                                child:Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 13, 0, 0),
                                  child: Text("알림",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 20, 20, 0),
                                child: Text(_artistData['message']),
                              ),

                              Container(
                                color: Colors.black12,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 5, 4, 5),
                                      child: ElevatedButton(
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("닫기")
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }, child: Text("보기")),
              ),
            )),
          ],
        ),
      );
    }

    return Expanded( 
      child: ListView(
        children: [Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder(bottom: BorderSide(color: Colors.black12)),
            children: tableRows,
          ),
        ),],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    print("zz : ${artistImg?['path']}");
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          artistImg != null?
          Image.network(artistImg?['path']
            ,width: double.infinity,
            height: 200,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,) : Container(),
          Center(
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
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text("내역",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                            Text("(유효기간 1년)",style: TextStyle(fontSize: 13),),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          height: 30,
                          padding: const EdgeInsets.only(left: 3),
                          decoration: BoxDecoration(

                          ),
                          child: DropdownButton<String>(
                            underline: Container(),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                            value: _selectedItem,
                            items: _items.map((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Container(
                                  child: Text(item),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _num = 0;
                                _selectedItem = value!;
                              });
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
                children: <TableRow>[
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]), // 헤더의 배경색 지정
                    children: <Widget>[
                      Container(
                        height: 50,
                        child: Center(child: Text('날짜', style: TextStyle(fontWeight: FontWeight.bold)))
                      ),
                      Container(
                          height: 50,
                          child: Center(child: Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold)))
                      ),
                      Container(
                          height: 50,
                          child: Center(child: Text('금액', style: TextStyle(fontWeight: FontWeight.bold)))
                      ),
                      Container(
                          height: 50,
                          child: Center(child: Text('메시지', style: TextStyle(fontWeight: FontWeight.bold)))
                      ),
                    ],
                  ),
                ]
            ),
          ),
          FutureBuilder(
              future: _donationList(_selectedItem), builder: (context, snapshot) => snapshot.data ?? Container()
          )
        ],
      ),
    );
  }
}
