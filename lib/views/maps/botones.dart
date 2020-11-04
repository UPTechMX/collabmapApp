import 'package:flutter/material.dart';
import 'package:siap/views/maps/map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:siap/models/layout/iconos.dart';

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  BuildContext context;
  GlobalKey<MapWidgetState> keyMapa;

  FancyFab(
      {this.onPressed, this.tooltip, this.icon, this.keyMapa, this.context});

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        heroTag: "btn1",
        onPressed: () {
          widget.keyMapa.currentState.setActividad('addMarker');
          widget.keyMapa.currentState.actividadFncDrag(context: widget.context);
//          widget.keyMapa.currentState.delPuntos();
          animate();
        },
        tooltip: 'Marker',
        mini: true,
        child: Icon(Icons.location_on),
      ),
    );
  }

  Widget linea() {
    return Container(
      child: FloatingActionButton(
        heroTag: "btn2",
        onPressed: () {
          widget.keyMapa.currentState.setActividad('addPolyline');
          widget.keyMapa.currentState.delPuntos();
          animate();
        },
        tooltip: 'Path',
        mini: true,
        child: Icono(
          svgName: 'polyline',
          width: 30,
        ),
      ),
    );
  }

  Widget area() {
    return Container(
      child: FloatingActionButton(
        heroTag: "btn3",
        onPressed: () {
          widget.keyMapa.currentState.setActividad('addPolygon');
          widget.keyMapa.currentState.delPuntos();
          animate();
        },
        tooltip: 'Polygon',
        mini: true,
        child: Icono(
          svgName: 'polygon',
          width: 30,
        ),
      ),
    );
  }

  Widget miUbic() {
    return Container(
      child: FloatingActionButton(
        heroTag: "btn4",
        onPressed: () {
          myLocation();
        },
        tooltip: 'Location',
        mini: true,
        child: Icon(Icons.location_searching),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        heroTag: "btn5",
        onPressed: () {
          animate();
          widget.keyMapa.currentState.setActividad(null);
        },
        tooltip: 'Toggle',
        mini: true,
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double vAlign = -8;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            (_translateButton.value + vAlign) * 3.0,
            0.0,
          ),
          child: add(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            (_translateButton.value + vAlign) * 2.0,
            0.0,
          ),
          child: linea(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value + vAlign,
            0.0,
          ),
          child: area(),
        ),
        toggle(),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            0.0,
            0.0,
          ),
          child: miUbic(),
        ),
      ],
    );
  }

  void myLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    widget.keyMapa.currentState
        .centrar(lat: position.latitude, lng: position.longitude);
  }
}

class BotonesBarra extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  BuildContext context;
  GlobalKey<MapWidgetState> keyMapa;
  bool spatial;
  Map question;

  BotonesBarra(
      {Key key,
      this.onPressed,
      this.tooltip,
      this.icon,
      this.keyMapa,
      this.context,
      this.spatial,
      this.question})
      : super(key: key);

  @override
  BotonesBarraState createState() => BotonesBarraState();
}

class BotonesBarraState extends State<BotonesBarra> {
  void myLocation() async {
//      print('aaaa');
//    Geolocator geolocator = Geolocator();//..forceAndroidLocationManager = true;
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//      print('position: $position');

//    Position position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
//    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    widget.keyMapa.currentState
        .centrar(lat: position.latitude, lng: position.longitude);
  }

  @override
  Widget build(BuildContext context) {
//    print('SPATIAL: ${widget.spatial}');
    Widget add() {
      return Container(
        child: FloatingActionButton(
          heroTag: "btn1",
          backgroundColor: widget.keyMapa.currentState.actividad == 'addMarker'
              ? Color(0xFF2568D8)
              : Colors.white,
          onPressed: () {
            widget.keyMapa.currentState.setActividad('addMarker');
            widget.keyMapa.currentState
                .actividadFncDrag(context: widget.context);
            setState(() {});
            print(widget.keyMapa.currentState.actividad);
          },
          tooltip: 'Marker',
          mini: true,
          child: Icon(
            Icons.location_on,
            color: widget.keyMapa.currentState.actividad == 'addMarker'
                ? Colors.white
                : Colors.grey,
          ),
        ),
      );
    }

    Widget linea() {
      return Container(
        child: FloatingActionButton(
          heroTag: "btn2",
          backgroundColor:
              widget.keyMapa.currentState.actividad == 'addPolyline'
                  ? Color(0xFF2568D8)
                  : Colors.white,
          onPressed: () {
            widget.keyMapa.currentState.setActividad('addPolyline');
            widget.keyMapa.currentState.delPuntos();
            setState(() {});
          },
          tooltip: 'Path',
          mini: true,
          child: Icono(
            svgName: 'polyline',
            width: 30,
            color: widget.keyMapa.currentState.actividad == 'addPolyline'
                ? Colors.white
                : Colors.grey,
          ),
        ),
      );
    }

    Widget area() {
      return Container(
        child: FloatingActionButton(
          heroTag: "btn3",
          backgroundColor: widget.keyMapa.currentState.actividad == 'addPolygon'
              ? Color(0xFF2568D8)
              : Colors.white,
          onPressed: () {
            widget.keyMapa.currentState.setActividad('addPolygon');
            widget.keyMapa.currentState.delPuntos();
            setState(() {});
          },
          tooltip: 'Polygon',
          mini: true,
          child: Icono(
            svgName: 'polygon',
            width: 30,
            color: widget.keyMapa.currentState.actividad == 'addPolygon'
                ? Colors.white
                : Colors.grey,
          ),
        ),
      );
    }

    Widget miUbic() {
      return Container(
        child: FloatingActionButton(
          heroTag: "btn4",
          backgroundColor: Colors.white,
          onPressed: () {
            myLocation();
          },
          tooltip: 'Location',
          mini: true,
          child: Icon(
            Icons.location_searching,
            color: Colors.grey,
          ),
        ),
      );
    }

    Widget edit() {
      return Container(
        child: FloatingActionButton(
          heroTag: "btn5",
          backgroundColor: Colors.white,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: 'Location',
          mini: true,
          child: Icono(
            svgName: 'edit',
            width: 30,
            color: Colors.grey,
          ),
        ),
      );
    }

//    print('-=-=-=-=-=-=');
//    print(widget.question['tipo']);
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: add(),
          ),
          Expanded(
            flex: (widget.question['tipo'] == 'op') ? 0 : 1,
            child: (widget.question['tipo'] == 'op') ? Container() : linea(),
          ),
          Expanded(
            flex: (widget.question['tipo'] == 'op') ? 0 : 1,
            child: (widget.question['tipo'] == 'op') ? Container() : area(),
          ),
          Expanded(
            flex: (widget.question['tipo'] == 'op') ? 0 : 1,
            child: (widget.question['tipo'] == 'op') ? Container() : miUbic(),
          ),
          Expanded(
            flex: (widget.question['tipo'] == 'cm') ? 1 : 0,
            child: (widget.question['tipo'] == 'cm') ? edit() : Container(),
          )
        ],
      ),
    );
  }

  actualizaEstado() {
    setState(() {});
  }
}
