import 'package:flutter/material.dart';

class Support extends StatefulWidget {
  const Support({Key? key}) : super(key: key);

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  List<bool> showAdditionalText = [false, false]; // 각 질문에 대한 상태

  void toggleAdditionalText(int index) {
    setState(() {
      showAdditionalText[index] = !showAdditionalText[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
      ),
      body: Column(
        children: [
          for (var i = 0; i < showAdditionalText.length; i++)
            Column(
              children: [
                GestureDetector(
                  onTap: () => toggleAdditionalText(i),
                  child: Text(
                    '질문 $i', // 여기에 질문을 입력하세요
                    style: TextStyle(
                      color: Colors.blue, // 클릭 가능한 텍스트 색상
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                if (showAdditionalText[i])
                  Text(
                    '답변 $i', // 여기에 대답을 입력하세요
                  ),
              ],
            ),
        ],
      ),
    );
  }
}