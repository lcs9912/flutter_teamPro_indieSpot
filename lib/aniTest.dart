import 'package:flutter/material.dart';

class AnimationExample extends StatefulWidget {
  const AnimationExample({super.key});

  @override
  _AnimationExampleState createState() => _AnimationExampleState();
}

class _AnimationExampleState extends State<AnimationExample> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('애니메이션 예제'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (!_isVisible) {
                  _controller.forward(); // 애니메이션 시작
                } else {
                  _controller.reverse(); // 애니메이션 역방향으로 실행
                }
                setState(() {
                  _isVisible = !_isVisible;
                });
              },
              child: Text(_isVisible ? '숨기기' : '보이기'),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1), // 시작 위치 (아래)
                end: Offset(0, 0),  // 끝 위치 (0으로 이동)
              ).animate(_controller),
              child: _icon(), // _icon 위젯을 SlideTransition으로 감쌈
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    return Column(
      children: [
        IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        IconButton(onPressed: () {}, icon: Icon(Icons.add)),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
