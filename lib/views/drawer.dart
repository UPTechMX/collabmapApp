import 'package:siap_monitoring/models/translations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap_monitoring/views/configuration/mapManager/mapManager.dart';
import 'package:siap_monitoring/views/configuration/settings/settings.dart';
import 'package:siap_monitoring/views/home/sync.dart';
import 'package:siap_monitoring/models/conexiones/DBEst.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/models/conexiones/api.dart';
import 'package:siap_monitoring/views/home/about.dart';
import 'package:siap_monitoring/views/home/privacidad.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:siap_monitoring/views/questionnaires/targets/targetsHome.dart';

// Variables for SimpleDialog options
enum Confirmation { yes, no }

class Opciones extends StatefulWidget {
  @override
  OpcionesState createState() => OpcionesState();
}

class OpcionesState extends State<Opciones> {
  @override
  Widget build(BuildContext context) {
    void cambiaVentana(String accion) {
//      Navigator.of(context).pop();
//      Navigator.push(context,
//          new MaterialPageRoute(builder: (context)=>Actividades(accion,_nivel)));
    }

    final logo = CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48,
      child: Image.asset('images/iuLogo.png'),
    );

    final drawerHelper = DrawerHeader(
      child: logo,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
    );

    final cerrarSesionBtn = PopupMenuItem(
        value: 1,
        child: Boton(
            texto: Translations.of(context).text('close_session'),
            onClick: mostrarDialogCerrarSesion));

    final mapManager = PopupMenuItem(
        value: 1,
        child: Boton(
            texto: Translations.of(context).text('map_manager'),
            onClick: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => MapManager()));
            }));

    final webPage = PopupMenuItem(
        value: 1,
        child: Boton(
            texto: Translations.of(context).text('web_page'),
            onClick: () async {
              var url = '$urlHtml/consultations';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            }));

    final about = PopupMenuItem(
        value: 1,
        child: Boton(
            texto: Translations.of(context).text('about'),
            onClick: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => About()));
            }));

    final siap = PopupMenuItem(
        value: 1,
        child: Boton(
            texto: Translations.of(context).text('siap'),
            onClick: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => TargetsHome()));
            }));

    final privacidad = PopupMenuItem(
        value: 1,
        child: Boton(
            texto: Translations.of(context).text('noticeofprivacy'),
            onClick: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => Privacidad()));
            }));

    var separador = PopupMenuDivider(
      height: 10,
    );

    return PopupMenuButton<int>(
      icon: Icon(Icons.menu),
      itemBuilder: (context) => [
        webPage,
        separador,
        about,
        separador,
        privacidad,
        //separador,
//        mapManager,
        //siap,
        separador,
        cerrarSesionBtn,
      ],
    );
  }

  Widget Boton({String texto, var onClick}) {
    return SizedBox(
      width: double.infinity,
      child: ButtonTheme(
//          minWidth: 150.0,
//          height: MediaQuery.of(context).size.height * .117,
        buttonColor: Colors.blue,
        child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            onClick();
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                texto.toUpperCase(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void cerrarSesion() async {
    DB db = DB.instance;
    SharedPreferences userData = await SharedPreferences.getInstance();
    userData.remove('login');
    userData.remove('username');
    userData.remove('password');
    userData.remove('token');
    userData.remove('firstSync');
    //userData.remove('aceptaPriv');

    Tablas DBTablas = Tablas();
    Map tablas = DBTablas.getTablas();

    for (var t in tablas.keys) {
      print('tabla: $t');
      await db.query('DELETE FROM $t WHERE 1');
    }

    Navigator.pushReplacementNamed(context, 'login');
  }

  Future<void> mostrarDialogCerrarSesion() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(Translations.of(context).text('close_session')),
            children: [
              Padding(
                  child:
                      Text(Translations.of(context).text('close_session_text')),
                  padding: EdgeInsets.all(25.0)),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(Confirmation.yes);
                  cerrarSesion();
                },
                child: Text(Translations.of(context).text('yes')),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(Confirmation.no);
                },
                child: Text(Translations.of(context).text('no')),
              )
            ],
          );
        })) {
      case Confirmation.yes:
        print("Goodbye!");
        break;
      case Confirmation.no:
        break;
    }
  }
}
