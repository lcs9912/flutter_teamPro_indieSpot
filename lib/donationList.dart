import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'baseBar.dart';

class DonationList extends StatefulWidget {

  final String artistId;

  DonationList({required this.artistId});
  @override
  State<DonationList> createState() => _DonationListState();
}

class _DonationListState extends State<DonationList> {
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();
  FirebaseFirestore fs = FirebaseFirestore.instance;
  Map<String,dynamic>? artistData;
  QueryDocumentSnapshot? artistImg;
  String? _selectedItem;
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
    DocumentSnapshot artistSnap = await fs.collection("artist").doc(widget.artistId).get();
    if(artistSnap.exists){
      setState(() {
        artistData = artistSnap.data() as Map<String,dynamic>;
      });
      QuerySnapshot artistImgSnap = await fs.collection("artist").doc(widget.artistId).collection("image").get();
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
          .doc(widget.artistId)
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
          .doc(widget.artistId)
          .collection("donation_details")
          .orderBy("date", descending: true)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
          .get();
    }
    List<TableRow> tableRows = [];

    for (var artistDoc in artistSnap.docs) {
      Map<String, dynamic> _artistData = artistDoc.data() as Map<String, dynamic>;
      var userId = _artistData['user'];

      // 병렬로 데이터 가져오기
      var userSnap = fs.collection("userList").doc(userId).get();

      // await을 사용하여 데이터를 가져올 때까지 기다립니다.
      Map<String, dynamic> userData = (await userSnap).data() as Map<String, dynamic>;

      Timestamp timeStamp = _artistData['date'];
      DateTime date = timeStamp.toDate();
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      String formattedHour = DateFormat('HH:mm').format(date);

      tableRows.add(
        TableRow(
          children: [
            TableCell(child: _buildTableCell(
                Column(
                  children: [
                    Text(formattedDate),
                    Text(formattedHour),
                  ],
                )
            )),
            TableCell(child: _buildTableCell(
                Center(child: Text(userData['nick']))
            )),
            TableCell(child: _buildTableCell(
                Center(child: Text(_numberFormat.format(_artistData['amount'])))
            )),
            TableCell(child: _buildTableCell(
              Center(
                child: TextButton(
                  onPressed: () => _showDialog(_artistData['message']),
                  child: Text("보기",style: TextStyle(color: Color(0xFF233067)),),
                ),
              ),
            )),
          ],
        ),
      );
    }
    return Expanded(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              children: tableRows,
            ),
          ),
        ],
      ),
    );
  }

// TableRow의 Cell을 생성하는 함수
  Widget _buildTableCell(Widget child) {
    return Container(
      height: 50,
      child: Center(child: child),
    );
  }

// Dialog를 표시하는 함수
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          child: SizedBox(
            height: 200,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("후원 메시지",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 80,
                          child: SingleChildScrollView(
                            child:
                              Text(message),
                          )
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text("닫기"),
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF233067))),
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
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          '받은 후원',
          style: TextStyle(color: Colors.white,),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(bottom: 38),
        child: Column(
          children: [
            artistImg != null?
            Image.network(artistImg?['path']
              ,width: double.infinity,
              height: 200,
              fit: BoxFit.contain,
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
            Table(
                children: <TableRow>[
                  TableRow(
                    decoration: BoxDecoration(color: Color(0xFF233067)), // 헤더의 배경색 지정
                    children: <Widget>[
                      Container(
                        height: 50,
                        child: Center(child: Text('날짜', style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold)))
                      ),
                      Container(
                          height: 50,
                          child: Center(child: Text('닉네임', style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold)))
                      ),
                      Container(
                          height: 50,
                          child: Center(child: Text('금액', style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold)))
                      ),
                      Container(
                          height: 50,
                          child: Center(child: Text('메시지', style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold)))
                      ),
                    ],
                  ),
                ]
            ),
            FutureBuilder(
                future: _donationList(_selectedItem), builder: (context, snapshot) => snapshot.data ?? Container()
            )
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
                _editDonationAmount();
                setState(() {
                  artistData?['donationAmount'] = 0;
                });
                //Navigator.of(context).push(MaterialPageRoute(builder: (context) => BuskingReservation.spot(widget._spotId, widget._data['spotName']),));
              },
              child: Text('정산하기', style: TextStyle(fontSize: 17),),
            ),)
          ],
        ),
      )
    );
  }

  Future<void> _editDonationAmount() async{
    DocumentSnapshot doc = await fs.collection('artist').doc(widget.artistId).get();
    int donationAmount = (doc.data() as Map<String, dynamic>)['donationAmount'] as int;
    String? userId = Provider.of<UserModel>(context, listen: false).userId;

    if (userId != null) {
      await fs.collection('artist').doc(widget.artistId).update({
        'donationAmount': 0,
      }).then((value) async {
        var docFirst = await fs.collection('userList').doc(userId).collection('point').limit(1).get();
        if (docFirst.docs.isNotEmpty) {
          int pointBalance = docFirst.docs.first.data()['pointBalance'];
          int updatedBalance = pointBalance + donationAmount; // donationAmount 더하기
          // Firestore에 업데이트
          await fs.collection('userList').doc(userId).collection('point').doc(docFirst.docs.first.id).update({
            'pointBalance': updatedBalance,
          });
        }
        await fs.collection('userList').doc(userId).collection('point').doc(docFirst.docs.first.id).collection('points_details').add({
          'type' : '정산',
          'date' : FieldValue.serverTimestamp(),
          'amount' : donationAmount
        });
      });
    }
  }
}
