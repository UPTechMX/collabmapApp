import 'package:flutter/material.dart';
import 'package:siap_monitoring/views/questionnaires/targets/targetsElemsList.dart';
import 'package:siap_monitoring/views/barra.dart';
import 'package:siap_monitoring/models/cuestionario/checklist.dart';
import 'package:siap_monitoring/views/contestaCuestionario/bloques.dart';
import 'package:siap_monitoring/views/contestaCuestionario/areas.dart';
import 'package:siap_monitoring/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap_monitoring/views/contestaCuestionario/pregunta.dart';

class ContestaCuestionario extends StatelessWidget {
  int vId;
//  String etapa;
  Checklist chk;
  Map areas = new Map();
  Map bloquesAct = new Map();
  Map areasAct = new Map();

  GlobalKey<BloquesBtnState> KeyBloques;
  GlobalKey<AreasState> KeyAreas;
  GlobalKey<PreguntasContState> KeyPreguntas;
  GlobalKey<PreguntaState> KeyPregunta;

  ContestaCuestionario({
    this.vId,
//    this.etapa,
    this.KeyBloques,
    this.KeyAreas,
    this.KeyPreguntas,
    this.KeyPregunta,
  }) {
//    this._vId = vId;
//    this._etapa = etapa;
    this.chk = new Checklist(this.vId);

    areas['_datGral_'] = new Map();
    areas['_datGral_']['nombre'] = 'Datos generales';
    this.bloquesAct['__general__'] = 1;
    this.areasAct['_datGral_'] = 1;
  }

  @override
  Widget build(BuildContext context) {
//    print('bb');
    return SafeArea(
      child: Scaffold(
        appBar: Barra(),
//      drawer: Opciones(_nivel,_accion),

        body: new Center(
          child: new ListView(
            children: <Widget>[
              Container(
                height: 60.0,
                child: BloquesBtn(
                    chk: chk,
                    key: KeyBloques,
                    KeyAreas: KeyAreas,
                    KeyPreguntas: KeyPreguntas,
                    KeyPregunta: KeyPregunta,
                    bloquesAct: bloquesAct,
                    activo: '__general__'),
              ),
              Container(
                height: 60,
                child: Areas(
                    chk: chk,
                    key: KeyAreas,
                    KeyBloques: KeyBloques,
                    KeyPreguntas: KeyPreguntas,
                    KeyPregunta: KeyPregunta,
                    areas: areas,
                    areasAct: areasAct,
                    activo: '_datGral_'),
              ),
              Container(
                child: PreguntasCont(
                  key: KeyPreguntas,
                  keyAreas: KeyAreas,
                  keyBloques: KeyBloques,
                  keyPregunta: KeyPregunta,
                  pagina: 'preguntas',
                  bId: 'bId',
                  aId: 'aId',
                  pId: 'pId',
                  chk: chk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
