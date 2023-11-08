import 'package:flutter/material.dart';
import 'package:indie_spot/adminInquiry.dart';
import 'package:indie_spot/adminUserList.dart';
import 'package:indie_spot/baseBar.dart';

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
        // title: Text(
        //   '',
        //   style: TextStyle(
        //     color: Colors.black,
        //   ),
        // ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16),
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdminInquiry(),)),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF392F31),
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
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdminUserList(),)),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF392F31),
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
          ],
        ),
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}
