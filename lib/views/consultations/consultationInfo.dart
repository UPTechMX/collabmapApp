import 'package:flutter/material.dart';
import 'package:siap/models/layout/paginaList.dart';
import 'package:siap/models/componentes/iconos.dart';
import 'package:siap/models/translations.dart';
import 'consultation.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:strings/strings.dart';

class ConsultationInfo extends StatelessWidget {

  var datos;
  Color color;
  bool actual;

  ConsultationInfo({this.datos,this.color,this.actual});

  @override
  Widget build(BuildContext context) {
//    print('datos: $datos');
    String iconNom = datos['icon'];
    iconNom = iconNom.replaceAll('fa-', '');
    iconNom = camelize(iconNom);
    iconNom = iconNom.replaceAll('-', '');
    iconNom = '${iconNom[0].toLowerCase()}${iconNom.substring(1)}';

    double tamanoIcono = MediaQuery.of(context).size.width*.25;
    var icon = Container(
//      padding: EdgeInsets.only(top:tamanoIcono*.10,left: tamanoIcono*.15),
//      height: tamanoIcono,
//      width: tamanoIcono,
      child: Center(
//        heightFactor: tamanoIcono,
//        widthFactor: tamanoIcono,
        child: Icon(
          FA.icono[iconNom],
          size: tamanoIcono*.49,
          color: color,
        ),
      ),
    );

    return Pagina(
      esLista: false,
      drawer: false,
      elemento: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height*.01,),
            Text(
              datos['pName'].toUpperCase(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: MediaQuery.of(context).size.height*.03
              ),
            ),
            Text(
              datos['name'].toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height*.04
              ),
            ),
            Text(
              '${datos['initDate']} / ${datos['finishDate'].toUpperCase()}',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height*.02
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*.02,),
            SizedBox(
              height: tamanoIcono+10,
              width: tamanoIcono+10,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top:5,
                    left:5,
                    child: Image.asset(
                      'images/icons/fondoIcono.png',
                      width: tamanoIcono,
                    ),
                  ),
                  icon,
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height*.03,),
//            Text(
//              datos['description'],
//              textAlign: TextAlign.justify,
//            ),
            Html(
              data:'${datos['description']}',
              customTextAlign: (a) {
                return TextAlign.justify;
              },
            ),

            SizedBox(height: MediaQuery.of(context).size.height*.03,),
            actual?RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color:color,
                  width: 2
                ),
              ),
              onPressed: (){
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context)=>
                        Consultation(
                          datos: datos,
                          color: color,
                          actual: actual,
                        )
                    )
                );

              },
              color: Colors.white,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                            '${Translations.of(context).text('participate').toUpperCase()}',
                            style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ):
            Container(),
          ],
        ),
      ),
    );
  }
}

class Accion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

