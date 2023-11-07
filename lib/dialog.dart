import 'package:flutter/material.dart';

import 'login.dart';

class DialogHelper {
  static void showArtistRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 330,
                  height: 45,
                  color: Colors.black12,
                  child:Padding(
                    padding: const EdgeInsets.fromLTRB(8, 13, 0, 0),
                    child: Text("알림",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 20, 0),
                  child: Text("아티스트 등록을 먼저 한 후에 이용이 가능합니다."),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 20, 30),
                  child: Text("아티스트 등록 페이지로 이동하시겠습니까?"),
                ),
                Container(
                  color: Colors.black12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 4, 5),
                        child: ElevatedButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text("취소")
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 8, 5),
                        child: ElevatedButton(
                          onPressed: (){},
                          child: Text("확인"),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
  static void showUserRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 330,
                  height: 45,
                  color: Colors.black12,
                  child:Padding(
                    padding: const EdgeInsets.fromLTRB(8, 13, 0, 0),
                    child: Text("알림",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 20, 0),
                  child: Text("로그인 후 이용 가능 합니다"),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 20, 30),
                  child: Text("로그인 페이지로 이동하시겠습니까?"),
                ),
                Container(
                  color: Colors.black12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 4, 5),
                        child: ElevatedButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text("취소")
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 8, 5),
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                          },
                          child: Text("확인"),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}