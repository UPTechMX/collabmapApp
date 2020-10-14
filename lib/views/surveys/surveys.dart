import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/models/componentes/boton.dart';
import 'survey.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:siap_monitoring/views/consultations/downloadMaps.dart';
import 'package:siap_monitoring/views/consultations/chkAction.dart';

class Surveys extends StatefulWidget {
  var consultationId;
  String consultationName;
  Surveys({this.consultationId,this.consultationName});

  @override
  SurveysState createState() => SurveysState();
}

class SurveysState extends State<Surveys> {


  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getData(),
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
            List elementos = snapshot.data;
            if(elementos.length == 0){
              return Container(
                height: 100,
                child: Center(
                  child: Text(''),
                ),
              );
            }
            rows.add(DownloadMap(consultationId: widget.consultationId,));
            for(int i = 0; i < elementos.length; i++){
//              print(elementos[i]);
              rows.add(elemento(datos: elementos[i],));
            }
            return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: rows,
              ),
            );
          default:
            return Column();
        }

      },
    );
  }

  Future<List> getData() async {
    DB db = DB.instance;


    List datos = await db.query('''
        SELECT c.* 
        FROM ConsultationsChecklist cc
        LEFT JOIN Checklist c ON c.id = cc.checklistId 
        WHERE cc.consultationsId = ${widget.consultationId}
      ''');

//    List datos = await db.query("SELECT * FROM surveys WHERE consultation_id = ${widget.consultationId}");
    datos ??= [];

//    print('DATOS: $datos');

    List datosExt = [];
    for(int i = 0;i<datos.length;i++){
//      print('I: $i');

      Map dato = Map.from(datos[i]);
      datosExt.add(dato);



    }

//    var vis = await db.query("SELECT * FROM Visitas WHERE type = 'cons'");
//    print("VIS: $vis");
//    print(datosExt);

    return datosExt;
  }

  elemento({var datos}){
//    print('Datos: $datos');
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]
          ),
          top: BorderSide(
            color: Colors.grey[300]
          ),
        )
      ),
      child: Boton(
        texto: datos['name'],
        onClick: (){
          if(datos['avanceDouble'] >= 100){
            //ToDo: Descomentar el return;
//            return;
          }
          Navigator.push(context,
              new MaterialPageRoute(builder: (context)=>
                  Survey(
                    id: datos['id'],
                    datos:datos,
                  )
              )
          );
        },
        icono: Icon(Icons.add,color: Colors.white,),
        color: Colors.white,
        widget: true,
        elemento: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      datos['nombre'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ChkAction(datChk: datos,consultationId: widget.consultationId,)
//                    child: Text(
//                      'continuar',
//                      textAlign: TextAlign.right,
//                      style: TextStyle(color: Colors.black),
//                    ),
                  ),
                ],
              ),
            ),
//            Container(
//              padding: EdgeInsets.only(top: 0,bottom: 10),
//              width: double.infinity,
//              child: LinearPercentIndicator(
////             width: 500,
//                lineHeight: 7,
//                percent: datos['avanceDouble']/100,
//                backgroundColor: Colors.grey[300],
//                progressColor: Colors.blue,
//              ),
//            )
          ],
        ),
      ),
    );
  }

}

