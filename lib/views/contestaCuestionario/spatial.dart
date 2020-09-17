import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:siap/models/conexiones/api.dart';
import 'package:siap/views/maps/map.dart';
import 'package:siap/models/translations.dart';
import 'package:latlong/latlong.dart';
import 'package:siap/views/maps/consultation.dart';

class Spatial extends StatelessWidget {

  var value;
  var question;
  var setValue;
  int vId;
  bool spatial;
  GlobalKey<MapWidgetState> keyMapa = GlobalKey();

  Spatial({
    this.value,
    this.question,
    this.setValue,
    this.spatial = false,
    this.vId,
  });


  @override
  Widget build(BuildContext context) {

//    List sdl = jsonDecode(question['spatial_data']);
//    Map sd = sdl[0];
//
//    var spatialData = {
//      "study_area": sd['study_area'],
//      "center": sd['center'],
//      "zoom": sd['zoom'],
//      "edit_inputs": true
//    };

//    var acomodado = acomodaDatos(datos: spatialData);
//    getProblems(question: question);
//      print(question);
//      print(vId);

    return FutureBuilder(
      future: getSpatialData(pregId: question['id'],vId:vId),
      builder: (context,snapshot){
//        setValue('${question['type']}');
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text(Translations.of(context).text('waiting'));
          case ConnectionState.done:
            if (snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }
//            print('SNAPSHOT: ${snapshot.data}');
//            print('question: ${question}');
//            print('FILE: ${snapshot.data['mapFile']}');
//            return Text('aa');
            return RaisedButton(
              onPressed: (){
                Navigator.push(context,
                  new MaterialPageRoute(builder: (context)=>Consultation(
//                    datos:acomodado,
//                    tiles: snapshot.data['mapFile'],
//                    problems:snapshot.data['problems'],
//                    question: question,

                    keyMapa: keyMapa,
                    tiles: snapshot.data['mapFile'],
                    spatialData: snapshot.data,
                    problems: snapshot.data['problems'],
                    question: question,
                    vId:vId

                  )));
              },
              child: Text('ir al mapa'),
            );

//            return question['tipo'] == 'cm'?RaisedButton(
//              onPressed: (){
//                Navigator.push(context,
//                  new MaterialPageRoute(builder: (context)=>Consultation(
////                    datos:acomodado,
////                    tiles: snapshot.data['mapFile'],
////                    problems:snapshot.data['problems'],
////                    question: question,
//
//                    keyMapa: keyMapa,
//                    tiles: snapshot.data['mapFile'],
//                    spatialData: snapshot.data,
//                    problems: snapshot.data['problems'],
//                    question: question,
//                    vId:vId
//
//                  )));
//              },
//              child: Text('ir al mapa'),
//            )
//            :Container(
//              height: MediaQuery.of(context).size.height*.55,
//              width: double.infinity,
//              child: MapWidget(
//                key: keyMapa,
//                tiles: snapshot.data['mapFile'],
//                spatialData: snapshot.data,
//                problems: snapshot.data['problems'],
//                question: question,
//                spatial: true,
//                vId:vId
//              ),
//            );
        }
        return Column();
      },
    );

    return Container();
  }

}
