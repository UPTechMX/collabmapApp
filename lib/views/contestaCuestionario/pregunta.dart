import 'package:flutter/material.dart';
import 'package:siap_monitoring/views/questionnaires/targets/targetsElemsList.dart';
import 'package:siap_monitoring/models/cuestionario/checklist.dart';
import 'package:siap_monitoring/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap_monitoring/views/contestaCuestionario/bloques.dart';
import 'package:siap_monitoring/views/contestaCuestionario/areas.dart';
import 'spatial.dart';

import 'package:siap_monitoring/views/maps/map.dart';

class Pregunta extends StatefulWidget {
  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;

  Checklist chk;
  GlobalKey<PreguntasContState> KeyPreguntas;
  GlobalKey<TargetsElemsListState> keyTargElemList;

  String bId;
  String aId;
  String pId;

  Pregunta(
      {Key key,
      this.chk,
      this.KeyPreguntas,
      this.keyAreas,
      this.keyBloques,
      this.keyTargElemList,
      this.bId,
      this.aId,
      this.pId})
      : super(key: key);

  @override
  PreguntaState createState() =>
      PreguntaState(chk: chk, identificador: null // ToDo: CABIAR/Borrar este
          );
}

class PreguntaState extends State<Pregunta> {
  TextEditingController respuestaControlador = TextEditingController();
  TextEditingController justificacionControlador = TextEditingController();

  GlobalKey<MapWidgetState> keyMapa = GlobalKey();

  Map preg;
  num justif;
  num justif2;
  num justifPreg;
  num justifPreg2;
  var resp;
  Checklist chk;
  Map respuestaPreg;
  var justifChange;
  var respChange;
  var identificador;
  String direccion;
  var selected;
  var selected2;

  PreguntaState({
    this.preg,
    this.chk,
    this.identificador,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: tipoPregunta(identificador),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Column(
            children: <Widget>[
              Center(child: Text('No se encontró pregunta')),
              botonesContinuar()
            ],
          );

        var preg = snapshot.data[0]['preg'];

        preg['justif'] ??= 0;
        preg['justif'] = int.parse('${preg['justif']}');

        justifPreg = preg['justif'];
        if (justif2 == null) {
          justif = justifPreg == 1 ? 1 : 0;
        } else {
          justif = justif2;
        }

        if (justifPreg != 1) {
          if (preg['tipo'] == 'mult') {
            var respuestas = preg['respuestas'];

            Map resps = new Map<String, List>();
            if (respuestas is List) {
              for (int i = 0; i < respuestas.length; i++) {
                resps['$i'] = new List();
                List r = respuestas[i];
                resps['$i'].add(r[0]);
              }
            } else {
              resps = respuestas;
            }

            if (preg['valResp'] != '_' && preg['valResp'] != '-') {
              var resp;
              if (selected2 == null) {
                if (preg['valResp'] != null) {
                  resp = resps[preg['valResp']][0];
                } else {
                  resp = null;
                }
              } else {
                resp = resps[selected2][0];
              }

              if (resp != null) {
                justif = '${resp['justif']}' == '1' ? 1 : 0;
              } else {
                justif = null;
              }
            }
          }
        }

        justificacionControlador = TextEditingController(
            text: justifChange == null ? preg['justificacion'] : justifChange);

        return Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              preg['subarea'] != null
                  ? subArea(parseHtmlString(preg['subareaNom']))
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              Text(
                parseHtmlString(preg['pregunta']),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              respuestas(preg),
              justif == 1
                  ? justificacion()
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              (preg['comShopper'] != null && preg['comShopper'] != '')
                  ? comentarios(parseHtmlString(preg['comShopper']))
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              botonesContinuar(),
            ],
          ),
        );
      },
    );
  }

  Future<List> tipoPregunta(identificador) async {
    var p;
    Map r = new Map();
    List list = new List();
    Map pregs = await chk.resultados(true);

    var bloqueAct;
    var areaAct;

    if (identificador == null) {
      for (var i in pregs.keys) {
        identificador = i;

        if (pregs[i]['tipo'] != 'sub') break;
      }

      for (var i in pregs.keys) {
        if (pregs[i]['respuesta'] != null &&
            pregs[i]['respuesta'] != '' &&
            pregs[i]['respuesta'] != '_' &&
            pregs[i]['respuesta'] != '-' &&
            pregs[i]['tipo'] != 'sub') {
          identificador = i;
          bloqueAct = pregs[i]['bloque'];
          areaAct = pregs[i]['area'];
          widget.keyBloques.currentState.updBloquesAct(pregs[i]['bloque']);
          widget.keyAreas.currentState.updAreasAct(pregs[i]['area']);
        } else {
          identificador = i;
          bloqueAct = pregs[i]['bloque'];
          areaAct = pregs[i]['area'];
          widget.keyBloques.currentState.updBloquesAct(pregs[i]['bloque']);
          widget.keyAreas.currentState.updAreasAct(pregs[i]['area']);
          if (pregs[i]['muestra'] == 1 && pregs[i]['tipo'] != 'sub') {
            break;
          }
        }
      }
      bloqueAct = pregs[identificador]['bloque'];
      areaAct = pregs[identificador]['area'];

      widget.keyBloques.currentState
          .updBloquesAct(pregs[identificador]['bloque']);
      widget.keyBloques.currentState.updBloqueActivo(bloqueAct);
      var est = await chk.estructura();
      var areas = est['bloques'][bloqueAct]['areas'];
      widget.keyAreas.currentState.actualizaAreas(areas);
      widget.keyAreas.currentState.updAreaActivo(areaAct);
    }

    this.identificador = identificador;

    if (identificador != null) {
      p = pregs[identificador];
    } else {
      p = null;
    }

    if (p != null) {
      r['preg'] = p;
    } else {
      r['preg'] = null;
    }

    widget.keyBloques.currentState.updBloqueActivo(p['bloque']);
    var est = await chk.estructura();
    var areas = est['bloques'][p['bloque']]['areas'];

    widget.keyAreas.currentState.actualizaAreas(areas);
    widget.keyAreas.currentState.updAreaActivo(p['area']);

    list.add(r);
    return list;
  }

  justificacion() {
    return Container(
      padding: EdgeInsets.only(top: 60),
      child: Column(
        children: <Widget>[
          Text('Justificacion'),
          TextField(
            controller: justificacionControlador,
            onChanged: (text) {
              justifChange = text;
            },
          ),
        ],
      ),
    );
  }

  respuestas(preg) {
    String respText;
    if (preg['respuesta'] == null ||
        preg['respuesta'] == '_' ||
        preg['respuesta'] == '-' ||
        preg['respuesta'] == '') {
      respText = null;
    } else {
      respText = preg['respuesta'];
    }
    respuestaControlador =
        TextEditingController(text: respChange == null ? respText : respChange);

    var valResp = preg['valResp'];
    var tipoPreg = preg['tipo'];

    switch (tipoPreg) {
      case 'mult':
        if (selected2 == null) {
          selected = (valResp == '_' || valResp == '-' ? null : valResp);
        } else {
          selected = selected2;
        }

        var respuestas = preg['respuestas'];

        Map resps = new Map<String, List>();
        if (respuestas is List) {
          for (int i = 0; i < respuestas.length; i++) {
            resps['$i'] = new List();
            List r = respuestas[i];
            resps['$i'].add(r[0]);
          }
        } else {
          resps = respuestas;
        }
        List items = new List<DropdownMenuItem>();
        for (var i in resps.keys) {
          var respuesta = resps[i][0];
          if (respuesta['elim'] == 1 || respuesta['elim'] == '1') {
            continue;
          }

          var item = DropdownMenuItem(
            child: Text(
              parseHtmlString(respuesta['respuesta']),
              style: TextStyle(fontSize: 14),
            ),
            value: respuesta['valor'],
          );
          items.add(item);
        }

        return Center(
            child: DropdownButton(
          items: items,
          value: selected,
          hint: Text('Selecciona una respuesta'),
          onChanged: (value) {
            setState(() {
              selected2 = value;
              if (justifPreg != 1) {
                if ('${resps[value][0]['justif']}' == '1') {
                  justif2 = 1;
                } else {
                  justif2 = null;
                }
              }
            });
          },
        ));
        break;
      // TODO: DEFINIR ESPACIALES (PINTAR MAPAS)
      case 'op':
      case 'spatial':
      case 'cm':
//        print('PREG: $preg');
        return Spatial(
          question: preg,
          vId: chk.vId,
        );
        break;
      case 'num':
      case 'ab':
        return Container(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            children: <Widget>[
              Text(
                tipoPreg == 'num'
                    ? 'Escribe un valor numérico'
                    : 'Escribe la respuesta',
              ),
              TextField(
                keyboardType: tipoPreg == 'num'
                    ? TextInputType.number
                    : TextInputType.text,
                textInputAction: TextInputAction.done,
                controller: respuestaControlador,
                autofocus: false,
                onChanged: (text) {
                  respChange = text;
                },
                onSubmitted: (term) {
                  accSig();
                },
              ),
            ],
          ),
        );
        break;
    }
  }

  subArea(texto) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey,
          ),
          child: Center(
              child: Text(
            texto,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          )),
        ),
        Container(
          width: 0,
          height: 30,
        )
      ],
    );
  }

  comentarios(texto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(9),
          child: Text(
            'Comentarios a considerar:',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(7)),
          child: Center(
              child: Text(
            texto,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            textAlign: TextAlign.justify,
          )),
        ),
        Container(
          width: 0,
          height: 30,
        )
      ],
    );
  }

  botonesContinuar() {
    return Container(
      padding: EdgeInsets.only(top: 50),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: RaisedButton(
              color: Colors.blue,
              child: Text(
                'Regresar',
              ),
              onPressed: () {
                accReg();
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(''),
          ),
          Expanded(
            flex: 5,
            child: RaisedButton(
              color: Colors.blue,
              child: Text(
                'Continuar',
              ),
              onPressed: () {
//                print('aaa');
                accSig();
              },
            ),
          ),
        ],
      ),
    );
  }

  accSig() async {
    Map pregs = await chk.resultados(false);
    var respuesta;
    if (pregs.length != 0) {
      respuesta = getResp(pregs);
    } else {
//      ant['pId'] = null;
    }

//      print('========= RESPUESTA allOk antes : $respuesta ======');
    if (respuesta != null) {
//        print('aa: $respuesta');
      if (allOk(respuesta)) {
//        print('========= RESPUESTA allOk ======');
//        print(respuesta);
        chk.guardaResp(respuesta);
//      print('esperé');

        Map pregs = await chk.resultados(true);

        var sig = await chk.sigPregSaltos(identificador, pregs);
//      print('SIG ${sig} a $identificador');
        if (sig['pId'] != null) {
          cambiaEstados(sig);
        } else {
          var datos = await chk.datosChk(false);
          var paginaSig = 'fotografias';
          var bloque = '__fotografias__';

          var areas = new Map();
          areas['_fotos_'] = new Map();
          areas['_fotos_']['nombre'] = 'Fotografías';
          var areaAct = '_fotos_';

          if (datos['etapa'] == 'visita' || datos['etapa'] == 'instalacion') {
            paginaSig = 'instalacion';
            bloque = '__instalaciones__';

            areas = new Map();
            areas['_insts_'] = new Map();
            areas['_insts_']['nombre'] = 'Instalación';
            areaAct = '_insts_';
          }
          widget.KeyPreguntas.currentState.cambiaPagina(paginaSig);
          widget.keyBloques.currentState.updBloqueActivo(bloque);
          widget.keyAreas.currentState.actualizaAreas(areas);
          widget.keyAreas.currentState.updAreaActivo(areaAct);
        }
      }
    } else {
//      print( ' ===== ${chk.datosVis['etapa']} = = =');

      var paginaSig;
      var bloque;
      var areas = new Map();
      var areaAct;
      switch (chk.datosVis['etapa']) {
        case 'visita':
        case 'instalacion':
          paginaSig = 'instalacion';
          bloque = '__instalaciones__';
          areas['_insts_'] = new Map();
          areas['_insts_']['nombre'] = 'Instalación';
          areaAct = '_insts_';

          break;
        default:
          paginaSig = 'fotografias';
          bloque = '__fotografias__';
          areas['_fotos_'] = new Map();
          areas['_fotos_']['nombre'] = 'Fotografías';
          areaAct = '_fotos_';
      }

      widget.KeyPreguntas.currentState.cambiaPagina(paginaSig);
      widget.keyBloques.currentState.updBloqueActivo(bloque);
      widget.keyAreas.currentState.actualizaAreas(areas);
      widget.keyAreas.currentState.updAreaActivo(areaAct);
    }
  }

  accReg() async {
    Map pregs = await chk.resultados(true);
    var respuesta;
    Map ant = {};
    if (pregs.length != 0) {
      respuesta = getResp(pregs);
      ant = await chk.antPregSaltos(identificador, pregs);
    } else {
      ant['pId'] = null;
    }
    if (ant['pId'] != null) {
      cambiaEstados(ant);
    } else {
//      widget.KeyPreguntas.currentState.cambiaPagina('general');
//      widget.keyBloques.currentState.updBloqueActivo('__general__');
    }
    if (respuesta != null && allOk(respuesta)) {
      chk.guardaResp(respuesta);
    }
  }

  getResp(pregs) {
    var preg = pregs[identificador];

    var respuestas = preg['respuestas'];
    List items = new List<DropdownMenuItem>();

    Map resps = new Map<String, List>();
    if (respuestas is List) {
      for (int i = 0; i < respuestas.length; i++) {
        resps['$i'] = new List();
        List r = respuestas[i];
        resps['$i'].add(r[0]);
      }
    } else {
      resps = respuestas;
    }

    Map<String, dynamic> r = new Map();
    r['justificacion'] = justificacionControlador.text;
    r['preguntasId'] = preg['id'];
    r['identificador'] = identificador;
    r['visitasId'] = chk.vId;
    switch (preg['tipo']) {
      case 'num':
      case 'ab':
        //TODO: DEFINIR ESPACIALES (TOMAR RESPUESTA)
        r['respuesta'] = respuestaControlador.text;
        break;
      case 'spatial':
        r['respuesta'] = "Ubicación regisrada";
        break;
      case 'cm':
        r['respuesta'] = "Problema(s) registrado(s)";
        break;
      case 'op':
        r['respuesta'] = "Punto registrado";
        break;
      case 'mult':
        if (selected != null) {
          r['respuesta'] = resps[selected][0]['id'];
        } else {
          r['respuesta'] = null;
        }
    }
    return r;
  }

  cambiaPregunta(identif, dir) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      identificador = identif;
      direccion = dir;
      selected2 = null;
      justif = 0;
      justif2 = null;
      justifPreg2 = 0;
      justifChange = null;
      respChange = null;
    });
  }

  cambiaEstados(ele) async {
    cambiaPregunta(ele['pId'], 'siguiente');
    widget.keyBloques.currentState.updBloquesAct(ele['bId']);
    widget.keyBloques.currentState.updBloqueActivo(ele['bId']);

    var est = await chk.estructura();
    var areas = est['bloques'][ele['bId']]['areas'];
    widget.keyAreas.currentState.actualizaAreas(areas);
    widget.keyAreas.currentState.updAreasAct(ele['aId']);
    widget.keyAreas.currentState.updAreaActivo(ele['aId']);
  }

  bool allOk(resp) {
    var ok = true;
    if (justif == 1 &&
        (resp['justificacion'] == null || resp['justificacion'] == '')) {
      ok = false;
    }
    if (resp['respuesta'] == null || resp['respuesta'] == '') {
      ok = false;
    }
    return ok;
  }
}
