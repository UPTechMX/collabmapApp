import 'package:flutter/material.dart';
import 'package:siap/models/cuestionario/checklist.dart';
import 'package:siap/views/contestaCuestionario/pregunta.dart';
import 'package:siap/views/contestaCuestionario/bloques.dart';
import 'package:siap/views/contestaCuestionario/areas.dart';
import 'package:siap/views/contestaCuestionario/general.dart';
import 'package:siap/views/contestaCuestionario/fotografias.dart';
import 'package:siap/views/contestaCuestionario/instalaciones.dart';


class PreguntasCont extends StatefulWidget{

  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<PreguntaState> keyPregunta;
  GlobalKey<PreguntasContState> llave;


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
  }) : super(key:key);

  @override
  PreguntasContState createState() => PreguntasContState(
    chk:chk,
    bId:bId,
    aId:aId,
    pId:pId,
    pagina:pagina,
  );

}

class PreguntasContState extends State<PreguntasCont>{

  String bId;
  String aId;
  String pId;
  Checklist chk;
  String pagina;

  PreguntasContState({
    this.chk,
    this.bId,
    this.aId,
    this.pId,
    this.pagina
  });

  TextEditingController justificacionControlador = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
//    print('PAGINA $pagina');
    switch(pagina){
      case 'preguntas':
//        print(chk.est);
        return Center(
          child: Pregunta(
            key:widget.keyPregunta,
            chk: chk,
            KeyPreguntas: widget.key,
            keyAreas: widget.keyAreas,
            keyBloques: widget.keyBloques,
          ),
        );
      case 'general':
        return General(
          chk: chk,
          keyPreguntas: widget.key,
          keyAreas: widget.keyAreas,
          keyBloques: widget.keyBloques,
          keyPregunta: widget.keyPregunta,
        );
      case 'instalacion':
        return Instalaciones(
          chk: chk,
          keyAreas: widget.keyAreas,
          keyBloques: widget.keyBloques,
          keyPreguntas: widget.key,
        );
      case 'fotografias':
        return Fotografias(
          chk: chk,
          keyPreguntas: widget.key,
          keyAreas: widget.keyAreas,
          keyBloques: widget.keyBloques,
        );
    }

  }

  cambiaPagina(pag){
    setState(() {
      pagina = pag;
    });
  }

}
