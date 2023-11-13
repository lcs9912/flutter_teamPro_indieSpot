import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'dialog.dart';
import 'login.dart';
import 'userModel.dart';
import 'contactUs.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
class Support extends StatefulWidget {
  final List<Map<String, dynamic>> inquiries = [];
  final List<bool> isExpandedList = List.generate(11, (index) => false);
  final bool isExpanded = false;
  final int expandedIndex = -1;
  @override
  State<Support> createState() => _SupportState();
}


class _SupportState extends State<Support> {
  late String _userId; // 수정: _userId를 late 변수로 변경
  String? reply;
  @override
  void initState() {
    super.initState();
    _userId = Provider.of<UserModel>(context, listen: false).userId ?? "";
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

  Widget _buildEditIconButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.edit,
        color: Colors.white,
      ),
      onPressed: () {
        if (_userId.isNotEmpty) {
          // 로그인 상태라면 페이지 이동
          Get.to(
            ContactUs(), // 이동하려는 페이지
            preventDuplicates: true, // 중복 페이지 이동 방지
            transition: Transition.noTransition, // 이동 애니메이션 off
          );
        } else {
          // 로그인 상태가 아니라면 다이얼로그 표시
          _showEditDialog(context);
        }
      },
    );
  }
  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text('로그인 후 이용가능합니다'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }
  // 로그인 해라
  static void showUserRegistrationDialog(BuildContext context) {
    Dialogs.materialDialog(
        color: Colors.white,
        msg: '로그인 후 이용해주세요.',
        title: '로그인 후 이용가능',
        lottieBuilder: Lottie.asset(
          'assets/Animation - 1699599464228.json',
          fit: BoxFit.contain,
        ),
        context: context,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: '취소',
            iconData: Icons.done,
            color: Color(0xFF233067),
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
          IconsButton(
            onPressed: () {
              Get.to(
                  LoginPage(), //이동하려는 페이지
                  preventDuplicates: true, //중복 페이지 이동 방지
                  transition: Transition.noTransition //이동애니메이션off
              );
            },
            text: '로그인',
            iconData: Icons.done,
            color: Color(0xFF233067),
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF233067),
              title: Text(
                '고객센터',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              iconTheme: IconThemeData(color: Colors.white),
              actions: [
                _buildEditIconButton(context),
              ],
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                onTap: (index) {
                  if (index == 1 && (_userId.isEmpty)) {
                    DialogHelper.showUserRegistrationDialog(context);
                    return;
                  }
                },
                tabs: [
                  Tab(text: 'FAQ',),
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
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            if (showAdditionalText[index])
                              Container(
                                color: Colors.grey[200],
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  answers[index],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            Divider( // 이 부분이 추가된 부분입니다.
                              color: Colors.grey[300], // 회색 줄의 색상을 지정합니다.
                              thickness: 1, // 회색 줄의 두께를 조절합니다.
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),

                Scaffold(
                  body: SingleChildScrollView(

                    child: Stack(
                        children: [
                          Positioned(
                            top: MediaQuery
                                .of(context)
                                .size
                                .height / 20 - 20, // 수직 중앙에 위치
                            left: MediaQuery
                                .of(context)
                                .size
                                .width / 3 - 0, // 수평 중앙에 위치
                            child: Text(
                              '나의 문의 내역', // 여기에 표시할 텍스트
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20, // 텍스트 크기
                              ),
                            ),
                          ),

                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 20), // 간격 조절
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: getInquiries(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<
                                            Map<String, dynamic>>> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text( '');
                                      } else {
                                        List<Map<String,
                                            dynamic>> inquiries = snapshot
                                            .data ?? [];
                                        return Column(
                                          children: inquiries
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            Map<String, dynamic> inquiry = entry
                                                .value;
                                            String category = inquiry['category']
                                                .toString();
                                            String content = inquiry['content']
                                                .toString();
                                            bool isExpanded = widget
                                                .isExpandedList[index];

                                            return GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                      BuildContext context) {
                                                    Map<String,
                                                        dynamic> inquiry = inquiries[index];
                                                    String category = inquiry['category']
                                                        .toString();
                                                    String content = inquiry['content']
                                                        .toString();

                                                    return AlertDialog(
                                                      contentPadding: EdgeInsets
                                                          .all(16),
                                                      // 패딩을 조절합니다.
                                                      title: Text(
                                                          '카테고리: $category'),
                                                      content: Container(
                                                          width: 300,
                                                          height: 300,
                                                          // 원하는 너비로 설정합니다.
                                                          child: FutureBuilder<
                                                              String>(

                                                            future: getNickFromUserList(
                                                                _userId),
                                                            builder: (
                                                                BuildContext context,
                                                                AsyncSnapshot<
                                                                    String> snapshot) {
                                                              if (snapshot
                                                                  .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return CircularProgressIndicator();
                                                              } else
                                                              if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    'Error: ${snapshot
                                                                        .error}');
                                                              } else {
                                                                String nick = snapshot
                                                                    .data ?? "";
                                                                return Column(
                                                                  crossAxisAlignment: CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                          bottom: 8),
                                                                      width: 280,
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .grey[200],
                                                                        // 배경색 설정
                                                                        border: Border
                                                                            .all(
                                                                            color: Colors
                                                                                .grey),
                                                                        // 테두리 추가
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            8),
                                                                      ),
                                                                      padding: EdgeInsets
                                                                          .all(
                                                                          8),
                                                                      child: Text(
                                                                        '작성자: $nick',
                                                                        style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: 280,
                                                                      height: 200,
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .grey[200],
                                                                        // 배경색 설정
                                                                        border: Border
                                                                            .all(
                                                                            color: Colors
                                                                                .grey),
                                                                        // 테두리 추가
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            8),
                                                                      ),
                                                                      padding: EdgeInsets
                                                                          .all(
                                                                          8),
                                                                      child: Text(
                                                                        '문의내용: $content',
                                                                        style: TextStyle(
                                                                          fontStyle: FontStyle
                                                                              .italic,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }
                                                            },
                                                          )
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                context).pop();
                                                          },
                                                          child: Text('Close'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },

                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,

                                                  children: [
                                                    SizedBox(height: 16),
                                                    // 간격 조절
                                                    Container(
                                                      width: 300,
                                                      height: 120,
                                                      margin: EdgeInsets.only(
                                                          bottom: 8),
                                                      padding: EdgeInsets.all(
                                                          8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius: BorderRadius
                                                            .circular(8),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                              '카테고리: $category',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight
                                                                      .bold)),
                                                          SizedBox(height: 8),
                                                          FutureBuilder<String>(
                                                            future: getNickFromUserList(
                                                                _userId),
                                                            builder: (
                                                                BuildContext context,
                                                                AsyncSnapshot<
                                                                    String> snapshot) {
                                                              if (snapshot
                                                                  .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return CircularProgressIndicator();
                                                              } else
                                                              if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    'Error: ${snapshot
                                                                        .error}');
                                                              } else {
                                                                String nick = snapshot
                                                                    .data ?? "";
                                                                return Text(
                                                                    '작성자: $nick');
                                                              }
                                                            },
                                                          ),
                                                          SizedBox(height: 8),
                                                          (reply == null)
                                                              ? Row(
                                                            children: [
                                                              Icon(Icons
                                                                  .access_time,
                                                                  color: Colors
                                                                      .orange),
                                                              // 답변 대기 아이콘
                                                              SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                  '답변대기',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .orange)),
                                                            ],
                                                          )
                                                              : (isExpanded
                                                              ? Expanded(
                                                            child: Text(
                                                              'Content: $content',
                                                              softWrap: true,
                                                              overflow: TextOverflow
                                                                  .fade,
                                                            ),
                                                          )
                                                              : Container()),
                                                        ],
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]
                    ),
                  ),
                  floatingActionButton: Positioned(
                    right: 20,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: () {
                        if (_userId.isNotEmpty) {
                          // 로그인 상태라면 페이지 이동
                          Get.to(
                            ContactUs(),
                            transition: Transition.noTransition, // 이동 애니메이션 off
                          );
                        } else {
                          // 로그인 상태가 아니라면 다이얼로그 표시
                          _showEditDialog(context);
                        }
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

  Future<List<Map<String, dynamic>>> getInquiries() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> inquiriesSnapshot = await firestore
        .collection('userList')
        .doc(_userId)
        .collection('inquiry')
        .get();

    List<Map<String, dynamic>> inquiries = inquiriesSnapshot.docs
        .map((doc) => {
      'category': doc['category'],
      'content': doc['content'],
      'cDateTime': doc['cDateTime'],
    })
        .toList();

    return inquiries;
  }
  Future<String> getNickFromUserList(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await firestore
          .collection('userList')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String nick = userDoc['nick'].toString();
        return nick;
      } else {
        return ""; // 해당하는 사용자를 찾지 못한 경우 빈 문자열을 반환하거나 다른 값을 반환할 수 있습니다.
      }
    } catch (e) {
      print('Error fetching nick: $e');
      return ""; // 에러가 발생한 경우 빈 문자열을 반환하거나 다른 값을 반환할 수 있습니다.
    }
  }

}