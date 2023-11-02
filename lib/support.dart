import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userModel.dart';
import 'contactUs.dart';
import 'package:provider/provider.dart';

class Support extends StatefulWidget {

  @override
  State<Support> createState() => _SupportState();
}


class _SupportState extends State<Support> {
  late String _userId; // 수정: _userId를 late 변수로 변경
  @override
  void initState() {
    super.initState();
    _userId = Provider.of<UserModel>(context, listen: false).userId ?? "";
    print('dddd$_userId');
  }

  List<bool> showAdditionalText = List.generate(11, (index) => false);


  List<String> questions = [
    'Q.솔로일 경우에도 팀/솔로 신청을 해야하나요?',
    'Q.솔로로 가입되어있어도 팀에 또가입할 수 있나요?',
    'Q.인디스팟에 문의하고 싶어요',
    'Q.새로운 팀원을 모집하려면 어떻게 해야하나요?',
    'Q.가입한 팀을 나중에 탈퇴하려면 어떻게 해야하나요?',
    'Q.내가 속한 팀의 정보를 수정하려면 어떻게 해야하나요?',
    'Q.팀장을 어떻게 변경할 수 있나요?',
    'Q.팀을 해체하려면 어떻게 해야하나요?',
    'Q.팬으로 가입한 후에 아티스트로 전환하려면 어떻게 해야하나요?',
    'Q.아티스트로 가입한 후에 팬으로 전환하려면 어떻게 해야하나요?',
    'Q.팀에 초대받았는데 어떻게 수락하나요?',
  ];

  List<String> answers = [
    'A.네 솔로일 때도 팀/솔로 신청 부분에서 내용을 작성해주셔야 아티스트 활동이 가능합니다.',
    'A.네. 가능합니다. 실제 본인이 솔로 활동도 하고 팀에 속해서도 활동하고 있으면 솔로로 등록하고, 팀으로도 등록할 수 있고, 다른 팀에 초대받을 수도 있습니다. 팀, 솔로 등록에는 개수 제한이 없습니다.',
    'A.1:1 문의 또는 아래 카카오톡 문의 주시기 바랍니다. 최대한 빠르게 답변 드리겠습니다.',
    'A.팀 페이지에서 "팀원 모집" 버튼을 클릭하고 필요한 정보를 작성하여 팀원을 모집할 수 있습니다.',
    'A.팀 페이지에서 "팀 탈퇴" 버튼을 클릭하여 팀을 나중에 탈퇴할 수 있습니다.',
    'A.팀 페이지에서 필요한 정보를 수정하고 저장 버튼을 클릭하여 팀 정보를 수정할 수 있습니다.',
    'A.팀 페이지에서 "팀장 변경" 버튼을 클릭하여 팀장을 변경할 수 있습니다.',
    'A.팀 페이지에서 "팀 해체" 버튼을 클릭하여 팀을 해체할 수 있습니다.',
    'A.팬 페이지에서 "아티스트로 전환" 버튼을 클릭하고 필요한 정보를 작성하여 아티스트로 전환할 수 있습니다.',
    'A.아티스트 페이지에서 "팬으로 전환" 버튼을 클릭하여 팬으로 전환할 수 있습니다.',
    'A.팀 초대 메시지를 받은 채팅방으로 이동하여 초대를 확인하고 수락할 수 있습니다.',
  ];

  void toggleAdditionalText(int index) {
    setState(() {
      showAdditionalText[index] = !showAdditionalText[index];
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Support'),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'FAQ'),
                  Tab(text: '문의하기'),
                ],
              ),
            ),
            body: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(questions.length, (index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => toggleAdditionalText(index),
                                child: Text(
                                  questions[index],
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              if (showAdditionalText[index])
                                Container(
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    answers[index],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  Scaffold(
                    body: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20), // 간격 조절
                          FutureBuilder(
                            future: getInquiries(), // Firebase에서 문의 내용 가져오는 함수 호출
                            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<String> inquiries = snapshot.data ?? []; // 가져온 데이터

                                return Row(
                                  children: inquiries.map((inquiry) {
                                    return Container(
                                      margin: EdgeInsets.only(right: 8), // content와의 간격 조절
                                      child: Text(inquiry), // 각각의 문의 내용을 출력
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    floatingActionButton: Positioned(
                      right: 20,
                      bottom: 20,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ContactUs(),
                          ));
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
    ],
    )
    )
    );
  }

  Future<List<String>> getInquiries() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> inquiriesSnapshot = await firestore
        .collection('userList')
        .doc(_userId) // 사용자 ID를 넣어주세요
        .collection('inquiry')
        .get();

    List<String> inquiries = inquiriesSnapshot.docs
        .map((doc) => doc['content'].toString()) // 가져온 데이터 중 content 필드 사용
        .toList();

    return inquiries;
  }
}

