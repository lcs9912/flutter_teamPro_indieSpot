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
  List<Map<String,dynamic>> pastRentalList = [];
  List<Map<String,dynamic>> spaceList = [];
  List<Map<String,dynamic>> pastSpaceList = [];
  DateTime currentDate = DateTime.now();
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
          Padding(
            padding: const EdgeInsets.only(top: 20,left: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("예정된 예약 내역", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
              ],
              ),
          ),
          SizedBox(
            height: 280,
            child:rentalList.isNotEmpty? ListView.builder(
                itemCount: rentalList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(spaceList[index]["spaceName"]),
                    subtitle: Row(
                      children: [
                        Text("${rentalList[index]['rentalDate']} ${rentalList[index]['startTime']}~${rentalList[index]['endTime']}"),
                      ],
                    ),
                    leading: Container(
                      width: 80,
                      child: Image.network(rentalList[index]["spaceImg"][0],fit: BoxFit.fill,)
                    ),
                  );
                },
            ) : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text("예약된 내역이 없습니다.")],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20,left: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("이전 예약 내역", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child:pastRentalList.isNotEmpty? ListView.builder(
              itemCount: pastRentalList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(pastSpaceList[index]["spaceName"]),
                  subtitle: Row(
                    children: [
                      Text("${pastRentalList[index]['rentalDate']} ${rentalList[index]['startTime']}~${rentalList[index]['endTime']}"),
                    ],
                  ),
                  leading: Container(
                    width: 80,
                    child: Image.network(pastRentalList[index]["spaceImg"][0],fit: BoxFit.fill,)
                  ),
                );
              },
            ) : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text("예약된 내역이 없습니다.")],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
  Future<void> rentalCheck()async{
    QuerySnapshot spaceSnap = await fs.collection("commercial_space").get();
    List<Map<String,dynamic>> rentalData = [];
    List<Map<String,dynamic>> pastrentalData = [];
    List<Map<String,dynamic>> spaceData = [];
    List<Map<String,dynamic>> pastspaceData = [];
    spaceSnap.docs.forEach((element) async{
      String spaceId = element.id;
      CollectionReference rentalCollection = fs.collection("commercial_space").doc(spaceId).collection("rental");
      CollectionReference rentalImg = fs.collection("commercial_space").doc(spaceId).collection("image");
      try {
        QuerySnapshot rentalSnap = await rentalCollection.orderBy('startTime', descending: true).get();
        QuerySnapshot spaceImg = await rentalImg.get();

        rentalSnap.docs.forEach((doc) {
          if(doc.get("artistId")==artistId){
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            DateTime startTime = data['startTime'].toDate();
            // Convert timestamp fields to DateTime
            if (startTime.isBefore(currentDate)) {
              data['spaceImg'] = spaceImg.docs.first.get('path');
              if (data['startTime'] is Timestamp) {
                DateTime startTime = (data['startTime'] as Timestamp).toDate();
                data['startTime'] = DateFormat('HH:mm').format(startTime);
                data['rentalDate'] = DateFormat('yyyy-MM-dd').format(startTime);
              }
              if (data['endTime'] is Timestamp) {
                DateTime endTime = (data['endTime'] as Timestamp).toDate();
                data['endTime'] = DateFormat('HH:mm').format(endTime);
              }
              pastrentalData.add(data);
              pastspaceData.add(element.data() as Map<String,dynamic>);
            }else{
              data['spaceImg'] = spaceImg.docs.first.get('path');
              if (data['startTime'] is Timestamp) {
                DateTime startTime = (data['startTime'] as Timestamp).toDate();
                data['startTime'] = DateFormat('HH:mm').format(startTime);
                data['rentalDate'] = DateFormat('yyyy-MM-dd').format(startTime);
                data['spaceImg'] = spaceImg.docs.first.get('path');
              }
              if (data['endTime'] is Timestamp) {
                DateTime endTime = (data['endTime'] as Timestamp).toDate();
                data['endTime'] = DateFormat('HH:mm').format(endTime);
              }
              rentalData.add(data);
              spaceData.add(element.data() as Map<String,dynamic>);
            }
          }
        });
        setState(() {
          rentalList = rentalData;
          spaceList = spaceData;
          pastRentalList = pastrentalData;
          pastSpaceList = pastspaceData;
        });
      } catch (e) {
        print("Error fetching rental collection: $e");
        // Handle errors
      }
    });

  }
}
