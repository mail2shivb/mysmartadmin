import 'package:flutter/material.dart';

class ProtoRadius {
  ProtoRadius._();
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double xxl = 28;

  static BorderRadius all(double r) => BorderRadius.all(Radius.circular(r));
  static BorderRadius topSheet(double r) =>
      BorderRadius.vertical(top: Radius.circular(r));
}
