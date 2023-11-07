import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/userModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'baseBar.dart';

class RenTalHistory extends StatefulWidget {

  @override
  State<RenTalHistory> createState() => _RenTalHistoryState();
}

class _RenTalHistoryState extends State<RenTalHistory> {
  String? artistId = "";
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  List<Map<String,dynamic>> rentalList = [];
  List<Map<String,dynamic>> spaceList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    rentalCheck();

    if(!userModel.isArtist){

    }else{
      artistId = userModel.artistId;
    }
  }
  @override
  Widget build(BuildContext context) {
    print("zzz$rentalList");
    print("zzz$spaceList");
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
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          '예약 내역',
          style: TextStyle(color: Colors.black,),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Text("예약 내역"),
            ),
          SizedBox(
            height: 600,
            child: ListView.builder(
                itemCount: rentalList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(spaceList[index]["spaceName"]),
                    subtitle: Row(
                      children: [
                        Text("${rentalList[index]['rentalDate']} ${rentalList[index]['startTime']}~${rentalList[index]['endTime']}"),
                      ],
                    ),
                    //leading: Image.network(src),
                  );
                },
            ),
          )
        ],
      ),
    );
  }
  Future<void> rentalCheck()async{
    QuerySnapshot spaceSnap = await fs.collection("commercial_space").get();
    List<Map<String,dynamic>> rentalData = [];
    List<Map<String,dynamic>> spaceData = [];
    spaceSnap.docs.forEach((element) async{
      String spaceId = element.id;
      CollectionReference rentalCollection = fs.collection("commercial_space").doc(spaceId).collection("rental");
      try {
        QuerySnapshot rentalSnap = await rentalCollection.get();

        rentalSnap.docs.forEach((doc) {
          if(doc.get("artistId")==artistId){
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // Convert timestamp fields to DateTime
            if (data['startTime'] is Timestamp) {
              DateTime startTime = (data['startTime'] as Timestamp).toDate();
              data['startTime'] = DateFormat('HH:mm').format(startTime);
              data['rentalDate'] = DateFormat('yyyy-MM-dd').format(startTime);
            }
            if (data['endTime'] is Timestamp) {
              DateTime endTime = (data['endTime'] as Timestamp).toDate();
              data['endTime'] = DateFormat('HH:mm').format(endTime);
            }
            rentalData.add(data);
            spaceData.add(element.data() as Map<String,dynamic>);
          }
        });
        setState(() {
          rentalList = rentalData;
          spaceList = spaceData;
        });
      } catch (e) {
        print("Error fetching rental collection: $e");
        // Handle errors
      }
    });

  }
}
