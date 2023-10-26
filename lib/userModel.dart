import 'package:flutter/cupertino.dart';

class UserModel with ChangeNotifier{
  String? _userEmail;
  String? get userEmail => _userEmail;
  bool get isLogin => _userEmail != null;

  void login(String email){
    _userEmail = email;
    notifyListeners();
  }

  logout(){
    _userEmail = null;
    notifyListeners();
  }
}