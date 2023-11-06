import 'package:flutter/material.dart';
import 'package:indie_spot/adminInquiry.dart';
import 'package:indie_spot/adminUserList.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(onPressed: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdminInquiry(),)), child: Text('문의 관리')),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(onPressed: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdminUserList(),)), child: Text('계정 관리')),
              )
            ],
          )
        ],
      ),
    );
  }
}
