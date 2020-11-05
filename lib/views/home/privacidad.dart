import 'package:flutter/material.dart';
import 'package:siap/models/layout/paginaList.dart';
import 'package:siap/models/translations.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/models/conexiones/api.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/views/consultations/consultationsHome.dart';
import 'home.dart';

class Privacidad extends StatelessWidget {
  bool conAcept;
  bool barraSinBoton;
  Privacidad({this.conAcept = false, this.barraSinBoton = false});

  @override
  Widget build(BuildContext context) {
    return conAcept
        ? ConsultationsHome()
        : Pagina(
            drawer: false,
            esLista: false,
            nombrePagina: null,
            barraSinBoton: barraSinBoton,
            sync: true,
            elemento: FutureBuilder(
              future: getData(),
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
                    Map datos = snapshot.data;
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        color: Colors.white.withAlpha(200),
                        padding: EdgeInsets.only(
                            left: 5, bottom: 15, right: 5, top: 15),
                        child: Column(
                          children: <Widget>[
                            Text(
                              Translations.of(context)
                                  .text('noticeofprivacy')
                                  .toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height * .03,
                                color: Color(0xFFF8B621),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Html(
                              data: '${datos['privacidad']}',
                              customTextAlign: (a) {
                                return TextAlign.justify;
                              },
                            ),
                            conAcept ? PrivCheck() : Container(),
                          ],
                        ),
                      ),
                    );
                  default:
                    return Column();
                }
              },
            ),
          );
  }

  getData() async {
    print("Privacidad:" + conAcept.toString());
    DB db = DB.instance;
    // TODO :: ARREGLAR ESTO!
    Map dat = Map();
    List datos =
        await db.query("SELECT * FROM General WHERE name = 'privacy' ");

    if (datos == null) {
//      print('entra');
      Map r = await getDatos2(
          opt: 'getGeneral/privacy', varNom: null, imprime: false);
//      print('R: $r');
      dat['privacidad'] = r['texto'];
    } else {
      dat['privacidad'] = datos[0]['texto'];
    }
//
//    datos ??= [];
//

    return dat;
  }
}

class PrivCheck extends StatefulWidget {
  @override
  _PrivCheckState createState() => _PrivCheckState();
}

class _PrivCheckState extends State<PrivCheck> {
  bool activo = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Checkbox(
                value: activo,
                onChanged: (a) {
                  setState(() {
                    activo = a;
                  });
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                Translations.of(context)
                    .text('noticeofprivacyAgree')
                    .toUpperCase(),
                style: TextStyle(
                  color: Color(0xFFF8B621),
                ),
              ),
            )
          ],
        ),
        RaisedButton(
          color: Color(0xFFF8B621),
          child: Text(
            Translations.of(context).text('send').toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            if (activo) {
              aceptacionPriv();
              Navigator.of(context).pop();
            }
          },
        )
      ],
    ));
  }

  aceptacionPriv() async {
    SharedPreferences userData = await SharedPreferences.getInstance();
    userData.setBool('aceptaPriv', true);
    Route route =
        MaterialPageRoute(builder: (context) => Home(aceptaPriv: true));
    Navigator.pushReplacement(context, route);
  }
}
