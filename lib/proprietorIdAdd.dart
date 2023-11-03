import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:indie_spot/artistList.dart';
import 'package:indie_spot/lsjMain.dart';
import 'donationList.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'buskingReservation.dart';

class ProprietorAdd extends StatefulWidget {
  const ProprietorAdd({super.key});

  @override
  State<ProprietorAdd> createState() => _ProprietorAddState();
}

class _ProprietorAddState extends State<ProprietorAdd> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
