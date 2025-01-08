import 'package:flutter/material.dart';

var primaryColor = const Color(0xFF578E7E);
var secondaryColor = const Color.fromARGB(255, 249, 248, 244);
var accentColor = const Color(0xFF3D3D3D);
var backgroundColor = const Color(0xFFFFFAEC);
var warningColor = const Color(0xFFFFE4B2);
var dangerColor = const Color.fromARGB(255, 248, 108, 108);
var successColor = const Color.fromARGB(255, 87, 155, 98);
var greyColor = const Color(0xFF3D3D3D);

TextStyle headerStyle({int level = 1, bool dark = true}) {
  List<double> levelSize = [30, 24, 20, 14, 12];

  return TextStyle(
      fontSize: levelSize[level - 1],
      fontWeight: FontWeight.bold,
      color: dark ? Colors.black : Colors.white);
}

var buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 15),
    backgroundColor: primaryColor);
