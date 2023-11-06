
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUserInfo extends StatefulWidget {
  final String id;
  AdminUserInfo(this.id, {super.key});

  @override
  State<AdminUserInfo> createState() => _AdminUserInfoState();
}

class _AdminUserInfoState extends State<AdminUserInfo> {
  FirebaseFirestore fs = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

      ),
    );
  }

  Future<List<Widget>?> _adminUserInfoDetails() async {
    var userQuerySnapshot = await fs.collection('userList')
        .doc(widget.id)
        .get();

    if(userQuerySnapshot.id.isNotEmpty){
      var userImageSnapshot = await userQuerySnapshot.reference.collection('image').limit(1).get();
      if(userImageSnapshot.docs.isNotEmpty != null) {
        String image = userImageSnapshot.docs.first.data()['path'];
      }
    }

      List<Widget> userItems = [];

  }
}
