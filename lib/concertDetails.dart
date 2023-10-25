import 'package:flutter/material.dart';

class ConcertDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭의 개수 (상세 정보와 공연 후기)
      child: Scaffold(
        appBar: AppBar(
          title: Text('공연 상세 페이지'),
          bottom: TabBar(
            tabs: [
              Tab(text: '상세 정보'),
              Tab(text: '공연 후기'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 첫 번째 탭 (상세 정보)
            Container(
              child: Column(
                children: [
                  // 상단 이미지
                  Image.asset(
                    'assets/bus_sample1.jpg',
                    height: 300, // 이미지 높이 설정
                    width: 600,// 이미지가 위젯에 맞게 조절되도록 설정
                  ),

                  // 이어서 다른 위젯들을 추가할 수 있습니다.
                  // ...
                ],
              ),
            ),

            // 두 번째 탭 (공연 후기)
            Center(
              child: Text('여기에 공연 후기가 들어갑니다.'),
            ),
          ],
        ),
      ),
    );
  }
}
