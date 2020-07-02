import 'package:flutter/material.dart';
import 'package:siap/views/contestaCuestionario/bloques.dart';
import 'package:siap/views/contestaCuestionario/areas.dart';
import 'package:siap/views/contestaCuestionario/pregunta.dart';
import 'package:siap/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap/models/cuestionario/checklist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:siap/models/conexiones/DB.dart';


class General extends StatefulWidget{

  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<PreguntasContState> keyPreguntas;
  GlobalKey<PreguntaState> keyPregunta;

  Checklist chk;
  String bId;
  String aId;
  String pId;


  General({
    Key key,
    this.chk,
    this.keyPreguntas,
    this.keyAreas,
    this.keyBloques,
    this.keyPregunta,
    this.bId,
    this.aId,
    this.pId
  }):super(key:key);

  @override
  GeneralState createState() => GeneralState(chk:chk);

}

class GeneralState extends State<General>{

  Checklist chk;

  TextEditingController horaControlador = TextEditingController();
  var horaChange;
  TextEditingController resumenControlador = TextEditingController();
  var resumenChange;

  var fechaChange = null;
  DateTime fecha;
  var formatter = new DateFormat('yyyy-MM-dd');

  TimeOfDay hora;

  GeneralState({this.chk});


  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List>(
      future:getDatosGral() ,
      builder: (context,snapshot){
        if(!snapshot.hasData) return Center(child: Text('No se encontraron datos.'));
        return Column(
          children: snapshot.data.map(
              (data) {
//                print(data['fechaRealizacion']);
                if(data['fechaRealizacion'] != null){
                  var f = data['fechaRealizacion'].split('-');
                  if(data['fechaRealizacion'] != null && f[0] != null && f[1] != null && f[2] != null){
                    fecha = fechaChange == null?DateTime(int.parse(f[0]),int.parse(f[1]),int.parse(f[2])):fechaChange;
                  }else{
                    fecha = DateTime.now();
                  }
                }else{
                  fecha = fechaChange == null?DateTime.now():fechaChange;
                }
                if(data['horaRealizacion'] != null){
                  var h = data['horaRealizacion'].split(':');
                  hora = horaChange == null?TimeOfDay(hour: int.parse(h[0]), minute: int.parse(h[1])):horaChange;
                }else{
                  hora = horaChange == null?TimeOfDay.now():horaChange;
                }
//                hora = horaChange == null?TimeOfDay(hour: 10, minute: 00):

                resumenControlador = TextEditingController(text:resumenChange == null?data['resumen']:resumenChange);
//                horaControlador = TextEditingController(text:horaChange == null?data['horaRealizacion']:horaChange);
                return Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      fechaHora(),
                      resumen(),
                      botonesContinuar(),
                    ],
                  ),
                );
              }
          ).toList(),
        );
      },

    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: fecha,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != fecha)
      setState(() {
        fechaChange = picked;
      });
  }

  Future<Null> _selectTime(BuildContext context) async {

    final TimeOfDay hpicked = await showTimePicker(
      context: context,
      initialTime: hora,
    );
    if (hpicked != null)
      setState(() {
        horaChange = hpicked;
      });
  }



  fechaHora(){
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Text(
                'Fecha',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(''),
            ),
            Expanded(
              flex: 5,
              child: Text(
                'Hora',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Row(
                children: <Widget>[
                  Text(formateaFecha(fecha)),
                  SizedBox(height: 20.0,),
                  IconButton(
                    icon: Icon(Icons.event),
                    onPressed: () => _selectDate(context),
                  ),

                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(''),
            ),
            Expanded(
              flex: 5,
              child:Row(
                children: <Widget>[
                  Text(formateaHora(hora)),
                  SizedBox(height: 20.0,),
                  IconButton(
                    icon:Icon(Icons.timer),
                    onPressed: () => _selectTime(context),
                  )
                ],
              ),
            ),
          ],
        ),

      ],
    );
  }

  resumen(){
    return Container(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              'Resumen',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            child: TextField(
              keyboardType: TextInputType.text,
              controller: resumenControlador,
              autofocus: false,
              onChanged: (text){
                resumenChange = text;
              },
            ),
          )
        ],
      ),
    );

  }

  botonesContinuar(){
    return Container(
      padding: EdgeInsets.only(top:50),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 5,
              child: Container(width: 0,height: 0,)
          ),
          Expanded(
            flex: 1,
            child: Text(''),
          ),
          Expanded(
            flex: 5,
            child: RaisedButton(
              color: Colors.blue,
              child: Text(
                'Continuar',
              ),
              onPressed: (){
                aPregs();
              },
            ),
          ),
        ],
      ),
    );
  }


  Future<List> getDatosGral() async {

    var datos = await chk.datosVisita(true);

    List list = [];

    list.add(datos);

    return list;

  }

  aPregs() async {
    var db = DB.instance;


    Map r = new Map();
    r['fechaRealizacion'] = formateaFecha(fecha);
    r['horaRealizacion'] = formateaHora(hora);
    r['resumen'] = resumenControlador.text;
    r['id'] = chk.vId;

    SharedPreferences userData = await SharedPreferences.getInstance();
    int usrId;
    if(userData.getBool('login') != null){
      usrId = userData.getInt('userId');
    }



    String sql = '''
      UPDATE Visitas SET 
        resumen = "${r['resumen']}",
        offline = 1
        WHERE id = ${r['id']}
    ''';

//    sql = 'DELETE FROM RespuestasVisita WHERE visitasId = ${r['id']}';
//    print(sql);

    db.query(sql);


    widget.keyPreguntas.currentState.cambiaPagina('preguntas');
//    print(r);

  }

  formateaFecha(fecha){
    return "${formatter.format(fecha)}";
  }

  formateaHora(hora){
    return '${hora.hour}:${hora.minute.toString().padLeft(2,'0')}';
  }

}