import 'package:flutter/material.dart';
import 'package:siap/models/componentes/iconos.dart';
import 'package:flutter_svg/flutter_svg.dart';


class Tarjeta extends StatelessWidget {

  Map datos;
  Tarjeta({this.datos});

  @override
  Widget build(BuildContext context) {
//    print('datos: ${datos}');
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xFFA27AE4),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'FECHA: ',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Divider(
                    color: Color(0xFFA27AE4),
                    thickness: 2,
                  ),
                  Text(
                    'CÓDIGO',
                    style: TextStyle(
                      color: Colors.blue,
//                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'CONSULTA TITULO NUM 03 ------',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 10,right: 10,top: 40),
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      'images/icons/fondoIcono.png',
                    ),
                  ),
                  Icono(
                    svgName: 'bus',
                    color: Colors.green,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
