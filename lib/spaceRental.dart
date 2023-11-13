import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/pointRecharge.dart';
import 'package:indie_spot/rentalHistory.dart';
import 'package:indie_spot/userModel.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:table_calendar/table_calendar.dart';
import 'baseBar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class SpaceRental extends StatefulWidget {
  final DocumentSnapshot document;
  SpaceRental({required this.document});
  @override
  State<SpaceRental> createState() => _SpaceRentalState();
}

class _SpaceRentalState extends State<SpaceRental> {
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  DateTime selectedDay = DateTime.now();
  List<int> availableHours = [];
  List<int> selectedHours = [];
  List<int> checkHours = [];
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();
  String? artistId = "";
  String? userId = "";
  int pointBalance = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAvailableHours();
    rentalCheck();
    final userModel = Provider.of<UserModel>(context, listen: false);
    if(!userModel.isArtist){

    }else{
      artistId = userModel.artistId;
      userId = userModel.userId;
      userPoint();
    }
  }
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
          '장소 예약',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          titleText("예약 날짜"),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: calendar(),
          ),
          titleText("예약 시간"),
          rentalTime(),
          Padding(
            padding: const EdgeInsets.only(left: 20,top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("예약 장소 : ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                    Text(widget.document.get("spaceName"))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    children: [
                      Text("보유 포인트 : ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                      Text("${_numberFormat.format(pointBalance)}P")
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("예약 일시",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                Text("공간 사용료",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8,left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "${DateFormat('yyyy-MM-dd(E)','ko_KR').format(selectedDay)}"
                    "${selectedHours.isNotEmpty? (selectedHours.first).toString()+':00' : ''}"
                    "${selectedHours.length == 2? '~'+(selectedHours.last).toString()+':00('+(selectedHours.last-selectedHours.first).toString()+"시간)":''}"
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text("${selectedHours.length == 2? _numberFormat.format((selectedHours.last-selectedHours.first)*widget.document.get("rentalfee"))+"P" : ""}"),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: 40),
          child: Row(
            children: [
              Expanded(child: ElevatedButton(
                style: ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(Size(0, 48)),
                    backgroundColor: MaterialStatePropertyAll(Color(0xFF233067)),
                    elevation: MaterialStatePropertyAll(0),
                    shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero
                        )
                    )
                ),
                onPressed: () {
                  if(selectedHours.length != 2){
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        title: Text("알림"),
                        content: Text("예약할 시간을 선택해주세요."),
                        actions: [
                          ElevatedButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                                return;
                              },
                              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF233067))),
                              child: Text("확인")
                          )
                        ],
                      );
                    },);
                    return;
                  }else{
                    if(((selectedHours.last-selectedHours.first)*widget.document.get("rentalfee")) > pointBalance){
                      showDialog(context: context, builder: (context) {
                        return AlertDialog(
                          title: Text("알림"),
                          content: Text("포인트가 부족합니다."),
                          actions: [
                            ElevatedButton(
                                onPressed: (){
                                  Navigator.of(context).pop();
                                  return;
                                },
                                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF233067))),
                                child: Text("취소")
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.to(
                                    PointRecharge(), //이동하려는 페이지
                                    preventDuplicates: true, //중복 페이지 이동 방지
                                    transition: Transition.noTransition //이동애니메이션off
                                )?.then((value) {
                                  if (value != null && value) {
                                    Get.off(
                                      ()=>SpaceRental(document: widget.document),
                                      transition: Transition.noTransition
                                    );
                                    Navigator.pop(context, true);
                                    return;
                                  }
                                });
                              },
                              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF233067))),
                              child: Text("충전"),
                            )
                          ],
                        );
                      },);
                      return;
                    }
                  }
                  showUserRegistrationDialog(context);
                },
                child: Text('예약', style: TextStyle(fontSize: 17),),
              ),)
            ],
          ),
        )
    );
  }
  void showUserRegistrationDialog(BuildContext context) {
    Dialogs.materialDialog(
        color: Colors.white,
        msg: "예약 장소 : ${widget.document.get("spaceName")}\n"
            "예약 날짜 : ${DateFormat('yyyy-MM-dd(E)','ko_KR').format(selectedDay)}\n"
            "예약 시간 : ${(selectedHours.first).toString()+':00'}~${(selectedHours.last).toString()+':00('+(selectedHours.last-selectedHours.first).toString()+"시간)"}\n"
            "예약 후 포인트 : ${(pointBalance-(selectedHours.last-selectedHours.first)*widget.document.get("rentalfee"))}",
        title: '예약 하시겠습니까?',
        lottieBuilder: Lottie.asset(
          'assets/celendar.json',
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
              rentalAdd();
              Get.off(
                  RenTalHistory(), //이동하려는 페이지
                  preventDuplicates: true, //중복 페이지 이동 방지
                  transition: Transition.noTransition //이동애니메이션off
              );
            },
            text: '예약',
            iconData: Icons.done,
            color: Color(0xFF233067),
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
  }

  Future<void> userPoint() async{
    QuerySnapshot userSnap = await fs.collection("userList").doc(userId).collection("point").get();
    setState(() {
      pointBalance = userSnap.docs.first.get("pointBalance");
    });
  }
  void rentalAdd()async{
    String date = DateFormat('yyyy-MM-dd').format(selectedDay);
    String startTime = '$date ${(selectedHours.first).toString()+':00'}';
    DateTime startDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(startTime);
    String endTime = '$date ${(selectedHours.last).toString()+':00'}';
    DateTime endDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(endTime);
    fs.collection("commercial_space")
        .doc(widget.document.id)
        .collection("rental")
        .add({
          'artistId' : artistId,
          'cost' : ((selectedHours.last-selectedHours.first)*widget.document.get("rentalfee")),
          'startTime' : startDateTime,
          'endTime' : endDateTime
        });
    QuerySnapshot doc =  await fs.collection("userList").doc(userId).collection("point").limit(1).get();
    fs.collection("userList").doc(userId).collection("point").doc(doc.docs.first.id).update(
        {
          "pointBalance" : pointBalance-((selectedHours.last-selectedHours.first)*widget.document.get("rentalfee"))
        }
    );
    fs.collection("userList").doc(userId).collection("point").doc(doc.docs.first.id).collection("points_details").add(
      {
        "amount" : ((selectedHours.last-selectedHours.first)*widget.document.get("rentalfee")),
        "date" : FieldValue.serverTimestamp(),
        "type" : "예약"
      }
    );
  }
  Widget titleText(String txt){
    return Padding(
      padding: const EdgeInsets.only(top: 20,left: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(txt,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }
  Widget calendar(){
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: DateTime.now(),
      firstDay: DateTime.now(),
      lastDay: DateTime(3000),
      headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronVisible: false,
          rightChevronVisible: false,
          headerPadding: EdgeInsets.only(top: 20,bottom: 10),
          titleTextStyle: TextStyle(fontWeight: FontWeight.w700)),

      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        if (selectedDay.isBefore(DateTime.now())) {
          return;
        }
        setState(() {
          this.selectedDay = selectedDay;
          selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
          selectedHours.clear();
          rentalCheck();
        });
      },

      selectedDayPredicate: (DateTime date) {
        if (date.isBefore(DateTime.now())) {
          return false; // 오늘 이전의 날짜는 비활성화
        }
        return date.year == selectedDay.year &&
            date.month == selectedDay.month &&
            date.day == selectedDay.day;
      },
      calendarBuilders: CalendarBuilders(
        disabledBuilder: (context, date, _) {
          if (date.isBefore(DateTime.now())) {
            return Container(
              margin: const EdgeInsets.all(2.0),
              alignment: Alignment.center,
              child: Text(
                date.day.toString(),
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
  void getAvailableHours() async{
    List<String> hours = await widget.document.get("availableTimeslots").split('~');
    int startHour = int.parse(hours[0].split(':')[0]);
    int endHour = int.parse(hours[1].split(':')[0]);

    List<int> available = List.generate(endHour - startHour + 1, (index) => startHour + index);
    setState(() {
      availableHours = available;
    });
  }
  Future<void> rentalCheck()async{
    checkHours = [];
    DateTime selectedDayPlusOne = selectedDay.add(Duration(days: 1));
    QuerySnapshot checkSnap = await fs
        .collection("commercial_space")
        .doc(widget.document.id)
        .collection("rental")
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDay))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(selectedDayPlusOne))
        .get();
    List<int> checkTime = [];
    if(checkSnap.docs.isNotEmpty){
      for(int i =0; i<checkSnap.docs.length; i++){
        DateTime startDateTime = DateTime.fromMillisecondsSinceEpoch(checkSnap.docs[i].get("startTime").seconds * 1000);
        String startFormattedTime = DateFormat.Hm().format(startDateTime);
        DateTime endDateTime = DateTime.fromMillisecondsSinceEpoch(checkSnap.docs[i].get("endTime").seconds * 1000);
        String endFormattedTime = DateFormat.Hm().format(endDateTime);
        int startHour = int.parse(startFormattedTime.split(':')[0]);
        int endHour = int.parse(endFormattedTime.split(':')[0]);
        for(int i= startHour; i<=endHour; i++){
          checkTime.add(i);
        }
      }
      setState(() {
        checkHours = checkTime;
      });
    }else{
      setState(() {
        checkHours = [];
      });
    }


  }
  Widget rentalTime() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(availableHours.length, (index) {
          int hour = availableHours[index];
          bool isSelected = selectedHours.contains(hour) ||
              (selectedHours.length == 2 &&
                  hour > selectedHours[0] &&
                  hour < selectedHours[1]);
          bool isReserved = checkHours.contains(hour);

          bool checked = checkHours.isNotEmpty?(selectedHours.length == 1) &&
              ((selectedHours[0] > checkHours.first && hour < checkHours.first) ||
                  (selectedHours[0] < checkHours.last && hour > checkHours.last)) : false;

          return ElevatedButton(
            onPressed: isReserved || checked
                ? null // 이미 예약된 시간이거나 선택 불가능한 시간이면 onPressed를 null로 설정하여 버튼을 비활성화
                : () {
              if (selectedHours.contains(hour)) {
                // 이미 선택된 시간을 다시 눌렀을 때, 선택을 취소하고 리스트를 비웁니다.
                setState(() {
                  selectedHours.clear();
                });
              } else {
                if (selectedHours.isEmpty) {
                  // 아무것도 선택되어 있지 않으면 선택한 시간을 추가합니다.
                  setState(() {
                    selectedHours.add(hour);
                  });
                } else if (selectedHours.length == 1) {
                  // 이미 선택된 시간이 있을 경우 선택한 시간들 사이의 시간들을 선택합니다.
                  setState(() {
                    selectedHours.add(hour);
                    selectedHours.sort();
                  });
                } else if (selectedHours.length == 2) {
                  // 이미 두 개의 시간이 선택된 경우, 선택된 시간을 초기화하고 다시 선택합니다.
                  setState(() {
                    selectedHours.clear();
                    selectedHours.add(hour);
                  });
                }
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                isSelected
                    ? Color(0xFF233067)
                    : isReserved
                    ? Colors.grey
                    : checked
                    ? Colors.grey
                    : Colors.white,
              ),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // 버튼의 모서리를 둥글게 설정
                  side: BorderSide(color:
                  isSelected
                      ? Color(0xFF233067)
                      : isReserved
                      ? Colors.grey
                      : checked
                      ? Colors.grey
                      : Color(0xFF233067),
                  ), // 버튼의 테두리 색상 설정
                ),
              ),
            ),
            child: Text(
              hour.toString() + ':00',
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isReserved
                    ? Colors.black38
                    : checked
                    ? Colors.black38
                    : Color(0xFF233067),
              ),
            ),
          );
        })
      ),
    );
  }
}
