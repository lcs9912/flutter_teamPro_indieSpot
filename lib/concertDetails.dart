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
            SingleChildScrollView(
              child: Container(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 상단 이미지
                    Image.asset(
                      'assets/bus_sample1.jpg',
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 30), // 간격 추가
                    Text(
                      'INTRODUCTION',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10), // 간격 추가
                    Container(
                      height: 1.0,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.1),
                    ),
                    SizedBox(height: 10), // 간격 추가
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "  기본정보",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(

                      color: Color(0xFFdcdcdc),
                      height: 250,
                      width: 400,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Image.asset(
                                'assets/기본.jpg',
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Nick",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 30),
                                Container(
                                  height: 1.0,
                                  width: 200,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "장소          place",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "시간          time",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "출연          musision",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "장르          rock",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "  댓글",
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              // Add your refresh logic here
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: Icon(Icons.mode_comment),
                        ),
                        maxLines: null, // Allow multiple lines for the comment
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 두 번째 탭 (공연 후기)
            SingleChildScrollView(
              child: Center(
                child: Text('여기에 공연 후기가 들어갑니다.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
