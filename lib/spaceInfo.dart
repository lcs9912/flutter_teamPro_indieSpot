import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'baseBar.dart';

class SpaceInfo extends StatefulWidget {

  @override
  State<SpaceInfo> createState() => _SpaceInfoState();
}

class _SpaceInfoState extends State<SpaceInfo> {
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  List<String> imgPath = [];
  List<Map<String,dynamic>> spaceList= [];
  PageController _pageController = PageController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    spaceImg();
    spaceData();
  }
  @override
  Widget build(BuildContext context) {
    print(imgPath);
    print(spaceList);
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
          '상업 공간',
          style: TextStyle(color: Colors.black,),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              children:[
               for(int i=0; i< imgPath.length; i++)
                  Image.network(imgPath[i])
              ]
            ),
          ),
          Container(
            height: 70,
            color: Colors.grey[100],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text((spaceList[0]["spaceName"]).toString(),style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Future<void> spaceData() async{
    DocumentSnapshot spaceSnap = await fs.collection("commercial_space").doc("YUAv5824ONbCtRuEbSWs").get();
    if(spaceSnap.exists){
      setState(() {
        spaceList.add({
          "description" : spaceSnap.get("description"),
          "equipmentYn" : spaceSnap.get("equipmentYn"),
          "spaceName" : spaceSnap.get("spaceName"),
          "spaceType" : spaceSnap.get("spaceType"),
          "regions" : spaceSnap.get("regions"),
          "managerContact" : spaceSnap.get("managerContact"),
          "startTime" : spaceSnap.get("startTime"),
          "endTime" : spaceSnap.get("endTime")
        });
      });
    }
  }

  Future<void> spaceImg()async{
    QuerySnapshot imgSnap = await fs.collection("commercial_space").doc("YUAv5824ONbCtRuEbSWs").collection("image").get();
    if(imgSnap.docs.isNotEmpty){
      setState(() {
        for (var element in imgSnap.docs) {
          imgPath.add(element.get("path"));
        }
      });
    }
  }
}
