import 'package:flutter/cupertino.dart';

class UserModel with ChangeNotifier{
  String? _userId;
  String? _artistId;
  String? get userId => _userId;
  String? get artistId => _artistId;
  bool get isLogin => _userId != null;
  bool get isArtist => _artistId != null;

  void login(String userId){
    _userId = userId;
    notifyListeners();
  }

  void loginArtist(String userId, String artistId){
    _userId = userId;
    _artistId = artistId;
    notifyListeners();
  }

  logout(){
    _userId = null;
    _artistId = null;
    notifyListeners();
  }
}