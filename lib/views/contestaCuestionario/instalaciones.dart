import 'package:flutter/material.dart';
import 'package:siap/models/cuestionario/checklist.dart';
import 'package:siap/views/contestaCuestionario/bloques.dart';
import 'package:siap/views/contestaCuestionario/areas.dart';
import 'package:siap/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap/views/contestaCuestionario/instalacionesList.dart';
import 'package:siap/views/contestaCuestionario/instalacionSel.dart';
import 'package:siap/views/surveys/surveys.dart';

class Instalaciones extends StatefulWidget {
  Checklist chk;
  GlobalKey<PreguntasContState> keyPreguntas;
  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<SurveysState> keySurvey;

  Instalaciones(
      {this.chk,
      this.keyPreguntas,
      this.keyBloques,
      this.keyAreas,
      this.keySurvey});

  @override
  InstalacionesState createState() => InstalacionesState(
      chk: chk,
      keyPreguntas: keyPreguntas,
      keyBloques: keyBloques,
      keyAreas: keyAreas,
      keySurvey: keySurvey);
}

class InstalacionesState extends State<Instalaciones> {
  Checklist chk;
  GlobalKey<PreguntasContState> keyPreguntas;
  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<SurveysState> keySurvey;

  var datosChk;
  int chkId;

  InstalacionesState(
      {this.chk,
      this.keyPreguntas,
      this.keyBloques,
      this.keyAreas,
      this.keySurvey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InstalacionSel(
            chk: chk,
            keyPreguntas: keyPreguntas,
            keyBloques: keyBloques,
            keyAreas: keyAreas,
            keySurvey: keySurvey,
          ),
          InstalacionesList(
            chk: chk,
            keyPreguntas: widget.key,
          )
        ],
      ),
    );
  }
}
