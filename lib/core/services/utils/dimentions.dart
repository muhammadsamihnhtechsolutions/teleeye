import 'package:flutter/material.dart';

double getHeight({required BuildContext context}) {
  return MediaQuery.of(context).size.height;
}

double getWidth({required BuildContext context}) {
  return MediaQuery.of(context).size.width;
}
