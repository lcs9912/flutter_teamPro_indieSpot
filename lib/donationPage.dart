import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/donationArtistList.dart';
import 'package:indie_spot/userModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DonationPage extends StatefulWidget {

  final String artistId;

  DonationPage({required this.artistId});

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
  Map<String, dynamic> artistData = {};
  Map<String, dynamic>? artistImg;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  int amountInput = 1;
  int messageInput = 1;
  int userInput = 1;
  @override
  void initState(){
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
      Navigator.pop(context);
    } else {
      _userId = userModel.userId;
      pointBalanceSearch().then((value) => _donationUser.text = userData?['nick']);
      artistInfo();
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
      }else{userPoint = {};}
    } else {userData = {};}
  }

  Future<void> artistInfo() async {
    DocumentSnapshot artistSnapshot = await fs.collection('artist').doc(widget.artistId).get();
    if (artistSnapshot.exists) {
      setState(() {
        artistData = artistSnapshot.data() as Map<String,dynamic>;
      });
      QuerySnapshot imgSnapshot = await fs.collection('artist').doc(widget.artistId).collection("image").get();
      if(imgSnapshot.docs.isNotEmpty){
        setState(() {
          artistImg = imgSnapshot.docs.first.data() as Map<String, dynamic>;
        });
      }else{artistImg = {};}
    } else {artistData ={};}
  }
  void _updataDonation() async{
    String amount1 = _donationAmount.text.replaceAll(',', '');
    await Future.delayed(Duration(seconds: 1));
    int amount = artistData['donationAmount']+int.parse(amount1);
    FirebaseFirestore.instance.collection("artist").doc(widget.artistId).update({'donationAmount' : amount});
    int userPoint1 = userPoint?['pointBalance'] - int.parse(amount1);
    QuerySnapshot userPointSnap = await FirebaseFirestore.instance.collection("userList").doc(_userId).collection("point").get();
    DocumentSnapshot doc = userPointSnap.docs[0];
    FirebaseFirestore.instance.collection("userList").doc(_userId).collection("point").doc(doc.id).update({"pointBalance" : userPoint1});
    FirebaseFirestore.instance.collection("artist").doc(widget.artistId).collection("donation_details").add(
        {
          'amount' : int.parse(amount1),
          'user' : _userId,
          'message' : _donationMessage.text,
          'date' : FieldValue.serverTimestamp()
        }
    );
    FirebaseFirestore.instance.collection("userList").doc(_userId).collection("point").doc(doc.id).collection("points_details").add(
        {
          'amount' : int.parse(amount1),
          'date' : FieldValue.serverTimestamp(),
          'message' : _donationMessage.text,
          'artistId' : widget.artistId,
          'type' : "후원"
        }
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
          'DONATION',
          style: TextStyle(color: Colors.white,),
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: 200,
            child: artistImg != null && artistImg?['path'] != null
                ? Image.network(artistImg?['path'],fit: BoxFit.fill,)
                : Container(),
          ),
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
                Row(
                  children: [
                    Text("후원 금액 " ,style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    amountInput != 1? Text("필수입력사항",style: TextStyle(color: Colors.red,fontSize: 13),) : Container()
                  ],
                ),
                TextField(
                  controller: _donationAmount,
                  keyboardType: TextInputType.number,
                  onTap: (){
                    setState(() {
                      amount = "원";
                      _hintText = "";
                      amountInput = 1;
                    });
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      value = value.replaceAll(',', '');
                      final plainNumber = _numberFormat.parse(value);
                      _donationAmount.text = _numberFormat.format(plainNumber);
                      _donationAmount.selection = TextSelection.fromPosition(TextPosition(offset: _donationAmount.text.length));
                      int enteredValue = int.parse(value);
                      int userPointBalance = userPoint?['pointBalance'];
                      if(enteredValue > userPointBalance){
                        _donationAmount.text = _numberFormat.format(userPointBalance);
                        _donationAmount.selection = TextSelection.fromPosition(TextPosition(offset: _donationAmount.text.length));
                      }
                    }
                  },

                  onEditingComplete: () {
                    // 텍스트 필드가 포커스를 잃은 경우
                    if (_donationAmount.text.isEmpty) {
                      setState(() {
                        _hintText = "후원할 금액을 입력하세요"; // 힌트 텍스트 다시 설정
                      });
                    }
                  },
                  decoration: InputDecoration(hintText: _hintText,suffix: Text(amount),
                    enabledBorder: amountInput ==1? OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black38, // 비활성 상태 보더 색상 설정
                      ),
                    ) : OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.red
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF233067), // 활성 상태 보더 색상 설정
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                 children: [
                   for(int price in _price)
                     Padding(
                       padding: const EdgeInsets.all(4.0),
                       child: ElevatedButton(
                           onPressed: (){
                             int userPointBalance = userPoint?['pointBalance'];
                             setState(() {
                               if(price > userPointBalance){
                                 _donationAmount.text = _numberFormat.format(userPointBalance);
                               }else{
                                 _donationAmount.text = _numberFormat.format(price);
                               }
                               amount = "원";
                               amountInput = 1;
                             });
                           },
                           child: Text("${_numberFormat.format(price)}원"),
                         style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF233067))),
                       ),
                     ),
                   Padding(
                     padding: const EdgeInsets.all(4.0),
                     child: ElevatedButton(
                         onPressed: (){
                           setState(() {
                             _donationAmount.text = _numberFormat.format(userPoint?['pointBalance']);
                             amountInput = 1;
                           });
                         },
                         child: Text("전액"),
                       style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF233067))),
                     ),
                   )
                 ],
                ),
                Row(
                  children: [
                    Text("후원 메세지",style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    messageInput != 1?Text("필수입력사항",style: TextStyle(color: Colors.red),) : Container()
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: SingleChildScrollView(
                    child: TextField(
                      onTap: (){
                        setState(() {
                          messageInput = 1;
                        });
                      },
                      controller: _donationMessage,
                      maxLines: null,
                      decoration: InputDecoration(
                          hintText: _hintText2,
                          enabledBorder: messageInput ==1? OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black38, // 비활성 상태 보더 색상 설정
                            ),
                          ) : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red
                            )
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF233067), // 활성 상태 보더 색상 설정
                            ),
                          ),
                          isCollapsed: true,
                          contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 100)
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text("후원자명",style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    userInput != 1? Text("필수입력사항",style: TextStyle(color: Colors.red),) : Container()
                  ],
                ),
                TextField(
                  controller: _donationUser,
                  decoration: InputDecoration(
                    enabledBorder: userInput ==1? OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black38, // 비활성 상태 보더 색상 설정
                      ),
                    ) : OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.red
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF233067), // 활성 상태 보더 색상 설정
                      ),
                    ),
                  ),
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
              if(_donationAmount.text.isEmpty){
                setState(() {
                  amountInput = 2;
                });
              }
              if(_donationMessage.text.isEmpty){
                setState(() {
                  messageInput = 2;
                });
              }
              if(_donationUser.text.isEmpty){
                setState(() {
                  userInput = 2;
                });
              }
              String amount1 = _donationAmount.text.replaceAll(',', '');
              if(_donationAmount.text.isNotEmpty&&int.parse(amount1) < 1000){
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text("최소 1,000원부터 후원 가능합니다."),
                    actions: [
                      ElevatedButton(onPressed: (){
                        Navigator.of(context).pop();

                      }, child: Text("확인"))
                    ],
                  );
                },);
                return;
              }
              if(_donationAmount.text.isNotEmpty&&_donationMessage.text.isNotEmpty){
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text("후원하시겠습니까?"),
                    actions: [
                      ElevatedButton(
                        onPressed: (){Navigator.of(context).pop();}, child: Text("취소"),
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF233067))),
                      ),
                      ElevatedButton(onPressed: (){
                        _updataDonation();
                        Get.off(
                          ()=>DonationArtistList(),
                          transition: Transition.noTransition
                        );
                      },style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF233067)))
                      , child: Text("확인"))
                    ],
                  );
                },);
              }
            },
            child: Text("후원하기"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF233067),
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
