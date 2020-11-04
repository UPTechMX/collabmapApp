import 'package:flutter/material.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/views/surveys/surveys.dart';

class Checklist {
  int vId; //visita id
  int id; // checklist id
  Map est; // estructura
  List resps; // respuestas de la visita
  List bloques; // bloques del checklist
  Map preguntas; // preguntas/Resultados del checklist
  Map calcs; // calculos del checklist
  Map datosVis; // Datos generales de la visita
  Map datosChecklist;
  Map fotosInst = Map();
  GlobalKey<SurveysState> keySurvey;

  DB db = DB.instance;

  Checklist(int vId) {
    this.vId = vId;
    datosVisita(true);
  }

  _getChkId() async {
    int chkId;
    String sql = '''
    SELECT v.*
    FROM Visitas v
    WHERE v.id = ${this.vId}
    ''';
//     print( "$sql");
    var datVis = await db.query(sql);
//    print(datVis[0]);
    this.id = datVis[0]['checklistId'];
    chkId = datVis[0]['checklistId'];
    return chkId;
  }

  chkId() async {
    if (this.id != null) {
//      this.id = null;
      return this.id;
    } else {
      id = await this._getChkId();
      return id;
    }
  }

  _getEst() async {
//    print('aa');
    var est = new Map();
    var id = await this.chkId();
//    print('ID: $id');
    List chkDB = await db.query("SELECT * FROM Checklist WHERE id = $id");
//    print(chkDB);
    if (chkDB != null) {
      est = await json.decode(chkDB[0]['est']);
    }
//    print('EST }');
    return est;
  }

  estructura() async {
    if (this.est == null) {
      this.est = await this._getEst();
      return this.est;
    } else {
//      print('Borraest');
//      this.est = null;
      return this.est;
    }
  }

  getResp() async {
    var resps = await db
        .query("SELECT * FROM RespuestasVisita WHERE visitasId = ${this.vId}");
    this.resps = resps;

    return resps;
  }

  getBloques() async {
    var est = await this.estructura();
//    print("ESTRUCTURA ${est}");
//    print(await this.chkId());

    Map bloques = (est['bloques'] is List) ? Map() : est['bloques'];

    List lista = [];
    bloques.forEach((k, v) {
      v['identificador'] = k;
      lista.add(v);
    });
    this.bloques = lista;
//    print(lista);
    return lista;
  }

  getBloquesCalc() async {
    List bloques = await this.getBloques();
    var calculos = await this.calculos(false);
    var preguntas = await this.resultados(false);

//    this.calcs['bloques']['tec']['areas']['a_3_5_5']['muestra'] = 0;
//    print('ddd ${bloques[4]['identificador']}');

    return bloques;
  }

  resultados(bool fromDB) async {
    //print(this.preguntas);
    if (this.preguntas == null || fromDB) {
//      print('TRUE');
      this.preguntas = await _getResultadosDB();
      return this.preguntas;
    } else {
//      print('FALSE');
      return this.preguntas;
    }
  }

  _getResultadosDB() async {
//    print('Entra getResultadosDB');

    var est = await this.estructura();

//    print(est);
    List pregs = [];
    for (var b in est['bloques'].keys) {
      var bloque = est['bloques'][b];
//      print(bloque);
      for (var a in bloque['areas'].keys) {
        var area = bloque['areas'][a];
        for (var p in area['preguntas'].keys) {
          var pregunta = area['preguntas'][p];
//          print(pregunta['tipo']);
          if (pregunta['tipo'] == 'sub') {
            for (var sp in pregunta['subpregs'].keys) {
              var subPreg = pregunta['subpregs'][sp];
              pregs.add(subPreg);
//              print(subPreg['tipo']);
            }
          } else {
//            print(pregunta['tipo']);
            pregs.add(pregunta);
          }
        }
      }
    }

//    print( pregs );

//    return null;
//    print(this.vId);
    List respuestas = [];
    for (int i = 0; i < pregs.length; i++) {
      var pregunta = pregs[i];
//      print(pregunta['tipo']);

      String sql = '''
        SELECT rv.*
        FROM RespuestasVisita rv
        WHERE visitasId = ${this.vId} AND preguntasId = ${pregunta['id']} 
      ''';
      List respuesta = await db.query(sql);

      if (respuesta != null) {
//        print(respuesta);
        var resp = respuesta[0];
        Map tmp = Map();
        tmp['siglas'] = pregunta['tipo'];
        tmp['identificador'] = pregunta['identificador'];
        tmp['orden'] = pregunta['orden'];
        tmp['valResp'] = null;
        tmp['rNom'] = null;
        tmp['valor'] = null;

        if (pregunta['tipo'] == 'mult') {
          var pregResps = pregunta['respuestas'];
          for (var r in pregResps.keys) {
            if ('${resp['respuesta']}' == '${pregResps[r][0]['id']}') {
              tmp['valResp'] = pregResps[r][0]['valor'];
              tmp['valor'] = pregResps[r][0]['valor'];
              tmp['rNom'] = pregResps[r][0]['respuesta'];
            }
          }
        } else {
          tmp['valResp'] = resp['respuesta'];
          tmp['rNom'] = resp['respuesta'];
        }

        tmp['id'] = resp['id'];
        tmp['visitasId'] = resp['visitasId'];
        tmp['preguntasId'] = resp['preguntasId'];
        tmp['respuesta'] = resp['respuesta'];
        tmp['justificacion'] = resp['justificacion'];

        respuestas.add(tmp);
//        print('TMP: $tmp');
      }

//      print(respuesta);

    }

//    return null;

//    String sql = '''
//      SELECT t.siglas,p.tiposId,r.valor, p.identificador, rv.*, p.orden,
//      CASE
//        WHEN t.siglas = 'mult' THEN r.valor
//        ELSE rv.respuesta
//      END as valResp,
//
//      CASE
//        WHEN t.siglas = 'mult' THEN r.respuesta
//        ELSE rv.respuesta
//      END as rNom
//
//      FROM RespuestasVisita rv
//      LEFT JOIN Preguntas p ON rv.preguntasId = p.id
//      LEFT JOIN Tipos t ON p.tiposId = t.id
//      LEFT JOIN Respuestas r ON rv.respuesta = r.id AND (r.elim != 1 OR r.elim IS NULL)
//      WHERE visitasId = ${this.vId}
//    ''';

//    List respuestas = await db.query(sql);
//    respuestas ??= List();
//    respuestas = respuestas == null?new List():respuestas;

//    String sql2 = "SELECT * FROM RespuestasVisita WHERE visitasId = ${this.vId}";
//    List respuestas2 = await db.query(sql2);
//
//    for(int i = 0;i<respuestas2.length;i++){
//      print('${respuestas2[i]}');
//    }

//    String sql2 = 'DELETE FROM RespuestasVisita WHERE visitasId = ${this.vId}';
//    db.query(sql2);
//    for(int i = 0; i<respuestas.length;i++){
//      print('$i : ${respuestas[i]}');
//    }
//    var iii = respuestas.indexWhere((r) => r['identificador'] == 'area1');
//    print('RESPUESTAS ${respuestas[iii]}');
    for (int i = 0; i < respuestas.length; i++) {
//      print(respuestas[i]);
    }

    Map<String, dynamic> bloques =
        (est['bloques'] is List) ? Map() : est['bloques'];
//    print('bloques $bloques');
    try {
      bloques.forEach((bId, b) {
//        print('BBBBBAREAS: ${b['areas'].runtimeType}');
        List<dynamic> AAA = List<dynamic>();

        Map<String, dynamic> areas = b['areas'].runtimeType == AAA.runtimeType
            ? Map<String, dynamic>()
            : b['areas'];

        areas.forEach((aId, a) {
          if (a['preguntas'].length == 0) {
            a['preguntas'] = <String, dynamic>{};
          }

//          print('TIPO ARR: ${a['preguntas'].runtimeType}');
          Map<String, dynamic> preguntas = a['preguntas'];
          preguntas.forEach((pId, p) {
            switch (p['tipo']) {
              case 'sub':
                Map subpregs = p['subpregs'];
                subpregs.forEach((spId, sp) {
                  var ii =
                      respuestas.indexWhere((r) => r['identificador'] == spId);

                  est['bloques'][bId]['areas'][aId]['preguntas'][pId]
                          ['subpregs'][spId]['respuesta'] =
                      (ii == -1) ? null : respuestas[ii]['respuesta'];
                });

                break;
              case 'mult':
                var ii =
                    respuestas.indexWhere((r) => r['identificador'] == pId);
//              print('pId = $pId');
//              print('ii = $ii');
                est['bloques'][bId]['areas'][aId]['preguntas'][pId]
                        ['respuesta'] =
                    (ii == -1) ? null : respuestas[ii]['respuesta'];

                break;
              default:
                break;
            }
          });
        });
      });
    } catch (e) {
      print('ERROR: ${e}');
    }

    Map preguntas = new Map();
    bloques.forEach((bidentif, b) {
//      print('ACCCCCAAAA!!!! ${b['areas'].runtimeType}');
      List<dynamic> AAA = List<dynamic>();
      Map<String, dynamic> areas = b['areas'].runtimeType == AAA.runtimeType
          ? Map<String, dynamic>()
          : b['areas'];

//      Map areas = b['areas'];
      areas.forEach((aidentif, a) {
        Map pregs = a['preguntas'];
        pregs.forEach((pidentif, p) {
          preguntas[pidentif] = p;
          preguntas[pidentif]['bloque'] = bidentif;
          preguntas[pidentif]['area'] = aidentif;
          preguntas[pidentif]['muestra'] = 1;
          var ii = respuestas.indexWhere((r) => r['identificador'] == pidentif);
          switch (p['tipo']) {
            case 'mult':
              if (p['respuesta'] != null) {
                // $resp = $db->query("SELECT * FROM Respuestas WHERE id = $p[respuesta]")->fetch(PDO::FETCH_ASSOC);
                preguntas[pidentif]['respuesta'] = (ii == -1)
                    ? '_'
                    : respuestas[ii]['respuesta']; //$resp['valor'];
                preguntas[pidentif]['valResp'] = (ii == -1)
                    ? '_'
                    : respuestas[ii]['valResp']; //$resp['valor'];
                preguntas[pidentif]['nomResp'] = (ii == -1)
                    ? '_'
                    : respuestas[ii]['rNom']; //$resp['respuesta'];
                preguntas[pidentif]['justificacion'] = (ii == -1)
                    ? null
                    : respuestas[ii]['justificacion']; //$resp['respuesta'];

              } else {
                preguntas[pidentif]['respuesta'] = '';
                preguntas[pidentif]['valResp'] = '_';
                preguntas[pidentif]['nomResp'] = '';
                preguntas[pidentif]['justificacion'] = (ii == -1)
                    ? null
                    : respuestas[ii]['justificacion']; //$resp['respuesta'];
              }
              break;
            case 'num':
              preguntas[pidentif]['respuesta'] =
                  (ii == -1) ? '_' : respuestas[ii]['respuesta'];
              preguntas[pidentif]['valResp'] =
                  (ii == -1) ? '_' : respuestas[ii]['valResp'];
              preguntas[pidentif]['nomResp'] =
                  (ii == -1) ? '_' : respuestas[ii]['valResp'];
              preguntas[pidentif]['justificacion'] = (ii == -1)
                  ? null
                  : respuestas[ii]['justificacion']; //$resp['respuesta'];

              // $preguntas[$pidentif]['pId'] = $p['id'];
              break;
            case 'sub':
              var cont = p['conds'].length;
              if (cont == 0) {
                preguntas[pidentif]['valResp'] = '_';
              }
              break;
            case 'ab':
            // TODO: AGREGAR SPATIAL;
            case 'spatial':
            case 'cm':
            case 'op':
              preguntas[pidentif]['respuesta'] =
                  (ii == -1) ? '_' : respuestas[ii]['respuesta'];
              preguntas[pidentif]['valResp'] = '_';
              preguntas[pidentif]['valPreg'] = '_';
              preguntas[pidentif]['nomResp'] =
                  (ii == -1) ? '_' : respuestas[ii]['valResp'];
              preguntas[pidentif]['justificacion'] = (ii == -1)
                  ? null
                  : respuestas[ii]['justificacion']; //$resp['respuesta'];
              break;
            default:
              break;
          }

          if (p['tipo'] == 'sub') {
            Map subpregs = p['subpregs'];
            var ultimo;
            subpregs.forEach((spidentif, sp) {
              preguntas[spidentif] = sp;
              preguntas[spidentif]['bloque'] = bidentif;
              preguntas[spidentif]['area'] = aidentif;
              preguntas[spidentif]['subarea'] = pidentif;
              preguntas[spidentif]['subareaNom'] =
                  preguntas[pidentif]['pregunta'];
              preguntas[spidentif]['muestra'] = 1;

              var ii =
                  respuestas.indexWhere((r) => r['identificador'] == spidentif);
              switch (sp['tipo']) {
                case 'mult':
                  if (sp['respuesta'] != null) {
//                    if(spidentif == 'p_3_5_6_52'){
//                      print('$ii : ${respuestas[ii]}');
//                    }
                    // $resp = $db->query("SELECT * FROM Respuestas WHERE id = $p[respuesta]")->fetch(PDO::FETCH_ASSOC);
                    preguntas[spidentif]['respuesta'] = (ii == -1)
                        ? '_'
                        : respuestas[ii]['respuesta']; //$resp['valor'];
                    preguntas[spidentif]['valResp'] = (ii == -1)
                        ? '_'
                        : respuestas[ii]['valResp']; //$resp['valor'];
                    preguntas[spidentif]['nomResp'] = (ii == -1)
                        ? '_'
                        : respuestas[ii]['rNom']; //$resp['respuesta'];
                    preguntas[spidentif]['justificacion'] = (ii == -1)
                        ? null
                        : respuestas[ii]['justificacion']; //$resp['respuesta'];

                  } else {
                    preguntas[spidentif]['respuesta'] = '';
                    preguntas[spidentif]['valResp'] = '_';
                    preguntas[spidentif]['nomResp'] = '';
                    preguntas[spidentif]['justificacion'] = (ii == -1)
                        ? null
                        : respuestas[ii]['justificacion']; //$resp['respuesta'];
                  }
                  break;
                case 'num':
                  preguntas[spidentif]['respuesta'] =
                      (ii == -1) ? '_' : respuestas[ii]['respuesta'];
                  preguntas[spidentif]['valResp'] =
                      (ii == -1) ? '_' : respuestas[ii]['valResp'];
                  preguntas[spidentif]['nomResp'] =
                      (ii == -1) ? '_' : respuestas[ii]['valResp'];
                  preguntas[spidentif]['justificacion'] = (ii == -1)
                      ? null
                      : respuestas[ii]['justificacion']; //$resp['respuesta'];

//                  if(spidentif == 'area1'){
//                    print("ACAAAAASASASAS ${respuestas[ii]['valResp']} ");
//                    print( 'FFFFFFFFF ${(ii == -1)?'_':respuestas[ii]['valResp']}');
//                    print('gtgtgtgtgt ${preguntas[spidentif]['valResp']}');
//                  }

                  // $preguntas[$pidentif]['pId'] = $p['id'];
                  break;
                case 'sub':
                  var cont = p['conds'].length;
                  if (cont == 0) {
                    preguntas[spidentif]['valResp'] = '_';
                  }
                  break;
                case 'ab':
                // TODO: AGREGAR SPATIAL;
                case 'spatial':
                case 'cm':
                case 'op':
                  preguntas[spidentif]['respuesta'] =
                      (ii == -1) ? '_' : respuestas[ii]['respuesta'];
                  preguntas[spidentif]['valResp'] = '_';
                  preguntas[spidentif]['valPreg'] = '_';
                  preguntas[spidentif]['nomResp'] =
                      (ii == -1) ? '_' : respuestas[ii]['valResp'];
                  preguntas[spidentif]['justificacion'] = (ii == -1)
                      ? null
                      : respuestas[ii]['justificacion']; //$resp['respuesta'];
                  break;
                default:
                  break;
              }
            });
//            preguntas[pidentif].remove('subpregs');
          }
        });
      });
    });

    for (String identificador in preguntas.keys) {
//      print('identificador1 = $identificador');
//      if(identificador == 'area1'){
//        print('ANTES VALPREG  ${preguntas[identificador]['valResp']} --- ${preguntas[identificador]['valPreg']}');
//      }
      var valpreg = await valPreg(preguntas, identificador);

      preguntas[identificador]['valPreg'] =
          is_numeric('$valpreg') ? '$valpreg' : '_';
//      print('identificador2 = $identificador');

    }

    return preguntas;
  }

  valPreg(Map pregs, String identificador) async {
//    print(' Identificador $identificador, Pregs: $pregs');
    var valor;

    if (pregs[identificador] != null &&
        (pregs[identificador]['valPreg'] != null &&
            pregs[identificador]['valPreg'] != '_' &&
            pregs[identificador]['valPreg'] != '-') &&
        false) {
      valor = is_numeric('${pregs[identificador]['valResp']}') &&
              is_numeric('${pregs[identificador]['puntos']}')
          ? num.parse('${pregs[identificador]['valResp']}') *
              num.parse('${pregs[identificador]['puntos']}')
          : '_';
    } else {
      List conds = pregs[identificador]['conds'];
      if (conds.length == 0) {
//        print("IDENTIFICADOR ${pregs[identificador]}");

        valor = is_numeric('${pregs[identificador]['valResp']}') &&
                is_numeric('${pregs[identificador]['puntos']}')
            ? num.parse('${pregs[identificador]['valResp']}') *
                num.parse('${pregs[identificador]['puntos']}')
            : '_';
      } else {
        valor = is_numeric('${pregs[identificador]['valResp']}') &&
                is_numeric('${pregs[identificador]['puntos']}')
            ? num.parse('${pregs[identificador]['valResp']}') *
                num.parse('${pregs[identificador]['puntos']}')
            : '_';

        for (int i = 0; i < conds.length; i++) {
          var c = conds[i];
//          print('CONDS: $conds');
          var ok = await evalCond(pregs, c['condicion']);

          if (ok == 1) {
            switch ('${c['accion']}') {
              case '1':
                if (is_numeric(c['valor']) || c['valor'] == '_') {
                  valor = c['valor'];
                } else {
                  var a = await evalCond(pregs, c['valor']);
                  valor = is_numeric(pregs[identificador]['valResp']) &&
                          is_numeric(a)
                      ? num.parse(pregs[identificador]['valResp']) *
                          num.parse(a)
                      : '_';
                }
                break;
              case '2':
                valor = '_';
                pregs[identificador]['muestra'] = 0;
                break;
              case '5':
                var a = await evalCond(pregs, c['valor']);

                pregs[identificador]['puntos'] = a;
                valor = is_numeric(pregs[identificador]['valResp']) &&
                        is_numeric(a)
                    ? num.parse(pregs[identificador]['valResp']) * num.parse(a)
                    : '_';
                break;
            }
          }
        }
      }
    }

    return valor;
  }

//  cuenta(identificador){
//    var a = is_numeric(valResp(identificador)) ?1:0;
//    return a;
//  }
//
//  cuentaPos(identificador){
//    var a = valResp(identificador) > 0?1:0;
//    return a;
//  }

  evalCond(Map pregs, String test) async {
    // var pregs = this.resultados;

    RegExp pattern;
    // test = '(val(p_3_5_6_14) < 1 O val(p_3_5_6_14) > 1) Y 1<=1 ';

    //print('Testllega: $test');

    pattern = RegExp('/ /');
    test = test.replaceAllMapped(pattern, (match) {
      return '';
    });

    pattern = RegExp(r"val\(");
    test = test.replaceAllMapped(pattern, (match) {
      return 'valResp(';
    });

    pattern = RegExp(r"contar\(");
    test = test.replaceAllMapped(pattern, (match) {
      return 'cuenta(pregs,';
    });

    pattern = RegExp(r"pos\(");
    test = test.replaceAllMapped(pattern, (match) {
      return 'cuentaPos(pregs,';
    });

    pattern = RegExp(r"(p_[0-9]+_[0-9]+_[0-9]+_[0-9]+)");
    test = test.replaceAllMapped(pattern, (match) {
      return '"${match.group(0)}"';
    });

    pattern = RegExp(r"Y");
    test = test.replaceAllMapped(pattern, (match) {
      return ' AND ';
    });

    pattern = RegExp(r"O");
    test = test.replaceAllMapped(pattern, (match) {
      return ' OR ';
    });

//    pattern = RegExp(r"([^<>=!]{1})=");
//    test = test.replaceAllMapped(pattern, (match){
//      return '${match.group(0)}=';
//    });

    pattern = RegExp(r'valResp\("(p_[0-9]+_[0-9]+_[0-9]+_[0-9]+)"\)');
    test = test.replaceAllMapped(pattern, (match) {
      var identificador = match.group(1);
      var valor;

      if ('${pregs[identificador].runtimeType}' == 'Null') {
        return '_';
      }

      if (is_numeric(pregs[identificador]['valResp'])) {
        valor = num.parse(pregs[identificador]['valResp']);
      } else {
        valor = '_';
      }

      return '$valor';
    });

    pattern = RegExp(r"_");
    test = test.replaceAllMapped(pattern, (match) {
      return '"${match.group(0)}"';
    });

//     print('TestSale : $test');
    var evalSql = await db.query("SELECT $test as test");

    var eval = evalSql[0]['test'];
    // print(eval);
    // print('Eval: ${eval}');

    return eval;
  }

  calculos(bool fromDB) async {
    if (this.calcs == null || fromDB) {
      this.calcs = await _getCalculos();
      return this.calcs;
    } else {
      return this.calcs;
    }
  }

  _getCalculos() async {
    var pregs = await this.resultados(false);
    var chk = await this.estructura();
    print('Entra getCalculos');
    Map r = new Map<String, dynamic>();
    r['chk'] = new Map<String, dynamic>();
    r['chk']['max'] = 0;
    r['chk']['conseguido'] = '-';
    r['chk']['pond'] = '-';
    r['chk']['tipoProm'] = chk['tipoProm'];
    r['chk']['sumInf'] = '-';
    r['chk']['numInf'] = 0;
    r['chk']['promInf'] = 0;
    r['chk']['pregTot'] = 0;
    r['chk']['pregPos'] = 0;
    r['chk']['prom'] = '-';

    r['bloques'] = Map<String, dynamic>();

    for (String bId in chk['bloques'].keys) {
      Map b = chk['bloques'][bId];
      r['bloques'][bId] = new Map<String, dynamic>();
      r['bloques'][bId]['max'] = 0;
      r['bloques'][bId]['conseguido'] = '-';
      r['bloques'][bId]['sumInf'] = '-';
      r['bloques'][bId]['numInf'] = 0;
      r['bloques'][bId]['promInf'] = 0;
      r['bloques'][bId]['pond'] = '-';
      r['bloques'][bId]['tipoProm'] = b['tipoProm'];
      r['bloques'][bId]['valMax'] = b['valMax'];
      r['bloques'][bId]['muestra'] = 1;
      r['bloques'][bId]['pregTot'] = 0;
      r['bloques'][bId]['pregPos'] = 0;
      r['bloques'][bId]['nombre'] = b['nombre'];
      r['bloques'][bId]['areas'] = new Map<String, dynamic>();
      r['bloques'][bId]['conds'] = b['conds'];
      r['bloques'][bId]['encabezado'] = b['encabezado'];
      r['bloques'][bId]['prom'] = '-';

      for (String aId in b['areas'].keys) {
        Map a = b['areas'][aId];

        r['bloques'][bId]['areas'][aId] = new Map<String, dynamic>();
        r['bloques'][bId]['areas'][aId]['max'] = 0;
        r['bloques'][bId]['areas'][aId]['conseguido'] = '-';
        r['bloques'][bId]['areas'][aId]['sumInf'] = '-';
        r['bloques'][bId]['areas'][aId]['numInf'] = 0;
        r['bloques'][bId]['areas'][aId]['pond'] = '-';
        r['bloques'][bId]['areas'][aId]['valMax'] = a['valMax'];
        r['bloques'][bId]['areas'][aId]['muestra'] = 1;
        r['bloques'][bId]['areas'][aId]['pregTot'] = 0;
        r['bloques'][bId]['areas'][aId]['pregPos'] = 0;
        r['bloques'][bId]['areas'][aId]['nombre'] = a['nombre'];
        r['bloques'][bId]['areas'][aId]['conds'] = a['conds'];
        r['bloques'][bId]['areas'][aId]['efectos'] = 0;
        r['bloques'][bId]['areas'][aId]['modif'] = 0;

        List aPregs = new List();

        for (String pId in a['preguntas'].keys) {
          Map p = a['preguntas'][pId];

          Map tmp = new Map<String, dynamic>();
//          print('PPPPP: $p');
          tmp['tipo'] = p['tipo'];
          tmp['identificador'] = p['identificador'];
          if (p['tipo'] == 'sub') {
            tmp['subpregs'] = new List();
//            print('PPPPP: ${p['subpregs']}');
            for (String spId in p['subpregs'].keys) {
              Map sp = p['subpregs'][spId];
              Map tmp2 = new Map<String, dynamic>();
              tmp2['tipo'] = sp['tipo'];
              tmp2['identificador'] = sp['identificador'];
              tmp['subpregs'].add(tmp2);
            }
          }
          aPregs.add(tmp);
        }
        r['bloques'][bId]['areas'][aId]['preguntas'] = aPregs;
      }
    }

    pregs.forEach((pId, p) {
      var puntos;
      var valPreg;

      puntos = (is_numeric(p['valPreg']) && p['influyeValor'] == '1')
          ? num.parse('${p['puntos']}')
          : 0;
      valPreg = (is_numeric(p['valPreg']) && p['influyeValor'] == '1')
          ? num.parse('${p['valPreg']}')
          : '_';

      r['chk']['max'] += puntos;

      if (is_numeric('${r['chk']['conseguido']}')) {
        if (is_numeric('$valPreg')) {
          r['chk']['conseguido'] = num.parse('${r['chk']['conseguido']}');
          r['chk']['conseguido'] += valPreg;
        }
      } else {
        r['chk']['conseguido'] = valPreg;
      }
      if (is_numeric('$valPreg')) {
        r['chk']['pregTot']++;
        if (valPreg > 0) {
          r['chk']['pregPos']++;
        }
      }

      r['bloques'][p['bloque']]['max'] += puntos;

      if (is_numeric('${r['bloques'][p['bloque']]['conseguido']}')) {
        if (is_numeric('$valPreg')) {
          r['bloques'][p['bloque']]['conseguido'] =
              num.parse('${r['bloques'][p['bloque']]['conseguido']}');
          r['bloques'][p['bloque']]['conseguido'] += valPreg;
        } else {}
      } else {
        r['bloques'][p['bloque']]['conseguido'] = valPreg;
      }

      if (is_numeric('$valPreg')) {
        r['bloques'][p['bloque']]['pregTot']++;
        if (valPreg > 0) {
          r['bloques'][p['bloque']]['pregPos']++;
        }
      }

      r['bloques'][p['bloque']]['areas'][p['area']]['max'] += puntos;

      if (is_numeric(
          '${r['bloques'][p['bloque']]['areas'][p['area']]['conseguido']}')) {
        if (is_numeric('$valPreg')) {
          r['bloques'][p['bloque']]['areas'][p['area']]['conseguido'] +=
              valPreg;
        }
      } else {
        r['bloques'][p['bloque']]['areas'][p['area']]['conseguido'] = valPreg;
      }
      if (is_numeric('$valPreg')) {
        r['bloques'][p['bloque']]['areas'][p['area']]['pregTot']++;
        if (valPreg > 0) {
          r['bloques'][p['bloque']]['areas'][p['area']]['pregPos']++;
        }
      }
    });

    if (is_numeric('${r['chk']['conseguido']}')) {
      r['chk']['prom'] =
          r['chk']['max'] > 0 ? r['chk']['conseguido'] / r['chk']['max'] : 0;
    } else {
      r['chk']['prom'] = '-';
    }

    r['bloques'].forEach((bId, b) {
      if (is_numeric('${b['conseguido']}')) {
        r['bloques'][bId]['prom'] =
            b['max'] > 0 ? b['conseguido'] / b['max'] : 0;
      } else {
        r['bloques'][bId]['prom'] = '-';
      }
      for (int i = 0; i < b['conds'].length; i++) {
        Map c = b['conds'][i];

        // echo "bId<br/>";
        // print2(c);
        var ok = evalCond(pregs, c['condicion']);
        if (ok == 1) {
          // echo "Bloque: bId<br/>SE APLICA c[condicion]<br/> CON ACCION c[accion] <br/> Valor c[valor]<br/>-=-=-=-=-=<br/>";
          switch (c['accion']) {
            case '2':
              r['bloques'][bId]['prom'] = '-';
              r['bloques'][bId]['muestra'] = 0;
              break;
            case '3':
              r['bloques'][bId]['prom'] = c['valor'];
              break;
            case '4':
              if (is_numeric('${r['bloques'][bId]['prom']}') &&
                  is_numeric('${c['valor']}')) {
                r['bloques'][bId]['prom'] =
                    num.parse('${r['bloques'][bId]['prom']}') +
                        num.parse('${c['valor']}');
              }
              break;
            default:
              break;
          }
        }
      }
      b['areas'].forEach((aId, a) {
        // print2(a);
        if (is_numeric('${a['conseguido']}')) {
          r['bloques'][bId]['areas'][aId]['prom'] =
              a['max'] > 0 ? num.parse('${a['conseguido']}') / a['max'] : 0;
        } else {
          r['bloques'][bId]['areas'][aId]['prom'] = '-';
        }
        for (int i = 0; i < a['conds'].length; i++) {
          Map c = a['conds'][i];
          var ok = evalCond(pregs, c['condicion']);
          if (ok == 1) {
            switch (c['accion']) {
              case '2':
                r['bloques'][bId]['areas'][aId]['prom'] = '-';
                r['bloques'][bId]['areas'][aId]['muestra'] = 0;
                break;
              case '3':
                r['bloques'][bId]['areas'][aId]['prom'] = c['valor'];
                break;
              case '4':
                if (is_numeric('${r['bloques'][bId]['areas'][aId]['prom']}') &&
                    is_numeric('${c['valor']}')) {
                  r['bloques'][bId]['areas'][aId]['prom'] =
                      num.parse('${r['bloques'][bId]['prom']}') +
                          num.parse('${c['valor']}');
                }
                break;
              default:
                break;
            }
          }
        }
        var prom = r['bloques'][bId]['areas'][aId]['prom'];
        r['bloques'][bId]['areas'][aId]['prom'] = is_numeric('$prom')
            ? (num.parse('${a['valMax']}') / 100) * num.parse('$prom')
            : '-';
      });
    });
    for (int i = 0; i < chk['conds'].length; i++) {
      Map c = chk['conds'][i];

      var ok = evalCond(pregs, c['condicion']);
      if (ok == 1) {
        switch (c['accion']) {
          case '3':
            r['chk']['prom'] = c['valor'];
            break;
          case '4':
            if (is_numeric('${r['chk']['prom']}') &&
                is_numeric('${c['valor']}')) {
              r['chk']['prom'] =
                  num.parse('${r['chk']['prom']}') + num.parse('${c['valor']}');
            }
            break;
          default:
            break;
        }
      }
    }
    r['chk']['pond'] = r['chk']['max'] > 0 ? 100 / r['chk']['max'] : '-';

    for (String bId in r['bloques'].keys) {
      Map b = r['bloques'][bId];

      r['bloques'][bId]['pond'] = r['bloques'][bId]['max'] > 0
          ? num.parse('${r['bloques'][bId]['valMax']}') /
              r['bloques'][bId]['max']
          : '-';

      switch (r['tipoProm']) {
        case '1':
          r['bloques'][bId]['pond'] = r['chk']['pond'];
          break;
        case '2':
        case '3':
        default:
          r['bloques'][bId]['pond'] = r['bloques'][bId]['pond'];
          break;
      }

      for (String aId in b['areas'].keys) {
        Map a = b['areas'][aId];

        if (is_numeric('${r['bloques'][bId]['sumInf']}')) {
          r['bloques'][bId]['sumInf'] +=
              is_numeric('${a['prom']}') ? a['prom'] : 0;
        } else {
          r['bloques'][bId]['sumInf'] = a['prom'];
        }
        if (is_numeric('${a['prom']}')) {
          r['bloques'][bId]['numInf']++;
        }
        r['bloques'][bId]['areas'][aId]['pond'] =
            r['bloques'][bId]['areas'][aId]['max'] > 0
                ? num.parse('${r['bloques'][bId]['areas'][aId]['valMax']}') /
                    num.parse('${r['bloques'][bId]['areas'][aId]['max']}')
                : '-';
        switch (b['tipoProm']) {
          case '1':
            r['bloques'][bId]['areas'][aId]['pond'] = r['bloques'][bId]['pond'];
            break;
          case '2':
          case '3':
          default:
            r['bloques'][bId]['areas'][aId]['pond'] =
                r['bloques'][bId]['areas'][aId]['pond'];
            break;
        }
      }
      r['bloques'][bId]['promInf'] = r['bloques'][bId]['numInf'] > 0
          ? r['bloques'][bId]['sumInf'] / r['bloques'][bId]['numInf']
          : '-';

      switch (b['tipoProm']) {
        case '1':
          r['bloques'][bId]['prom'] = r['bloques'][bId]['prom'];
          break;
        case '2':
          if (is_numeric('${b['valMax']}') &&
              is_numeric('${r['bloques'][bId]['sumInf']}')) {
            r['bloques'][bId]['prom'] = (num.parse('${b['valMax']}') / 100) *
                num.parse('${r['bloques'][bId]['sumInf']}');
          } else {
            r['bloques'][bId]['prom'] = '-';
          }
          break;
        case '3':
          if (is_numeric('${b['valMax']}') &&
              is_numeric('${r['bloques'][bId]['promInf']}')) {
            r['bloques'][bId]['prom'] = (num.parse('${b['valMax']}') / 100) *
                num.parse('${r['bloques'][bId]['promInf']}');
          } else {
            r['bloques'][bId]['prom'] = '-';
          }
          break;
        default:
          r['bloques'][bId]['prom'] = r['bloques'][bId]['prom'];
          break;
      }
      b['prom'] = r['bloques'][bId]['prom'];

      if (is_numeric('${r['chk']['sumInf']}')) {
        r['chk']['sumInf'] +=
            is_numeric('${b['prom']}') ? num.parse('${b['prom']}') : 0;
      } else {
        r['chk']['sumInf'] = b['prom'];
      }
      if (is_numeric('${b['prom']}')) {
        r['chk']['numInf']++;
      }
    }

    r['chk']['promInf'] =
        r['chk']['numInf'] > 0 ? r['chk']['sumInf'] / r['chk']['numInf'] : '-';

    switch (r['chk']['tipoProm']) {
      case '1':
        r['chk']['prom'] = r['chk']['prom'];
        break;
      case '2':
        r['chk']['prom'] = r['chk']['sumInf'];
        break;
      case '3':
        r['chk']['prom'] = r['chk']['promInf'];
        break;
      default:
        r['chk']['prom'] = r['chk']['prom'];
        break;
    }

    return r;
  }

  getInstalacion(bool cantidades, String tipo) async {
    DB db = DB.instance;

    var datosVis = await datosVisita(true);
    var inst;
    switch (tipo) {
      case 'instalacion':
        inst = datosVis['instalacionRealizada'];
        break;
      case 'visita':
        inst = datosVis['instalacionSug'];
        break;
    }

    List instalacion = [];

    var equipos = await db.query(
        "SELECT * FROM InstalacionesEquipos WHERE instalacionesId = $inst");
//    print('Equipos $equipos');
    for (int i = 0; i < equipos.length; i++) {
//      print('dimensionesElemId = ${equipos[i]['dimensionesElemId']}');
      Map datEle = await datosEquipo(equipos[i]['dimensionesElemId']);

      Map elemInst = new Map();
//      print('datEle $datEle');
      elemInst['area'] = datEle['area'];
      var arbol = datEle['arbol'];
      String texto = '';
      for (int j = datEle['numDim'] - 1; j >= 0; j--) {
        texto += '${arbol["d$j"]} : ${arbol["de$j"]}';
        if (j == 0) {
          continue;
        }
        texto += ' > ';
//
      }

//      print('VARIABLES ${datEle['arbol']['variables']}');
//      if(datEle['arbol']['variables'] == 1){
//
//
//        sql = '''
//        SELECT cc.dimensionesElemId,cc.*
//          FROM ClientesComponentes cc
//			    WHERE clientesId = ${vInfo[clientesId]}
//        ''';
//
//        var unidad = datEle['arbol']['unidad'];
//        texto += '( ${comp} )'
//      }

      elemInst['texto'] = texto;
      instalacion.add(elemInst);
    }

//    print(instalacion);
    return instalacion;
  }

  getInstVis(int instId) async {
    DB db = DB.instance;

    List instalacion = [];

    var equipos = await db.query(
        "SELECT * FROM InstalacionesEquipos WHERE instalacionesId = $instId");
//    print('Equipos $equipos');
    for (int i = 0; i < equipos.length; i++) {
//      print('dimensionesElemId = ${equipos[i]['dimensionesElemId']}');
      Map datEle = await datosEquipo(equipos[i]['dimensionesElemId']);

      Map elemInst = new Map();
//      print('datEle $datEle');
      elemInst['area'] = datEle['area'];
      var arbol = datEle['arbol'];
      String texto = '';
      for (int j = datEle['numDim'] - 1; j >= 0; j--) {
        texto += '${arbol["d$j"]} : ${arbol["de$j"]}';
        if (j == 0) {
          continue;
        }
        texto += ' > ';
//
      }

      elemInst['texto'] = texto;
      instalacion.add(elemInst);
    }

//    print(instalacion);
    return instalacion;
  }

  datosEquipo(int elem) async {
    DB db = DB.instance;

    String sql;
    sql = '''
    SELECT a.nombre, COUNT(*) as numDim
		FROM Dimensiones d
		LEFT JOIN DimensionesElem de ON de.dimensionesId = d.id
		LEFT JOIN AreasEquipos a ON a.id = d.areasId
		LEFT JOIN Dimensiones dd ON dd.areasId = a.id
		WHERE de.id = $elem 
		GROUP BY a.id
    
    ''';

    List dats = await db.query(sql);
    var d = dats[0];
//    print('DATS: $dats');

    var numDim = d['numDim'];

    String LJ = '';
    String fields = '';

    for (int i = 0; i < numDim; i++) {
      if (i == 0) {
      } else {
        LJ += '''
        LEFT JOIN DimensionesElem de$i ON de$i.id = de${i - 1}.padre
					 LEFT JOIN Dimensiones d$i ON d$i.id = de$i.dimensionesId
        ''';
        fields += ',d$i.nombre as d$i, de$i.nombre as de$i';
      }
    }

    String sql2;
    sql2 = '''
    SELECT de0.nombre as de0, d0.nombre as d0, de0.variables, de0.unidad $fields FROM DimensionesElem de0 
		LEFT JOIN Dimensiones d0 ON d0.id = de0.dimensionesId
		$LJ
		WHERE de0.id = $elem
    ''';

    List dims = await db.query(sql2);
//    print('Dims $dims');

    Map r = new Map();
    r['area'] = d['nombre'];
    r['numDim'] = d['numDim'];
    r['arbol'] = dims[0];

    return r;
  }

  _getDatosVis() async {
    DB db = DB.instance;
    String sql;
    sql = '''
      SELECT *
      FROM Visitas v       
      WHERE v.id = ${vId}
    ''';

    var datos = await db.query(sql);

    var resp = datos == null ? null : datos[0];

    return resp;
  }

  datosVisita(bool fromDB) async {
    if (this.datosVis == null || fromDB) {
      this.datosVis = await _getDatosVis();
      return this.datosVis;
    } else {
      return this.datosVis;
    }
  }

  _getDatosChk() async {
    DB db = DB.instance;

    var chkId = await this.chkId();
//    print('GGG');
    var datos = await db.query("SELECT * FROM Checklist WHERE id = $chkId");

    return datos[0];
  }

  datosChk(bool fromDB) async {
    if (this.datosChecklist == null || fromDB) {
      this.datosChecklist = await _getDatosChk();
      return this.datosChecklist;
    } else {
      return this.datosChecklist;
    }
  }

  visible(pId, direccion) async {
    var res = await this.resultados(false);
    var est = await this.estructura();

    var p = res[pId];
    bool visible = true;

    for (var i in p['conds'].keys) {
      var c = p['conds'][i];
      if (c['accion'] == 2) {
        var v = evalCond(res, c['condicion']);
        if (v == 1) {
          visible = false;
        }
      }
    }

    if (visible) {
      return pId;
    } else {
      var sP = direccion(pId, est, res);
      if (sP == null) {
        return null;
      } else {
        return this.visible(sP['pId'], direccion);
      }
    }
  }

  siguiente(pId) async {
//    print('PPPPPID $pId');
    Map pregs = await this.resultados(false);
    var p = pregs[pId];
//    print('PPPPPP $p');
    var bId = p['bloque'];
    var aId = p['area'];

    if (p['subarea'] != null) {
      return await sigSubPreg(bId, aId, p['subarea'], pId);
    } else {
      var sP = await sigPreg(bId, aId, pId);
      p = pregs[sP['pId']];
      if (p == null) {
        Map r = new Map();
        r['bId'] = null;
        r['aId'] = null;
        r['pId'] = null;
        return r;
      }
      if (p['tipo'] == 'sub') {
        return await sigSubPreg(sP['bId'], sP['aId'], sP['pId'], 0);
      } else {
        return sP;
      }
    }
  }

  sigSubPreg(bId, aId, pId, spId) async {
    Map est = await this.estructura();
    Map pregs = this.preguntas;

    Map subPreguntas =
        est['bloques'][bId]['areas'][aId]['preguntas'][pId]['subpregs'];

    Map r = new Map();

    var nspId;
    if (spId == 0) {
      for (var i in subPreguntas.keys) {
        nspId = i;
        break;
      }
    } else {
      int j = 0;
      for (var i in subPreguntas.keys) {
        int r = 0;
        var next = null;
        for (var k in subPreguntas.keys) {
          next = k;
          if (r == j + 1) {
            break;
          }
          next = null;
          r++;
        }
        j++;
        if (i == spId) {
          nspId = next;
          break;
        }
      }
    }

    if (nspId == null) {
      var sP = await sigPreg(bId, aId, pId);
      pId = sP['pId'];
      aId = sP['aId'];
      bId = sP['bId'];

      if (pId == null) {
        r['pId'] = null;
        r['aId'] = null;
        r['bId'] = null;
        return r;
      } else {
        if (pregs[pId]['tipo'] == 'sub') {
          var ssp = sigSubPreg(bId, aId, pId, 0);
          return ssp;
        } else {
          r['pId'] = pId;
          r['aId'] = aId;
          r['bId'] = bId;

          return r;
        }
      }
    } else {
      r['pId'] = nspId;
      r['aId'] = aId;
      r['bId'] = bId;

      return r;
    }
  }

  sigPreg(bId, aId, pId) async {
    Map est = await this.estructura();
    var npId;
    Map r = new Map();
    Map preguntas = est['bloques'][bId]['areas'][aId]['preguntas'];
//    print('sigPreg bId: $bId, aId: $aId, pId: $pId');

    if (pId == 0) {
      for (var i in preguntas.keys) {
        npId = i;

        break;
      }
    } else {
//      print('sigPreg preguntas.length: ${preguntas.length}');
      if (preguntas.length == 0) {
        r['pId'] = null;
        r['aId'] = null;
        r['bId'] = null;
        return r;
      } else {
        int j = 0;
        for (var i in preguntas.keys) {
          int r = 0;
          var next = null;
          for (var k in preguntas.keys) {
            next = k;
            if (r == j + 1) {
              break;
            }
            next = null;
            r++;
          }
          j++;
          if (i == pId) {
            npId = next;
            break;
          }
        }
      }
    }
//      print('sigPreg NPID : $npId');

    if (npId == null) {
      var sA = await sigArea(bId, aId);
//        print('SIGUIENTE AREA $sA');
      aId = sA['aId'];
      bId = sA['bId'];

      if (aId == null) {
        r['pId'] = null;
        r['aId'] = null;
        r['bId'] = null;

        return r;
      } else {
        var sP = await sigPreg(bId, aId, 0);
//          print('AAAAAAAAAAA $sP');
        return sP;
      }
    } else {
      r['pId'] = npId;
      r['aId'] = aId;
      r['bId'] = bId;

      return r;
    }
  }

  sigArea(bId, aId) async {
//    print('bId: $bId, aId: $aId');
    Map est = await this.estructura();

    List<dynamic> AAA = List<dynamic>();
    Map<String, dynamic> areas =
        est['bloques'][bId]['areas'].runtimeType == AAA.runtimeType
            ? Map<String, dynamic>()
            : est['bloques'][bId]['areas'];

//    Map areas = est['bloques'][bId]['areas'];
//    print('AREAS2 $areas');
    var naId;
    Map r = new Map();

    if (aId == 0) {
      for (var i in areas.keys) {
        naId = i;
        break;
      }
    } else {
      var j = 0;
      for (var i in areas.keys) {
        var r = 0;
        var next = null;
        for (var k in areas.keys) {
          next = k;
          if (r == j + 1) {
            break;
          }
          next = null;
          r++;
        }
        j++;
        if (i == aId) {
          naId = next;
          break;
        }
      }
    }

    if (naId == null) {
      bId = await sigBloque(bId);
      if (bId == null) {
        r['bId'] = null;
        r['aId'] = null;
        return r;
      } else {
        return await sigArea(bId, 0);
      }
    } else {
      r['bId'] = bId;
      r['aId'] = naId;
      return r;
    }
  }

  sigBloque(bId) async {
    Map est = await this.estructura();
    Map bloques = est['bloques'];
    var nbId = null;
    int j = 0;
    for (var i in bloques.keys) {
      int r = 0;
      var next = null;
      for (var k in bloques.keys) {
        next = k;
        if (r == j + 1) {
          break;
        }
        next = null;
        r++;
      }
      j++;
      if (i == bId) {
        nbId = next;
      }
    }
    return nbId;
  }

  regBloque(bId) async {
    Map est = await this.estructura();
    Map bloques = est['bloques'];
    var nbId = null;

    int j = 0;
    for (var i in bloques.keys) {
      var r = 0;
      var prev = null;
      for (var k in bloques.keys) {
        prev = k;
        if (r == j - 1) {
          break;
        }
        prev = null;
        r++;
      }
      j++;
      if (i == bId) {
        nbId = prev;
      }
    }
    return nbId;
  }

  regArea(bId, aId) async {
//    print('bId: $bId, aId: $aId');
    Map est = await this.estructura();
    Map areas = est['bloques'][bId]['areas'];
//    print ("AREAS $areas");
    var naId = null;
    Map r = new Map();

    if (aId == 0) {
      for (var i in areas.keys) {
        naId = i;
      }
    } else {
      var j = 0;
      for (var i in areas.keys) {
        var r = 0;
        var prev = null;
        for (var k in areas.keys) {
          prev = k;
          if (r == j - 1) {
            break;
          }
          prev = null;
          r++;
        }
        j++;
        if (i == aId) {
          naId = prev;
          break;
        }
      }
    }
//    print('NAID: $naId');

    if (naId == null) {
//      print("REGRESA BLOQUE");
      bId = await regBloque(bId);
//      print('BLOQUE $bId');
      if (bId == null) {
        r['bId'] = null;
        r['aId'] = null;
        return r;
      } else {
        return await regArea(bId, 0);
      }
    } else {
      r['bId'] = bId;
      r['aId'] = naId;
      return r;
    }
  }

  regPreg(bId, aId, pId) async {
//    print('BID: $bId, AID: $aId, PID: $pId');
    Map est = await this.estructura();
    var npId;
    Map r = new Map();
    Map preguntas = est['bloques'][bId]['areas'][aId]['preguntas'];

    if (pId == 0) {
      for (var i in preguntas.keys) {
        npId = i;
      }
    } else {
      if (preguntas == null) {
        r['pId'] = null;
        r['aId'] = null;
        r['bId'] = null;
        return r;
      }
      int j = 0;
      for (var i in preguntas.keys) {
        int r = 0;
        var prev = null;
        for (var k in preguntas.keys) {
          prev = k;
          if (r == j - 1) {
            break;
          }
          prev = null;
          r++;
        }
        j++;
        if (i == pId) {
          npId = prev;
          break;
        }
      }
    }

//    print('NPID $npId');

    if (npId == null) {
      var sA = await regArea(bId, aId);
//      print('SSSSAAAAAA $sA');
      aId = sA['aId'];
      bId = sA['bId'];

      if (aId == null) {
        r['pId'] = null;
        r['aId'] = null;
        r['bId'] = null;
        return r;
      } else {
        return regPreg(bId, aId, 0);
      }
    } else {
      r['pId'] = npId;
      r['aId'] = aId;
      r['bId'] = bId;

      return r;
    }
  }

  regSubPreg(bId, aId, pId, spId) async {
    Map est = await this.estructura();
    Map pregs = await this.resultados(false);
    var nspId;
    Map r = new Map();
    Map subPreguntas =
        est['bloques'][bId]['areas'][aId]['preguntas'][pId]['subpregs'];

    if (spId == 0) {
      for (var i in subPreguntas.keys) {
        nspId = i;
      }
    } else {
      int j = 0;
      for (var i in subPreguntas.keys) {
        int r = 0;
        var prev = null;
        for (var k in subPreguntas.keys) {
          prev = k;
          if (r == j - 1) {
            break;
          }
          prev = null;
          r++;
        }
        j++;
        if (i == spId) {
          nspId = prev;
          break;
        }
      }
    }
//    print('NSPID: $nspId');

    if (nspId == null) {
      var sP = await regPreg(bId, aId, pId);
//      print('SP: $sP');
      pId = sP['pId'];
      aId = sP['aId'];
      bId = sP['bId'];

      if (pId == null) {
        r['pId'] = null;
        r['aId'] = null;
        r['bId'] = null;
        return r;
      } else {
        if (pregs[pId]['tipo'] == 'sub') {
          var ssp = regSubPreg(bId, aId, pId, 0);
          return ssp;
        } else {
          r['pId'] = pId;
          r['aId'] = aId;
          r['bId'] = bId;

          return r;
        }
      }
    } else {
      r['pId'] = nspId;
      r['aId'] = aId;
      r['bId'] = bId;

      return r;
    }
  }

  regresar(pId) async {
//    print('PPPPPPP $pId');
    Map pregs = await this.resultados(false);
    Map p = pregs[pId];
    var aId = p['area'];
    var bId = p['bloque'];

    if (p['subarea'] != null) {
      return await regSubPreg(bId, aId, p['subarea'], pId);
    } else {
      var sP = await regPreg(bId, aId, pId);
      p = pregs[sP['pId']];
      if (p == null) {
        Map r = new Map();
        r['bId'] = null;
        r['aId'] = null;
        r['pId'] = null;
        return r;
      }
      if (p['tipo'] == 'sub') {
        var rSP = await regSubPreg(sP['bId'], sP['aId'], sP['pId'], 0);
        return rSP;
      } else {
        return sP;
      }
    }
  }

  sigPregSaltos(pId, pregs) async {
    Map sig = await this.siguiente(pId);

    Map preg = pregs[sig['pId']];
//    print('SIGUIENTE $sig $preg');
    Map r = new Map();
    if (preg != null) {
      if (preg['muestra'] == 1) {
        return sig;
      } else {
        return sigPregSaltos(sig['pId'], pregs);
      }
    } else {
      r['bId'] = null;
      r['aId'] = null;
      r['pId'] = null;
      return r;
    }
  }

  antPregSaltos(pId, pregs) async {
    Map ant = await this.regresar(pId);
    Map preg = pregs[ant['pId']];
    Map r = new Map();
    if (preg != null) {
      if (preg['muestra'] == 1) {
        return ant;
      } else {
        return antPregSaltos(ant['pId'], pregs);
      }
    } else {
      r['bId'] = null;
      r['aId'] = null;
      r['pId'] = null;
      return r;
    }
  }

  guardaResp(resp) async {
    print(resp);
    var rvId;
    var rv = await db.query(
        "SELECT * FROM RespuestasVisita WHERE visitasId = ${resp['visitasId']} AND preguntasId = ${resp['preguntasId']}");
    if (rv == null) {
      print('-------- ACA -------');
      rvId = await db.insert('RespuestasVisita', resp, true);
    } else {
      rvId = rv[0]['id'];
      await db.query(
          "UPDATE RespuestasVisita SET respuesta = '${resp['respuesta']}', justificacion = '${resp['justificacion']}' WHERE id = $rvId");
    }

    await db.query(
        "UPDATE Visitas SET offline = 1 WHERE id = ${resp['visitasId']}");

    print('RVID: $rvId');
  }

  guardaMultimedia(file) async {
    Map f = new Map<String, dynamic>();
    f['visitasId'] = this.vId;
    f['tipo'] = 'img';
    f['nombre'] = 'imagen.jpg';
    f['archivo'] = file;
    f['descripcion'] = '';

    await db.insert('Multimedia', f, false);
  }

  getMultimedia() async {
    String sql = 'SELECT * FROM Multimedia WHERE visitasId = ${this.vId}';
    List mult = await db.query(sql);

    return mult;
  }

  faltaPreg() async {
    Map pregs = await this.resultados(true);
    var identificador = null;
    for (var i in pregs.keys) {
      if (pregs[i]['respuesta'] != null &&
          pregs[i]['respuesta'] != '' &&
          pregs[i]['respuesta'] != '_' &&
          pregs[i]['respuesta'] != '-' &&
          pregs[i]['tipo'] != 'sub') {
//        print('Entra $i');
      } else {
        if (pregs[i]['muestra'] == 1 && pregs[i]['tipo'] != 'sub') {
//          print('Falta preg $i');
          identificador = i;
          break;
        }
      }
    }
    return identificador;
  }

  finalizaVisita(
      {bool viable = true,
      String justifViable,
      GlobalKey<SurveysState> key}) async {
    var datChk = await datosChk(false);
    var datVisDB =
        await db.query("SELECT * FROM Visitas WHERE id = ${this.vId}");
    SharedPreferences userData = await SharedPreferences.getInstance();
    int usrId;
    if (userData.getBool('login') != null) {
      usrId = userData.getInt('userId');
    }

    var vis = datVisDB[0];
//    print(vis);

    DateTime now = new DateTime.now();
//    print(' - - - - NOW: $now - - - - - -');
    var hoy = '$now'.split(' ')[0];
//    print(' - - - - HOY: $hoy - - - - - -');
    String sql = '';
    sql =
        'UPDATE Visitas SET finishDate = "$hoy", finalizada = 1, offline = 1 WHERE id = ${this.vId}';
//    print(' Descomentar siguiente $sql ');

    try {
      await db.query(sql);
    } catch (e) {
      print(e);
      print(sql);
    }

    var estatus;
//    print('========  ESTATUS QUE LLEGA ======');
//    print(vis['estatus']);
    switch (vis['estatus']) {
      case '40':
      case '44':
      case '45':
      case '47':
        estatus = 48;
        break;
      case '30':
      case '33':
      case '34':
      case '35':
      case '37':
        estatus = 38;
        break;
      case '55':
      case '56':
      case '57':
      case '58':
        estatus = 60;
        break;
      case '44':
      case '45':
      case '46':
      case '47':
      case '48':
        if (vis['etapa'] == 'evaluacionInt') {
          estatus = 60;
        } else {
          estatus = 48;
        }
        break;
      case '55':
      case '56':
      case '57':
      case '58':
        estatus = 60;
        break;
      default:
        estatus = 60;
        break;
    }

    String comentario;
    switch (vis['etapa']) {
      case 'evaluacionInt':
        comentario = 'Finaliza cuestionario de evaluacion interna';
        break;
      case 'impacto':
        comentario = 'Finaliza cuestionario de impacto del proyecto';
        break;
      case 'seguimientoTel':
        comentario = 'Finaliza cuestionario de seguimiento telefónico';
        break;
      case 'seguimiento':
        comentario = 'Finaliza cuestionario de seguimiento en campo';
        break;
      case 'reparacion':
        comentario = 'Finaliza cuestionario de reparacion';
        break;
      case 'visita':
        comentario = 'Finaliza cuestionario de visita técnica';
        break;
      case 'instalacion':
        comentario = 'Finaliza cuestionario de visita instalación';
        break;
      default:
        comentario = null;
        break;
    }
    if (!viable) {
      estatus = 3;
      comentario = justifViable;
    }
//    print('========  ESTATUS QUE SALE ======');
//    print(estatus);

//    print(' Descomentar siguiente $sql ');
    try {
      await db.query(sql);
    } catch (e) {
      print(e);
      print(sql);
    }

    sql = "UPDATE Visitas SET estatus = $estatus WHERE id = ${this.vId} ";
//    print(' Descomentar siguiente $sql ');
    try {
      await db.query(sql);
    } catch (e) {
      print(e);
      print(sql);
    }
//    print('========  ESTATUS HASTA ACÁ ======');
//    print(estatus);
  }
}

bool is_numeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}

String parseHtmlString(String htmlString) {
  htmlString = htmlString == null ? '' : htmlString;

  var document = parse(htmlString);

  String parsedString = parse(document.body.text).documentElement.text;

  return parsedString;
}
