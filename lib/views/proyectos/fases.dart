import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/conexiones/api.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/models/componentes/boton.dart';
import 'package:siap_monitoring/views/consultations/consultations.dart';

class Fases extends StatelessWidget {

  var proyectoId;
  Fases({this.proyectoId});

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
            if(snapshot.data.length == 0){
              return Container(
                height: 100,
                child: Center(
                  child: Text(Translations.of(context).text('empty')),
                ),
              );
            }
            for(int i = 0; i < elementos.length; i++){
              rows.add(
                  Boton(
                    texto: elementos[i]['name'],
                    onClick: (){
                      Navigator.push(context,
                          new MaterialPageRoute(builder: (context)=>
                              Consultations(
                                phaseId: elementos[i]['id'],
                                phaseName: elementos[i]['name'],
                              )
                          )
                      );
                    },
                    icono: Icon(Icons.add,color: Colors.white,),
                    color: Color(0xFF2A6CD5),
                  )
              );
            }
            return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: rows,
              ),
            );
        }
        return Column();
      },
    );
  }

  Future<List> getData() async {
    DB db = DB.instance;

    List datos = await db.query("SELECT * FROM phases WHERE project = ${proyectoId}");
//    print('DATOS: $datos');
    datos ??= [];

    return datos;
  }


}
