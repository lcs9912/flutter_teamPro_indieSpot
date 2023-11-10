import 'package:flutter/material.dart';
import 'package:indie_spot/adminInquiry.dart';
import 'package:indie_spot/adminUserList.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:get/get.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu),
                color: Colors.white,
              );
            },
          ),
        ],
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // 뒤로가기 버튼을 눌렀을 때 수행할 작업
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFF233067),
        centerTitle: true,
        title: Text(
          '관리자',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: InkWell(
                onTap: () => Get.to(
                  AdminInquiry(),
                  transition: Transition.noTransition
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF233067),
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.help, size: 40, color: Colors.white,),
                      Text('문의 관리', style: TextStyle(fontSize: 20, color: Colors.white),)
                    ],
                  )
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: InkWell(
                onTap: () => Get.to(
                    AdminUserList(),
                    transition: Transition.noTransition
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF233067),
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 40, color: Colors.white,),
                      Text('회원 관리', style: TextStyle(fontSize: 20, color: Colors.white),)
                    ],
                  )
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}
