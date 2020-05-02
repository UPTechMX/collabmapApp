import 'package:flutter/material.dart';
import 'fases.dart';


class Proyecto extends StatelessWidget {

  Map datos;
  Proyecto({this.datos});

  @override
  Widget build(BuildContext context) {
//    print('project: ${datos['id']}');
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[350]),
            padding: EdgeInsets.all(15),
            child: Text(
              datos['name'],
              style:TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[200]),
            padding: EdgeInsets.all(15),
            child: Fases(proyectoId: datos['id'],),
          ),
        ],
      ),
    );
  }
}
