import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'baseBar.dart';
import 'package:intl/intl.dart';

class SpaceRental extends StatefulWidget {
  DocumentSnapshot document;
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAvailableHours();
    rentalCheck();
  }
  @override
  Widget build(BuildContext context) {
    print(checkHours);
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
        title: Text(
          '장소 예약',
          style: TextStyle(color: Colors.black,),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20,left: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("예약 날짜",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: calendar(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20,left: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("예약 시간",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          rentalTime()
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  Widget calendar(){
    final bool leftChevronVisible;
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
        if (selectedDay == null) {
          return false;
        }
        return date.year == selectedDay!.year &&
            date.month == selectedDay!.month &&
            date.day == selectedDay!.day;
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
        print(startHour);
        print(endHour);
        checkTime.add(startHour);
        checkTime.add(endHour);
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
          bool isBetweenRange = selectedHours.isNotEmpty &&
              hour > selectedHours[0] &&
              hour < selectedHours[selectedHours.length - 1];
          bool isReserved = checkHours.contains(hour)||(checkHours.length == 2 &&
              hour > checkHours[0] &&
              hour < checkHours[1]);
          return ElevatedButton(
            onPressed: isReserved
                ? null // 만약 이미 예약된 시간이면 onPressed를 null로 설정하여 버튼을 비활성화
                : () {
              if (selectedHours.contains(hour)) {
                // 이미 선택된 시간을 다시 눌렀을 때, 선택을 취소하고 리스트를 비웁니다.
                setState(() {
                  selectedHours.clear();
                  print(selectedHours);
                });
              } else {
                if (selectedHours.isEmpty) {
                  // 아무것도 선택되어 있지 않으면 선택한 시간을 추가합니다.
                  setState(() {
                    selectedHours.add(hour);
                    print(selectedHours);
                  });
                } else if (selectedHours.length == 1) {
                  // 이미 선택된 시간이 있을 경우 선택한 시간들 사이의 시간들을 선택합니다.
                  for(int i=checkHours[0]; i< checkHours[1]; i++){
                    print(checkHours[0]);
                    print(checkHours[1]);
                  }
                  setState(() {
                    selectedHours.add(hour);
                    selectedHours.sort();
                    print(selectedHours);
                  });
                }else if(selectedHours.length == 2){
                  setState(() {
                    selectedHours.clear();
                    selectedHours.add(hour);
                  });
                  print(selectedHours);
                }
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                isSelected
                    ? Colors.green
                    : isBetweenRange
                    ? Colors.orange
                    : isReserved ? Colors.grey : Colors.blue,
              ),
            ),
            child: Text(
              hour.toString() + ':00',
            ),
          );
        }
        ),
      ),
    );
  }
}
