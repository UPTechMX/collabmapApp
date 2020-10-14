import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/cuestionario/checklist.dart';

class Instalacion extends StatelessWidget{

  Checklist chk;
  int instId;
  String nombre;

  Instalacion({this.instId,this.chk,this.nombre});

  @override
  Widget build(BuildContext context) {
    

//    chk.getInstalacion();
    return FutureBuilder<List>(
      future: gInstalacion(instId),
      builder: (context,snapshot){
        if(!snapshot.hasData) return Center(child: Container(width: 0,height: 0,));
        return Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(color: Colors.grey[350],),
              child: Center(
                  child: Text(
                    nombre,
                    style: TextStyle(fontWeight:FontWeight.w600,fontSize: 15),
                  )
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: snapshot.data.map(
                      (datos)=>Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            datos['area'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                          ),
                        ),
                        Container(
                          child: Text(
                            datos['texto'],
                          ),
                        )
                      ],
                    ),
                  )
              ).toList(),
            )
          ],
        );
      },
    );
  }

  Future<List> gInstalacion(int instId) async {
    var instalacion = await chk.getInstVis(instId);

//    print(instalacion);
    return instalacion;
  }


}
