import 'package:flutter/material.dart';

class Barrita extends StatefulWidget {
  String actividad;
  var undo;
  var aceptar;
  var iconoUndo;

  Barrita({this.actividad, this.undo, this.aceptar, this.iconoUndo});

  @override
  BarritaState createState() => BarritaState();
}

class BarritaState extends State<Barrita> {
  @override
  Widget build(BuildContext context) {
    widget.iconoUndo ??= Icon(
      Icons.undo,
      color: Colors.grey,
      size: 30,
    );

    return Container(
//      padding: EdgeInsets.all(1),
//      padding: EdgeInsets.only(bottom: 20),
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
//        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: IconButton(
              icon: widget.iconoUndo,
              onPressed: () {
                widget.undo();
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: IconButton(
              icon: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 35,
              ),
              onPressed: () {
                widget.aceptar(context: context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
