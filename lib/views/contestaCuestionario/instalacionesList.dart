import 'package:flutter/material.dart';
import 'package:siap/models/cuestionario/checklist.dart';
import 'package:siap/views/contestaCuestionario/bloques.dart';
import 'package:siap/views/contestaCuestionario/areas.dart';
import 'package:siap/views/contestaCuestionario/pregunta.dart';
import 'package:siap/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/views/contestaCuestionario/instalacion.dart';
import 'package:siap/views/surveys/surveys.dart';

class InstalacionesList extends StatefulWidget {
  Checklist chk;
  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<PreguntaState> keyPregunta;
  GlobalKey<PreguntasContState> keyPreguntas;
  GlobalKey<SurveysState> keySurvey;

  InstalacionesList({
    this.chk,
    this.keyBloques,
    this.keyAreas,
    this.keyPreguntas,
    this.keyPregunta,
    this.keySurvey,
  });

  @override
  InstalacionesListState createState() => InstalacionesListState(
        chk: chk,
        keyPreguntas: key,
        keyAreas: keyAreas,
        keyBloques: keyBloques,
        keyPregunta: keyPregunta,
        keySurvey: keySurvey,
      );
}

class InstalacionesListState extends State<InstalacionesList> {
  Checklist chk;
  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<PreguntaState> keyPregunta;
  GlobalKey<PreguntasContState> keyPreguntas;
  GlobalKey<SurveysState> keySurvey;

  var db = DB.instance;

  var datosChk;
  int chkId;

  InstalacionesListState(
      {this.chk,
      this.keyBloques,
      this.keyAreas,
      this.keyPreguntas,
      this.keyPregunta,
      this.keySurvey});

  @override
  Widget build(BuildContext context) {
    getInstalaciones();
    return FutureBuilder<List>(
      future: getInstalaciones(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: Text('No se encontraron instalaciones.'));
        return Column(
          children: snapshot.data.map((inst) {
//            print(inst);
            return Instalacion(
              chk: chk,
              instId: inst['id'],
              nombre: inst['nombre'],
            );
            ;
          }).toList(),
        );
      },
    );
  }

  Future<List> getInstalaciones() async {
    datosChk = await chk.datosVisita(false);
    chkId = await chk.chkId();

    var insts = await db.query(
        'SELECT * FROM Instalaciones WHERE proyectosId = ${datosChk['proyectosId']}');
//    print(insts);
    return insts;
  }
}
