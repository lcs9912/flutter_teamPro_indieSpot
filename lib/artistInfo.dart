import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtistInfo extends StatefulWidget {
  final DocumentSnapshot doc;
  ArtistInfo({required this.doc});

  @override
  State<ArtistInfo> createState() => _ArtistInfoState();
}

class _ArtistInfoState extends State<ArtistInfo> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.doc.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text("${data['artistName']}"),
      ),
    );
  }
}
