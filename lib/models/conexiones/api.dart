import 'dart:io';

import 'package:http/http.dart' as http;
//import 'package:http/http.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/views/login/conexion.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:siap/models/translations.dart';

String SERVER = 'http://192.168.1.104/~juanma/collabmap/api/public/v1/';

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

      print("MANDA DATOS ESPACIALES");
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

Future<List> getDatos2({String opt,String varNom = null, bool imprime}) async {
  var respuesta;
  SharedPreferences userData = await SharedPreferences.getInstance();
  String body;

  String username = userData.getString('username');
  String password= userData.getString('password');
  Post getToken = await loginPost(username, password);
  String token = getToken.token;

  try{
    String url = '${SERVER}$opt';

    Map<String, String> headersMap = {
      'Authorization' : 'Bearer ' + token,
    };

    var uri = Uri.parse(url);
    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headersMap);
    var response = await request.send();


    if(response.statusCode == 201){
      if(imprime){
        print('RESPUESTA DEL SERVER: ${await response.stream.bytesToString()}');
      }
      respuesta = jsonDecode(await response.stream.bytesToString());
      if(varNom != null){
        userData.setString(varNom, body);
      }

    }else{
      print('EMPIEZA');
      print('RESPUESTA DEL SERVER: ${await response.stream.bytesToString()}');
      print('TERMINA');
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

  List answers = await db.query('''
    SELECT a.*, q.type, q.content as pregunta
    FROM answers a
    LEFT JOIN questions q ON q.id = a.question_id
    WHERE edit = 1 OR new = 1 OR (q.type = 'cm' OR q.type = 'spatial')
  ''');


  answers ??= [];

  Map<List,dynamic> responses = Map();

//    print('ANSWERS $answers');
  SharedPreferences userData = await SharedPreferences.getInstance();
  String username = userData.getString('username');
  String password = userData.getString('password');
  Post getToken = await loginPost(username, password);
  String token = getToken.token;

  for(int i = 0; i<answers.length;i++){
      Map answer = answers[i];

//      print('ANSWER: $answer');

      List response = [answer['survey_id'],answer['question_id']];

      SharedPreferences userData = await SharedPreferences.getInstance();
      int userId = userData.getInt('userId');
//      print('Response: $response');


      if(responses[response] == null){
//        print('No tenemos response local');
        var getResponse = await getDatos(
          opt: 'surveys/responses/?survey=${answer['survey_id']}&owner=$userId',
          cache: false,
          imprime: false,
          varNom: 'survey_${answer['survey_id']}',
        );
//        print('getResponse:  $getResponse ');
//        print('OPTIONS:  surveys/responses/?survey=${answer['survey_id']}&owner=$userId ');


        if(getResponse.length != 0){
//          print('Existe response en el server');
          responses[response] = getResponse[0];
        }else{
//          print('NO Existe response en el server');
          var postResponse = await postDatos(
            opt: 'surveys/responses/',
            verif: true,
            token: token,
            datos: {'survey':{'type':'String','name':'survey','value':answer['survey_id']}},
            metodo: 'post',
            imprime: true,
          );
//          print('ENVIA ${{'survey':{'type':'String','name':'survey','value':answer['survey_id']}}}');
//          print('RESPONSE RESP: $postResponse');

          responses[response] = postResponse;
        }
      }

//      print('Responses: $responses');
      var responseId = responses[response]['id'];

      Map<String,dynamic> datosAns = Map();
      datosAns['question'] = Map();
      datosAns['question']['name'] = 'question';
      datosAns['question']['type'] = 'String';
      datosAns['question']['value'] = '${answer['question_id']}';

      datosAns['response'] = Map();
      datosAns['response']['name'] = 'response';
      datosAns['response']['type'] = 'String';
      datosAns['response']['value'] = '${responseId}';

      datosAns['content'] = Map();
      datosAns['content']['name'] = 'content';
      datosAns['content']['type'] = 'String';
      switch(answer['type']){
        case 'spatial':
          List problems = await db.query("SELECT * FROM problems WHERE answers_id = ${answer['id']}");
//          print('PROBLEMS: $problems');
          if(problems != null){
            Map problemToAPI = await problemDBtoAPI(problemDB: problems[0]);
            String geometry = jsonEncode(problemToAPI['geometry']);
//            print('typeOf: ${geometry.runtimeType}');
//            print('Geometry: $geometry');
            datosAns['content']['value'] = '{"value":${geometry}}';

//            datosAns['content']['value'] = geometry;
          }else{
            datosAns['content']['value'] = '{"value":${answer['value']}}';
          }
          break;
        case 'bool':
          var value;
          switch(answer['value']){
            case '1':
            case 'true':
              value = true;
              break;
            case '0':
            case 'false':
              value = false;
              break;
            default:
              value = false;
              break;
          }
          datosAns['content']['value'] = '{"value":"${value}"}';
          break;
        default:
          datosAns['content']['value'] = '{"value":"${answer['value']}"}';
          break;
      }
//      print('Pregunta: ${answer['pregunta']} datosAns: $datosAns');

    var aIdServer = null;
      for(int a = 0; a<responses[response]['answers'].length;a++){
        Map answerResp = responses[response]['answers'][a];
//        print('Answer: $answerResp');

//        print('ans[question][id]: ${answerResp['question']['id']}, answer[question_id]: ${answer['question_id']} ');
        if(answerResp['question']['id'] == answer['question_id']){
//          print('encontrado');
          aIdServer = answerResp['id'];
        }
      }

      var resp;
      if(aIdServer == null){
        print('Post a server (nueva entrada)');
//        print('datosAns: $datosAns');
//        print('valueContent = ${datosAns['content']['value']}');
        resp = await postDatos(
          opt: 'surveys/answers/',
          verif: true,
          datos: datosAns,
          metodo: 'post',
          token: token,
          imprime: false,
        );
//        print('Resp: $resp');
      }else{
//        print('Put a server (edita)');

        resp = await postDatos(
          opt: 'surveys/answers/${aIdServer}/',
          verif: true,
          datos: datosAns,
          metodo: 'put',
          token: token,
          imprime: false,
        );
      }
      aIdServer = resp['id'];
//      print('aIdServer: $aIdServer');
//      print('type: ${answer['type']}');
      if(answer['type'] == 'cm'){
//        print('Pregunta tipo CM');

        String sql = '''SELECT * 
          FROM problems
          WHERE answers_id = ${answer['id']}
        ''';
//        print('SQL: $sql');

        List problemsDB = await db.query(sql);

//        print('ProblemsDB = $problemsDB');


        List problems = [];
        problemsDB ??= [];
        for(int p = 0;p<problemsDB.length;p++){

//          print('problemDB: ${problemsDB[p]}');

          Map problemToAPI = await problemDBtoAPI(problemDB: problemsDB[p]);
          problemToAPI['answer'] = aIdServer;

          problems.add(problemToAPI);
//          print('problemDB: ${problems[p]}');
//          print('problemToAPI: $problemToAPI');

        }
        print('PROBLEMS: $problems');
        print('====== ACA 01======');
        sendDatos(problems: problems,token: token,imprime: true);
      }
    }


  /////// POLLS

  List pollsDB = await db.query("SELECT * FROM pollsAnswers");
  pollsDB ??= [];
//  print('PollsDB: $pollsDB');

  for(int i = 0;i<pollsDB.length;i++){

    var poll = pollsDB[i];
    var pollResponse = await postDatos(
      opt: 'polls/responses/',
      verif: true,
      token: token,
      datos: {'poll':{'type':'String','name':'poll','value':poll['poll_id']}},
      metodo: 'post',
      imprime: false,
    );
    print('PollResponse: $pollResponse');

    Map<String,dynamic> datosAns = Map();

    datosAns['question'] = Map();
    datosAns['question']['name'] = 'question';
    datosAns['question']['type'] = 'String';
    datosAns['question']['value'] = '${poll['question_id']}';

    datosAns['response'] = Map();
    datosAns['response']['name'] = 'response';
    datosAns['response']['type'] = 'String';
    datosAns['response']['value'] = '${pollResponse['id']}';

    datosAns['content'] = Map();
    datosAns['content']['name'] = 'content';
    datosAns['content']['type'] = 'String';
    datosAns['content']['value'] = '${poll['value']}';


    print('datosAns: $datosAns');
    var pollAnsPost = await postDatos(
      opt: 'polls/answers/',
      verif: true,
      token: token,
      datos: datosAns,
      metodo: 'post',
      imprime: false,
    );

    print('=== POLLANS : ${pollAnsPost}');

    await db.query('DELETE FROM pollsAnswers');

//    print('pollAnsPost: $pollAnsPost');

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

  // get Proyectos
  var projects = await getDatos(opt: 'projects/projects/',varNom: 'projects',imprime: false);

  if(projects != null){
    List datosADB = [];
    List campos = ['id', 'name','description','content','content2','image'];
    for(int i = 0; i<projects.length;i++){

      List imgUrlL =  projects[i]['image'].split('/');
      String imgName = imgUrlL[imgUrlL.length - 1];

//      print('image: ${imgName} - ${projects[i]['image']}');
      await downloadFile(
        filename: imgName,
        url: projects[i]['image'],
        printAvance: false,
        subdir: 'projects/'
      );
      projects[i]['image'] = imgName;
//      print(projects[i]['content1']);
      Map tmp = Map<String,dynamic>();
      for(int j = 0;j<campos.length;j++){
        tmp[campos[j]] = projects[i][campos[j]];
      }
      datosADB.add(tmp);
    }
    await db.insertaLista('projects', datosADB, false, false);
  }

  // Phases

  var phases = await getDatos(opt: 'projects/phases/',varNom: 'projects',imprime: false);

  List datosADBC = [];
  if(phases != null){
    for(int i = 0;i<phases.length;i++){
      var dato = phases[i];
      dato.remove('created');
      var status = dato['status']['id'];
      dato.remove('status');
      dato['status'] = status;

      var consultations = dato['consultations'];
      if(consultations != null){
        for(int i = 0;i<consultations.length;i++){
          var datoC = consultations[i];
          datoC.remove('created');
          datoC['phase_id'] =dato['id'];
        }


        List campos = ['id','slug','name','order','description','icon','start_date','finish_date','phase_id'];
        for(int i = 0; i<consultations.length;i++){
//      print('CONSULTATION: ${consultations[i]}');
          Map tmp = Map<String,dynamic>();
          for(int j = 0;j<campos.length;j++){
            tmp[campos[j]] = consultations[i][campos[j]];
          }
//          print('======= tmp Consultation =======');
//          print(tmp);
          datosADBC.add(tmp);
        }


      }

      dato.remove('consultations');

    }

    List datosADB = [];
    List campos = ['id','slug','name','image','description','order','status','project'];
    for(int i = 0; i<phases.length;i++){
      Map tmp = Map<String,dynamic>();
      for(int j = 0;j<campos.length;j++){
        tmp[campos[j]] = phases[i][campos[j]];
      }
      datosADB.add(tmp);
    }

    await db.insertaLista('phases', datosADB, false, false);
  }

  await db.insertaLista('consultations', datosADBC, true, false);


  // surveys

  var surveys = await getDatos(opt: 'surveys/surveys/',varNom: 'surveys',imprime: false);

  // TODO: Borrar las siguientes dos lineas
//    db.query("DELETE FROM problems WHERE 1");
//    db.query('UPDATE questions SET type="cm" WHERE type="spatial" ');


  if(surveys != null){
    for(int i = 0;i<surveys.length;i++){
      var dato = surveys[i];

      var categoriesDB = await getDatos(opt: 'surveys/category-surveys/?category=&survey=${dato['id']}',varNom: 'categories',imprime: false);
      List categories = [];
      for(int c = 0;c<categoriesDB.length;c++){
        var cat = categoriesDB[c];
        categories.add(cat['category']);

        Map<String,dynamic> catSur = Map();
        catSur['survey_id'] = dato['id'];
        catSur['category_id'] = cat['category']['id'];
        catSur['id'] = cat['id'];

        await db.insert('categoriesSurvey', catSur, false);

      }
      await db.insertaLista('categories', categories, false, false);


      dato.remove('created');
      var consultation_id = dato['consultation']['id'];
      dato.remove('consultation');
      dato['consultation_id'] = consultation_id;
      List questions = dato['survey_questions'];
      dato.remove('survey_questions');

      List questionsAPI  = await getDatos(opt: 'surveys/questions',varNom: 'questions',imprime: false);

//        print('QUESTIONS: $questions');

      for(int j = 0; j<questions.length;j++){
        var question = questions[j];
//        print('QUESTION AAA: $question');
        switch(question['question']['type']){
          case 'bool':
          case 'text':
          case 'spatial':
          case 'numeric':
          case 'option':
          case 'cm':
            var q = question['question'];
            q['order'] = question['order'];
            var indicator = jsonEncode(q['indicator']);
            q.remove('indicator');
            q['indicator'] = indicator;
            var options = jsonEncode(q['options']);
            q.remove('options');
            q['options'] = options;

            var order = q['order'];
            q.remove('order');

//            print('INSERTA BBB: $q');
//            db.replace('questions', q);

            Map<String,dynamic> qs = Map();
            qs['survey_id'] = dato['id'];
            qs['question_id'] = q['id'];
            qs['order'] = order;

            db.replace('questionsSurvey', qs);

            break;
          default:
            break;
        }
      }

    }

    List datosADB = [];
    List campos = ['id','name','questions','consultation_id'];
    for(int i = 0; i<surveys.length;i++){
      Map tmp = Map<String,dynamic>();
      for(int j = 0;j<campos.length;j++){
        tmp[campos[j]] = surveys[i][campos[j]];
      }
      datosADB.add(tmp);
    }

    await db.insertaLista('surveys', datosADB, true, false);

  }

  // Questions

  List questionsAPI = await getDatos(opt: 'surveys/questions',varNom: 'questions',imprime: false);

//        print('QUESTIONS: $questions');

  questionsAPI ??= [];

  for(int j = 0; j<questionsAPI.length;j++){
    var question = questionsAPI[j];
//    print('QUESTION CCC: $question');

    var q = question;
    q['order'] = question['order'];
    var indicator = jsonEncode(q['indicator']);
    q.remove('indicator');
    q['indicator'] = indicator;
    var options = jsonEncode(q['options']);
    q.remove('options');
    q['options'] = options;

    var spatial_data = jsonEncode(q['spatial_data']);
    q.remove('spatial_data');
    q['spatial_data'] = spatial_data;

    var order = q['order'];
    q.remove('order');
    if(question['type'] == 'cm' || question['type'] == 'spatial'){
      List spatialQuestion = await getDatos(opt: 'surveys/spatial-questions/?question=${question['id']}',varNom: 'spatialQUestion${question['id']}',imprime: false);
      spatialQuestion ??= [];
      if(spatialQuestion.length > 0){
        Map mapaInfo = spatialQuestion[0]['map'];

        List urlL = mapaInfo['file'].split('/');
        String mapFile = urlL[urlL.length -1];

        q['mapName'] = mapaInfo['name'];
        q['mapFile'] = mapFile;
        q['mapUrl'] = mapaInfo['file'];
      }


    }

//        print('INSERTA DDD: $q');
    db.replace('questions', q);


  }

  // Respuestas

  SharedPreferences userData = await SharedPreferences.getInstance();
  int userId = userData.getInt('userId');

  var responses = await getDatos(
    opt: 'surveys/responses/?owner=$userId',
    cache: false,
    imprime: false,
    varNom: 'survey_respones',
  );

  for(int i = 0; i<responses.length;i++){
    Map response = responses[i];
    var survey_id = response['survey'];

    List answers = response['answers'];
    for(int j = 0; j<answers.length;j++){

      Map question = answers[j]['question'];

      Map<String,dynamic> answer = Map();
      answer['survey_id'] = survey_id;
      answer['question_id'] = question['id'];
      switch(question['type']){
        case 'numeric':
        case 'text':
        case 'option':
          answer['value'] = answers[j]['content']['value'];
          break;
        case 'bool':
//          print('BOOOOL: ${answers[j]['content']['value']} : ${answers[j]['content']['value'].runtimeType}');
          switch(answers[j]['content']['value']){
            case '0':
            case 'false':
//              print('booool false');
              answer['value'] = 0;
              break;
            case '1':
            case 'true':
//              print('booool true');
              answer['value'] = 1;
              break;
            default:
//              print('booool false default');
              answer['value'] = 0;
          }
          break;
        case 'spatial':
          answer['value'] = 'spatial';
          Map<String,dynamic> problem = Map();
          break;
        case 'cm':
          answer['value'] = 'cm';
          break;
        default:
          answer['value'] = answers[j]['content']['value'];
          break;
      }

      var ans = await db.query("SELECT * FROM answers WHERE survey_id = ${survey_id} AND question_id = ${question['id']}");
      if(ans != null){
        var probs = await db.query('SELECT * FROM problems WHERE answers_id = ${ans[0]['id']}');
        if(probs != null){
          await db.query('DELETE FROM points WHERE problemsId = ${probs[0]['id']}');
        }
        await db.query('DELETE FROM problems WHERE answers_id = ${ans[0]['id']}');
      }

      await db.replace('answers', answer);
      List ansDB = await db.query('SELECT * FROM answers WHERE survey_id = ${survey_id} AND question_id = ${question['id']} ');

      int answer_id = ansDB[0]['id'];

//      print('answer_id: ${answer_id}');

      // Pregunta Spatial Problems

      if(question['type'] == 'spatial'){
        Map<String,dynamic> problem = Map();

        problem['answers_id'] = answer_id;
        var problemAPI = answers[j]['content']['value'];
        switch(problemAPI['type']){
          case 'Point':
            problem['type'] = 'Marker';
            break;
          case 'LineString':
            problem['type'] = 'Polyline';
            break;
          case 'Polygon':
            problem['type'] = 'Polygon';
            break;
        }
//        print('problemAPI: $problemAPI');

        int problemId = await db.insert('problems', problem, true);

        List coordenadas;
        if(answers[j]['content']['value']['type'] == 'Point'){
          coordenadas = [[answers[j]['content']['value']['coordinates'][0],answers[j]['content']['value']['coordinates'][1]]];
        }else if(answers[j]['content']['value']['type'] == 'LineString'){
          coordenadas = answers[j]['content']['value']['coordinates'];
        }else{
          coordenadas = answers[j]['content']['value']['coordinates'][0];
        }
//        print('${answers[j]['content']['value']['type']} hhhhhhh: ${coordenadas}');


//        print('answer: ${answers[j]['content']['value']}');
//        print('Coordenadas: ${coordenadas.length}');
        for(int c = 0; c<coordenadas.length; c++){
          Map<String,dynamic> coord = Map();
          coord['problemsId'] = problemId;

//          print('tipo: ${answers[j]['content']['value']['type']}');
          var cm = acomodaCoordenadas(coords: coordenadas[c],donde: 'getAll', invierte: true);
//          print('coordenadasOrig: ${coordenadas[c]}, coordMod: $cm');
          if(cm.length != 0){
            coord['lat'] = cm[0];
            coord['lng'] = cm[1];
//            print('COOOOORD: $coord');
            await db.insert('points', coord,true);
          }
        }

      }

      // Problems

      if(question['type'] == 'cm'){

//        print('CM::::');
        await getProblems(answers_id: answers[j]['id'],answer_id_local: answer_id);

      }

    }
  }


  // POLLS

  List polls = await getDatos(opt: 'polls/polls/',varNom: 'polls',imprime: false);

  List pollsQuestions = [];
  if(polls != null){
    for(int i = 0;i<polls.length;i++){
      var dato = polls[i];

      List questions = dato['questions'];

      for(int  j = 0; j<questions.length;j++){
        Map question = questions[j];
        question['poll_id'] = question['poll'];
        question.remove('poll');
        pollsQuestions.add(question);
      }


      dato.remove('questions');

      dato['consultation_id'] = dato['consultation']['id'];

    }

    List datosADB = [];
    List campos = ['id','name','questions','consultation_id'];
    for(int i = 0; i<polls.length;i++){
      Map tmp = Map<String,dynamic>();
      for(int j = 0;j<campos.length;j++){
        tmp[campos[j]] = polls[i][campos[j]];
      }
      datosADB.add(tmp);
    }

    await db.insertaLista('polls', datosADB, false, false);
  }
  await db.insertaLista('pollsQuestions', pollsQuestions, true, false);


//  var points = await db.query("SELECT * FROM points");
//  points ??= [];
//  for(int i = 0; i<points.length;i++){
////    print('PUNTO ${points[i]}');
//  }

//  print('terminó');

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



