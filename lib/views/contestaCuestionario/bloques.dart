import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/cuestionario/checklist.dart';
import 'package:siap_monitoring/views/contestaCuestionario/areas.dart';
import 'package:siap_monitoring/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap_monitoring/views/contestaCuestionario/pregunta.dart';

class BloquesBtn extends StatefulWidget{

  Checklist chk;
  GlobalKey<AreasState> KeyAreas;
  GlobalKey<PreguntasContState> KeyPreguntas;
  GlobalKey<PreguntaState> KeyPregunta;
  Map bloquesAct;
  String activo;

  BloquesBtn({
    Key key,
    this.chk,
    this.KeyAreas,
    this.KeyPreguntas,
    this.KeyPregunta,
    this.bloquesAct,
    this.activo,
  }) : super(key : key);

  @override
  BloquesBtnState createState() => BloquesBtnState(chk:chk,bloquesAct:bloquesAct,activo: activo);

}

class BloquesBtnState extends State<BloquesBtn>{

  Checklist chk;
  Map bloquesAct = new Map();
  String activo;
  BloquesBtnState({this.chk,this.bloquesAct,this.activo}){
    this.bloquesAct['__general__'] = 1;
    this.bloquesAct['__fotografias__'] = 1;
    this.bloquesAct['__instalaciones__'] = 1;
  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder<List>(
      future: bloquesList(),
      builder: (context,snapshot){
        if(!snapshot.hasData) return Center(child: Text('No se encontraron bloques.'));
        return ListView(
            scrollDirection: Axis.horizontal,
            children:snapshot.data.map(
                (bloque){
                  if(bloque['muestra'] == 0){
                    return Container(width: 0,height: 0,);
                  }

                  return Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FlatButton(
                        onPressed: (){
                          if(bloquesAct[bloque['identificador']] == 1){
                            setState(() {
                              activo = bloque['identificador'];
                            });
                            clickBloque(bloque);
                          }
                        },
                        child:Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top:15,bottom: 5),
                              child: Text(
                                bloque['nombre'],
                                style: TextStyle(
                                  color: bloquesAct[bloque['identificador']] == 1?Colors.blue:Colors.grey,
                                ),
                              ),
                            ),
                            Container(
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: this.activo == bloque['identificador']?Colors.blue:Colors.transparent,
                              ),
                            )
                          ],
                        )
                    ),
                  );
                }
            ).toList()
        );
      },
    );
  }

  Future<List> bloquesList() async {

    List bloques = await chk.getBloques();
//    print('Bloques $bloques');
//    List bloques = await chk.getBloquesCalc();
//    print(bloques);
    var datos = await chk.datosChk(false);
//    print('Datos $datos');


    Map bloque = new Map();
    bloque['valor'] = 0;
    bloque['muestra'] = 1;
    bloque['identificador'] = '__general__';
    bloque['nombre'] = 'General';
    bloque['areas'] = new Map();
    bloque['areas']['_datGral_'] = new Map();
    bloque['areas']['_datGral_']['nombre'] = 'Datos generales';
//    bloques.insert(0, bloque);

    if(datos['etapa'] == 'visita' || datos['etapa'] == 'instalacion'){
      bloque = new Map();
      bloque['valor'] = 0;
      bloque['muestra'] = 1;
      bloque['identificador'] = '__instalaciones__';
      bloque['nombre'] = 'Instalación';
      bloque['areas'] = new Map();
      bloque['areas']['_insts_'] = new Map();
      bloque['areas']['_insts_']['nombre'] = 'Instalación';
      bloques.add(bloque);
    }

    bloque = new Map();
    bloque['valor'] = 0;
    bloque['muestra'] = 1;
    bloque['identificador'] = '__fotografias__';
    bloque['nombre'] = 'Fotografías';
    bloque['areas'] = new Map();
    bloque['areas']['_fotos_'] = new Map();
    bloque['areas']['_fotos_']['nombre'] = 'Fotografías';
    bloques.add(bloque);

    return bloques;
  }

  updBloquesAct(String identificador){
    setState(() {
      this.bloquesAct[identificador] = 1;
    });
  }

  updBloqueActivo(String identificador){
    setState(() {
      this.activo = identificador;
    });
  }

  clickBloque(bloque) async {
    widget.KeyAreas.currentState.actualizaAreas(bloque['areas']);
    Map area;
    for(var i in bloque['areas'].keys){
      area = bloque['areas'][i];
      widget.KeyAreas.currentState.updAreaActivo(i);
      break;
    }

    switch(bloque['identificador']){
      case '__general__':
        widget.KeyPreguntas.currentState.cambiaPagina('general');
        break;
      case '__fotografias__':
        widget.KeyPreguntas.currentState.cambiaPagina('fotografias');
        break;
      case '__instalaciones__':
        widget.KeyPreguntas.currentState.cambiaPagina('instalacion');
        break;
      default:
        if(widget.KeyPreguntas.currentState.pagina != 'preguntas'){
          widget.KeyPreguntas.currentState.cambiaPagina('preguntas');
        }

        var pregs = await chk.resultados(true);

        var pId;
        for(var i in area['preguntas'].keys){
          pId = i;
          break;
        }
        var preg = pregs[pId];
        if(preg['muestra'] == 1){

          widget.KeyPregunta.currentState.cambiaPregunta(pId, 'siguiente');
        }else{
          var p = chk.sigPregSaltos(pId, pregs);
          if(p['pId'] != null){
            widget.KeyPregunta.currentState.cambiaPregunta(p['pId'], 'siguiente');
            updBloqueActivo(p['bId']);
            var est = await chk.estructura();
            var areas = est['bloques'][p['bId']]['areas'];
            widget.KeyAreas.currentState.actualizaAreas(areas);
            widget.KeyAreas.currentState.updAreaActivo(p['aId']);

          }
        }
        break;
    }
  }
}
