import 'package:siap/models/translations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/views/configuration/mapManager/mapManager.dart';
import 'package:siap/views/configuration/settings/settings.dart';
import 'package:siap/views/home/sync.dart';
import 'package:siap/models/conexiones/DBEst.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/views/home/about.dart';
import 'package:siap/views/home/privacidad.dart';
import 'package:url_launcher/url_launcher.dart';



class Opciones extends StatefulWidget{
  
  @override
  OpcionesState createState() => OpcionesState();

}

class OpcionesState extends State<Opciones>{

  
  @override
  Widget build(BuildContext context) {

    void cambiaVentana(String accion){
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
            onClick: cerrarSesion
        )
    );




    final mapManager = PopupMenuItem(
      value: 1,
      child: Boton(
        texto: Translations.of(context).text('map_manager'),
        onClick: (){
          Navigator.of(context).pop();
          Navigator.push(context,
              new MaterialPageRoute(builder: (context)=>MapManager() ));
        }
      )
    );

    final webPage = PopupMenuItem(
      value: 1,
      child: Boton(
        texto: Translations.of(context).text('web_page'),
        onClick: () async {
          var url = 'http://paraguay.collabmap.in/';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        }
      )
    );


    final about = PopupMenuItem(
      value: 1,
      child: Boton(
        texto: Translations.of(context).text('about'),
        onClick: (){
          Navigator.of(context).pop();
          Navigator.push(context,
              new MaterialPageRoute(builder: (context)=>
                  About()
              )
          );
        }
      )
    );

    final privacidad = PopupMenuItem(
        value: 1,
        child: Boton(
            texto: Translations.of(context).text('noticeofprivacy'),
            onClick: (){
              Navigator.of(context).pop();
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context)=>
                      Privacidad()
                  )
              );
            }
        )
    );


    var separador = PopupMenuDivider(
      height: 10,
    );


    return PopupMenuButton<int>(
      icon: Icon(Icons.menu),
      itemBuilder: (context) => [
//        webPage,
//        about,
//        separador,
        privacidad,
//        separador,
//        mapManager,
//        separador,
        cerrarSesionBtn,
      ],
    );
  }

  Widget Boton({String texto, var onClick}){
    return SizedBox(
      width: double.infinity,
      child: ButtonTheme(
//          minWidth: 150.0,
//          height: MediaQuery.of(context).size.height * .117,
        buttonColor: Colors.blue,
        child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: (){
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

  void cerrarSesion() async{
    DB db = DB.instance;
    SharedPreferences userData = await SharedPreferences.getInstance();
    userData.remove('login');
    userData.remove('username');
    userData.remove('password');
    userData.remove('token');
    userData.remove('firstSync');
    userData.remove('aceptaPriv');

    Tablas DBTablas = Tablas();
    Map tablas = DBTablas.getTablas();

    for(var t in tablas.keys){
      print('tabla: $t');
      await db.query('DELETE FROM $t WHERE 1');
    }

    Navigator.pushReplacementNamed(context, 'login');

  }


}



