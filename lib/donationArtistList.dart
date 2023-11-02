
import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/donationPage.dart';

class DonationArtistList extends StatefulWidget {
  const DonationArtistList({super.key});

  @override
  State<DonationArtistList> createState() => _DonationArtistListState();
}

class _DonationArtistListState extends State<DonationArtistList> {
  final TextEditingController _search = TextEditingController();
  FocusNode _focusNode = FocusNode();

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
                              width: 100,
                              height: 100,
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
          TextField(
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
         _artistSearch(),
        ],
      ),
    );
  }
}
