import 'package:flutter/material.dart';
import 'package:siap/models/componentes/iconos.dart';

class BarritaEdtProblema extends StatefulWidget {
  String actividad;
  var aceptar;
  var cancelar;
  var addPunto;
  var delPunto;
  String type;

  BarritaEdtProblema(
      {Key key,
      this.aceptar,
      this.addPunto,
      this.delPunto,
      this.type,
      this.cancelar})
      : super(key: key);

  @override
  BarritaEdtProblemaState createState() => BarritaEdtProblemaState();
}

class BarritaEdtProblemaState extends State<BarritaEdtProblema> {
  String actividad;

  @override
  Widget build(BuildContext context) {
//    print(widget.type);
    return Container(
//      padding: EdgeInsets.all(1),
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: widget.type != 'Marker'
                ? IconButton(
                    icon: Icono(
                      svgName: 'addMarker',
                      color: actividad == 'add' ? Colors.amber : Colors.grey,
                      width: 50,
                    ),
                    onPressed: () {
                      if (actividad == 'add') {
                        setAct(null);
                        widget.addPunto('null');
                      } else {
                        setAct('add');
                        widget.addPunto('addMarkerPrb');
                      }
//                widget.undo();
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 30,
                    ),
                    onPressed: () {
                      widget.cancelar();
                    },
                  ),
          ),
          Expanded(
            flex: 3,
            child: widget.type != 'Marker'
                ? IconButton(
                    icon: Icono(
                      svgName: 'delMarker',
                      color: actividad == 'add' ? Colors.amber : Colors.grey,
                      width: 50,
                    ),
                    onPressed: () {
                      if (actividad == 'del') {
                        setAct(null);
                        widget.delPunto(null);
                      } else {
                        setAct('del');
                        widget.delPunto('delMarker');
                      }

//                widget.undo();
                    },
                  )
                : Container(),
          ),
          Expanded(
            flex: 3,
            child: IconButton(
              icon: Icon(
                Icons.check_circle,
                color: Colors.grey,
                size: 30,
              ),
              onPressed: () {
                widget.aceptar();
              },
            ),
          ),
        ],
      ),
    );
  }

  setAct(String act) {
    setState(() {
      actividad = act;
    });
  }
}
