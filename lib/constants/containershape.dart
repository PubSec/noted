import 'package:flutter/material.dart';
import 'package:noted/constants/mycolors.dart';

dynamic myContainer({required Widget child}) {
  return Container(
    transformAlignment: Alignment.center,
    margin: const EdgeInsets.fromLTRB(0, 100, 0, 0),
    decoration: const BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.all(Radius.circular(23))),
    height: 325,
    width: 500,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(25),
    child: child,
  );
}
