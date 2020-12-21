import 'package:flutter/material.dart';
import 'package:siap_monitoring/views/barra.dart';
import 'questions.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'tipeaValor.dart';
import 'package:siap_monitoring/views/maps/map.dart';

class Survey extends StatefulWidget {
  var id;
  Map datos;

  Survey({this.id,this.datos});

  @override
  SurveyState createState() => SurveyState(numPregs: datos['questions'].length, datos: datos);
}

class SurveyState extends State<Survey> {

  double avance = 0;
  int qIndex = 0;
  int numPregs;
  Map datos;
  var value;



  SurveyState({this.numPregs,this.datos}){

    for(int i = 0; i<numPregs;i++){
      if(datos['lastQ'] == datos['questions'][i]['id']){
        qIndex = i;
        var valor = tipeaValor(datos['questions'][i]['type'], datos['lastA']);
        value = valor;

        break;
      }
    }
    var index2 = qIndex+1;

    avance = numPregs != 0 ? qIndex/numPregs : 0;
  }

  @override
  Widget build(BuildContext context) {
//    print('qIndex: $qIndex');
//    print(widget.datos['questions'][qIndex]);
//    print("SURVEY");


    return Scaffold(
      appBar: Barra(),
//      drawer: Opciones(_nivel,_accion),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE9E9E9),
                  Color(0xFFFBFBFB),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset('images/fondo.png')
            ],
          ),
          Container(
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    left: 20,right: 20,top: 20
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(
                          '0%',
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '100%',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 20,right: 20,bottom: 20,top: 10
                  ),
                  child: Center(
                    child: LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 50,
                      animation: false,
                      lineHeight: 18.0,
                      animationDuration: 2500,
                      percent: avance,
                      center: Text("${(avance*100).toStringAsFixed(0)}%"),
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      progressColor: Color(0xFF2568D8),
                      backgroundColor: Color(0xFFdbdbdb),
                    ),
                  ),
                ),
                Question(
                  question: widget.datos['questions'][qIndex],
                  setQIndex: setQIndex,
                  numPregs: numPregs,
                  qIndex: qIndex,
                  questions: widget.datos['questions'],
                  value: value,
                )
              ],
            ),
          )
        ],
      )
    );
  }

  void setAvance({double av}){
    setState(() {
      avance = av;
    });
  }

  void setQIndex({int q}){
//    print(q);
    var numPreg = widget.datos['questions'].length;
    avance = numPreg != 0 ? (q)/numPreg : 0;
    setState(() {
      qIndex = q;
    });

  }

}
