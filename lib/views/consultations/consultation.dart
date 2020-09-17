import 'package:flutter/material.dart';
import 'package:siap/models/layout/paginaList.dart';
import 'package:siap/models/componentes/iconos.dart';
import 'package:siap/models/translations.dart';
import 'package:siap/views/surveys/surveys.dart';
import 'poll.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import 'package:siap/models/conexiones/api.dart';




class Consultation extends StatefulWidget {

  var datos;
  Color color;
  bool actual;

  Consultation({this.datos,this.color,this.actual});

  @override
  ConsultationState createState() => ConsultationState();
}

class ConsultationState extends State<Consultation> {


  @override
  Widget build(BuildContext context) {
//    print('datos: ${widget.datos}');

//    print('POLL: ${widget.datos['poll']}');

    double tamanoIcono = MediaQuery.of(context).size.width*.25;
    var icon = Container(
//      padding: EdgeInsets.only(top:tamanoIcono*.10,left: tamanoIcono*.15),
//      height: tamanoIcono,
//      width: tamanoIcono,
      child: Center(
//        heightFactor: tamanoIcono,
//        widthFactor: tamanoIcono,
        child: Icon(
          FA.icono[widget.datos['icon']],
          size: tamanoIcono*.49,
          color: widget.color,
        ),
      ),
    );

    var poll = widget.datos['poll'] != null ? widget.datos['poll']:'';
//    print('-- poll --');
//    print(poll);
//    print('length: ${poll.length}');

    return Pagina(
      esLista: false,
      drawer: false,
      elemento: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text(
              widget.datos['pName'].toUpperCase(),
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: MediaQuery.of(context).size.height*.03
              ),
            ),
            Text(
              widget.datos['name'].toUpperCase(),
              style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height*.04
              ),
            ),
            Text(
              '${widget.datos['initDate']} / ${widget.datos['finishDate'].toUpperCase()}',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height*.02
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*.02,),
//            DownloadMap(consultationId: widget.datos['id'],),
            Accion(
              color: Color(0xFF4068B2),
              height: MediaQuery.of(context).size.height*.1,
              texto: Translations.of(context).text('accmapandsurveys').toUpperCase(),
              icono: 'accCuestionarios',
              elemento: Surveys(
                consultationId: '${widget.datos['id']}',
                consultationName: 'aa',
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*.02,),
            Accion(
              color: Color(0xFF947BB8),
              height: MediaQuery.of(context).size.height*.1,
              texto: Translations.of(context).text('acccomplaints').toUpperCase(),
              icono: 'accQuejas',
              elemento: null,
              accion: envConsult,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*.02,),
            Accion(
              color: Color(0xFF4068B2),
              height: MediaQuery.of(context).size.height*.1,
              texto: Translations.of(context).text('accdocuments').toUpperCase(),
              icono: 'accDocs',
              elemento: null,
              accion: envConsult,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*.01,),
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(2),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5)
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(2),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5)
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*.81,
                  height: 2,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)
                  ),
                )
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*.01,),
            poll.length > 0?Poll(poll: poll,datos: widget.datos,):Container(),
          ],
        ),
      ),
    );
  }

  envConsult() async {
    var lang = ui.window.locale.languageCode;
    var code = widget.datos['description'];
//    print('http://paraguay.collabmap.in/${lang}/consultation/${code}');
    var url = '$urlHtml/consultations/?acc=consultation&consultationId=${widget.datos['id']}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class Accion extends StatefulWidget {

  Color color;
  double height;
  String texto;
  var elemento;
  String icono;
  var accion;

  Accion({
    this.color,
    this.height = 80,
    this.texto = '',
    this.elemento,
    this.icono = 'accCuestionarios',
    this.accion
  });

  @override
  AccionState createState() => AccionState();
}

class AccionState extends State<Accion> {

  bool activado = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 1,
          color: widget.color,
        )
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                  ),
                  child: Stack(
                    children: <Widget>[
                      Image.asset(
                        'images/flechaAcc.png',
                        fit: BoxFit.fill,
                        height: widget.height,
                        color: widget.color,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: widget.height * .06, left:widget.height * .1 ),
                        child: Image.asset(
                          'images/${widget.icono}.png',
                          height: widget.height*.9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.transparent,
                      width: 1,
                    )
                  ),
                  padding: EdgeInsets.only(top: 5,bottom: 5, left: 15, right: 15),
                  child: InkWell(
                    onTap: (){
                      if(widget.elemento != null){
                        setState(() {
                          activado = !activado;
                        });
                      }else{
                        widget.accion();
                      }
                    },
                    child: Text(
                      widget.texto,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: widget.height*.26,
                        color: widget.color,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          activado?(widget.elemento == null?Container():widget.elemento):Container(),
        ],
      ),
    );
  }
}
