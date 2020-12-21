import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/models/translations.dart';

import 'package:siap/views/contestaCuestionario/bloques.dart';
import 'package:siap/views/contestaCuestionario/areas.dart';
import 'package:siap/views/contestaCuestionario/contestaCuestionario.dart';
import 'package:siap/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap/views/contestaCuestionario/pregunta.dart';
import 'package:siap/views/verCuestionario/verCuestionario.dart';

class ChkAction extends StatefulWidget {
  Map datTE;
  Map datChk;

  ChkAction({this.datTE, this.datChk});

  @override
  ChkActionState createState() => ChkActionState();
}

class ChkActionState extends State<ChkAction> {
  GlobalKey<BloquesBtnState> KeyBloques = GlobalKey();
  GlobalKey<AreasState> KeyAreas = GlobalKey();
  GlobalKey<PreguntasContState> KeyPreguntas = GlobalKey();
  GlobalKey<PreguntaState> KeyPregunta = GlobalKey();

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

    String sql = '''
      SELECT v.*, f.code as fCode
      FROM Visitas v
      LEFT JOIN TargetsElems te ON te.id = v.elemId
      LEFT JOIN TargetsChecklist tc ON tc.targetsId = te.targetsId AND tc.checklistId = v.checklistId
      LEFT JOIN Frequencies f ON f.id = tc.frequency
      WHERE v.type = 'trgt' AND v.elemId = ${widget.datTE['id']} AND v.checklistId = ${widget.datChk['checklistId']}
      ORDER BY v.timestamp DESC LIMIT 1
    ''';

    List visita = await db.query(sql);
    visita ??= [];

    if (visita.length == 0) {
      return answerSurvey(
        checklistId: widget.datChk['checklistId'],
        elemId: widget.datTE['id'],
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
            elemId: widget.datTE['id'],
          );
        }
        return answered(finishDate: finishDate, vId: visita[0]['id']);
      }
    }

    print(
        'Visita chk[${widget.datChk['checklistId']}] uT[${widget.datTE['id']}]: $visita');
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
      child: Text(
        '${Translations.of(context).text('answerSurvey')}',
        style: TextStyle(color: Colors.grey[600]),
      ),
      onPressed: () {
        creaVisita(elemId: elemId, checklistId: checklistId);
      },
    );
  }

  Widget cont({int vId, int checklistId}) {
    return FlatButton(
      child: Text(
        '${Translations.of(context).text('continue')}',
        style: TextStyle(color: Colors.grey[600]),
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
//    print(formattedDate);

    Map<String, dynamic> datVis = Map();
    datVis['timestamp'] = formattedDate;
    datVis['checklistId'] = checklistId;
    datVis['type'] = 'trgt';
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
                )));
  }
}
