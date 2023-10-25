import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';

class BuskingList extends StatefulWidget{
  const BuskingList({super.key});

  @override
  State<BuskingList> createState() => _BuskingListState();
}

class _BuskingListState extends State<BuskingList> {
  final TextEditingController _search = TextEditingController();
  FocusNode _focusNode = FocusNode();
  late TextField sharedTextField;

  @override
  Widget build(BuildContext context) {

    sharedTextField = TextField(
      controller: _search,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: "팀명으로 검색하기",
        border: UnderlineInputBorder(),
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
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          title: Center(child: Text("공연 일정", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),)),
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
          bottom: TabBar(
              tabs: [
                Tab(text: '전체'),
                Tab(text: '지역'),
                Tab(text: '장르'),
              ],
            unselectedLabelColor: Colors.black, // 선택되지 않은 탭의 텍스트 색상
            labelColor: Colors.blue,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold, // 선택된 탭의 텍스트 굵기 설정
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal, // 선택되지 않은 탭의 텍스트 굵기 설정
            ),
          ),
          elevation: 1,
        ),
        drawer: MyDrawer(),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Column(
                children: [
                  sharedTextField,
                  Padding(
                    padding: EdgeInsets.all(12),
                    /*child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {

                    },
                ),*/
                  )
                ],
            ),
            Column(
              children: [
                sharedTextField,
                Padding(
                  padding: EdgeInsets.all(12),
                  /*child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {

                    },
                ),*/
                )
              ],
            ),
            Column(
              children: [
                sharedTextField,
                Padding(
                  padding: EdgeInsets.all(12),
                  /*child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {

                    },
                ),*/
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
