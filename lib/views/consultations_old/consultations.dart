import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:siap/views/consultations_old/tarjeta.dart';
import 'package:siap/models/conexiones/api.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/models/translations.dart';
import 'package:intl/intl.dart';

class Consultations extends StatefulWidget {
  @override
  ConsultationsState createState() => ConsultationsState();
}

class ConsultationsState extends State<Consultations> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getConsult(context: context),
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

            if(snapshot.data.length == 0){
              return Container(
                height: 100,
                child: Center(
                  child: Text(Translations.of(context).text('no_consultations')),
                ),
              );
            }
            for(int i = 0; i < tarjetas.length; i++){
              rows.add(Tarjeta(datos: tarjetas[i],));
            }
//            print('Rows : $rows');
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
    );
    
  }


  Future<List> getConsult({BuildContext context}) async {
    DB db = DB.instance;

    List consults = [];

    DateTime now = DateTime.now();
    String dt = '${DateFormat("yyyy-MM-dd").format(now)}T${DateFormat("HH:mm:ss").format(now)}';
//    print ('DT: $dt');
//    dt = '2019-10-31T12:00:00';

    var datos = await getDatos(opt: 'consultations/?status=3',varNom: 'consultations',imprime: false);
    String dir = (await getApplicationDocumentsDirectory()).path;
    db.query("UPDATE consultations SET status = 5 WHERE 1");

    for(int i = 0; i<datos.length; i++){
//      print(i);
//      print(datos[i]['study_area']['type']);
//      print('quitar el || true de la siguente linea - ($i)');
      if(datos[i]['status'] == 3){
        if(datos[i]['study_area'] == null){
          continue;
        }

        bool abierta = dt.compareTo(datos[i]['finish_date']) == -1;
//        print(' ${dt.compareTo(datos[i]['finish_date'])} : $abierta');
        if(!abierta){
          continue;
        }

        Map consultation = Map();
        consultation['id'] = datos[i]['id'];
        consultation['name'] = datos[i]['name'];
        consultation['code'] = datos[i]['code'];
        consultation['json'] = jsonEncode(datos[i]);
        consultation['status'] = datos[i]['status'];
        consultation['finish_date'] = datos[i]['finish_date'];
        consultation['edit_inputs'] = datos[i]['edit_inputs']?1:0;

        await db.replace('consultations', consultation);

        File f = await File('$dir/${datos[i]['id']}.mbtiles');
        datos[i]['descargado'] = await f.exists();

        Map areaEstudio = new Map();
//        print(datos[i]['study_area']);
        areaEstudio['type'] = datos[i]['study_area']['type'];
        areaEstudio['coordinates'] = [];
        List poligonos = datos[i]['study_area']['coordinates'];

        for(int j = 0;j<poligonos.length;j++){
          List poligono = poligonos[j];
          List poligonoTmp = [];
          for(int k = 0;k < poligono.length;k++){
            List subPoligono = poligono[k];
            List subPoligonoTmp = [];
            for(int l = 0;l<subPoligono.length;l++){
              var lng;
              var c = subPoligono[l];
              if(c[0] < 0 && c[0] < -180){
                lng = 360+c[0];
              }else{
                lng = c[0];
              }
              var coord = [lng,c[1]];
              subPoligonoTmp.add(coord);
            }
            poligonoTmp.add(subPoligonoTmp);
          }
          areaEstudio['coordinates'].add(poligonoTmp);
        }

        datos[i]['areaEstudio'] = areaEstudio;

        Map centro = new Map();
        centro['type'] = datos[i]['center']['type'];
        var lngC;
//        print("CENTROOOO");
//        print(datos[i]['code']);
//        print(datos[i]['center']);
        if(datos[i]['center']['coordinates'][0] < 0 && datos[i]['center']['coordinates'][0] < -180){
          lngC = 360+datos[i]['center']['coordinates'][0];
        }else{
          lngC = datos[i]['center']['coordinates'][0];
        }
        centro['coordinates'] = [lngC,datos[i]['center']['coordinates'][1]];
        datos[i]['centro'] = centro;

        List problems = await db.query("SELECT COUNT(*) as cuenta FROM problems WHERE consultationsId = ${datos[i]['id']}");

        datos[i]['problems'] = problems[0]['cuenta'];
//        print(problems);

        consults.add(datos[i]);

      }
    }
//    print(consults);
    return consults;
  }





}

