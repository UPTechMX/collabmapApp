import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'dart:io';
import 'dart:math';
import 'catSel.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'barrita.dart';
import 'barraEdtProblema.dart';
import 'package:siap/models/translations.dart';
import 'package:poly/poly.dart' as Poly;
import 'package:siap/models/layout/iconos.dart';
import 'package:extended_math/extended_math.dart';
import 'package:siap/views/maps/botones.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:siap/models/conexiones/api.dart';


class MapWidget extends StatefulWidget {

  Map datos;
  File tiles;
  List problems = [];
  bool spatial;
  var question;
  Map spatialData;
  var vId;

  MapWidget({
    Key key,
    this.datos,
    this.tiles,
    this.problems,
    this.spatialData,
    this.spatial = true,
    this.question,
    this.vId,
  }):super(key:key);

  @override
  MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {

  GlobalKey<BarritaEdtProblemaState> keyBarraEdtProblema = GlobalKey();
  GlobalKey<BotonesBarraState> keyBotones = GlobalKey();

  var conexion;

  Map datos;
  String actividad = null;
  String actVentana = null;
  String photo = null;

  bool recentrar = false;
  LatLng newCentro;

  Poly.Polygon poly;

  double north;
  double south;
  double east;
  double west;
  LatLng center;

  int problemEdtId;
  int problemEdtIndex;
  int markerEdtId;
  int markerEdtIndex;
  String typeEdt;
  bool edtGral = false;
  LatLng latlngOld;
  bool centerEdt = true;
  var markerEdt;


  MapController _mapctl = MapController();

  TextEditingController inputController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String inputChange;
  var catId;

  List<LatLng> puntoUbicArr = [];
  List<LatLng> tappedPoints = [];
  List<LatLng> tappedPlPoints = [];
  List<LatLng> tappedPgPoints = [];
  List<LatLng> tappedPgPointsL = [];
  List<LatLng> marcadorEditando = [];

  @override
  Widget build(BuildContext context) {


    if(recentrar){
      center = newCentro;
      recentrar = false;
    }

    double zoom = 13;

    List poligonos = widget.spatialData['studyareas'];
    double n = -360;
    double s = 360;
    double e = -360;
    double w = 360;

//    print("POLIGONOS: $poligonos");
    List<Poly.Point> puntosPoligono = [];
    List polygons = <Polygon>[];
    for(int j = 0; j<poligonos.length; j++){
      var geometry = jsonDecode(poligonos[j]['geometry']);
      var poligono = geometry['coordinates'];
//      print('POLIGONO: $poligono');
      for(int k = 0;k<poligono.length;k++){
        List subPoligono = poligono[k];
        List subPolygonPoints = <LatLng>[];

        for(int i = 0;i<subPoligono.length;i++){
          n = max(n,subPoligono[i][1]);
          s = min(s,subPoligono[i][1]);
          e = max(e,subPoligono[i][0]);
          w = min(w,subPoligono[i][0]);
          subPolygonPoints.add(LatLng(subPoligono[i][1], subPoligono[i][0]));
          Poly.Point punto = Poly.Point(subPoligono[i][1],subPoligono[i][0]);
          puntosPoligono.add(punto);
        }

        Polygon polygon = Polygon(
          points: subPolygonPoints,
          color: Color.fromARGB(110 , 125, 124, 128),
        );
        polygons.add(polygon);
      }
    }

    var latC = (n+s)/2;
    var lngC = (w+e)/2;
//    print([latC,lngC]);

    center ??= LatLng(
      latC,
      lngC,
    );


//    print([n,s,w,e]);

    poly = Poly.Polygon(puntosPoligono);


    List markersProblems = <Marker>[];
    List polylinesProblems = <Polyline>[];
    List polygonProblems = <Polygon>[];

    // TODO problema con los puntos.
    for(int j = 0; j<widget.problems.length;j++){
      Map problem = widget.problems[j];
      List points = <LatLng>[];
      for(int k = 0; k<widget.problems[j]['points'].length;k++){
        points.add(widget.problems[j]['points'][k]['latLng']);
      }
      switch(problem['type']){
        case 'Marker':
//          print('AAAA');
          markersProblems.add(
              Marker(
                width: 40.0,
                height: 40.0,
                point: points[0],
                anchorPos: AnchorPos.align(AnchorAlign.top),
                builder: (ctx) => Container(
                    child:GestureDetector(
                      child: Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.purple,
                      ),
                    )
                ),
              )
          );
          print('POINTSSS: $points');
          break;
        case 'Polyline':
          if(points != null){
//            print('points');
//            print(points);
            polylinesProblems.add(
                Polyline(
                  points: points,
                  strokeWidth: 4.0,
                  color: Colors.purple.withOpacity(.8),
                )
            );
          }
          break;
        case 'Polygon':
          if(points != null){
//            print(prbPoints);
            polygonProblems.add(
                Polygon(
                  points: points,
                  color: Colors.purple.withOpacity(.7),
                )
            );
          }
          break;
      }
    }
    var PolylineProblemLayer = PolylineLayerOptions(
      polylines: polylinesProblems,
    );
    var PolygoneProblemLayer = PolygonLayerOptions(
      polygons: polygonProblems,
    );

    List marcadoresEdt = <Marker>[];
    if(edtGral){
      for(int i = 0;i<widget.problems.length;i++){
        var problem = widget.problems[i];
//        print('problemId: ${problem['id']}, problemEdtId: $problemEdtId');
        if(problem['id'] != problemEdtId){
          continue;
        }
        List points = problem['points'];
        if(points != null){
          for(int j = 0;j<points.length;j++){
            Marcador marcador = Marcador(
              keyMapa: widget.key,
              latlng: points[j]['latLng'],
              fatherIndex: i,
              type: problem['type'],
              fatherId: problem['id'],
              index: j,
              id: points[j]['id'],
              icono: typeEdt != 'Marker'?Icono(svgName: 'circulo',):null,
              color : typeEdt != 'Marker'?Colors.red:null,
              pos : typeEdt != 'Marker'?AnchorPos.align(AnchorAlign.center):null,
              width : typeEdt != 'Marker'?25:null,
              height : typeEdt != 'Marker'?25:null,
            );
            marcadoresEdt.add(marcador.marker);
          }
        }
      }
    }
    var layerMarcadoresEdt = MarkerLayerOptions(markers: marcadoresEdt);

    List marcadorEdt = <Marker>[];
//    marcadoresEdt.add(Text('aaa'));

    Marcador marcador;
    MarkerLayerOptions layerMarcadorEditando;
    if(marcadorEditando.length > 0){
      marcador = Marcador(
        keyMapa: widget.key,
        latlng: marcadorEditando[0],
        icono: Icono(svgName: 'circulo',color: Colors.red,),
        color : Colors.red,
        pos : AnchorPos.align(AnchorAlign.center),
        width : 25,
        height : 25,
      );
      layerMarcadorEditando = MarkerLayerOptions(markers: [marcador.marker]);
    }else{
      layerMarcadorEditando = MarkerLayerOptions(markers: []);
    }


    int numPoints = 0;
    var markers = tappedPoints.map((latlng) {
      var color;
      var icono;
      var pos;
      double width;
      double height;
//      print('ACTIVIDAD: $actividad');
      switch(actividad){
        case 'addMarker':
          color = Colors.purple;
          icono = null;
          pos = null;
          width = null;
          height = null;

          break;
        default:
          icono = Icono(svgName: 'circulo',);
          color = Colors.white;
          pos = AnchorPos.align(AnchorAlign.center);
          width = 15;
          height = 15;
          break;
      }

      Marcador marker = Marcador(
        index: numPoints++,
        latlng: latlng,
        type: 'point',
        fatherIndex: 0,
        color: color,
        icono: icono,
        pos: pos,
        width: width,
        height: height,
      );

      return marker.marker;
    }).toList();

    var miUbic = puntoUbicArr.map((latlng) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: latlng,
        anchorPos: AnchorPos.align(AnchorAlign.center),
        builder: (ctx) => Container(
            child:GestureDetector(
              child: Icono(svgName: 'punto',color: Color(0xFF222e99),),
            )
        ),
      );
    }).toList();

    List<LatLng> PlPoints = tappedPlPoints.map((latlng){
      return latlng;
    }).toList();
    var polyline = PolylineLayerOptions(
      polylines: [
        Polyline(
          points: PlPoints,
          strokeWidth: 4.0,
          color: Colors.purple.withOpacity(.8),
        ),
      ],
    );

    List<LatLng> PgPointsL = tappedPgPointsL.map((latlng){
      return latlng;
    }).toList();
    var polygonL = PolylineLayerOptions(
      polylines: [
        Polyline(
          points: PgPointsL,
          strokeWidth: 4.0,
          isDotted: false,
          color: Colors.lightBlue.withOpacity(.8),
        ),
      ],
    );

    PolylineLayerOptions polygonLC = PolylineLayerOptions();
    if(PgPointsL.length != 0){
      polygonLC = PolylineLayerOptions(
        polylines: [
          Polyline(
            points: [PgPointsL[0],PgPointsL.last],
            strokeWidth: 4.0,
            isDotted: true,
            color: Colors.lightBlue.withOpacity(.8),
          ),
        ],
      );
    }

    List<LatLng> PgPoints = tappedPgPoints.map((latlng){
      return latlng;
    }).toList();
    var polygon = PolygonLayerOptions(
      polygons: [
        Polygon(
          points: PgPoints,
          color: Colors.purple.withOpacity(.7),
        ),
      ],
    );
    Widget barrita = Container(width: 0,height: 0,);
//    print('ACTIVIDAD!!!! : $actividad, edtGral: $edtGral, type: $typeEdt');
    if(actividad != null && (tappedPlPoints.length > 0 || tappedPgPoints.length > 0) ){

      barrita = Barrita(
        undo: undo,
        actividad: actividad,
        aceptar: addProblem,
      );
    }else if(actividad == 'addMarker'){
      barrita = Barrita(
        actividad: actividad,
        iconoUndo: Icon(
          Icons.cancel,
          color: Colors.grey,
          size: 30,
        ),
        undo: (){
          actividad = null;
          delPuntos();
        },
        aceptar: addProblem,
      );
    }else if(edtGral && (actividad == null || actividad == 'delMarker' || actividad == 'addMarkerPrb')){
      barrita = BarritaEdtProblema(
        key: keyBarraEdtProblema,
        aceptar: finalizarEdt,
        addPunto: setActividad,
        delPunto: setActividad,
        type: typeEdt,
      );
    }else if(actividad == 'edtMarker'){
//      print('o este');
      barrita = BarritaEdtProblema(
        key: keyBarraEdtProblema,
        aceptar: okEdtMarker,
        cancelar: (){
          undoEdtMarker(eGral: true);
        },
        addPunto: setActividad,
        delPunto: setActividad,
        type: 'Marker',
      );
    }


    return Center(
      child:Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
              child: barrita,
            ),
            Flexible(
              child: FlutterMap(
                mapController: _mapctl,
                options: MapOptions(
                  center: center,
                  minZoom: 10,
                  maxZoom: 17.0,
                  zoom: 12,
//                  swPanBoundary: LatLng(s, w),
//                  nePanBoundary: LatLng(n, e),
                  onTap: (latlng){
                    actividadFncTap(latlng: latlng,context: context);
                  },
                  onPositionChanged: (pos,a){
                    if(a){
                      center = pos.center;
                    }

                    LatLng latlng = center;
                    actividadFncDrag(latlng: latlng,context: context);

                    north = pos.bounds.north;
                    south = pos.bounds.south;
                    east = pos.bounds.east;
                    west = pos.bounds.west;

                  },
                ),
                layers: [

                  widget.tiles == null?
                  TileLayerOptions(
                      urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']):
                  TileLayerOptions(
                      tileProvider: MBTilesImageProvider.fromFile(widget.tiles),
                      maxZoom: 17.0,
                      backgroundColor: Colors.white,
                      tms: true),
                  PolygonLayerOptions(
                    polygons: polygons,
                  ),
                  polyline,
                  polygon,
                  polygonL,
                  polygonLC,
                  PolylineProblemLayer,
                  PolygoneProblemLayer,
                  MarkerLayerOptions(markers: markersProblems),
                  MarkerLayerOptions(markers: markers),
                  MarkerLayerOptions(markers: miUbic),
                  layerMarcadoresEdt,
                  layerMarcadorEditando,
                ],
              ),
            ),
            BotonesBarra(
              key: keyBotones,
              keyMapa: widget.key,
              context: context,
              spatial: widget.spatial,
            ),
            !widget.spatial?
            RaisedButton(
              color: Colors.grey[400],
              child: Text(
                Translations.of(context).text('finish_map').toUpperCase(),
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ):
            Container(),

          ],
        ),
      ),
    );
  }

  delPuntos({bool finEdt = true}){
    if(latlngOld != null){
      undoEdtMarker(eGral: false);
    }
    if(finEdt){
      finalizarEdt(delActividad: false);
    }
    setState(() {
      tappedPoints = [];
      tappedPlPoints = [];
      tappedPgPoints = [];
      tappedPgPointsL = [];
    });

    keyBotones.currentState.actualizaEstado();
  }

  setActividad(String act){
    setState(() {
      actividad = act;
    });
    delPuntos(finEdt: false);
    photo = null;
  }

  void actividadFncDrag({LatLng latlng, BuildContext context}){

    actVentana = actividad;
    latlng ??= center;
    Poly.Point punto = Poly.Point(latlng.latitude,latlng.longitude);
    bool inside = poly.isPointInside(punto);

//    print('QUITAR el true de abajo y cambiar este chequeo a otro lugar');
//    if(inside || true){
    switch(actividad){
      case 'addMarker':
        setState(() {
          tappedPoints = [center];
        });
        break;
      case 'edtMarker':
        widget.problems[problemEdtIndex]['points'][markerEdtIndex]['latLng'] = latlng;
        setState((){
          actividad = 'edtMarker';
//            print('typeEdt: $typeEdt');
          if(typeEdt != 'Marker'){
            marcadorEditando = [latlng];
          }
        });
        break;
    }
//    }else{
//      Alert(context: context,texto: Translations.of(context).text('outside_the_polygon'));
//    }
  }

  void actividadFncTap({LatLng latlng, BuildContext context}){

    actVentana = actividad;
    latlng ??= center;
    Poly.Point punto = Poly.Point(latlng.latitude,latlng.longitude);
    bool inside = poly.isPointInside(punto);

    if(inside){
      switch(actividad){
        case 'addMarker':
          setState(() {
            tappedPoints = [center];
          });
          break;
        case 'addPolyline':
          setState(() {
            tappedPlPoints.add(latlng);
            tappedPoints.add(latlng);
          });
          break;
        case 'addPolygon':
          bool intersect = revisaIntersect(polygon: tappedPgPoints,latlng: latlng);
          if(!intersect){
            setState(() {
              tappedPgPoints.add(latlng);
              tappedPgPointsL.add(latlng);
              tappedPoints.add(latlng);
            });
          }else{
            Alert(context: context,texto: Translations.of(context).text('polygon_intersects'));
          }
          break;
//        case 'edtMarker':
//          latlngOld ??= widget.problems[problemEdtIndex]['points'][markerEdtIndex]['latLng'];
//          widget.problems[problemEdtIndex]['points'][markerEdtIndex]['latLng'] = latlng;
////          updMarker(latlang: latlng);
//          setState(()=>actividad = 'edtMarker');
//          break;
        case 'addMarkerPrb':
          addMarkerPrb(latlng);
          break;
      }
    }else{
      if(actividad != null){
        Alert(context: context,texto: Translations.of(context).text('outside_the_polygon'));

      }
    }
  }

  revisaIntersect({List polygon,var latlng = null}){
    List<LatLng> nPolygon = [];
    for(int i = 0;i<polygon.length;i++){
      nPolygon.add(polygon[i]);
    }
    if(latlng != null){
      nPolygon.add(latlng);
    }

    if(nPolygon.length <4){
      return false;
    }

    List<List<Vector>> segmentos = [];
    for(int i = 1; i<nPolygon.length; i++){
      Vector vf = Vector(<num>[nPolygon[i].latitude,nPolygon[i].longitude]);
      Vector vi = Vector(<num>[nPolygon[i-1].latitude,nPolygon[i-1].longitude]);
      segmentos.add([vf,vi]);
    }

    segmentos.add([Vector(<num>[nPolygon.last.latitude,nPolygon.last.longitude]),Vector(<num>[nPolygon[0].latitude,nPolygon[0].longitude])]);

    for(int i = segmentos.length-1;i>0;i--){
      var s1 = segmentos[i];
      for(int j = i-1;j>=0;j--){
        var s2 = segmentos[j];
//        print('i: $i, j:$j');
        bool intersect = lineSegmentsIntersect(s1[0], s1[1], s2[0], s2[1]);
        if(intersect){
          return true;
        }
      }
    }
    return false;
  }

  double determinant(Vector vector1, Vector vector2) {
    double det = vector1.itemAt(1) * vector2.itemAt(2) - vector1.itemAt(2) * vector2.itemAt(1);
    return det;
  }

  bool lineSegmentsIntersect(Vector segment1_Start, Vector segment1_End, Vector segment2_Start, Vector segment2_End) {
    double det = determinant(segment1_End - segment1_Start, segment2_Start - segment2_End);
    double t = determinant(segment2_Start - segment1_Start, segment2_Start - segment2_End) / det;
    double u = determinant(segment1_End - segment1_Start, segment2_Start - segment1_Start) / det;
//    print('t:$t, u:$u');
    return (t > 0) && (u > 0) && (t < 1) && (u < 1);
  }

  addMarkerPrb(LatLng latlng) async {
    DB db = DB.instance;
    Map datPunto = Map<String,dynamic>();
    datPunto['lat'] = latlng.latitude;
    datPunto['lng'] = latlng.longitude;
    datPunto['problemsId'] = problemEdtId;
    int id = await db.insert('points', datPunto,false);

    Map pTmp = Map<String,dynamic>();
    pTmp['id'] = id;
    pTmp['latLng'] = latlng;
    widget.problems[problemEdtIndex]['points'].add(pTmp);
    setState(()=>actividad = null);
    keyBarraEdtProblema.currentState.setAct(null);
  }

  updMarker({LatLng latlang}){
    DB db = DB.instance;
    var lat = latlang.latitude;
    var lng = latlang.longitude;

    db.query('UPDATE points SET lat = $lat, lng = $lng WHERE id = $markerEdtId');

  }

  centrar({var lat, var lng, bool ubic = true, bool makeZoom = true}){
    print('centrar - lat:$lat,lng:$lng, ubic: $ubic, makeZoom: $makeZoom ');
    LatLng centro = LatLng(lat,lng);
    double zoom;
    if(makeZoom){
      zoom = 17;
    }else{
      zoom = _mapctl.zoom;
    }
    _mapctl.move(centro, zoom);
    setState(() {
      if(ubic){
        puntoUbicArr = [];
        puntoUbicArr.add(centro);
//        print(puntoUbicArr);
      }
    });

  }

  Future<void> addProblem({BuildContext context, bool edit = false,Map problem,bool editable = true,bool fix = false}) async {

    inputController = TextEditingController(text:null);
    nameController = TextEditingController(text:null);
    bool ya = false;

    bool apareceDraft;
//    if(widget.datos['edit_inputs']){
    if(false){
      apareceDraft = false;
    }else{
      apareceDraft = true;
    }

    if(actividad == 'addMarker'){
      LatLng latlng = center;
      Poly.Point punto = Poly.Point(latlng.latitude,latlng.longitude);
      bool inside = poly.isPointInside(punto);

      if(!inside){
        Alert(context: context,texto: Translations.of(context).text('outside_the_polygon'));
        return '';
      }
    }



    if(edit && !ya){
      ya = true;
      inputController = TextEditingController(text:problem['description']);
      nameController = TextEditingController(text:problem['name']);
      catId = problem['categoriesId'];
      photo = problem['photo'];
      print('CATID: $catId');
    }

    DB db = DB.instance;
//    print('PREGUNTA: ${widget.question}');
    List cats = await db.query('''
      SELECT c.* 
      FROM Categories c
      WHERE c.preguntasId = ${widget.question['id']} 
    ''');

    cats ??= [];

//    print('CATS $cats');
    var ansId;

    var ans = await db.query("SELECT * FROM RespuestasVisita WHERE visitasId = ${widget.vId} AND preguntasId = ${widget.question['id']}");
//    print('------ ANS $ans ---------');
    if(ans == null){
      Map<String,dynamic> dAns = Map();
      dAns['visitasId'] = widget.vId;
      dAns['preguntasId'] = widget.question['id'];
      dAns['respuesta'] = 'spatial';
      dAns['new'] = 1;

      ansId = await db.insert('RespuestasVisita', dAns, true);
//      print('-=-=-=-=-=-=-=-=-=-=-=-=-=-=ANS CREADO $ansId');

    }else{
      ansId = ans[0]['id'];
    }

    print('ANSID: $ansId');

    if(!widget.spatial){
      if(nameController.text == ''){
        var cuantos = await db.query('SELECT COUNT(*) as cuantos FROM problems WHERE respuestasVisitaId = ${ansId}');
        nameController = TextEditingController(text: '${Translations.of(context).text('problem')}_${cuantos[0]['cuantos'] + 1}');
      }

      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  editable?
                  Container(width: 0,height: 0,):
                  Text(
                    Translations.of(context).text('not_editable'),
                    style:TextStyle(color: Colors.grey),
                  ),
                  Text(
                    Translations.of(context).text('name').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17
                    ),
                  ),
                  !fix?
                  TextField(
                    maxLines: 1,
                    decoration: InputDecoration(
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF2568D8),
                                width: 1
                            )
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: Translations.of(context).text("describe"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )
                    ),
                    controller: nameController,
                    onChanged: (text){
                      inputChange = text;
                    },
                  ):
                  Text(nameController.text),
                  SizedBox(height: 20,),
                  Text(
                    Translations.of(context).text('describeproblem').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17
                    ),
                  ),
                  !fix?
                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF2568D8),
                                width: 1
                            )
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: Translations.of(context).text("describe"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )
                    ),
                    controller: inputController,
                    onChanged: (text){
                      inputChange = text;
                    },
                  ):
                  Text(inputController.text),
                  Container(height: 20,),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.transparent,
                            width: 1
                        )
                    ),
                    child: Text(
                      Translations.of(context).text('category').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2568D8),
                      ),
                    ),
                  ),
                  CatSel(
                    cats: cats,
                    setCat: setCat,
                    edit:edit,
                    catId: problem == null?0:problem['categoriesId'],
                    fix: fix,
                  ),
                  Container(height: 30,),
                  BtnPhotos(
                    photo:photo,
                    setPhoto:setPhoto,
                    editable: editable,
                    fix: fix,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  Translations.of(context).text(!fix?'cancel':'close'),
                ),
                onPressed: () {
//                print(actVentana);
                  Navigator.of(context).pop();
                  fncCancel(actVentana);
                },
              ),
              apareceDraft && !fix?FlatButton(
                child: Text(Translations.of(context).text('save_draft')),
                onPressed: (){
                  String input = inputController.text;
                  String name = nameController.text;
                  bool allOk = true;
                  if(input.length < 3){
                    allOk = false;
                    Alert(context: context,texto: Translations.of(context).text('string_size'));
                  }
                  if(name.length < 3){
                    allOk = false;
                    Alert(context: context,texto: Translations.of(context).text('string_size'));
                  }
                  if(catId == null && allOk){
                    allOk = false;
                    Alert(context: context,texto: Translations.of(context).text('cat_not_null'));
                  }

                  if(allOk){
                    Navigator.of(context).pop();
                    print('aaa');
                    fncSend(actVentana:actVentana,edit:edit,id:problem == null?0:problem['id'],draft: true);
                  }
                },
              ):
              Container(width: 0,height: 0,),
              editable && !fix?FlatButton(
                child: Text(Translations.of(context).text('send')),
                onPressed: () {
//                print(actVentana);
                  String input = inputController.text;
                  bool allOk = true;

                  if(input.length < 3){
                    allOk = false;
                    Alert(context: context,texto: Translations.of(context).text('string_size'));
                  }
                  if(catId == null && allOk){
                    allOk = false;
                    Alert(context: context,texto: Translations.of(context).text('cat_not_null'));
                  }

                  if(allOk){
                    Navigator.of(context).pop();
                    if(edit && problem != null && problem['draft'] == 1){
//                    print('aaaaaa $allOk');
//                    problem['draft'] = null;
                    }
                    print('(actVentana:$actVentana,edit:$edit,id:${problem == null?0:problem['id']},draft: ${false},question: ${widget.question},answer_id: $ansId)');
                    print('bbb');
                    fncSend(actVentana:actVentana,edit:edit,id:problem == null?0:problem['id'],draft: false,question: widget.question,answer_id: ansId);
                  }

                },
              ):Container(width:0,height:0),
            ],
          );
        },
      );
    }else{

      Map aaa = {'actVentana':actVentana,'edit':edit,'id':problem == null?0:problem['id'],'draft': false,'question': widget.question,'answer_id': ansId};
      print(aaa);
      print('ccc');
      fncSend(actVentana:actVentana,edit:edit,id:problem == null?0:problem['id'],draft: false,question: widget.question,answer_id: ansId);

        // TODO: ESTO ESTÁ GENERANDO PROBLEMAS CON EL WIDGET
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Translations.of(context).text('confirmed')),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(Translations.of(context).text('data_saved')),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  Translations.of(context).text('close'),
                ),
                onPressed: () {
//                print(actVentana);
                  Navigator.of(context).pop();
//                  fncCancel(actVentana);
                },
              ),
              Container(width: 0,height: 0,),
            ],
          );
        },
      );

    }

  }

  Future<void> Alert({BuildContext context,String texto}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
//          title: Text('Point alert'),
          content: SingleChildScrollView(
            child: Center(
              child: Text(texto),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(Translations.of(context).text("ok")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void fncCancel(String actVentana){
    String input = inputController.text;
    delPuntos();
    setState(() {
      actividad = null;
    });
    catId = null;
  }

  void fncSend({String actVentana,bool edit = false,int id,bool draft = true,Map question,int answer_id}) async {
    DB db = DB.instance;
    print('EDIT $edit');

    var connectivityResult = await (Connectivity().checkConnectivity());
    var cType = connectivityResult.toString().split('.')[1];

    SharedPreferences userData = await SharedPreferences.getInstance();
    String sendProblemsSettings = userData.getString('sendProblems');


//    print('actVentana: $actVentana, edit: $edit, id: $id, draft:$draft');

    String input = inputController.text;
    String name = nameController.text;
//    print('ActVentana : $actVentana');

    print('AnswerId: $answer_id');

    Map problemDat = Map<String,dynamic>();


    problemDat['categoriesId'] = catId;
    problemDat['description'] = input;
    problemDat['name'] = name;
    problemDat['respuestasVisitaId'] = answer_id;
//    print('PHOTOOOOO: $photo');
    problemDat['photo'] = photo;
//    problemDat['draft'] = draft?1:null;
    problemDat['edit'] = edit;


//    print(problemDat);
//    print(question);
//    print("- - - - - - - - - - -ACAAAAAA- - - - - - - - - - - - -");

//    print(problemDat);
    switch(actVentana){
      case 'addMarker':
        problemDat['type'] = 'Marker';
        break;
      case 'addPolyline':
        problemDat['type'] = 'Polyline';
        break;
      case 'addPolygon':
        problemDat['type'] = 'Polygon';
        break;
    }

//    print('EDIT : $edit');
    if(edit){
      print('edit');
      problemDat['id'] = id;
      String draftDB = !draft?', draft = NULL':'';

      String sql = '''
        UPDATE problems 
        SET categoriesId = '${problemDat['categoriesId']}', description= '${problemDat['description']}',name = '${problemDat['name']}',
        respuestasVisitaId = '${answer_id}', photo = ${problemDat['photo']==null?'NULL':"'${problemDat['photo']}'"},
        edit = ${problemDat['edit']?1:'NULL'} $draftDB
        WHERE id = ${problemDat['id']}   
        ''';

//      print('SQL : $sql');
      await db.query(sql);
//      await db.replace('problems', problemDat);
    }else{
//      print('NVO: ${question}');
      if(question['tipo'] == 'spatial' || question['tipo'] == 'op'){
        await db.query('DELETE FROM problems WHERE respuestasVisitaId = $answer_id');
      }
      print('problemDat: $problemDat');
      id = await db.insert('problems', problemDat,true);
      print('ID: $id');
    }

    var problems = await db.query("SELECT * FROM Problems");
//    print('Problems:${problems}');

    Map prb = Map();
    Map pointsDat = Map<String,dynamic>();
    pointsDat['problemsId'] = id;
    switch(actVentana){
      case 'addMarker':
        prb['type'] = 'Marker';
        Map tmp = Map<String,dynamic>();
        prb['points'] = [];
        if(tappedPoints.length>0){
          pointsDat['lat'] = tappedPoints[0].latitude;
          pointsDat['lng'] = tappedPoints[0].longitude;
          print('pointsDat: $pointsDat');

          int id = await db.insert('points', pointsDat,false);
          tmp['latLng'] = tappedPoints[0];
          tmp['id'] = id;
          prb['points'].add(tmp);
        }
//        print(prb['points']);
        break;
      case 'addPolyline':
        prb['type'] = 'Polyline';
        prb['points'] = [];
        for(int i = 0; i<tappedPlPoints.length;i++){
          pointsDat['lat'] = tappedPlPoints[i].latitude;
          pointsDat['lng'] = tappedPlPoints[i].longitude;
          int id = await db.insert('points', pointsDat,false);
          Map tmp = Map<String,dynamic>();
          tmp['id'] = id;
          tmp['latLng'] = tappedPlPoints[i];
          prb['points'].add(tmp);

        }
//        print(tappedPlPoints);
        break;
      case 'addPolygon':
        prb['type'] = 'Polygon';
        prb['points'] = [];
        for(int i = 0; i<tappedPgPoints.length;i++){
          pointsDat['lat'] = tappedPgPoints[i].latitude;
          pointsDat['lng'] = tappedPgPoints[i].longitude;
          int id = await db.insert('points', pointsDat,false);
          Map tmp = Map<String,dynamic>();
          tmp['id'] = id;
          tmp['latLng'] = tappedPgPoints[i];
          prb['points'].add(tmp);
        }
//        print(tappedPgPoints);
        break;
    }
    setState(() {});
    if(cType == sendProblemsSettings){
//      print('ENVIANDO....');
      var problemDB = await db.query("SELECT * FROM problems WHERE id = $id");
      var problemToAPI = await problemDBtoAPI(problemDB: problemDB[0]);
//      print('problemToAPI: $problemToAPI');
      var serverResp = await sendOneProblem(problem: problemToAPI);
      var idServer = serverResp['id'];
      prb['idServer'] = idServer;
      await db.query("UPDATE problems SET idServer = $idServer WHERE id = $id");
    }

    if(!edit){
      prb['id'] = id;
      prb['catId'] = catId;
      //ToDo: echarle un ojo a esto
//      prb['consultationsId'] = widget.datos['id'];
      prb['photo'] = photo;
      if(question['tipo'] == 'spatial'){
        widget.problems = [prb];
      }else{
        widget.problems.add(prb);
      }
    }

    delPuntos();
    setState(() {
      actividad = null;
    });
//    print('input: $input, catId: $catId, photo: $photo');
    catId = null;
  }

  void setCat(catSel){
    catId = catSel;
  }

  setPhoto(photoName){
    photo = photoName;
  }

  void undo(){

    switch(actividad){
      case 'addPolyline':
        setState(() {
          tappedPlPoints.removeLast();
        });
        break;
      case 'addPolygon':
        setState(() {
          tappedPgPoints.removeLast();
          tappedPgPointsL.removeLast();
        });
        break;
    }
    tappedPoints.removeLast();
  }

  setEdtProblem({int problemId, int problemIndex, String type}){

    if(type == 'Marker'){
//      print('ENTRANDO!!');
      if(centerEdt){
        centerEdt = false;
        centrar(
          lat:widget.problems[problemIndex]['points'][0]['latLng'].latitude,
          lng:widget.problems[problemIndex]['points'][0]['latLng'].longitude,
          ubic: false,
          makeZoom:true,
        );
      }


      latlngOld = widget.problems[problemIndex]['points'][0]['latLng'];
      markerEdt = widget.problems[problemIndex]['points'][0];

//      print('ASASAS: ${markerEdt = widget.problems[problemIndex]['points'][0]['id']}');

      problemEdtIndex = problemIndex;
      markerEdtIndex = 0;
      markerEdtId = markerEdt = widget.problems[problemIndex]['points'][0]['id'];

      actividad = 'edtMarker';
    }


    setState(() {
//      print('aaaa: $type');
      edtGral = true;
      typeEdt = type;
      problemEdtId = problemId;
      problemEdtIndex = problemIndex;

    });

//    print('TypeEDT : $type');

  }

  setEdtMarker({int markerId, int markerIndex, String act}){
    setState(() {
      actividad = act;
      markerEdtId = markerId;
      markerEdtIndex = markerIndex;
    });
  }

  delMarker({int markerId, int markerIndex}){
    DB db = DB.instance;

    keyBarraEdtProblema.currentState.setAct(null);
    widget.problems[problemEdtIndex]['points'].removeAt(markerIndex);
    db.delete('points', 'id = $markerId', []);
    setState(() {
      actividad = null;
    });

  }

  finalizarEdt({bool delActividad = true}){
    DB db = DB.instance;
//    print('edt Pol: $problemEdtId');
//    db.query('UPDATE problems SET edit = 1 WHERE id = $problemEdtId');

    setState(() {
      if(delActividad){
        actividad = null;
      }
      edtGral = false;
      problemEdtIndex = null;
      problemEdtId = null;
      markerEdtId = null;
      markerEdtIndex = null;

    });
  }

  delProblem({Map problem,int index}) async {
    DB db = DB.instance;
//    print('delProblem');
    widget.problems.removeAt(index);
//    await db.delete('problems', 'id = ${problem['id']}', []);
    await db.query("UPDATE problems SET del = 1 WHERE id = ${problem['id']}");
    setState(() {
      actividad = null;
    });
  }

  undoEdtMarker({bool eGral}){
//    print('UNDO ACA');
//    print(latlngOld);
    centrar(lat:latlngOld.latitude,lng:latlngOld.longitude, ubic: false,makeZoom: false,);
//    print('latLngOldUndo: $latlngOld');
    if(typeEdt == 'Marker'){
//      print('aaa');
      edtGral = false;
    }

    widget.problems[problemEdtIndex]['points'][markerEdtIndex]['latLng'] = latlngOld;

    centerEdt = true;

    markerEdtId = null;
    markerEdtIndex = null;
    latlngOld = null;
    markerEdt = null;
    marcadorEditando = [];
    setState(()=>actividad = null);
  }

  okEdtMarker(){
    DB db = DB.instance;
    db.query('UPDATE problems SET edit = 1 WHERE id = $problemEdtId');
//    print('edtMarker: $problemEdtId');

    updMarker(latlang: center);
    markerEdtId = null;
    markerEdtIndex = null;
    latlngOld = null;
    markerEdt = null;
    centerEdt = true;

    if(typeEdt == 'Marker'){
      edtGral = false;
    }
    marcadorEditando = [];
    setState(()=>actividad = null);
  }

  setMarcadorEditando({LatLng latlng}){
    setState(() {
      marcadorEditando = [latlng];
    });
  }

}

class Marcador{

  GlobalKey<MapWidgetState> keyMapa = GlobalKey();
  int index;
  Marker marker;
  LatLng latlng;
  String type;
  int fatherIndex;
  int fatherId;
  int id;
  var icono;
  Color color;
  AnchorPos pos;
  double width;
  double height;


  Marcador({
    this.keyMapa,
    this.index,
    this.latlng,
    this.type,
    this.fatherIndex,
    this.fatherId,
    this.id,
    this.icono,
    this.color,
    this.pos,
    this.width,
    this.height,
  }){

    pos ??= AnchorPos.align(AnchorAlign.top);
    color ??= Colors.red[500];

    icono ??= Icon(
      Icons.location_on,
      size: 40,
      color: color,
    );

    width ??= 40;
    height ??= 40;

    marker = Marker(
      width: width,
      height: height,
      point: latlng,
      anchorPos: pos,
      builder: (ctx) => Container(
          child:GestureDetector(
            onTap: () {
//              print('index: $index, type: $type, fatherIndex: $fatherIndex, id: $id');
              if(keyMapa.currentState.actividad == 'delMarker'){
                keyMapa.currentState.delMarker(markerId: id,markerIndex: index);
              }else{
                bool makeZoom = true;
                if(keyMapa.currentState.actividad == 'edtMarker'){
                  keyMapa.currentState.okEdtMarker();
                  makeZoom = false;
                }


                keyMapa.currentState.latlngOld = latlng;
//                print('latLngOldMarker: ${keyMapa.currentState.latlngOld}');
                keyMapa.currentState.markerEdt = keyMapa.currentState.widget.problems[fatherIndex]['points'][index];
                if(keyMapa.currentState.centerEdt){
                  keyMapa.currentState.centerEdt = false;
                  keyMapa.currentState.centrar(
                      lat:latlng.latitude,
                      lng:latlng.longitude,
                      ubic: false,
                      makeZoom: makeZoom
                  );
                }

                keyMapa.currentState.setEdtMarker(act: 'edtMarker',markerId: id,markerIndex: index);
                if(type == 'Polygon' || type == 'Polyline'){
                  keyMapa.currentState.setMarcadorEditando(
                    latlng: latlng,
                  );
                }

              }
            },
            child: icono,
          )
      ),
    );
  }
}
