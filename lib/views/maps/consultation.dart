import 'package:flutter/material.dart';
import 'map.dart';
import 'botones.dart';
import 'appBar.dart';
import 'dart:io';
import 'drawerEdt.dart';

//import 'package:siap/pages/tap_to_add.dart';


class Consultation extends StatefulWidget {

  Map datos;
  File tiles;
  List problems;
  Map question;


  Consultation({
    this.datos,
    this.tiles,
    this.problems,
    this.question,
  });

  @override
  ConsultationState createState() => ConsultationState(
    question: question,
    problems: problems,
  );
}

class ConsultationState extends State<Consultation>{

  GlobalKey<MapWidgetState> keyMapa = GlobalKey();

  Map question;
  List problems;
  ConsultationState({this.question,this.problems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Barra(),
//      drawer: Opciones(_nivel,_accion),
      body: MapWidget(
        key:keyMapa,
        datos: widget.datos,
        tiles: widget.tiles,
        problems: problems,
        question: question,
        spatial: false,
      ),
      drawer: DrawerEdt(question: widget.question,keyMapa: keyMapa,),
//      body: Container(),
//      floatingActionButton: FancyFab(keyMapa: keyMapa,context: context,),
    );

  }
}