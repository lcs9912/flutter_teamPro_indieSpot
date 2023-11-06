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
              child: Text(_isVisible ? '숨기기' : '보이기'),
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
            ),
            _isVisible
                ? ScaleTransition(
              scale: _controller.drive(
                Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ),
              ),
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
              ),
            )
                : Container(), // 또는 SizedBox.shrink() 사용
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
