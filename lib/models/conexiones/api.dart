import 'dart:io';

import 'package:http/http.dart' as http;
//import 'package:http/http.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/models/conexiones/sendDatos.dart';
import 'package:siap/views/login/conexion.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:siap/models/translations.dart';
import 'package:latlong/latlong.dart';

//String urlHtml = 'http://paraguaytest.collabmap.in';
String urlHtml = 'http://chacarita.collabmap.in';
String SERVER = '$urlHtml/api/public/siapApp/';

Future getDatos({String opt,String varNom = null, bool imprime,bool cache = false}) async {
  var respuesta;
  SharedPreferences userData = await SharedPreferences.getInstance();
  String body;
  try{
    String url = '${SERVER}$opt';
    if(imprime) {
//      print(url);
    }
    final response = await http.get(url);
    if (response.statusCode == 200) {
      body = utf8.decode(response.bodyBytes);
      if(imprime){
//        print('Inicia respuesta del server');
//        print(body);
//        print('Finaliza respuesta del server');
      }

      if(varNom != null){
        userData.setString(varNom, body);
      }

      respuesta = jsonDecode(body);
    
    } else {
      body = utf8.decode(response.bodyBytes);
      if(imprime){
        print('Inicia respuesta del serverErr');
        print(body);
        print('Finaliza respuesta del serverErr');
      }
      respuesta = jsonDecode(body);
      throw Exception('Failed to load post');
      //    If that call was not successful, throw an error.
    }
  }catch(e){

    print('Error 02 = $e');
    if(cache){
      respuesta = jsonDecode(userData.getString(varNom));
    }else{
      respuesta = null;
    }
  }
  return respuesta;
}

Future<List> sendDatos({List problems, bool imprime = false, String token = null}) async {
  DB db = DB.instance;

  if(token == null){
    SharedPreferences userData = await SharedPreferences.getInstance();
    String username = userData.getString('username');
    String password = userData.getString('password');
    Post getToken = await loginPost(username, password);
    token = getToken.token;
  }
  String dir = (await getApplicationDocumentsDirectory()).path;

  for(int i = 0; i<problems.length;i++){
    Map problem = problems[i];
    try{
      var url = '${SERVER}surveys/spatial-inputs/';

      Map<String, String> headersMap = {
        'Authorization' : 'Bearer ' + token,
      };

      var uri = Uri.parse(url);
      http.MultipartRequest request;


//      print(problem['del']);
      if(problem['del'] == 1){
        print('DEEEEL!');
        if(problem['idServer'] != null){
//          print('ELIM SERVER');
          uri = Uri.parse('${url}${problem['idServer']}/');
//          print('${url}${problem['idServer']}/');
          request = new http.MultipartRequest("delete", uri);
        }else{
//          print('ELIM LOCAL');
          db.query('DELETE FROM problems WHERE id = ${problem['id']}');
          if(problem['photo'] != null){
            File foto = File('$dir/fotos/${problem['photo']}');
            foto.delete(recursive: true);
          }
          continue;
        }

      }else if(problem['edit'] == 1  && problem['idServer'] != null){
        print('EDITA');
        uri = Uri.parse('${url}${problem['idServer']}/');
//        print('${url}${problem['idServer']}/');
        request = new http.MultipartRequest("patch", uri);
      }else{

          if(problem['idServer'] == null || problem['idServer'] == ''){
            print('NUEVO ${problem}');
            request = new http.MultipartRequest("POST", uri);
          }
      }

      print('HEADERS: $headersMap');

      request.headers.addAll(headersMap);
      request.fields['answer'] = '${problem['answer']}';
      request.fields['name'] = '${problem['name']}';
      request.fields['description'] = '${problem['description']}';
      request.fields['category'] = '${problem['category']}';
      request.fields['geometry'] = jsonEncode(problem['geometry']);
      if(problem['edit'] == 1  && problem['idServer'] != null){
//        print('EDIT ${problem['idServer']}');
//        request.fields['id'] = '${problem['idServer']}';
      }
//      print('description : ${problem['description']}');
//      print(jsonEncode(problem['geometry']));
      try{
        request.files.add(await http.MultipartFile.fromPath('photo', '$dir/fotos/${problem['photo']}'));
      }catch(e){
        print('Err cargar foto para envío');
        print(e);
      }
      var response = await request.send();

//      print("MANDA DATOS ESPACIALES");
      if(response.statusCode == 201){
        db.query('DELETE FROM problems WHERE id = ${problem['id']}');
        if(problem['photo'] != null){
          File foto = File('$dir/fotos/${problem['photo']}');
          foto.delete(recursive: true);
        }
        if(imprime){
          print('EMPIEZA');
          print('RESPUESTA DEL SERVER: ${await response.stream.bytesToString()}');
          print('TERMINA');
        }

      }else{
        print('EMPIEZA Err');
        print('RESPUESTA DEL SERVER: ${await response.stream.bytesToString()}');
        print('TERMINA Err');
      }

    }catch(e){
      print('Error 03 = $e');
    }
  }

}

sendOneProblem({Map problem, bool imprime = false}) async {
  DB db = DB.instance;


  SharedPreferences userData = await SharedPreferences.getInstance();
  String username = userData.getString('username');
  String password = userData.getString('password');
  Post getToken = await loginPost(username, password);
  String token = getToken.token;
  String dir = (await getApplicationDocumentsDirectory()).path;

  /////////
//  Map problem = problems[i];
  try{
    var url = '${SERVER}problems/';

    Map campos = Map<String,dynamic>();
    campos['consultation'] = '${problem['consultation']}';
    campos['description'] = '${problem['description']}';
    campos['category'] = '${problem['category']}';
    campos['geometry'] = jsonEncode(problem['geometry']);
//    print(jsonEncode(problem['geometry']));

    Map<String, String> headersMap = {
      'Authorization' : 'Bearer ' + token,
    };

    var uri = Uri.parse(url);
    var request;

//    print(problem['del']);
    if(problem['edit'] == 1  && problem['idServer'] != null){
      uri = Uri.parse('${url}${problem['idServer']}/');
//      print('${url}${problem['idServer']}/');
      request = new http.MultipartRequest("patch", uri);
    }else{
      request = new http.MultipartRequest("POST", uri);
    }

    request.headers.addAll(headersMap);
    request.fields['consultation'] = '${problem['consultation']}';
    request.fields['description'] = '${problem['description']}';
    request.fields['category'] = '${problem['category']}';
    request.fields['geometry'] = jsonEncode(problem['geometry']);
    if(problem['edit'] == 1  && problem['idServer'] != null){
//      print('EDIT ${problem['idServer']}');
//        request.fields['id'] = '${problem['idServer']}';
    }
    try{
      request.files.add(await http.MultipartFile.fromPath('photo', '$dir/fotos/${problem['photo']}'));
    }catch(e){
      print('Err cargar foto para envío');
      print(e);
    }
    var response = await request.send();

    if(response.statusCode == 201){
      return jsonDecode(await response.stream.bytesToString());
    }else{
      print('EMPIEZA');
      print('RESPUESTA DEL SERVER: ${await response.stream.bytesToString()}');
      print('TERMINA');
    }

  }catch(e){
    print('Error 04 = $e');
  }






}

postDatos({Map datos, String opt, bool verif = false,String metodo, bool imprime = false,String token = null}) async {
  DB db = DB.instance;
  var request;
  Map<String, String> headersMap = {};
  if(verif){
    if(token == null){
//      print('ENTRAAAAA');
      SharedPreferences userData = await SharedPreferences.getInstance();
      String username = userData.getString('username');
      String password= userData.getString('password');
      Post getToken = await loginPost(username, password);
      token = getToken.token;
      if(imprime){
        print('TOKEN: $token');
      }
    }
//    print('TOKEN222: $token');
    headersMap = {
      'Authorization' : 'Bearer ' + token,
    };
  }

  try{
    String url = '${SERVER}$opt';
//    print('URL:  $url');
    var uri = Uri.parse(url);
    request = new http.MultipartRequest(metodo, uri);
    request.headers.addAll(headersMap);
    for(var i in datos.keys){
      var dato = datos[i];
      if(dato['type'] == 'String'){
        request.fields[dato['name']] = '${dato['value']}';
      }
    }
    var response = await request.send();


    if(response.statusCode == 201 || response.statusCode == 200){
      var resp = await response.stream.bytesToString();
      if(imprime){
//        print('- - - - - - - -- ');
        print(resp);
      }
      return jsonDecode(resp);
    }else{

      var resp = await response.stream.bytesToString();
      if(imprime){
        print('StatusCode: ${response.statusCode}');
        print('EMPIEZA');
        print('RESPUESTA DEL SERVER: ${resp}');
        print('TERMINA');
      }
      return jsonDecode(resp);
    }


  }catch(e){
    print('Errors = $e');
    return null;
  }


}

Future getDatos2({String opt,String varNom = null, bool imprime}) async {
  var respuesta;
  SharedPreferences userData = await SharedPreferences.getInstance();
  String body;

  String token = userData.getString('token');
  token ??= '';
  if(imprime){
    print('Token: $token');
  }
  try{
    String url = '${SERVER}$opt';

    Map<String, String> headersMap = {

      'Authorization' : 'Bearer ' + token,
    };

    var uri = Uri.parse(url);
    var request = new http.MultipartRequest("GET", uri);
    request.headers.addAll(headersMap);
    var response = await request.send();


    if(response.statusCode == 200){
      if(imprime){
        print('RESPUESTA DEL SERVER: ${await response.stream.bytesToString()}');
      }
      respuesta = jsonDecode(await response.stream.bytesToString());
      if(varNom != null){
        userData.setString(varNom, body);
      }

    }else{
      print('EMPIEZA Err');
      print('RESPUESTA DEL SERVER: ${await response.stream.bytesToString()}');
      print('TERMINA Err');
    }

  }catch(e){
    print('Error 01 = $e');
  }

  return respuesta;
}

Map generaDatoString({String name, var value}){
  Map resp = Map();
  resp['name'] = name;
  resp['type'] = 'String';
  resp['value'] = value;
  return resp;
}

problemDBtoAPI({Map problemDB}) async {
  DB db = DB.instance;
  Map problem = Map();

  String type;
  Map geometry = Map();
  List coordinates = [];
  List points = await db.query("SELECT * FROM points WHERE problemsId = ${problemDB['id']}");
  points ??= [];
//  print('POINTS: $points');

//  print('problemDB: $problemDB');

  switch(problemDB['type']){
    case 'Marker':
      type = 'Point';
//          print('AAAAA ${points[0]['lng']}');
      if(points.length>0){
        coordinates.add(points[0]['lng']);
        coordinates.add(points[0]['lat']);
      }
      break;
    case 'Polygon':
      type = 'Polygon';
      List subPoligono = [];
      List poligono = [];
//          print(points.length);
      for(int j = 0;j<points.length;j++){
        List tmp = [];
        tmp.add(points[j]['lng']);
        tmp.add(points[j]['lat']);
        poligono.add(tmp);
//            subPoligono.add(tmp);
      }
      if(points.length > 0){
        poligono.add([points[0]['lng'],points[0]['lat']]);
      }
      coordinates.add(poligono);
      break;
    case 'Polyline':
      type = 'LineString';
      for(int j = 0;j<points.length;j++){
        List tmp = [];

        tmp.add(points[j]['lng']);
        tmp.add(points[j]['lat']);
        coordinates.add(tmp);
      }
      break;
    default:
      type = 'Point';
      break;
  }
  geometry['coordinates'] = coordinates;
  geometry['type'] = type;

  problem['id'] = problemDB['id'];
  problem['geometry'] = geometry;
  problem['category'] = problemDB['catId'];
  problem['description'] = problemDB['input'];
  problem['name'] = problemDB['name'];
  problem['photo'] = problemDB['photo'];
  problem['answer_id'] = problemDB['answers_id'];
  problem['edit'] = problemDB['edit'];
  problem['idServer'] = problemDB['idServer'];
  problem['del'] = problemDB['del'];

  return problem;

}

sendData() async {

  DB db = DB.instance;

  SharedPreferences userData = await SharedPreferences.getInstance();

  String token = userData.getString('token');
  int userId = userData.getInt('userId');

  var datos = DatosDB();
  Map post = {};

  List dimensionesElems = await datos.getDimensionesElem(creadoOffline: true,offline: true);
  dimensionesElems ??= [];
//  print(dimensionesElems);
  post['dimensionesElems'] = {};
  post['dimensionesElems']['type'] = 'String';
  post['dimensionesElems']['name'] = 'dimensionesElems';
  post['dimensionesElems']['value'] = jsonEncode(dimensionesElems);
  var respDE = await postDatos(
      datos: post,
      imprime: false,
      metodo: 'post',
      verif: true,
      opt: 'sendDimensionesElems/user/${userId}',
      token: token
  );

  if(respDE['ok'] != 1){
    return;
  }

  for(int i = 0; i<dimensionesElems.length; i++){
    var dimElem = dimensionesElems[i];
    await db.query("DELETE FROM DimensionesElem WHERE id = ${dimElem['id']}");

    var targetsElem = dimensionesElems[i]['targetsElem'];
    for(int j = 0; j<targetsElem.length; j++){
      var targetElem = targetsElem[j]['trgtElem'];
      await db.query("DELETE FROM TargetsElems WHERE id = ${targetElem['id']}");

      var visitas = targetsElem[j]['visitas'];
      for(int k =0;k<visitas.length;k++){
        var visita = visitas[k]['visita'];
        await db.query("DELETE FROM Visitas WHERE id = ${visita['id']}");
        await db.query("DELETE FROM RespuestasVisita WHERE visitasId = ${visita['id']}");
      }

    }
  }


  List targetsElems= await datos.getTargetsElem(true,true,null);
  targetsElems ??= [];
  post['targetsElems'] = {};
  post['targetsElems']['type'] = 'String';
  post['targetsElems']['name'] = 'targetsElems';
  post['targetsElems']['value'] = jsonEncode(targetsElems);
  var respTE = await postDatos(
      datos: post,
      imprime: false,
      metodo: 'post',
      verif: true,
      opt: 'sendTargetsElems/user/${userId}',
      token: token
  );

  if(respTE['ok'] != 1){
    return;
  }

  for(int j = 0; j<targetsElems.length; j++){
    var targetElem = targetsElems[j]['trgtElem'];
    await db.query("DELETE FROM TargetsElems WHERE id = ${targetElem['id']}");

    var visitas = targetsElems[j]['visitas'];
//    print("VISITAS: $visitas");
    for(int k =0;k<visitas.length;k++){
      var visita = visitas[k]['visita'];
//      print('vId: ${visita['id']}');
      await db.query("DELETE FROM Visitas WHERE id = ${visita['id']}");
      await db.query("DELETE FROM RespuestasVisita WHERE visitasId = ${visita['id']}");
    }

  }


//////////////


  List uccs= await datos.getUserConsultationsChecklist(true,true);
  uccs ??= [];

  print('UCCS: $uccs');
  post['UsersConsultationsChecklist'] = {};
  post['UsersConsultationsChecklist']['type'] = 'String';
  post['UsersConsultationsChecklist']['name'] = 'UsersConsultationsChecklist';
  post['UsersConsultationsChecklist']['value'] = jsonEncode(uccs);
  var respUCC = await postDatos(
      datos: post,
      imprime: true,
      metodo: 'post',
      verif: true,
      opt: 'sendUCC/user/${userId}',
      token: token
  );

  if(respUCC['ok'] != 1){
    return;
  }

  for(int j = 0; j<uccs.length; j++){
    var ucc = uccs[j]['trgtElem'];
    await db.query("DELETE FROM UserConsultationsChecklist WHERE id = ${ucc['id']}");

    var visitas = uccs[j]['visitas'];
//    print("VISITAS: $visitas");
    for(int k =0;k<visitas.length;k++){
      var visita = visitas[k]['visita'];
//      print('vId: ${visita['id']}');
      await db.query("DELETE FROM Visitas WHERE id = ${visita['id']}");
      await db.query("DELETE FROM RespuestasVisita WHERE visitasId = ${visita['id']}");
    }

  }


  List visitasCreadoOffline = await datos.getVis(elemId: null, creadoOffline: true, offline: true,type: null);
  visitasCreadoOffline ??= [];

  print(visitasCreadoOffline);

  post['visitas'] = {};
  post['visitas']['type'] = 'String';
  post['visitas']['name'] = 'visitas';
  post['visitas']['value'] = jsonEncode(visitasCreadoOffline);
  var respV = await postDatos(
      datos: post,
      imprime: true,
      metodo: 'post',
      verif: true,
      opt: 'sendVisitas/user/${userId}',
      token: token
  );

  if(respV['ok'] != 1){
    return;
  }

  for(int k =0;k<visitasCreadoOffline.length;k++){
    var visita = visitasCreadoOffline[k]['visita'];
//    print('vId: ${visita['id']}');
    await db.query("DELETE FROM Visitas WHERE id = ${visita['id']}");
    await db.query("DELETE FROM RespuestasVisita WHERE visitasId = ${visita['id']}");
  }


  List visitasOffline = await datos.getVis(elemId: null, creadoOffline: false, offline: true,type: null);
  visitasOffline ??= [];
  post['visitas'] = {};
  post['visitas']['type'] = 'String';
  post['visitas']['name'] = 'visitas';
  post['visitas']['value'] = jsonEncode(visitasOffline);
  var respVO = await postDatos(
      datos: post,
      imprime: true,
      metodo: 'post',
      verif: true,
      opt: 'sendVisitas/user/${userId}',
      token: token
  );

  if(respVO['ok'] != 1){
    return;
  }

  for(int k =0;k<visitasOffline.length;k++){
    var visita = visitasOffline[k]['visita'];
//    print('vId: ${visita['id']}');
    await db.query("DELETE FROM Visitas WHERE id = ${visita['id']}");
    await db.query("DELETE FROM RespuestasVisita WHERE visitasId = ${visita['id']}");
  }


  List polls = await datos.getPolls();
  polls ??= [];
  print('POLLS: $polls');
  post['polls'] = {};
  post['polls']['type'] = 'String';
  post['polls']['name'] = 'polls';
  post['polls']['value'] = jsonEncode(polls);
  var respPoll = await postDatos(
      datos: post,
      imprime: true,
      metodo: 'post',
      verif: true,
      opt: 'sendPolls/user/${userId}',
      token: token
  );

  if(respPoll['ok'] != 1){
    print('respPoll: $respPoll');
    return;
  }

  for(int k =0;k<polls.length;k++){
    var pollId = polls[k]['id'];
//    print('vId: ${visita['id']}');
    await db.query("DELETE FROM UsersQuickPoll WHERE id = ${pollId}");

  }


}


Future downloadFile({
  String url,
  String filename,
  String subdir = null,
  bool chProgress = true,
  bool printAvance = false,
}) async {

  Dio dio = Dio();
  String dir = (await getApplicationDocumentsDirectory()).path;

  if(subdir != null){
    dir = '$dir/$subdir';

    var existeDir = await Directory(dir).exists();
    if(!existeDir){
      await Directory(dir).create(recursive: true)
          .then((Directory directory){
//            print(directory.path);
      });
    }
  }

  try{
//    print(url);
    await dio.download(url, '$dir/$filename', onReceiveProgress: (rec,total){
//        print('rec: $rec, total: $total');
      var porcentaje = ((rec/total)*100).toStringAsFixed(0);
      var totStr = (total/1024/1024).toStringAsFixed(1);
      var recStr = (rec/1024/1024).toStringAsFixed(1);
//      if(chProgress){
//        setState(() {
//          if(total == -1){
//            progreso = '-- MB / -- MB : -- %';
//          }else{
//            progreso = '$recStr MB / $totStr MB : $porcentaje %';
//          }
//          dlTotal = total;
//        });
//      }
      if(printAvance){
        print('$recStr MB / $totStr MB : $porcentaje %');
      }
    });
  }catch(e){
    print(e);
  }

}

getAllData() async {
  DB db = DB.instance;
  SharedPreferences userData = await SharedPreferences.getInstance();

  int userId = userData.getInt('userId');
  Map r = await getDatos2(opt: 'getAll/user/${userId}',varNom: null,imprime: false);

  for(var i in r.keys){
//    if(i == 'Problems'){
//      for(int j = 0; r['Problems'].length; j++){
//
//      }
////      print('ConsultationsChecklist: ${r[i]}');
//    }else{
//    }
      print('$i: ${r[i].runtimeType}');
      db.insertaLista(i, r[i], true, false);
  }

  List TargetsElems = r['TargetsElems'];
  for(int i =0; i<TargetsElems.length;i++){
//    print(TargetsElems[i]);
  }

}

acomodaDatos({Map datos}) {

  DB db = DB.instance;

  DateTime now = DateTime.now();

  Map consultation = Map();
  consultation['id'] = datos['id'];
  consultation['name'] = datos['name'];
  consultation['code'] = datos['code'];
  consultation['json'] = jsonEncode(datos);
  consultation['status'] = datos['status'];
  consultation['finish_date'] = datos['finish_date'];
  consultation['edit_inputs'] = datos['edit_inputs']?1:0;

//  File f = await File('$dir/${datos['id']}.mbtiles');
//  datos['descargado'] = await f.exists();

  Map areaEstudio = new Map();
//        print(datos['study_area']);
  areaEstudio['type'] = datos['study_area']['type'];
  areaEstudio['coordinates'] = [];
  List poligonos = datos['study_area']['coordinates'];

  for(int j = 0;j<poligonos.length;j++){
    List poligono = poligonos[j];
    List poligonoTmp = [];
    for(int k = 0;k < poligono.length;k++){
      List subPoligono = poligono[k];
      List subPoligonoTmp = [];
      for(int l = 0;l<subPoligono.length;l++){
        var lng;
        var c = subPoligono[l];
        var coord = acomodaCoordenadas(coords:c,donde: 'acomodaDatos',invierte: false);
        subPoligonoTmp.add(coord);
      }
      poligonoTmp.add(subPoligonoTmp);
    }
    areaEstudio['coordinates'].add(poligonoTmp);
  }

  datos['areaEstudio'] = areaEstudio;

  Map centro = new Map();
  centro['type'] = datos['center']['type'];
  var lngC;
//        print("CENTROOOO");
//        print(datos['code']);
//        print(datos['center']);
  if(datos['center']['coordinates'][0] < 0 && datos['center']['coordinates'][0] < -180){
    lngC = 360+datos['center']['coordinates'][0];
  }else{
    lngC = datos['center']['coordinates'][0];
  }
  centro['coordinates'] = [lngC,datos['center']['coordinates'][1]];
  datos['centro'] = centro;

//  List problems = await db.query("SELECT COUNT(*) as cuenta FROM problems WHERE consultationsId = ${datos['id']}");

//  datos['problems'] = problems[0]['cuenta'];
//        print(problems);
//    print(consults);
//  print(datos);
  return datos;
}

List acomodaCoordenadas({List coords,String donde = null, bool invierte = true}){


  var lng;
  if(coords.length == 0){
    return [];
  }


//  print('coords[0] ${coords[0]}');
//  print('coords[0].runtimeType ${coords[0].runtimeType}');

  if(coords[0] < 0 && coords[0] < -180){
    lng = 360+coords[0];
  }else{
    lng = coords[0];
  }

  List coord;
  if(invierte){
    coord = [coords[1],lng];
  }else{
    coord = [lng,coords[1]];
  }
//  print('Donde: $donde, coords: $coords, coord: $coord');
  return coord;

}

getProblems({var answers_id,var answer_id_local}) async {
  DB db = DB.instance;

//  print('answer_id_local: $answer_id_local');

  SharedPreferences sp = await SharedPreferences.getInstance();
  int userId = sp.getInt('userId');

  List problemsPorActualizar = await db.query('''SELECT * FROM problems
      WHERE answers_id = ${answer_id_local} AND idServer IS NOT NULL
    ''');

  problemsPorActualizar ??= [];
  for(int i = 0;i<problemsPorActualizar.length;i++){
    await db.query("DELETE FROM points WHERE problemsId = ${problemsPorActualizar[i]['id']}");
  }

  await db.query('''DELETE FROM problems
      WHERE answers_id = ${answer_id_local} AND idServer IS NOT NULL
    ''');

//  return;


//  var problemsServer = await getDatos(opt: "problems/?consultation=${widget.datos['id']}&owner=$userId",imprime: false);
  Map<String,dynamic> datos = Map();
  datos['answer'] = Map();
  datos['answer']['name'] = 'answer';
  datos['answer']['type'] = 'String';
  datos['answer']['value'] = '${answers_id}';

  var problemsServer = await postDatos(metodo: 'get',opt: "surveys/spatial-inputs/?answer=${answers_id}",datos: datos,imprime: false,verif: true);
//  print(problemsServer);


  for(int i = 0;i<problemsServer.length;i++){
    Map<String,dynamic> prbDB= Map();
    Map problem = problemsServer[i];
//      print(problem);

    Map tipos = {'LineString':'Polyline','Polygon':'Polygon','Point':'Marker'};

    prbDB['idServer'] = problem['id'];
    prbDB['type'] = tipos[problem['geometry']['type']];
    prbDB['input'] = problem['description'];
    prbDB['name'] = problem['name'];
    prbDB['catId'] = problem['category']['id'];
    prbDB['answers_id'] = answer_id_local;
    String photo = null;
    if(problem['photo'] != null){
      photo = problem['photo'].split('/').last;
      await _downloadFile(url:problem['photo'], filename: photo, subdir: 'fotos',chProgress: false,printAvance: false);
    }
    prbDB['photo'] = photo;
    var insR = await db.insert('problems', prbDB,false);

    List puntos = [];
    switch(problem['geometry']['type']){
      case 'Point':
        List coordenadas = problem['geometry']['coordinates'];
//        print(coordenadas);
        puntos.add(convierte(c:coordenadas,pId: insR));
        break;
      case 'Polygon':
        List coordenadas = problem['geometry']['coordinates'][0];
        for(int i = 0; i<coordenadas.length - 1; i++){
          puntos.add(convierte(c:coordenadas[i],pId: insR));
        }
//          print('coordenadas Polygon: $coordenadas');
        break;
      case 'LineString':
        List coordenadas = problem['geometry']['coordinates'];
        for(int i = 0; i<coordenadas.length;i++){
          puntos.add(convierte(c:coordenadas[i],pId: insR));
        }
        break;
    }

    for(int i = 0;i<puntos.length;i++){
      await db.insert('points', puntos[i],false);
    }
  }
}

getSpatialData({int pregId, int vId}) async {
  DB db = DB.instance;
//  print('pregId: $pregId');
  var studyAreas = await db.query('SELECT * FROM StudyArea WHERE preguntasId = $pregId');
  studyAreas ??= [];

//  await db.query("DELETE FROM Problems");
//  await db.query("DELETE FROM points");
//  var pp = await db.query("SELECT * FROM points");
//  print('POINTS: $pp');
  var problemsDB = await db.query('''
    SELECT p.* FROM 
    Problems p
    LEFT JOIN RespuestasVisita rv ON rv.id = p.respuestasVisitaId
    WHERE rv.visitasId = $vId AND rv.preguntasId = $pregId 
  ''');

  List problems = [];
  if(problemsDB != null){
    for(int i = 0; i<problemsDB.length; i++){

      var problem = Map.from(problemsDB[i]);
      List pointsDB = await db.query("SELECT * FROM points WHERE problemsId = ${problem['id']}");
//      print('POINTSDB: $pointsDB');
      pointsDB ??= [];
      List puntos = [];
      for(int j = 0;j<pointsDB.length;j++){
        Map<String,dynamic> ptTmp = Map();
//          print('aaaaa ${problemPoints[i]['lat']},${problemPoints[i]['lng']}');

        ptTmp['latLng'] = LatLng(pointsDB[j]['lat'],pointsDB[j]['lng']);
        ptTmp['id'] = pointsDB[j]['id'];
        puntos.add(ptTmp);

      }
      problem['points'] = puntos;
      problems.add(problem);
//      print("PROBLEM: $problem");
    }
  }

//  print('PPPROBLEMS: $problems');

//  problemsDB ??= [];

  Map<String,dynamic> resp = Map();
  resp['studyareas'] = studyAreas;
  resp['problems'] = problems;

  return resp;


}

convierte({List c,int pId}){
  double lng;
  if(c[0] < 0 && c[0] < -180){
    lng = 360+c[0];
  }else{
    lng = c[0];
  }

  return {'problemsId':pId,'lat':c[1],'lng':lng};
}

Future _downloadFile({
  String url,
  String filename,
  String subdir = null,
  bool chProgress = true,
  bool printAvance = false,
}) async {

  Dio dio = Dio();
  String dir = (await getApplicationDocumentsDirectory()).path;

  if(subdir != null){
    dir = '$dir/$subdir';

    var existeDir = await Directory(dir).exists();
    if(!existeDir){
      await Directory(dir).create(recursive: true)
          .then((Directory directory){
//            print(directory.path);
      });
    }
  }

  try{
    print(url);
    await dio.download(url, '$dir/$filename', onReceiveProgress: (rec,total){
//        print('rec: $rec, total: $total');
      var porcentaje = ((rec/total)*100).toStringAsFixed(0);
      var totStr = (total/1024/1024).toStringAsFixed(1);
      var recStr = (rec/1024/1024).toStringAsFixed(1);
      if(printAvance){
        print('$recStr MB / $totStr MB : $porcentaje %');
      }
    });
  }catch(e){
    print(e);
  }

}

Future<void> emergente({BuildContext context,Widget content,List<Widget> actions}) async {

  if(actions.length == 0){
    actions = [
      FlatButton(
        child: Text(Translations.of(context).text('ok')),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ];
  }
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
//          title: Text('Point alert'),
        content: SingleChildScrollView(
          child: Center(
            child: content,
          ),
        ),
        actions: actions,
      );
    },
  );
}

checaTamano({String serverPath}) async {
  Dio dio = Dio();
//  print('SERVER: $SERVER');
//  print('${serverPath[0]}');
  if(serverPath[0] == '/'){
    serverPath = serverPath.substring(1);
  }
  String url = '${SERVER}$serverPath';
//  print('URL: $url');
  var tamano;

  CancelToken token = new CancelToken();
  try{
    await dio.request(url,cancelToken: token,onReceiveProgress: (parcial,total){
//        print('TOTAL: $total');
      if(total>=0){
        tamano = (total/1024/1024).toStringAsFixed(1);;
        token.cancel('$total');
      }
    });
  } on DioError catch(e,x){
  }

//  print('TAMAÑO $tamano');
  return tamano;
//    print('tamaño: $tamano MB');

}



