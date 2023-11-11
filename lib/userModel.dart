import 'package:flutter/cupertino.dart';

class UserModel with ChangeNotifier{
  String? _userId;
  String? _artistId;
  String? _artLeader;
  String? _admin;
  String? get userId => _userId;
  String? get artistId => _artistId;
  bool get isAdmin => _admin != null;
  bool get isLogin => _userId != null;
  bool get isArtist => _artistId != null;
  bool get isLeader => (_artistId != null && _artLeader == 'Y');

  void login(String userId, String? admin){
    _userId = userId;
    _admin = admin;
    notifyListeners();
  }

  void loginArtist(String userId, String artistId, String status, String? admin){
    _userId = userId;
    _artistId = artistId;
    _artLeader = status;
    _admin = admin;
    notifyListeners();
  }

  logout(){
    _userId = null;
    _artistId = null;
    _admin = null;
    _artLeader = null;
    notifyListeners();
  }
}