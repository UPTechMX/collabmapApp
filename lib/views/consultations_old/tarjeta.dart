import 'package:flutter/material.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/models/conexiones/api.dart';
import 'package:siap/views/maps/consultation.dart';
import 'package:latlong/latlong.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:siap/models/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

class Tarjeta extends StatefulWidget {
  Map datos;
  bool prbEnv = false;

  Tarjeta({
    this.datos
  });
  @override
  TarjetaState createState() => TarjetaState();
}

class TarjetaState extends State<Tarjeta> {

  bool descargando = false;
  bool descargado = false;
  var progreso = "0";
  var avance = "";
  int dlTotal;
  bool sending = false;

  var subscription = Connectivity();
  @override
  initState() {
    super.initState();
    subscription.onConnectivityChanged.listen((ConnectivityResult result){
      envioAut(estatus: result,quien: 'subscripción');
    });
  }

// Be sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();
  }

  getConnectivity() async {

    var connectivityResult = await (Connectivity().checkConnectivity());
    envioAut(estatus: connectivityResult,quien: 'getConnectivity');

//    if (connectivityResult == ConnectivityResult.mobile) {
//      print("Connected to Mobile Network");
//    } else if (connectivityResult == ConnectivityResult.wifi) {
//      print("Connected to WiFi");
//    } else {
//      print("Unable to connect. Please Check Internet Connection");
//    }
  }



  checaTamano({Map datos, BuildContext context}) async {
    Dio dio = Dio();
    String url = '${SERVER}/media/mbtiles/${datos['code']}.mbtiles';
    var tamano;

    CancelToken token = new CancelToken();
    try{
      await dio.request(url,cancelToken: token,onReceiveProgress: (parcial,total){
//        print(total);
        if(total>=0){
          tamano = (total/1024/1024).toStringAsFixed(1);;
          token.cancel('$total');
        }
      });
    } on DioError catch(e,x){
    }

    downloadInfo(context: context,tamano: tamano);
//    print('tamaño: $tamano MB');

  }

  getOffline(datos) async {
    DB db = DB.instance;

    setState(() => descargando = true);

    await getCats();

//    String url = 'http://notland.mx/proyectos/collabmap/${datos['code']}.mbtiles';
    String url = '${SERVER}/media/mbtiles/${datos['code']}.mbtiles';
    await _downloadFile(url:url, filename: '${datos['id']}.mbtiles',printAvance: false);

//    print('dlTotal = $dlTotal');
    if(dlTotal == -1){
      setState(() => descargando = false);
      widget.datos['descargado'] = false;
      setState(() => descargado = false);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File dwFile = File('$dir/${datos['id']}.mbtiles');
      dwFile.delete(recursive: true);

    }else{
      setState(() => descargando = false);
      widget.datos['descargado'] = true;
      setState(() => descargado = true);
    }

  }

  getCats() async {
    DB db = DB.instance;

    var datos = widget.datos;
    var cats = await getDatos(opt:'categories/',varNom: 'categories',imprime: false);
    var catsCons = await getDatos(opt:'categories-consultation/?&consultation=${datos['id']}',varNom:'categories-consultation',imprime: false);
    var groups = await getDatos(opt:'groups/', varNom: 'groups', imprime: false);

    for(var i = 0;i<cats.length;i++){
      db.replace('categories', cats[i]);
    }
    for(var i = 0;i<catsCons.length;i++){
      db.replace('categoriesConsultation', catsCons[i]);
    }
    for(var i = 0;i<groups.length;i++){
      db.replace('groups', groups[i]);
    }

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
        if(chProgress){
          setState(() {
            if(total == -1){
              progreso = '-- MB / -- MB : -- %';
            }else{
              progreso = '$recStr MB / $totStr MB : $porcentaje %';
            }
            dlTotal = total;
          });
        }
        if(printAvance){
          print('$recStr MB / $totStr MB : $porcentaje %');
        }
      });
    }catch(e){
      print(e);
    }

  }

  goConsultation(datos) async {
    DB db = DB.instance;

    String dir = (await getApplicationDocumentsDirectory()).path;
    File file =  await File('$dir/${datos['id']}.mbtiles');
//    print('$dir/${datos['id']}.mbtiles');
//    print(await file.exists());

    List problemsDB = await db.query('''SELECT * 
      FROM problems 
      WHERE consultationsId = ${datos['id']}
      AND (del != 1 OR del IS NULL)
    ''');
    List problems = [];
    if(problemsDB != null){
      for(int i = 0; i<problemsDB.length; i++){
        Map<String, dynamic> problem = Map<String, dynamic>.from(problemsDB[i]);

        List problemPoints = await db.query("SELECT * FROM points WHERE problemsId = ${problemsDB[i]['id']}");
        List puntos = [];
        if(problemPoints!=null){
          for(int i = 0;i<problemPoints.length;i++){
            Map<String,dynamic> ptTmp = Map();
            ptTmp['latLng'] = LatLng(problemPoints[i]['lat'],problemPoints[i]['lng']);
            ptTmp['id'] = problemPoints[i]['id'];
            puntos.add(ptTmp);
          }
        }
        problem['points'] = puntos;
        problems.add(problem);
      }
    }else{
      problemsDB = [];
    }

//    print('PROBLEMS: $problems');

    Navigator.push(context,
        new MaterialPageRoute(builder: (context)=>Consultation(
          datos:datos,
//          tiles:file,
          problems:problems
        )));

  }

  sendProblems({int id,bool unico = true,bool all = false}) async {

    setState(() {
      progreso = progreso = Translations.of(context).text('sending_data');
    });
    DB db = DB.instance;

    List problemsDB;
    if(all){
      problemsDB = await db.query('''
      SELECT * FROM problems 
      WHERE consultationsId = $id AND (idServer IS NULL OR edit = 1 OR del = 1)
      ''');
    }else{
      problemsDB = await db.query('''
      SELECT * FROM problems 
      WHERE consultationsId = $id AND (idServer IS NULL OR edit = 1 OR del = 1)
      AND (draft IS NULL OR draft = 0)
      ''');
    }


    problemsDB ??= [];
    List problems = [];
    for(int i = 0; i<problemsDB.length;i++){
      var problem = await problemDBtoAPI(problemDB: problemsDB[i]);
      problems.add(problem);
    }

    print('======= ACA 02 =======');
    await sendDatos(problems: problems);
    await getCats();



    widget.prbEnv = true;

    if(unico){
      setState(() {
        sending = false;
      });
    }


  }

  Future<void> downloadInfo({BuildContext context, String tamano}) async {

    String texto;
//    print('tamano: $tamano');
//    print(tamano == '0.0');
    if(tamano == null || tamano == '0.0'){
      texto = Translations.of(context).text('no_file');
    }else{
      texto = '${Translations.of(context).text('download_file')} $tamano MB';
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translations.of(context).text('download_title')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(texto),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: tamano != null ? Text(Translations.of(context).text('cancel')):Text(Translations.of(context).text('ok')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            tamano != null?FlatButton(
              child: Text('Download'),
              onPressed: () {
                Navigator.of(context).pop();
                getOffline(widget.datos);
              },
            ):
            Container(width: 0,height: 0,),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

//    print('finish_date ${widget.datos['finish_date']}');
    Widget btnDwd = RaisedButton(
      onPressed: (){
//        goConsultation(widget.datos);
//        getOffline(widget.datos);
//        print('aaa');
        checaTamano(datos: widget.datos, context: context);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: Colors.blue,
      child: Container(
        width: double.infinity,
        child: Text(Translations.of(context).text('download_offline_map')),
      ),
    );

    Widget btnSend = RaisedButton(
      onPressed: () async {
        setState(() {
          sending = true;
        });
        await sendProblems(id: widget.datos['id'],unico: false);
        await getProblems();
        setState(() {
          sending = false;
        });

      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: Colors.blue,
      child: Container(
        width: double.infinity,
        child: Text(Translations.of(context).text('sync_data')),
      ),
    );

    final conectando = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: <Widget>[
          Center(
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 20,),
          Text('$progreso'),
        ],
      ),
    );

    var btnGoToConsultation = RaisedButton(
      onPressed: (){
        goConsultation(widget.datos);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: Colors.blue,
      child: Container(
        width: double.infinity,
        child: Text(Translations.of(context).text('go_to_consultation')),
      ),
    );


    Widget btn;
    if(descargando){
      btn = conectando;
      btnSend = Container();
    }else if(widget.datos['descargado']){
      btn = sending?Container():btnGoToConsultation;
      setState( () => descargado = true);
    }else{
      btn = btnDwd;
      btnSend = Container();
    }

    getConnectivity();
    return Container(
      width: double.infinity,
      child: Card(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[350]),
              padding: EdgeInsets.all(15),
              child: Text(
                this.widget.datos['code'],
                style:TextStyle(),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(15),
              child: Text(
                this.widget.datos['name'],
                style:TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 40,right: 40),
              child: Column(
                children: <Widget>[
                  btn
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 40,right: 40),
              child: Column(
                children: <Widget>[
                  sending?conectando:btnSend,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  envioAut({var estatus,String quien}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String conf = sp.getString('sendProblems');

    print('Quien $quien');
    if(!sending && !widget.prbEnv){
      var cType = estatus.toString().split('.')[1];

      switch(cType){
        case 'mobile':
          if(conf == 'always'){
            setState(() {
              sending = true;
            });
            sendProblems(id: widget.datos['id'],unico: true);
          }
          break;
        case 'wifi':
//          print('ESTOOOOO');
          if(conf == 'wifi' || conf == 'always'){
            setState(() {
              sending = true;
            });
            sendProblems(id:widget.datos['id'],unico: true);
          }
          break;
        default:
          break;

      }
//      print('estatus: $estatus, conf: $conf, quien: $quien');
    }
  }

  getProblems({var answer_id}) async {
    DB db = DB.instance;

    setState(() {
      progreso = Translations.of(context).text('receiving_data');
    });

    SharedPreferences sp = await SharedPreferences.getInstance();
    int userId = sp.getInt('userId');

    List problemsPorActualizar = await db.query('''SELECT * FROM problems
      WHERE answers_id = ${answer_id} AND idServer IS NOT NULL
    ''');

    problemsPorActualizar ??= [];
    for(int i = 0;i<problemsPorActualizar.length;i++){
      await db.query("DELETE FROM points WHERE problemsId = ${problemsPorActualizar[i]['id']}");
    }

    await db.query('''DELETE FROM problems
      WHERE answers_id = ${answer_id} AND idServer IS NOT NULL
    ''');

    var problemsServer = await getDatos(opt: "surveys/spatial-inputs",imprime: false,);
  
    for(int i = 0;i<problemsServer.length;i++){
      Map<String,dynamic> prbDB= Map();
      Map problem = problemsServer[i];
//      print(problem);

      Map tipos = {'LineString':'Polyline','Polygon':'Polygon','Point':'Marker'};

      prbDB['idServer'] = problem['id'];
      prbDB['type'] = tipos[problem['geometry']['type']];
      prbDB['input'] = problem['description'];
      prbDB['catId'] = problem['category'];
      prbDB['consultationsId'] = problem['consultation'];
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
          print(coordenadas);
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


}

