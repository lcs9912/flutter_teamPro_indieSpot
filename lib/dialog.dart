import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:get/get.dart';

import 'artistRegi.dart';
import 'login.dart';

class DialogHelper {
  static void showArtistRegistrationDialog(BuildContext context) {
    Dialogs.materialDialog(
        color: Colors.white,
        msg: '아티스트 등록 후 이용해주세요.',
        title: '아티스트 등록 후 이용가능',
        lottieBuilder: Lottie.asset(
          'assets/Animation - 1699599464228.json',
          fit: BoxFit.contain,
        ),
        context: context,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: '취소',
            iconData: Icons.done,
            color: Color(0xFF233067),
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
          IconsButton(
            onPressed: () {
              Get.to(
                  ArtistRegi(), //이동하려는 페이지
                  preventDuplicates: true, //중복 페이지 이동 방지
                  transition: Transition.noTransition //이동애니메이션off
              )?.then((value) => Get.back());

            },
            text: '아티스트 등록',
            iconData: Icons.done,
            color: Color(0xFF233067),
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
  }
  static void showUserRegistrationDialog(BuildContext context) {
    Dialogs.materialDialog(
        color: Colors.white,
        msg: '로그인 후 이용해주세요.',
        title: '로그인 후 이용가능',
        lottieBuilder: Lottie.asset(
          'assets/Animation - 1699599464228.json',
          fit: BoxFit.contain,
        ),
        context: context,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: '취소',
            iconData: Icons.done,
            color: Color(0xFF233067),
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
          IconsButton(
            onPressed: () {
              Get.to(
                  LoginPage(), //이동하려는 페이지
                  preventDuplicates: true, //중복 페이지 이동 방지
                  transition: Transition.noTransition //이동애니메이션off
              );
            },
            text: '로그인',
            iconData: Icons.done,
            color: Color(0xFF233067),
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
  }

  static void showArtistLeaderRegistrationDialog(BuildContext context) {
    Dialogs.materialDialog(
        color: Colors.white,
        title: '리더만 이용이 가능합니다.',
        lottieBuilder: Lottie.asset(
          'assets/Animation - 1699599464228.json',
          fit: BoxFit.contain,
        ),
        context: context,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: '확인',
            iconData: Icons.done,
            color: Color(0xFF233067),
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
  }
}