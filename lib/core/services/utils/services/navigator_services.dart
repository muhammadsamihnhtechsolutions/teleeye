import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class NavigatorServices {
  void to({
    required BuildContext context,
    required Widget widget,
  }) {
    Navigator.of(context).push(
      PageTransition(
        child: widget,
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 100),
      ),
    );
  }

  toReplacement({
    required BuildContext context,
    required Widget widget,
  }) {
    Navigator.of(context).pushReplacement(
      PageTransition(
        child: widget,
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 100),
      ),
    );
  }

  void toPushAndRemoveUntil({
    required BuildContext context,
    required Widget widget,
  }) {
    Navigator.of(context).pushAndRemoveUntil(
        PageTransition(
          child: widget,
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 100),
        ),
        ModalRoute.withName('/'));
  }

  void pop({
    required BuildContext context,
  }) {
    Navigator.pop(context);
  }
}
