import 'package:flutter/material.dart';
import 'map.dart';
import 'botones.dart';
import 'appBar.dart';
import 'dart:io';
import 'drawerEdt.dart';

//import 'package:siap/pages/tap_to_add.dart';


class Consultation extends StatefulWidget {

  GlobalKey<MapWidgetState> keyMapa = GlobalKey();
  File tiles;
  List problems = [];
  var question;
  Map spatialData;
  var vId;
  Map datos;

  Consultation({
    this.keyMapa,
    this.datos,
    this.tiles,
    this.problems,
    this.question,
    this.spatialData,
    this.vId,
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
//        key:keyMapa,
//        datos: widget.datos,
//        tiles: widget.tiles,
//        problems: problems,
//        question: question,
//        spatial: false,

        key: keyMapa,
        tiles: widget.tiles,
        spatialData: widget.spatialData,
        problems: widget.problems,
        question: widget.question,
        spatial: false,
        vId:widget.vId

      ),
      drawer: DrawerEdt(question: widget.question,keyMapa: keyMapa,vId: widget.vId,),
//      body: Container(),
//      floatingActionButton: FancyFab(keyMapa: keyMapa,context: context,),
    );

  }
}