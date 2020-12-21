import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/views/consultations/consultation.dart';
import 'package:siap/views/consultations/healthPoll.dart';
import 'package:flutter/material.dart';
import 'package:siap/models/translations.dart';
import 'package:siap/models/conexiones/api.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/models/componentes/iconos.dart';
import 'dart:convert';

class Poll extends StatefulWidget {
  var poll;
  var datos;

  Poll({this.poll, this.datos});

  @override
  PollState createState() => PollState();
}

class PollState extends State<Poll> {
  int value = null;

  @override
  Widget build(BuildContext context) {
    var palomita = Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * .012),
      child: Align(
        alignment: Alignment.topRight,
        child: Icon(
          Icons.check_circle,
          color: Color(0xFFF8B621),
        ),
      ),
    );

//    print('POLL: ${widget.poll}');
//    print('QUESTIONS = = = = =');
//    print(widget.poll);
//    List preguntas = widget.poll['questions'];
    String textoPregunta;
    int idPregunta = null;

    bool conHealth = false;
    bool conQuick = true;
    textoPregunta = '';
//    if(preguntas.length > 0){
////      print('++++ MAS DE UNA ++++');
//
//      for(int i = 0; i<preguntas.length;i++){
////        print(preguntas[i]);
//        if(preguntas[i]['type'] == 'quick'){
//          textoPregunta = '${preguntas[i]['content']}';
//          idPregunta = preguntas[i]['id'];
//          conQuick = true;
//          break;
//        }
//      }
//
//      for(int i = 0; i<preguntas.length;i++){
////        print(preguntas[i]);
//        if(preguntas[i]['type'] == 'health'){
//          conHealth = true;
//          break;
//        }
//      }
//    }

    return Column(
      children: <Widget>[
//        conHealth?Container(
//          child: Column(
//            children: <Widget>[
//              Accion(
//                color: Color(0xFFFF0000),
//                height: MediaQuery.of(context).size.height*.1,
//                texto: Translations.of(context).text('pollHealth').toUpperCase(),
//                icono: 'accCOVID',
//                elemento: HealthPoll(pollId: widget.poll['id'],),
//              ),
//              SizedBox(height: 10,)
//            ],
//          )
//        ):Container(),

        conQuick
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withAlpha(170),
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.poll.toUpperCase(),
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$textoPregunta',
                      style: TextStyle(
                          color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: IconButton(
                                  iconSize:
                                      MediaQuery.of(context).size.width * .2,
                                  icon: Image.asset(
                                    'images/caritaTriste.png',
                                    color:
                                        value == 0 ? Color(0xFFF8B621) : null,
                                  ),
                                  onPressed: () {
                                    sync();
                                    saveValue(value: 0, idPregunta: idPregunta);
                                    setState(() {
                                      value = 0;
                                    });
                                  },
                                ),
                              ),
                              value == 0 ? palomita : Container(),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: IconButton(
                                  iconSize:
                                      MediaQuery.of(context).size.width * .2,
                                  icon: Image.asset(
                                    'images/caritaNeutra.png',
                                    color:
                                        value == 5 ? Color(0xFFF8B621) : null,
                                  ),
                                  onPressed: () {
                                    sync();
                                    saveValue(value: 5, idPregunta: idPregunta);
                                    setState(() {
                                      value = 5;
                                    });
                                  },
                                ),
                              ),
                              value == 5 ? palomita : Container(),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: IconButton(
                                  iconSize:
                                      MediaQuery.of(context).size.width * .2,
                                  icon: Image.asset(
                                    'images/caritaFeliz.png',
                                    color:
                                        value == 10 ? Color(0xFFF8B621) : null,
                                  ),
                                  onPressed: () {
                                    sync();
                                    saveValue(
                                        value: 10, idPregunta: idPregunta);
                                    setState(() {
                                      value = 10;
                                    });
                                  },
                                ),
                              ),
                              value == 10 ? palomita : Container(),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : Container(),
      ],
    );
  }

  saveValue({int value, int idPregunta}) async {
    DB db = DB.instance;

    SharedPreferences userData = await SharedPreferences.getInstance();
    int userId = userData.getInt('userId');

    DateTime now = new DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd H:m:s').format(now);
//    print(formattedDate);

    Map<String, dynamic> datos = Map();
    datos['usersId'] = userId;
    datos['timestamp'] = formattedDate;
    datos['consultationsId'] = widget.datos['id'];
    datos['score'] = value;

    var r = await db.insert('UsersQuickPoll', datos, true);

//    print(r);
  }

  sync() {
    return emergente(
      context: context,
      actions: [
        FlatButton(
          child: Text(Translations.of(context).text('ok')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
      content: Container(
        child: Column(
          children: <Widget>[
            Icono(
              svgName: 'finish',
              color: Color(0xFFF8B621),
              width: MediaQuery.of(context).size.height * .18,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              Translations.of(context).text('syncrecomendation').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFFF8B621), fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              Translations.of(context).text('syncreason').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
