import 'package:flutter/material.dart';
import 'package:siap/models/cuestionario/checklist.dart';
import 'package:siap/views/contestaCuestionario/bloques.dart';
import 'package:siap/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap/views/contestaCuestionario/pregunta.dart';
import 'package:siap/views/surveys/surveys.dart';

class Areas extends StatefulWidget {
  Checklist chk;
  Map areas;
  String bloqueId;
  GlobalKey<BloquesBtnState> KeyBloques;
  GlobalKey<PreguntasContState> KeyPreguntas;
  GlobalKey<PreguntaState> KeyPregunta;
  GlobalKey<SurveysState> KeySurvey;

  Map areasAct = new Map();
  String activo;

  Areas(
      {Key key,
      this.areas,
      this.bloqueId,
      this.chk,
      this.KeyBloques,
      this.KeyPreguntas,
      this.KeyPregunta,
      this.KeySurvey,
      this.areasAct,
      this.activo})
      : super(key: key);

  @override
  AreasState createState() => AreasState(
        areas: areas,
        chk: chk,
        bloqueId: bloqueId,
        areasAct: areasAct,
        activo: activo,
      );
}

class AreasState extends State<Areas> {
  Map areas;
  Checklist chk;
  int cuenta;
  String bloqueId;

  Map areasAct = new Map();
  String activo;

  AreasState(
      {this.areas, this.bloqueId, this.chk, this.areasAct, this.activo}) {
    areasAct['_fotos_'] = 1;
    areasAct['_datGral_'] = 1;
    areasAct['_insts_'] = 1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: areasList(areas),
      builder: (context, snapshot) {
//        print('snapshot : ${snapshot.data}');
        if (!snapshot.hasData)
          return Center(child: Text('No se encontraron áreas.'));
        return ListView(
            scrollDirection: Axis.horizontal,
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: snapshot.data.map((area) {
//                      print('AreasAct : $areasAct');
//                      print('Area Activa : $activo');
              return Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: FlatButton(
                    onPressed: () {
                      if (areasAct[area['identificador']] == 1) {
                        setState(() {
                          activo = area['identificador'];
                        });
                        clickArea(area);
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 10, bottom: 5),
                          child: Text(
                            area['nombre'],
                            style: TextStyle(
                              color: areasAct[area['identificador']] == 1
                                  ? Colors.green
                                  : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color: this.activo == area['identificador']
                                ? Colors.green
                                : Colors.transparent,
                          ),
                        )
                      ],
                    )),
              );
            }).toList());
      },
    );
  }

  Future<List> areasList(areas) async {
//    print(areas);

    List lista = [];
    areas.forEach((k, v) {
      v['identificador'] = k;
      lista.add(v);
    });
    return lista;
  }

  void actualizaAreas(Areas) {
    setState(() {
      areas = Areas;
    });
  }

  updAreasAct(String identificador) {
    setState(() {
      this.areasAct[identificador] = 1;
    });
  }

  updAreaActivo(String identificador) {
    setState(() {
      this.activo = identificador;
    });
  }

  clickArea(area) async {
    if (area['identificador'] != '_datGral_') {
      var pregs = await chk.resultados(true);
      var pId;
      for (var i in area['preguntas'].keys) {
        pId = i;
        break;
      }
      var preg = pregs[pId];
      if (preg['muestra'] == 1) {
        widget.KeyPregunta.currentState.cambiaPregunta(pId, 'siguiente');
      } else {
        var p = chk.sigPregSaltos(pId, pregs);
        if (p['pId'] != null) {
          widget.KeyPregunta.currentState.cambiaPregunta(p['pId'], 'siguiente');
          widget.KeyBloques.currentState.updBloqueActivo(p['bId']);
          var est = await chk.estructura();
          var areas = est['bloques'][p['bId']]['areas'];
          actualizaAreas(areas);
          updAreaActivo(p['aId']);
        }
      }
    }
  }
}
