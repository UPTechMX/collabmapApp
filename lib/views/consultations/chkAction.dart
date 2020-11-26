import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/models/translations.dart';

import 'package:siap/views/contestaCuestionario/bloques.dart';
import 'package:siap/views/contestaCuestionario/areas.dart';
import 'package:siap/views/contestaCuestionario/contestaCuestionario.dart';
import 'package:siap/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap/views/contestaCuestionario/pregunta.dart';
import 'package:siap/views/surveys/surveys.dart';
import 'package:siap/views/verCuestionario/verCuestionario.dart';

class ChkAction extends StatefulWidget {
  var consultationId;
  Map datChk;
  GlobalKey<SurveysState> KeySurvey;
  ChkAction({this.consultationId, this.datChk, this.KeySurvey});

  @override
  ChkActionState createState() => ChkActionState();
}

class ChkActionState extends State<ChkAction> {
  GlobalKey<BloquesBtnState> KeyBloques = GlobalKey();
  GlobalKey<AreasState> KeyAreas = GlobalKey();
  GlobalKey<PreguntasContState> KeyPreguntas = GlobalKey();
  GlobalKey<PreguntaState> KeyPregunta = GlobalKey();
  GlobalKey<SurveysState> KeySurvey = GlobalKey();

  //ChkActionState({this.KeySurvey});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getInfo(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text(Translations.of(context).text('waiting'));
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
//            print('Snapshot:${snapshot.data}');
            return Container(
              padding: EdgeInsets.all(5),
              child: Center(
                child: snapshot.data,
              ),
              decoration: BoxDecoration(
//                color: Colors.amber,
//                border: Border.all(
//                  color: Colors.black,
//                )
                  ),
            );
          default:
            return Column();
        }
      },
    );
  }

  Future getInfo() async {
    DB db = DB.instance;

    SharedPreferences userData = await SharedPreferences.getInstance();
    int userId = userData.getInt('userId');

//    print('datCHK: ${widget.datChk}');
    String sql = '''
      SELECT v.*, f.code as fCode
      FROM Visitas v
      LEFT JOIN UsersConsultationsChecklist ucc ON ucc.id = v.elemId
      LEFT JOIN ConsultationsChecklist cc ON cc.id = ucc.consultationsChecklistId
      LEFT JOIN Frequencies f ON f.id = cc.frequency
      WHERE v.type = 'cons' AND v.checklistId = ${widget.datChk['id']} 
        AND ucc.usersId = $userId AND cc.consultationsId = ${widget.consultationId}
      ORDER BY v.timestamp DESC LIMIT 1
    ''';

    List visita = await db.query(sql);
    visita ??= [];

//    print('VISITA: $visita');

//    return Text('aa');

    if (visita.length == 0) {
//      print('aaaa');
//      print(widget.datChk['id'].runtimeType);
//      print(widget.consultationId.runtimeType);

      String uccSql = '''
      SELECT ucc.*
      FROM UsersConsultationsChecklist ucc
      LEFT JOIN ConsultationsChecklist cc ON cc.id = ucc.consultationsChecklistId
      WHERE cc.checklistId = ${widget.datChk['id']} AND ucc.usersId = $userId AND cc.consultationsId = ${widget.consultationId} 
      
      ''';

      var ucc = await db.query(uccSql);

      int uccId;
      if (ucc == null) {
        var cc = await db.query(
            "SELECT * FROM ConsultationsChecklist WHERE consultationsId = ${widget.consultationId} AND checklistId = ${widget.datChk['id']} ");

        Map<String, dynamic> di = Map();
        di['consultationsChecklistId'] = cc[0]['id'];
        di['usersId'] = userId;
        di['creadoOffline'] = 1;
        di['offline'] = 1;

        uccId = await db.insert('UsersConsultationsChecklist', di, false);
      } else {
        uccId = ucc[0]['id'];
      }

//      return Text('$uccId');

      return answerSurvey(
        checklistId: widget.datChk['id'],
        elemId: uccId,
      );
    } else {
      var vis = visita[0];
      DateTime nextDate;
      DateTime now = new DateTime.now();
      switch (vis['fCode']) {
        case "oneTime":
          nextDate = now.add(Duration(days: -100000));
          break;
        case "daily":
          nextDate = now.add(Duration(days: -1));
          break;
        case "weekly":
          nextDate = now.add(Duration(days: -7));
          break;
        case "2weeks":
          nextDate = now.add(Duration(days: -14));
          break;
        case "3weeks":
          nextDate = now.add(Duration(days: -21));
          break;
        case "monthly":
          nextDate = now.add(Duration(days: -30));
          break;
        case "2months":
          nextDate = now.add(Duration(days: -60));
          break;
        case "3months":
          nextDate = now.add(Duration(days: -90));
          break;
        case "4months":
          nextDate = now.add(Duration(days: -120));
          break;
        case "6months":
          nextDate = now.add(Duration(days: -180));
          break;
        case "yearly":
          nextDate = now.add(Duration(days: -365));
          break;
        default:
          break;
      }

      if (vis['finalizada'] == null) {
        return cont(
          checklistId: widget.datChk['checklistId'],
          vId: visita[0]['id'],
        );
      }

      var finishDate =
          vis['finishDate'] != null ? vis['finishDate'].split(' ')[0] : null;
      DateTime fDate = DateTime.parse('$finishDate 00:00:00Z');
      String nextDateStr = '$nextDate'.split(' ')[0];
      nextDate = DateTime.parse("$nextDateStr 00:00:00Z");

      if (vis['fCode'] == 'oneTime') {
        return answered(finishDate: finishDate, vId: visita[0]['id']);
      } else {
        var difference = fDate.difference(nextDate).inDays;
//        print('FinishDate: $fDate');
//        print('nextDate: ${nextDate}');
//        print('Difference: ${difference.runtimeType}');
        if (difference <= 0) {
          return answerSurvey(
            checklistId: widget.datChk['checklistId'],
            elemId: widget.consultationId,
          );
        }
        return answered(finishDate: finishDate, vId: visita[0]['id']);
      }
    }

//    print('Visita chk[${widget.datChk['checklistId']}] uT[${widget.datCons['id']}]: $visita');
  }

  Widget answered({String finishDate, int vId}) {
    return Column(
      children: <Widget>[
        Text(
          '${Translations.of(context).text('sended')}:${finishDate}',
          style: TextStyle(color: Colors.grey[600], fontSize: 9),
        ),
        FlatButton(
          child: Text(
            '${Translations.of(context).text('seeResults')}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          onPressed: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => VerCuestionario(vId)));
          },
        )
      ],
    );
  }

  Widget answerSurvey({int elemId, int checklistId}) {
    return FlatButton(
      color: Color(0xFF94C122),
      child: Text(
        '${Translations.of(context).text('answerSurvey')}',
        style: TextStyle(color: Colors.grey[50]),
      ),
      onPressed: () {
        creaVisita(elemId: elemId, checklistId: checklistId);
      },
    );
  }

  Widget cont({int vId, int checklistId}) {
    return FlatButton(
      color: Color(0xFF94C122),
      padding: EdgeInsets.all(8.5),
      child: Text(
        '${Translations.of(context).text('continue')}',
        style: TextStyle(color: Colors.grey[50]),
      ),
      onPressed: () {
        goToSurvey(vId: vId);
      },
    );
  }

  void creaVisita({int elemId, int checklistId}) async {
    DB db = DB.instance;

    DateTime now = new DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    Map<String, dynamic> datVis = Map();
    datVis['timestamp'] = formattedDate;
    datVis['checklistId'] = checklistId;
    datVis['type'] = 'cons';
    datVis['elemId'] = elemId;
    datVis['creadoOffline'] = 1;

    var vId = await db.insert('Visitas', datVis, true);

    goToSurvey(vId: vId);
  }

  void goToSurvey({int vId}) async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => ContestaCuestionario(
                  vId: vId,
                  KeyBloques: KeyBloques,
                  KeyAreas: KeyAreas,
                  KeyPreguntas: KeyPreguntas,
                  KeyPregunta: KeyPregunta,
                  KeySurvey: widget.KeySurvey,
                )));
  }
}
