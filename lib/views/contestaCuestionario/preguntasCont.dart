import 'package:flutter/material.dart';
import 'package:siap_monitoring/views/questionnaires/targets/userTarget.dart';
import 'package:siap_monitoring/views/questionnaires/targets/targetsElemsList.dart';
import 'package:siap_monitoring/models/cuestionario/checklist.dart';
import 'package:siap_monitoring/views/contestaCuestionario/pregunta.dart';
import 'package:siap_monitoring/views/contestaCuestionario/bloques.dart';
import 'package:siap_monitoring/views/contestaCuestionario/areas.dart';
import 'package:siap_monitoring/views/contestaCuestionario/general.dart';
import 'package:siap_monitoring/views/contestaCuestionario/fotografias.dart';
import 'package:siap_monitoring/views/contestaCuestionario/instalaciones.dart';

class PreguntasCont extends StatefulWidget {
  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<PreguntaState> keyPregunta;
  GlobalKey<PreguntasContState> llave;
  GlobalKey<UserTargetState> keyUser;

  Checklist chk;
  String bId;
  String aId;
  String pId;
  String pagina;

  PreguntasCont({
    Key key,
    this.chk,
    this.bId,
    this.aId,
    this.pId,
    this.pagina,
    this.keyAreas,
    this.keyBloques,
    this.keyPregunta,
    this.keyUser,
  }) : super(key: key);

  @override
  PreguntasContState createState() => PreguntasContState(
        chk: chk,
        bId: bId,
        aId: aId,
        pId: pId,
        pagina: pagina,
      );
}

class PreguntasContState extends State<PreguntasCont> {
  String bId;
  String aId;
  String pId;
  Checklist chk;
  String pagina;

  PreguntasContState({this.chk, this.bId, this.aId, this.pId, this.pagina});

  TextEditingController justificacionControlador = TextEditingController();

  @override
  Widget build(BuildContext context) {
//    print('PAGINA $pagina');
    switch (pagina) {
      case 'preguntas':
//        print(chk.est);
        return Center(
          child: Pregunta(
            key: widget.keyPregunta,
            chk: chk,
            KeyPreguntas: widget.key,
            keyAreas: widget.keyAreas,
            keyBloques: widget.keyBloques,
            keyUser: widget.keyUser,
          ),
        );
      case 'general':
        return General(
          chk: chk,
          keyPreguntas: widget.key,
          keyAreas: widget.keyAreas,
          keyBloques: widget.keyBloques,
          keyPregunta: widget.keyPregunta,
          keyUser: widget.keyUser,
        );
      case 'instalacion':
        return Instalaciones(
          chk: chk,
          keyAreas: widget.keyAreas,
          keyBloques: widget.keyBloques,
          keyPreguntas: widget.key,
          keyUser: widget.keyUser,
        );
      case 'fotografias':
        return Fotografias(
          chk: chk,
          keyPreguntas: widget.key,
          keyAreas: widget.keyAreas,
          keyBloques: widget.keyBloques,
          keyUser: widget.keyUser,
        );
    }
  }

  cambiaPagina(pag) {
    setState(() {
      pagina = pag;
    });
  }
}
