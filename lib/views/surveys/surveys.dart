import 'package:flutter/material.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/models/translations.dart';
import 'package:siap/models/componentes/boton.dart';
import 'survey.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:siap/views/consultations/downloadMaps.dart';

class Surveys extends StatefulWidget {
  var consultationId;
  String consultationName;
  Surveys({this.consultationId,this.consultationName});

  @override
  SurveysState createState() => SurveysState();
}

class SurveysState extends State<Surveys> {


  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getData(),
      builder: (context,snapshot){
        List<Widget> rows = [];
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text(Translations.of(context).text('waiting'));
          case ConnectionState.done:
            if (snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }
            List elementos = snapshot.data;
            if(elementos.length == 0){
              return Container(
                height: 100,
                child: Center(
                  child: Text(''),
                ),
              );
            }
            rows.add(DownloadMap(consultationId: widget.consultationId,));
            for(int i = 0; i < elementos.length; i++){
//              print(elementos[i]);
              rows.add(elemento(datos: elementos[i],));
            }
            return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: rows,
              ),
            );
          default:
            return Column();
        }

      },
    );
  }

  Future<List> getData() async {
    DB db = DB.instance;


    List datos = await db.query("SELECT * FROM surveys WHERE consultation_id = ${widget.consultationId}");
    datos ??= [];

//    print('DATOS: $datos');

    List datosExt = [];
    for(int i = 0;i<datos.length;i++){
//      print('I: $i');


      var dato = Map.from(datos[i]);
      dato['questions'] = await db.query('''
        SELECT q.*, qs.survey_id 
        FROM questions q
        LEFT JOIN questionsSurvey qs ON q.id = qs.question_id  
        WHERE qs.survey_id = ${dato['id']} ORDER BY `order`
      ''');

//      print( 'QUESTIONS: ${dato['questions']}');

      if(dato['questions'] == null || dato['questions'].length == 0){
        continue;
      }

//      print('Dato: ${dato['name']} : ${dato['questions']}');

      var lastQ = await db.query('''
        SELECT q.id, a.value, qs.`order` 
        FROM questions q
        LEFT JOIN questionsSurvey qs ON qs.question_id = q.id
        LEFT JOIN answers a ON a.question_id = q.id AND a.survey_id = qs.survey_id
        WHERE qs.survey_id = ${dato['id']} AND a.value IS NULL 
        ORDER BY qs.`order`
      ''');

      lastQ ??= await db.query('''
        SELECT q.id, a.value, qs.`order` 
        FROM questions q
        LEFT JOIN questionsSurvey qs ON qs.question_id = q.id
        LEFT JOIN answers a ON a.question_id = q.id AND a.survey_id = qs.survey_id
        WHERE qs.survey_id = ${dato['id']} 
        ORDER BY qs.`order`
      ''');

      lastQ ??= [];



//      var pregs = await db.query('SELECT `order` FROM questions');
//      print('PREGS: $pregs');
//      print('SQL: $sql');

//      var aaa = await db.query("SELECT * FROM questionsSurvey");
//      print('questionsSurvey: $aaa');
//      print('DATO["questions"]: ${dato['questions']}');

//      print('lastQ: ${lastQ}');


      if(lastQ != null && lastQ.length > 0){
        dato['lastQ'] = lastQ[0]['id'];
        dato['lastA'] = lastQ[0]['value'];
      }else{
        dato['lastQ'] = 0;
        dato['lastA'] = 0;
      }

      dato['questions'] ??= [];
      var numQuest = dato['questions'].length;

      if(numQuest == 0){
        dato['avance'] = '- -';
        dato['avanceDouble'] = 0;
      }else{
        var numAnsDB = await db.query("SELECT COUNT(*) as cuenta FROM answers WHERE survey_id = ${dato['id']}");
        var numAns = numAnsDB != null ? numAnsDB[0]['cuenta']:0;
        double avance = numAns/numQuest*100;
        dato['avance'] = '${avance.toStringAsFixed(0)}';
        dato['avanceDouble'] = avance;
      }
      datosExt.add(dato);
//      print(dato['questions']);


    }



    return datosExt;
  }

  elemento({var datos}){
//    print('Datos: $datos');
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]
          ),
          top: BorderSide(
            color: Colors.grey[300]
          ),
        )
      ),
      child: Boton(
        texto: datos['name'],
        onClick: (){
          if(datos['avanceDouble'] >= 100){
            //ToDo: Descomentar el return;
//            return;
          }
          Navigator.push(context,
              new MaterialPageRoute(builder: (context)=>
                  Survey(
                    id: datos['id'],
                    datos:datos,
                  )
              )
          );
        },
        icono: Icon(Icons.add,color: Colors.white,),
        color: Colors.white,
        widget: true,
        elemento: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      datos['name'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${datos['avance']} %',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 0,bottom: 10),
              width: double.infinity,
              child: LinearPercentIndicator(
//             width: 500,
                lineHeight: 7,
                percent: datos['avanceDouble']/100,
                backgroundColor: Colors.grey[300],
                progressColor: Colors.blue,
              ),
            )
          ],
        ),
      ),
    );
  }

}

