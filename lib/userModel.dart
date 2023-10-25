import 'package:flutter/cupertino.dart';

class UserModel with ChangeNotifier{
  String? _userId;
  String? get userId => _userId;
  bool get isLogin => _userId != null;

  void login(String id){
    _userId = id;
    notifyListeners();
  }

  void logout(){
    _userId = null;
    notifyListeners();
  }
}