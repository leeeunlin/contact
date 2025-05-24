import 'package:flutter/material.dart';

TextStyle headerText({Color? color}) {
  return TextStyle(
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: color ?? Colors.black,
  );
}

TextStyle textButton({Color? color}) {
  return TextStyle(
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: color ?? Colors.black,
  );
}
