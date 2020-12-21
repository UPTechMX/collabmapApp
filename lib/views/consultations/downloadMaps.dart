import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'dart:io';
import 'package:siap_monitoring/models/conexiones/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/models/componentes/colorLoader.dart';
import 'package:dio/dio.dart';



class DownloadMap extends StatefulWidget {

  var consultationId;
  DownloadMap({this.consultationId});

  @override
  DownloadMapState createState() => DownloadMapState();
}

class DownloadMapState extends State<DownloadMap> {
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getDatos(),
      builder: (context,snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Container();
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.done:
            if (snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }
            List elementos = snapshot.data;

            if(snapshot.data.length == 0){
              return Container();
            }

            List<Widget> mapas = [];
            mapas.add(
              Text(
                Translations.of(context).text('download_title').toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
                ),
              )
            );

            mapas.add(SizedBox(height: 10,));

            double total = 0;
            for(int i = 0; i < elementos.length; i++){
              var m = elementos[i];
              var row = Row(

                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text('${i+1}'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                        '${m['mapName']}'.toUpperCase(),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                        '${m['tamano']} MB'.toUpperCase(),
                    ),
                  ),
                ],
              );

              total += double.parse(m['tamano']);

              mapas.add(row);

            }

            mapas.add(SizedBox(height: 10,));

            var row = Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${total} MB'.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),

                  ),
                ),
              ],
            );

            mapas.add(row);

            return Container(
              padding: EdgeInsets.all(15),
              child: RaisedButton(
                child: Text(Translations.of(context).text("mapsfordownload").toUpperCase()),
                onPressed: (){
                  emergente(
                    context: context,
                    actions: [
                      FlatButton(
                        child: Text(Translations.of(context).text('cancel')),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text(Translations.of(context).text('ok')),
                        onPressed: () {
                          Navigator.of(context).pop();
                          emergente(
                            content: Container(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: ColorLoader3(
                                      radius: 50,
                                      dotRadius: 15,
                                    ),
                                  ),
                                  Descargando(mapas: elementos,reset: reset,),
                                ],
                              ),
                            ),
                            actions: [
                              Container()
                            ],
                            context: context
                          );
                        },
                      )
                    ],
                    content: Container(
                      child: Column(
                        children: mapas,
                      ),
                    )
                  );
                },
              ),
            );
          default:
            return Column();
        }

      },
    );
  }

  getDatos() async {
    DB db  = DB.instance;
    
    var questions = await db.query('''
      SELECT q.id, q.mapFile, q.mapUrl, q.mapName, q.content as question, s.name as survey  
      FROM surveys s
      LEFT JOIN questionsSurvey qs ON qs.survey_id = s.id
      LEFT JOIN questions q ON q.id = qs.question_id
      WHERE consultation_id = ${widget.consultationId} AND (q.type == 'cm' OR q.type == 'spatial')
      GROUP BY q.mapFile
    ''');
//    print(questions);

    String dir = (await getApplicationDocumentsDirectory()).path;

    Directory mapsDir = await Directory('${dir}/maps');
    if(!(await mapsDir.exists())){
      mapsDir.create(recursive: true);
    }

    String path = '${dir}/maps';


    List mapas = [];
    questions ??= [];
//    print('QuestionsL : ${questions.length}');
    for(int i = 0;i<questions.length;i++){
//      print('Questions $i : $questions');

      Map q = questions[i];

      if(q['mapFile'] == null){
        continue;
      }
//      print('Mapa: ${path}/${q['mapFile']} ');
      File mapa = await File('${path}/${q['mapFile']}');



      if( !(await mapa.exists()) ){
        Map tmp = Map();
        tmp['mapFile'] = q['mapFile'];
        tmp['mapUrl'] = q['mapUrl'];
        tmp['mapName'] = q['mapName'];

        var tamano = await checaTamano(
          serverPath: tmp['mapUrl']
        );
        tmp['tamano'] = tamano;
        mapas.add(tmp);

      }

    }
//    print('mapas: $mapas');

    return mapas;
  }

  reset(){
    setState(() {});
  }

}

class Descargando extends StatefulWidget {

  List mapas;
  var reset;

  Descargando({this.mapas,this.reset});

  @override
  DescargandoState createState() => DescargandoState();
}

class DescargandoState extends State<Descargando> {

  var progreso = '';
  var fileName = '';
  bool finalizado = false;

  @override
  initState(){
    super.initState();
    descargaAll();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Column(
        children: <Widget>[
          Text(
            'file: $fileName'.toUpperCase(),
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            '$progreso',
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold
            ),

          ),
          SizedBox(height: 10,),
          finalizado?RaisedButton(
            child: Text(Translations.of(context).text('close')),
            onPressed: (){
              widget.reset();
              Navigator.of(context).pop();
            },
          ):Container(),
        ],
      ),
    );
  }

  descargaAll() async {
    for(int i = 0; i<widget.mapas.length;i++){
      var mapa = widget.mapas[i];

      setState(() {
        progreso = '';
        fileName = mapa['mapName'];
      });

      var url = mapa['mapUrl'][0] == '/'? mapa['mapUrl'].substring(1):mapa['mapUrl'];
      url = '${SERVER}/$url';

       await download(
        printAvance: false,
        url: url,
        chProgress: true,
        filename: mapa['mapFile'],
        subdir: 'maps'
      );

    }

    setState(() {
      finalizado = true;
    });
  }

  Future download({
    String url,
    String filename,
    String subdir = null,
    bool chProgress = true,
    bool printAvance = false,
  }) async {

    Dio dio = Dio();
    String dir = (await getApplicationDocumentsDirectory()).path;
//    print('aaaa');

    if(subdir != null){
      dir = '$dir/$subdir';
      print('DIR: $dir');

      var existeDir = await Directory(dir).exists();
      if(!existeDir){
        print('No EXISTE');
        await Directory(dir).create(recursive: true)
            .then((Directory directory){
//            print(directory.path);
        });
      }
    }


    try{
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
//          dlTotal = total;
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


}
