import 'package:flutter/cupertino.dart';

class UserModel with ChangeNotifier{
  String? _userId;
  String? _artistId;
  String? _artLeader;
  String? get userId => _userId;
  String? get artistId => _artistId;
  bool get isLogin => _userId != null;
  bool get isArtist => _artistId != null;
  bool get isLeader => (_artistId != null && _artLeader == 'Y');

  void login(String userId){
    _userId = userId;
    notifyListeners();
  }

  void loginArtist(String userId, String artistId, String status){
    _userId = userId;
    _artistId = artistId;
    _artLeader = status;
    notifyListeners();
  }

  logout(){
    _userId = null;
    _artistId = null;
    notifyListeners();
  }
}