import 'package:flutter/material.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowList extends StatefulWidget {
  const FollowList({super.key});

  @override
  State<FollowList> createState() => _FollowListState();
}
class _FollowListState extends State<FollowList> {
  String? _userId;
  String? _artistId;

  void getFollowingArtistIds() async {
    String? userId = _userId;
    QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
        .collection('userList')
        .doc(userId)
        .collection('following')
        .get();

    List<DocumentSnapshot> followingDocuments = followingSnapshot.docs;

    for (var document in followingDocuments) {
      var data = document.data() as Map<String, dynamic>;
      var artistId = data['artistId'];
      print("Artist ID: $artistId");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userId = Provider.of<UserModel>(context).userId;
    _artistId = Provider.of<UserModel>(context).artistId;

    print('_userId: $_userId');
    getFollowingArtistIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Follow List'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('userList')
            .doc(_userId)
            .collection('following')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var followingList = snapshot.data!.docs;
          List<Widget> followingWidgets = [];
          for (var following in followingList) {
            followingWidgets.add(
              ListTile(
                title: Text(following['artistId']),
              ),
            );
          }
          return Column(
            children: followingWidgets,
          );
        },
      ),
    );
  }
}
