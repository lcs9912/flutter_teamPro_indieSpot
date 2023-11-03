import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';

class ExchangeInformation extends StatefulWidget {
  final String point;
  const ExchangeInformation(this.point, {super.key});

  @override
  State<ExchangeInformation> createState() => _ExchangeInformationState();
}

class _ExchangeInformationState extends State<ExchangeInformation> {
  final _name = TextEditingController(); //이름
  final _juminbeonho = TextEditingController(); //주민번호
  final _phone = TextEditingController(); //전화번호
  final _bankName = TextEditingController(); // 은행이름
  final _accountHolder = TextEditingController(); //예금주
  final _accountNumber = TextEditingController(); //계좌번호

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: _appBar(),
      body: ListView(
        children: [
          Row(
            children: [
              Expanded(child: ElevatedButton(
                style: ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(Size(0, 48)),
                    backgroundColor: MaterialStatePropertyAll(Color(0xFF392F31)),
                    elevation: MaterialStatePropertyAll(0),
                    shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero
                        )
                    )
                ),
                onPressed: () {
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: Text('환전 신청'),
                      content: Text('환전 신청하시겠습니까?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('취소')),
                        TextButton(onPressed: (){
                          //_addBuskingSpot();
                          Navigator.of(context).pop();
                        }, child: Text('환전')),
                      ],
                    );
                  },);
                },
                child: Text('환전신청 ', style: TextStyle(fontSize: 17),),
              ),)
            ],
          )
        ],
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }

  AppBar _appBar() {
    return AppBar(
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
        '정보입력',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}
