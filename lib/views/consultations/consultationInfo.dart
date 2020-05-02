import 'package:flutter/material.dart';
import 'package:siap/models/layout/paginaList.dart';
import 'package:siap/models/componentes/iconos.dart';
import 'package:siap/models/translations.dart';
import 'consultation.dart';

class ConsultationInfo extends StatelessWidget {

  var datos;
  Color color;
  bool actual;

  ConsultationInfo({this.datos,this.color,this.actual});

  @override
  Widget build(BuildContext context) {
//    print('datos: $datos');


    double tamanoIcono = MediaQuery.of(context).size.width*.25;
    var icon = Container(
//      padding: EdgeInsets.only(top:tamanoIcono*.10,left: tamanoIcono*.15),
//      height: tamanoIcono,
//      width: tamanoIcono,
      child: Center(
//        heightFactor: tamanoIcono,
//        widthFactor: tamanoIcono,
        child: Icon(
          FA.icono[datos['icon']],
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
              '${datos['start_date']} / ${datos['slug'].toUpperCase()}',
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
            Text(
              datos['description'],
//              '''
//                When your desired layout feels too complex for Columns and Rows, AlignPositioned is a real life saver. Flutter is very composable, which is good, but sometimes it's unnecessarily complex to translate some layout requirement into a composition of simpler widgets.
//
//                The AlignPositioned aligns, positions, sizes, rotates and transforms its child in relation to both the container and the child itself. In other words, it lets you easily and directly define where and how a widget should appear in relation to another.
//
//                For example, you can tell it to position the top-left of its child at 15 pixels to the left of the top-left corner of the container, plus move it two thirds of the child's height to the bottom plus 10 pixels, and then rotate 15 degrees. Do you even know how to start doing this by composing basic Flutter widgets? Maybe, but with AlignPositioned it's much easier, and it takes a single widget.
//
//                Besides layout, AlignPositioned is specially helpful for explicit animations (those that use a controller), since you can just calculate the final position, size and rotation you want for each frame. Without it you may find yourself having to animate a composition of widgets.
//
//                Meanwhile, AnimatedAlignPositioned and AnimChain widgets are helpful for implicit animations, which are very easy to create. If you change their parameters they animate automatically, interpolating between the old and new parameter values.
//              ''',
              textAlign: TextAlign.justify,
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

