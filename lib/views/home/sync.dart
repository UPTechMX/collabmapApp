import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/layout/paginaList.dart';
import 'package:siap_monitoring/models/componentes/colorLoader.dart';
import 'package:siap_monitoring/models/conexiones/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/views/home/home.dart';
import 'package:siap_monitoring/models/componentes/iconos.dart';

class Sync extends StatefulWidget {
  bool ventana;
  bool firstSync;
  bool barraSinBoton;
  Sync({this.ventana = false,this.firstSync = false, this.barraSinBoton = false});

  @override
  SyncState createState() => SyncState(ventana: ventana,firstSync: firstSync);
}

class SyncState extends State<Sync> {

  bool loading = false;
  String etapa = '';
  String proceso = '';
  bool ventana;
  bool firstSync;


  SyncState({this.ventana = false,this.firstSync = false});

  @override
  Widget build(BuildContext context) {
    return Pagina(
      drawer: false,
      esLista: false,
      sync: true,
      barraSinBoton: widget.barraSinBoton,
      elemento: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 15),
            child: firstSync?
            Container():
            Text(
              Translations.of(context).text('sync_rquired'),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top:40),
            child: loading ? ColorLoader3(
              radius: 50,
              dotRadius: 15,
            ) :
            FlatButton(
              onPressed: sync,
              child: Container(
                padding: EdgeInsets.all(10),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Colors.grey
                  )
                ),
                child: Icono(
                  svgName: 'sync',
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top:20),
            child: Text(
              etapa,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
      nombrePagina: 'Sync',
    );
  }

  sync() async {
    setState(() {
      loading = true;
    });
    setState(() {
      etapa = Translations.of(context).text('sending_data');
    });
//    print('----- Inicia Send -----');
    await sendData();

//    print('----- Termina Send -----');

    setState(() {
      etapa = Translations.of(context).text('receiving_data');
    });
    await getAllData();

    SharedPreferences userData = await SharedPreferences.getInstance();
    userData.setBool('firstSync', true);
//
    setState(() {
      loading = false;
      etapa = '';
    });
//
    List<Widget> actions = [];
      actions.add(
          FlatButton(
            child: Text(Translations.of(context).text('ok')),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (context) => Home(firstSync: true,aceptaPriv: true,));
              Navigator.pushReplacement(context, route);
            },
          )
      );
    

    emergente(
      context: context,
      actions: actions,
      content: Column(
        children: <Widget>[
          Icono(
            svgName: 'finish',
            color: Color(0xFF2568D8),
            width: MediaQuery.of(context).size.height * .18,
          ),
          SizedBox(height: 15,),
          Text(
            Translations.of(context).text('syncsuccessful').toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF2568D8),
                fontWeight: FontWeight.bold
            ),
          )
        ],
      ),
    );

  }


}