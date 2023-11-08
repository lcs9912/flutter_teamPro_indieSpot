
import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/donationPage.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
class DonationArtistList extends StatefulWidget {
  const DonationArtistList({super.key});

  @override
  State<DonationArtistList> createState() => _DonationArtistListState();
}

class _DonationArtistListState extends State<DonationArtistList> {
  final TextEditingController _search = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String? userId = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if(userModel.isLogin){
      userId = userModel.userId;
    }else{
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Builder(
              builder: (context) {
                return IconButton(
                    color: Colors.black54,
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back)
                );
              }
          ),
        title: Center(child: Text("DONATION", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),)),
        actions: [
          Builder(
              builder: (context) {
                return IconButton(
                    color: Colors.black54,
                    onPressed: (){
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(Icons.menu)

                );
              }
          )
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _search,
              focusNode: _focusNode,
              textInputAction: TextInputAction.go,
              onSubmitted: (value){
                setState(() {

                });
              },
              decoration: InputDecoration(
                hintText: "팀명으로 검색하기",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  onPressed: () {
                    _focusNode.unfocus();
                    _search.clear();
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
                prefixIcon: Icon(Icons.search),
              ),
        ),
          ),
         _artistSearch(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("FOLLOWING",style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          _following()
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  Widget _artistSearch(){
    return Container(
      height: 300,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black38))),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("artist").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) {
            return Container();
          }
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> artistData = doc.data() as Map<String,dynamic>;
              if(artistData['artistName'].contains(_search.text)) {
                return FutureBuilder(
                  future: FirebaseFirestore.instance.collection("artist")
                      .doc(doc.id).collection("image")
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot>imageSnapshot) {
                    if (!imageSnapshot.hasData) {
                      return Container();
                    }
                    Map<String, dynamic> imgData = imageSnapshot.data!
                        .docs
                        .first.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text("${artistData['artistName']}"),
                      subtitle: Text("${artistData['genre']}"),
                      leading: Image.network(
                          imgData['path'],
                          width: 80,
                          fit: BoxFit.fill
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DonationPage(artistId : doc.id),));
                      },
                    );
                  },
                );
              }else{
                return Container();
              }
            },
          );
        },
      ),
    );
  }
  Widget _following(){
    return Container(
      height: 210,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("userList").doc(userId).collection("following").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) {
            return Container();
          }
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              String artistId = doc.get("artistId");
                return FutureBuilder(
                  future: FirebaseFirestore.instance.collection("artist")
                      .doc(artistId)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot>artistSnapshot) {
                    if (!artistSnapshot.hasData) {
                      return Container();
                    }
                    Map<String, dynamic> artistData = artistSnapshot.data!.data() as Map<String, dynamic>;
                    return FutureBuilder(
                        future: FirebaseFirestore.instance.collection("artist").doc(artistId).collection("image").get(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> imgSnap) {
                          if(imgSnap.hasData){
                            return ListTile(
                              title: Text("${artistData['artistName']}"),
                              subtitle: Text("${artistData['genre']}"),
                              leading: Image.network(
                                  imgSnap.data!.docs.first.get("path"),
                                  width: 80,
                                  fit: BoxFit.fill
                              ),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DonationPage(artistId : doc.id),));
                              },
                            );
                          }
                          return Container();
                        },
                    );
                  },
                );
            },
          );
        },
      ),
    );
  }
}
