import 'package:flutter/material.dart';
import 'package:siap/models/componentes/iconos.dart';
import 'package:siap/models/translations.dart';

class TarjetaConsultation extends StatelessWidget {

  Map datos;
  Color color;
  var icon;

  TarjetaConsultation({
    this.datos,
    this.color,
    this.icon
  });

  @override
  Widget build(BuildContext context) {
//    print('datos: ${datos}');
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: color,
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
                    '${datos['actual'] == 'true'?datos['finishDate']:datos['initDate']}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Divider(
                    color: color,
                    thickness: 2,
                  ),
//                  Text(
//                    '${Translations.of(context).text('code').toUpperCase()}: ${datos['slug']}',
//                    style: TextStyle(
//                      color: color,
////                      fontWeight: FontWeight.bold,
//                      fontSize: 17,
//                    ),
//                  ),
                  SizedBox(height: 5,),
                  Text(
                    '${datos['name']}',
                    style: TextStyle(
                      color: color,
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
//              padding: EdgeInsets.only(left: 10,right: 10),
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      'images/icons/fondoIcono.png',
                      width: MediaQuery.of(context).size.width*.195,
                    ),
                  ),
                  icon,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
