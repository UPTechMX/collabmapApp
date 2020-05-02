import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class Icono extends StatelessWidget{
  String svgName;
  Color color;
  double width;
  Icono({
    this.svgName,
    this.color = Colors.white,
    this.width = 20,
  });
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'images/icons/${svgName}.svg',
      width: width,
      color: color,
    );
  }
}