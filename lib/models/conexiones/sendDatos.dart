import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';




class DatosDB {
  DB db = DB.instance;

  getDimensionesElem({bool creadoOffline,bool offline}) async {

    String sql;
    List dimensionesElem = [];
    String wCreadoOffline;
    String wOffline;

    if(creadoOffline){
      wCreadoOffline = ' creadoOffline = 1 ';
    }else{
      wCreadoOffline = ' (creadoOffline = 0 OR creadoOffline IS NULL) ';
    }
//    if(offline){
//      wOffline = ' offline = 1 ';
//    }else{
//      wOffline = ' (offline = 0 OR offline IS NULL) ';
//    }

    sql = 'SELECT * FROM DimensionesElem WHERE $wCreadoOffline';
    List dimsElems = await db.query(sql);
    dimsElems ??= [];


    for(int i = 0; i<dimsElems.length;i++){
      var c = dimsElems[i];

      Map dimElem = Map.from(dimsElems[i]);
      dimElem['targetsElem'] = await getTargetsElem(false,false,c['id']);
      dimensionesElem.add(dimElem);

    }

    return dimensionesElem;

  }

  getUserConsultationsChecklist(bool creadoOffline, bool offline) async {
    String sql;
    List UsersConsultationsChecklist = [];
    String wCreadoOffline;
    String wOffline;


    if(creadoOffline){
      wCreadoOffline = ' creadoOffline = 1 ';
    }else{
      wCreadoOffline = ' (creadoOffline = 0 OR creadoOffline IS NULL) ';
    }
    if(offline){
      wOffline = ' offline = 1 ';
    }else{
      wOffline = ' (offline = 0 OR offline IS NULL) ';
    }

    sql = 'SELECT * FROM UsersConsultationsChecklist WHERE $wCreadoOffline AND $wOffline';

    List uccs = await db.query(sql);

//    print('CTES = $uccs');

    uccs ??= List();
    for(int i = 0;i<uccs.length;i++){
      var c = uccs[i];
      print('UCC: $c');

      Map ucc = Map();
      ucc['ucc'] = c;
      print('elemID: ${c['id']}');
      ucc['visitas'] = await getVis(elemId:c['id'], creadoOffline: false, offline: false,type: 'cons');
      print('VISITAS: ${ucc['visitas']}');
      UsersConsultationsChecklist.add(ucc);
    }

    List vis = await db.query("SELECT * FROM Visitas WHERE type = 'cons'");
    print("VISITAS: $vis");
//    print('UsersConsultationsChecklist: $UsersConsultationsChecklist');
//    print('======= TargetsELem SOLICITADOS $creadoOffline, $offline ========');
//    for(int i = 0;i<UsersConsultationsChecklist.length;i++){
//      print('${UsersConsultationsChecklist[i]['nombre']} ');
//    }

    return UsersConsultationsChecklist;
  }


  getTargetsElem(bool creadoOffline, bool offline, int dimensionesElemId) async {
    String sql;
    List targetsElem = [];
    String wCreadoOffline;
    String wOffline;


    if(creadoOffline){
      wCreadoOffline = ' creadoOffline = 1 ';
    }else{
      wCreadoOffline = ' (creadoOffline = 0 OR creadoOffline IS NULL) ';
    }
    if(offline){
      wOffline = ' offline = 1 ';
    }else{
      wOffline = ' (offline = 0 OR offline IS NULL) ';
    }

    if(dimensionesElemId != null){
      sql = 'SELECT * FROM TargetsElems WHERE dimensionesElemId = $dimensionesElemId';
    }else {
      sql = 'SELECT * FROM TargetsElems WHERE $wCreadoOffline AND $wOffline';
    }
    
    List trgtsElems = await db.query(sql);

//    print('CTES = $trgtsElems');

    trgtsElems ??= List();
    for(int i = 0;i<trgtsElems.length;i++){
      var c = trgtsElems[i];
      Map trgtElem = Map();
      trgtElem['trgtElem'] = c;
      trgtElem['visitas'] = await getVis(elemId:c['id'], creadoOffline: false, offline: false,type: 'trgt');
      targetsElem.add(trgtElem);
    }
//    print('targetsElem: $targetsElem');
//    print('======= TargetsELem SOLICITADOS $creadoOffline, $offline ========');
//    for(int i = 0;i<targetsElem.length;i++){
//      print('${targetsElem[i]['nombre']} ');
//    }

    return targetsElem;
  }


  getVis({int elemId, bool creadoOffline, bool offline, String type}) async {

    var vvv = await db.query("SELECT * FROM Visitas WHERE type = 'cons'");
    print('VVVV: $vvv');
    print("ELEMID: $elemId");

    List visitas = [];
    String sql;

    String wCreadoOffline;
    String wOffline;

    if(creadoOffline){
      wCreadoOffline = ' creadoOffline = 1 ';
    }else{
      wCreadoOffline = ' (creadoOffline = 0 OR creadoOffline IS NULL) ';
    }
    if(offline){
      wOffline = ' offline = 1 ';
    }else{
      wOffline = ' (offline = 0 OR offline IS NULL) ';
    }

    if(elemId != null){
      sql = 'SELECT * FROM Visitas WHERE elemId = $elemId AND type = "$type" ';
    }else {
      sql = 'SELECT * FROM Visitas WHERE $wCreadoOffline AND $wOffline';
    }

    print('SQL: $sql');
    var vis = await db.query(sql);

    vis ??= List();
    for(int i = 0; i<vis.length;i++){
      var v = vis[i];
      Map visita = Map();
      visita['visita'] = v;
      visita['respuestas'] = await getRespuestasVisita(v['id']);
      visita['multimedia'] = await getMult(v['id']);
      visitas.add(visita);
    }

    return visitas;
  }

  getRespuestasVisita(int vId) async {
    List respuestasDB = await db.query('''
      SELECT rv.*
      FROM RespuestasVisita rv  
      WHERE rv.visitasId = $vId
    ''');
    List respuestas = [];
    respuestasDB ??= [];
    for(int i = 0; i< respuestasDB.length;i++){
      Map respuesta = Map.from(respuestasDB[i]);
      if(respuesta['respuesta'] == 'spatial'){
        List problemsDB = await db.query("SELECT * FROM problems WHERE respuestasVisitaId = ${respuesta['id']}");
        problemsDB ??= [];
        List problems = [];
        for(int j = 0;j<problemsDB.length;j++){
          Map problem = Map.from(problemsDB[j]);
          problem['photo64'] = problem['photo'] != null? await getFileToStr(archivo: problem['photo'],subdir: 'fotos'):'';

          List points = await db.query("SELECT * FROM Points WHERE problemsId = ${problem['id']}");
          points ??= [];
          problem['points'] = points;
//          print(problem['photo64']);
          problems.add(problem);

        }
//        print("PROBLEMS: $problems");
        respuesta['problems'] = problems;

      }
      respuestas.add(respuesta);
    }
//    print('RESPUESTAS $respuestas');
    return respuestas;
  }

  getMult(int vId) async {
    List mResult = await db.query("SELECT * FROM Multimedia WHERE visitasId = $vId");
    List mult = [];
    mult ??= [];
    mResult ??= List();
    for(int i = 0;i<mResult.length; i++){
      Map m = Map();
      for(var k in mResult[i].keys){
        m[k] = mResult[i][k];
      }

      var archivo = m['archivo'];
      String base64Image = await getFileToStr(archivo: archivo,subdir: '$vId');

      m['File'] = base64Image;

      mult.add(m);
    }

    return mult;
  }

  getFileToStr({String archivo,String subdir}) async {
    var directory = await getApplicationDocumentsDirectory(); // AppData folder path
//    print("$archivo,$subdir");
    if(archivo != null && archivo != ''){
      var path = '${directory.path}/$subdir';
      File file = await File('${path}/${archivo}');
      String base64Image = await base64Encode(file.readAsBytesSync());

      return base64Image;
    }else{
      return null;
    }

  }

  getPolls() async {

    SharedPreferences userData = await SharedPreferences.getInstance();
    int usrId = userData.getInt('userId');

    List polls = await db.query("SELECT * FROM UsersQuickPoll WHERE usersId = $usrId");

    return polls;

  }


  List<Map<String, dynamic>> makeModifiableResults(
      List<Map<String, dynamic>> results) {
    // Generate modifiable
    return List<Map<String, dynamic>>.generate(
        results.length, (index) => Map<String, dynamic>.from(results[index]),
        growable: true);
  }

  delVisita(visita) async {

    try{
      await db.query('DELETE FROM RespuestasVisita WHERE visitasId = ${visita['visita']['id']}');
      await db.query('DELETE FROM Multimedia WHERE visitasId = ${visita['visita']['id']}');
      await db.query('DELETE FROM Visitas WHERE id= ${visita['visita']['id']}');

      Directory directory = await getApplicationDocumentsDirectory(); // AppData folder path
      String path = '${directory.path}/${visita['visita']['id']}';

      Directory vDir = Directory(path);

      try{
        vDir.delete(recursive: true);
      }catch(e){
        print('Error al intentar eliminar el archivo $e');
      }


      return true;
    }catch(e){
      return false;
    }

  }

  send(Map elemento,String tipo) async {

    String estatus;

    SharedPreferences userData = await SharedPreferences.getInstance();
    int usrId = userData.getInt('userId');
    int nivel = userData.getInt('nivel');
    String hash = userData.getString('hash');

    try{
      String url = 'https://sistema.solucionpluvial.com/API/sendCampo.php';
      estatus = 'Enviando al servidor los datos de $tipo';

//      keyInicio.currentState.setEstatusSync(estatus);
      print('todavia acá');
//      var str = {'usrId':'$usrId','nivel':'$nivel', 'hash':hash,'tipo':tipo,'elemento':jsonEncode(elemento)};

//      var directory = await getApplicationDocumentsDirectory();
//      var dir = directory.path;
//      var file = await File('$dir/counter.txt');
////      file.writeAsString('$str');
//      print(dir);
//



//      print(str);
      final response = await http.post(url,body:{'usrId':'$usrId','nivel':'$nivel', 'hash':hash,'tipo':tipo,'elemento':jsonEncode(elemento)});
      print('todavia acá 2');
//      keyInicio.currentState.setEstatusSync('Termina envio al servidor de datos de $tipo');

      if (response.statusCode == 200) {
//        print('XXXXXXXX');
        print('Inicia respuesta del server');
        print(response.body);
        print('Finaliza respuesta del server');
        estatus = 'Se ha enviado al servidor los datos de $tipo';
//        keyInicio.currentState.setEstatusSync(estatus);
        return jsonDecode(response.body);
      } else {
        String error = '''
Error al sincronizar. El servidor devolvió: 
${response.body}
        ''';
        print('====== Error del server =====');
//        keyInicio.currentState.setError(error);
//        print('aaaa');
        print(response.body);
        print(response.statusCode);
//        print('aaaa');
        throw Exception('Failed to load post');
        //    If that call was not successful, throw an error.
      }

    }catch(e){
//      return null;
    }

  }




}