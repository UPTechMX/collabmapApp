import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/models/conexiones/api.dart';
import 'package:siap_monitoring/models/layout/iconos.dart';
import 'package:poly/poly.dart' as Poly;
import 'package:siap_monitoring/models/translations.dart';



class DrawerEdt extends StatefulWidget {

  GlobalKey<MapWidgetState> keyMapa = GlobalKey();
  Map question;
  var vId;

  DrawerEdt({
    this.keyMapa,
    this.question,
    this.vId
  });

  @override
  DrawerEdtState createState() => DrawerEdtState();
}

class DrawerEdtState extends State<DrawerEdt> {

  var estado;
  Poly.Polygon bound;

  @override
  Widget build(BuildContext context) {

//    print('north: ${widget.keyMapa.currentState.north}');
//    print('south: ${widget.keyMapa.currentState.south}');
//    print('east: ${widget.keyMapa.currentState.east}');
//    print('west: ${widget.keyMapa.currentState.west}');
    List<Poly.Point> puntosBounds = [];
    puntosBounds.add(Poly.Point(widget.keyMapa.currentState.north,widget.keyMapa.currentState.west));
    puntosBounds.add(Poly.Point(widget.keyMapa.currentState.north,widget.keyMapa.currentState.east));
    puntosBounds.add(Poly.Point(widget.keyMapa.currentState.south,widget.keyMapa.currentState.east));
    puntosBounds.add(Poly.Point(widget.keyMapa.currentState.south,widget.keyMapa.currentState.west));

    bound = Poly.Polygon(puntosBounds);

    void cerrarSesion() async{
      SharedPreferences userData = await SharedPreferences.getInstance();
      userData.remove('login');
      userData.remove('username');
      userData.remove('password');
      userData.remove('token');
      Navigator.pushReplacementNamed(context, 'login');
    }

    final logo = CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48,
      child: Image.asset('images/iuLogo.png'),
    );

    final drawerHelper = DrawerHeader(
      child: logo,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
    );

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          drawerHelper,
          Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: Text(
              Translations.of(context).text('geometries').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          FutureBuilder(
            future: getProblems(),
            builder: (context,snapshot){
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Text('Esperando resultados...');
                case ConnectionState.done:
                  if (snapshot.hasError){
                    return Text('Error: ${snapshot.error}');
                  }

                  print(snapshot.data);
                  int i = 0;
                  return Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
                      children: snapshot.data.map(
                          (problem){
                            return problema(problem:problem,index:problem['index']);
                          }
                      ).toList().cast<Widget>(),
                    ),
                  );
                default:
                  return Container();
              }

            },
          ),
        ],
      ),
    );
  }

  Future<List> getProblems() async {
    DB db = DB.instance;


    var ansId;
    var ans = await db.query("SELECT * FROM RespuestasVisita WHERE preguntasId = ${widget.question['id']} AND visitasId = ${widget.vId}");
    if(ans == null){
      Map<String,dynamic> dAns = Map();
      dAns['visitasId'] = widget.vId;
      dAns['preguntasId'] = widget.question['id'];
      dAns['valor'] = 'spatial';
      dAns['new'] = 1;
      ansId = await db.insert('RespuestasVisita', dAns, true);
      print('- - - - -aca- - - - -');
    }else{
      ansId = ans[0]['id'];
      print('- - - - - alla - - - -');
    }


    List problemsDB = await db.query('''SELECT * 
      FROM problems 
      WHERE respuestasVisitaId = ${ansId}
      AND (del != 1 OR del IS NULL)
    ''');
    problemsDB ??= [];
    List problems = [];


    for(int i = 0;i<problemsDB.length;i++){
      bool puntoDentro = false;
      List puntos = await db.query("SELECT * FROM points WHERE problemsId = ${problemsDB[i]['id']}");
      for(int j = 0;j<puntos.length;j++){

        Poly.Point punto = Poly.Point(puntos[j]['lat'],puntos[j]['lng']);
        if(bound.isPointInside(punto)){
          puntoDentro = true;
          break;
        }
      }
      Map<String, dynamic> problem = Map<String, dynamic>.from(problemsDB[i]);

      problem['index'] = i;

      if(puntoDentro){
        problems.add(problem);
      }

    }

    print('PROBLEMS: $problems');
    return problems;
  }

  Widget problema({Map problem,int index}){
    var icono;

    switch(problem['type']){
      case 'Marker':
        icono = Icon(Icons.location_on,color: Colors.grey[600],);
        break;
      case 'Polyline':
        icono = Icono(svgName: 'polyline',width: 35,color: Colors.grey[600],);
        break;
      case 'Polygon':
        icono = Icono(svgName: 'polygon',width: 35,color: Colors.black);
        break;
    }

    print('0000000------');
    bool editable = true;
//    print('PROBLEM: $problem, editableC: ${widget.keyMapa.currentState.widget.datos['edit_inputs']}');
//    if(!widget.keyMapa.currentState.widget.datos['edit_inputs']){
    if(!false){
      print('ENTRA ACA');
      if(problem['idServer'] != null){
        editable = false;
      }else{
        editable = true;
      }
    }

    Future<void> EditBtns({BuildContext context,String texto,int problemId,int problemIndex, String type}) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
//          title: Text('Point alert'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
//                  Center(
//                    child: Text(
//                      texto,
//                      style: TextStyle(fontWeight: FontWeight.bold),
//                    ),
//                  ),
                  FlatButton(
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        Translations.of(context).text('geometries').toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey
                        ),
                      ),
                    ),
                    color: Colors.white,
                    onPressed: (){
                      widget.keyMapa.currentState.setEdtProblem(
                        problemId: problem['id'],
                        problemIndex: index,
                        type: problem['type'],);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[200]
                      )
                    ),
                  ),
                  FlatButton(
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        Translations.of(context).text('general_info').toUpperCase(),
                        style: TextStyle(
                            color: Colors.grey
                        ),
                      ),
                    ),
                    color: Colors.white,
                    onPressed: (){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      widget.keyMapa.currentState.addProblem(context: context,edit: true,problem: problem,editable: editable);
                    },
                  ),
                ],
              ),
            ),

            actions: <Widget>[
              FlatButton(
                child: Text(Translations.of(context).text('close')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


    return Card(
      child: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(15),
        width: double.infinity,
        height: 60,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: icono,
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 5,
              child: Text(
                '${problem['name']}',
                style: TextStyle(
                  color: Colors.grey[600]
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.edit,
                  color: editable?Colors.grey[600]:Colors.transparent,
                ),
                onPressed: (){
                  if(editable){
                    EditBtns(
                      context: context,
                      texto: Translations.of(context).text('edit'),
                      problemId: problem['id'],
                      problemIndex: index,
                      type: problem['type'],
                    );
                  }
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.info,color: Colors.grey[600],),
                onPressed: (){
//                  print('click');
                  print('(context: $context,edit: true,problem: $problem,editable: $editable,fix: true)');
                  Navigator.of(context).pop();
                  widget.keyMapa.currentState.addProblem(context: context,edit: true,problem: problem,editable: editable,fix: false);
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.delete,
                  color: editable?Colors.grey[600]:Colors.transparent,
                ),
                onPressed: (){
                  if(editable){

                    emergente(
                      context: context,
                      content: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Center(
                                child: Icono(
                                  svgName: 'alerta',
                                  color: Color(0xFFDBBD3E),
                                  width: MediaQuery.of(context).size.height*.18,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.transparent
                                )
                              ),
                            ),
                            SizedBox(height: 5,),
                            Text(
                              Translations.of(context).text('confdelete').toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                      ),
                      actions: [
                        FlatButton(
                          child: Text(Translations.of(context).text('cancel')),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text(Translations.of(context).text('confirm')),
                          onPressed: () {
                            DB db = DB.instance;
                            widget.keyMapa.currentState.delProblem(problem: problem,index: index);
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                        ),
                      ]

                    );

                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}

