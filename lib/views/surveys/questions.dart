import 'package:flutter/material.dart';
import 'respuestas.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'tipeaValor.dart';
import 'package:siap/models/translations.dart';
import 'package:siap/models/conexiones/api.dart';
import 'package:siap/models/componentes/iconos.dart';


class Question extends StatefulWidget {

  Map question;
  var setQIndex;
  int numPregs;
  int qIndex;
  List questions;
  var value;


  Question({
    this.question,
    this.setQIndex,
    this.numPregs,
    this.qIndex,
    this.questions,
    this.value,
  });

  @override
  QuestionState createState() => QuestionState(
    qIndex: qIndex,
    numPregs: numPregs,
    question: question,
    setQIndex: setQIndex,
    value: value,
  );
}

class QuestionState extends State<Question> {

  var value;

  Map question;
  var setQIndex;
  int numPregs;
  int qIndex;

  QuestionState({
    this.question,
    this.setQIndex,
    this.numPregs,
    this.qIndex,
    this.value
  });

  @override
  Widget build(BuildContext context) {

//    print(widget.question);

    return Container(
      padding: EdgeInsets.only(top:10,left: 15,right: 15),
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              '${widget.question['content']}',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          CampoRespuesta(
            question: widget.question,
            value: value,
            setValue: setValue,
          ),
          Botones(
            setQIndex: widget.setQIndex,
            qIndex: widget.qIndex,
            numPregs: widget.numPregs,
            question: widget.question,
            questions: widget.questions,
            value: value,
            getValue: getValue,
            setValue: setValue,
          ),
        ],
      ),
    );
  }

  setValue(valor){
    value = valor;
  }

  getValue(){
    return value;
  }

}

class Botones extends StatelessWidget {

  var setQIndex;
  var qIndex;
  var numPregs;
  var question;
  var questions;
  var value;
  var getValue;
  var setValue;
  Botones({
    this.setQIndex,
    this.qIndex,
    this.numPregs,
    this.question,
    this.questions,
    this.value,
    this.getValue,
    this.setValue,
  });

  @override
  Widget build(BuildContext context) {
//    print('qIndex+1 = ${(qIndex+1)}');
    return Container(
      padding: EdgeInsets.only(top: 35,left: 15,right: 15),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: qIndex != 0 ?
              RaisedButton(
                onPressed: (){
                  cambiaPreg(avanza: false);
                },
                color: Color(0xFF2568D8),
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                )
              ):
              Container(),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: Center(
                child: Text(
                  '${qIndex+1}/$numPregs',
                  style: TextStyle(
                    color: Color(0xFF2568D8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: (qIndex+1) != numPregs ?
            RaisedButton(
              onPressed: (){
                cambiaPreg(avanza: true);
              },
              color: Color(0xFF2568D8),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                )
            ):
            RaisedButton(
                onPressed: (){
                  var valor = getValue();
                  if(valor != null){
                    guardaResp();
                    emergente(
                      context: context,
                      actions: [
                        FlatButton(
                          child: Text(Translations.of(context).text('ok')),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                      content: Container(
                        child: Column(
                          children: <Widget>[
                            Icono(
                              svgName: 'finish',
                              color: Color(0xFF2568D8),
                              width: MediaQuery.of(context).size.height * .18,
                            ),
                            SizedBox(height: 15,),
                            Text(
                              Translations.of(context).text('syncrecomendation').toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2568D8),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 15,),
                            Text(
                              Translations.of(context).text('syncreason').toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
//                    Navigator.pop(context);
                  }
                },
                color: Color(0xFF2568D8),
                child: Text(
                  Translations.of(context).text('finalize'),
                  style: TextStyle(color: Colors.white),
                )
            ),
          ),

        ],
      ),
    );
  }

  void guardaResp() async {

    DB db = DB.instance;

    Map resp = Map();
    resp['value'] = getValue();
    resp['question_id'] = question['id'];
    resp['survey_id'] = question['survey_id'];

    var ansDB = await db.query("SELECT * FROM answers WHERE survey_id = ${question['survey_id']} AND question_id = ${question['id']}");
    var ansId = ansDB == null?null:ansDB[0]['id'];

    if(ansId != null){
      Map ans = ansDB[0];
      resp['id'] = ansId;
      if(ans['value'] != resp['value']){
        resp['edit'] = 1;
      }
    }else{
      resp['new'] = 1;
    }

//    print('RESP: $resp');

    var r = await db.replace('answers', resp);
  }

  void cambiaPreg({bool avanza = true}) async {
    var valor = getValue();

    if(valor != null && valor != ''){
      await guardaResp();
      Map nPreg;
      if(avanza){
        nPreg = questions[qIndex+1];
      }else{
        nPreg = questions[qIndex-1];
      }
      var nextAns = await getAnswerDB(questionId: nPreg['id'],surveyId: nPreg['survey_id'], type: nPreg['type']);

      var nextVal = nextAns['value'];
      setValue(nextVal);

      if(avanza){
        setQIndex(q:qIndex+1);
      }else{
        setQIndex(q:qIndex-1);
      }
    }else{
//      print('respVacia');
      if(!avanza){
        Map nPreg;
        nPreg = questions[qIndex-1];
        var nextAns = await getAnswerDB(questionId: nPreg['id'],surveyId: nPreg['survey_id'], type: nPreg['type']);
        var nextVal = nextAns['value'];
        setValue(nextVal);
        setQIndex(q:qIndex-1);
      }
    }

  }


  getAnswerDB({int surveyId,int questionId,String type}) async {
    DB db = DB.instance;

//    print('survey: $surveyId, question: $questionId');

    Map answer = Map();

    var resp = await db.query('SELECT id,value FROM answers WHERE question_id = $questionId AND survey_id = $surveyId');
    var answer_id = resp == null ? null : resp[0]['id'];
//    if(resp == null){
//      Map<String,dynamic> datAns =  {'question_id':questionId,'survey_id':surveyId};
//      answer_id = await db.insert('answers', datAns, true);
//    }

    var valor = resp == null ? null : resp[0]['value'];

    value = tipeaValor(type, valor);

    answer['value'] = value;
    answer['answer_id'] = answer_id;

    return answer;

  }

}


