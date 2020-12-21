import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/views/maps/map.dart';
import 'package:latlong/latlong.dart';
import 'package:siap_monitoring/views/maps/consultation.dart';
import 'package:siap_monitoring/models/conexiones/api.dart';
import 'dart:convert';


import 'dart:io';
import 'package:path_provider/path_provider.dart';


class CampoRespuesta extends StatelessWidget {

  var question;
  var value;
  var setValue;

  CampoRespuesta({
    this.question,
    this.value,
    this.setValue,
  });

  @override
  Widget build(BuildContext context) {
    print('Tipo preg ${question['type']}, value: $value');

    return Container(
      child: Column(
        children: <Widget>[
//          Text('type: ${question['type']}'),
//        Text('AAA: $value : $question : '),
          SizedBox(height: 15.0),
          question['type'] == 'option'?
            Opt(
              value: value,
              question: question,
              setValue: setValue,
            ):
            Container(),
          question['type'] == 'numeric'?
            Abierta(
              value: value,
              question: question,
              setValue: setValue,
            ):
            Container(),
          question['type'] == 'text'?
            Abierta(
              value: value,
              question: question,
              setValue: setValue,
            ):
            Container(),
          question['type'] == 'bool'?
            Booleana(
              value: value,
              question: question,
              setValue: setValue,
            ):
            Container(),
          question['type'] == 'spatial'?
            Spatial(
              spatial:true,
              value: value,
              question: question,
              setValue: setValue,
            ):
            Container(),
          question['type'] == 'cm'?
            (
                question['spatial_data'] == '[]'?
                Container(
                  child: Text(Translations.of(context).text('underconstruction')),
                ):
                Spatial(
                  spatial:false,
                  value: value,
                  question: question,
                  setValue: setValue,
                )
            ):
            Container(),

        ],
      ),
    );
  }
}

class Opt extends StatefulWidget {
  var value;
  var question;
  var setValue;
  Opt({
    this.value,
    this.question,
    this.setValue,
  });
  @override
  OptState createState() => OptState(value: value);

}

class OptState extends State<Opt> {
  var selected;
  var value;
  OptState({this.value}){
   selected = value;
  }

  @override
  Widget build(BuildContext context) {

    List items = new List<DropdownMenuItem>();
    var cats = jsonDecode(widget.question['options']);
    for(int i = 0;i<cats.length;i++){
      var cat = cats[i];
      var item = DropdownMenuItem(
        child: Text(
          cat['option'],
        ),
        value: cat['id'],
      );
      items.add(item);
    }

    return DropdownButtonFormField(
      items: items,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color(0xFF2568D8),
                width: 2
            )
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0)
        ),
        isDense: true,
      ),
      value: selected,
      hint: Text(Translations.of(context).text('select')),
      onChanged: (valor){
        widget.setValue(valor);
        setState(() {
          selected = valor;
        });
      },
    );
  }
}

class Abierta extends StatelessWidget {

  var value;
  var question;
  var setValue;
  Abierta({
    this.value,
    this.question,
    this.setValue,
  }){
    resp = TextEditingController(text:value == null?null:'$value');
  }

  TextEditingController resp = TextEditingController();

  @override

  Widget build(BuildContext context) {

    return TextField(
      textAlignVertical: TextAlignVertical.top,
      maxLines: question['type'] == 'numeric'?1:15,
      textAlign: TextAlign.justify,
      controller: resp,
      onChanged: (text){
        setValue(text);
      },
      keyboardType: question['type'] == 'numeric'?TextInputType.number:TextInputType.text,
      decoration: InputDecoration(
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF2568D8),
            width: 2
          )
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: Translations.of(context).text("answer"),
//        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        )
      ),
    );

  }
}

class Booleana extends StatefulWidget {

  var value;
  var question;
  var setValue;
  Booleana({
    this.value,
    this.question,
    this.setValue,
  });

  @override
  BooleanaState createState() => BooleanaState(value: value);
}

class BooleanaState extends State<Booleana> {

  var checked;
  var value;
  BooleanaState({this.value}){

    print('VALUE: $value : ${value.runtimeType}');
    if(value == null){
      checked = false;
    }else{
      switch(value){
        case '1':
        case 'true':
          checked = true;
          break;
        case '0':
        case 'false':
        default:
          checked = false;
          break;
      }
    }
//    widget.setValue(checked);
  }

  @override
  Widget build(BuildContext context) {

    widget.setValue(checked);
//    print('CHECKED: $checked');
    return Checkbox(
      value: checked,
      onChanged: (val) {
        print(val);
        widget.setValue(val);
        setState(() {
          checked = val;
        });
      },
    );
  }
}

class Spatial extends StatelessWidget {

  var value;
  var question;
  var setValue;
  bool spatial;
  GlobalKey<MapWidgetState> keyMapa = GlobalKey();

  Spatial({
    this.value,
    this.question,
    this.setValue,
    this.spatial = false,
  });


  @override
  Widget build(BuildContext context) {

    List sdl = jsonDecode(question['spatial_data']);
    Map sd = sdl[0];

    var spatialData = {
      "study_area": sd['study_area'],
      "center": sd['center'],
      "zoom": sd['zoom'],
      "edit_inputs": true
    };

    var acomodado = acomodaDatos(datos: spatialData);
    getProblems(question: question);

    return FutureBuilder(
      future: getProblems(question: question),
      builder: (context,snapshot){
        setValue('${question['type']}');
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
//            print('FILE: ${snapshot.data['mapFile']}');
            return question['type'] == 'cm'?RaisedButton(
              onPressed: (){
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context)=>Consultation(
                        datos:acomodado,
                        tiles: snapshot.data['mapFile'],
                        problems:snapshot.data['problems'],
                        question: question,
                    )));
              },
              child: Text('ir al mapa'),
            ):Container(
                height: MediaQuery.of(context).size.height*.55,
                width: double.infinity,
                child: MapWidget(

                  tiles: snapshot.data['mapFile'],
                  datos: acomodado,
                  problems: snapshot.data['problems'],
                  question: question,
                  spatial: true,
                ),
              );
        }
        return Column();
      },
    );

    return Container();
  }

}

Future<Map> getProblems({Map question}) async {
  DB db = DB.instance;

  var ans = await db.query("SELECT * FROM answers WHERE survey_id = ${question['survey_id']} AND question_id = ${question['id']}");

  var ansId = ans == null?null:ans[0]['id'];


//  await db.query('''DELETE
//      FROM problems
//      WHERE answers_id = ${ansId}
//      AND (del != 1 OR del IS NULL)
//    ''');

  List problemsDB = await db.query('''SELECT *
      FROM problems
      WHERE answers_id = ${ansId}
      AND (del != 1 OR del IS NULL)
    ''');

//  var resp = await db.query('SELECT * FROM answers');
//  db.query("DELETE FROM answers");

//  print('problemsDB: $problemsDB');
  List problems = [];
  if(problemsDB != null){
    for(int i = 0; i<problemsDB.length; i++){
      Map<String, dynamic> problem = Map<String, dynamic>.from(problemsDB[i]);

//      await db.query('DELETE FROM points WHERE problemsId = ${problemsDB[i]['id']}');

      List problemPoints = await db.query("SELECT * FROM points WHERE problemsId = ${problemsDB[i]['id']}");
//      print('problemPoints: $problemPoints');
      List puntos = [];
      if(problemPoints!=null){
        for(int i = 0;i<problemPoints.length;i++){
          Map<String,dynamic> ptTmp = Map();
//          print('aaaaa ${problemPoints[i]['lat']},${problemPoints[i]['lng']}');
          ptTmp['latLng'] = LatLng(problemPoints[i]['lat'],problemPoints[i]['lng']);
          ptTmp['id'] = problemPoints[i]['id'];
          puntos.add(ptTmp);
        }
      }
      problem['points'] = puntos;
      problems.add(problem);
    }
  }

  String dir = (await getApplicationDocumentsDirectory()).path;

  Directory mapsDir = await Directory('${dir}/maps');
  if(!(await mapsDir.exists())){
    mapsDir.create(recursive: true);
  }
  String path = '${dir}/maps';
  File file;
  File mapa = await File('${path}/${question['mapFile']}');
  if( (await mapa.exists()) ){
    file = mapa;
  }else{
    file = null;
  }

  Map r = Map();
  r['problems'] = problems;
  r['mapFile'] = file;

//  print(problems);
  return r;

}









