import 'dart:io';

import 'package:flutter/material.dart';
import 'package:siap_monitoring/views/barra.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiver/io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'tarjetaInfo.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';

class MapManager extends StatefulWidget {
  @override
  MapManagerState createState() => MapManagerState();
}

class MapManagerState extends State<MapManager> {

  bool act = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Barra(),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            child: Text(
              Translations.of(context).text('map_manager'),
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          FutureBuilder(
            future: getConsult(),
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
                  List tarjetas = snapshot.data;


                  for(int i = 0; i < tarjetas.length; i++){
                    rows.add(TarjetaInfo(datos: tarjetas[i],updateFnc: update,));
                  }

                  return Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
                      children: rows,
                    ),
                  );
              }
              return Column();
            },

          )
        ],
      ),
    );
  }

  Future<List> getConsult() async {
    DB db = DB.instance;

    List consults = [];

    var mapas = await db.query("SELECT mapFile,mapName FROM questions WHERE mapFile IS NOT NULL OR mapFile != '' GROUP BY mapFile");
//    print('MAPAS: $mapas');


    SharedPreferences userData = await SharedPreferences.getInstance();

    String datosJson = await userData.getString('consultations');


    String dir = (await getApplicationDocumentsDirectory()).path;

    for(int i = 0; i<mapas.length; i++){
//      print('mapFile: ${mapas[i]['mapFile']}');
      File map = await File('$dir/maps/${mapas[i]['mapFile']}');
      if(!await map.exists()){
        continue;
      }
      Map datConsult = Map();
      datConsult['name'] = mapas[i]['mapName'];
      datConsult['fileName'] = mapas[i]['mapFile'];
      datConsult['fileSize'] = (map.lengthSync()/1024/1014).toStringAsFixed(1);

      consults.add(datConsult);
    }
    print("CONSULTS: $consults");
    return consults;
  }

  update(){
    setState(() {
      act = true;
    });
  }
}

