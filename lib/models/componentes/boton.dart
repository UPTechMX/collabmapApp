import 'package:flutter/material.dart';

class Boton extends StatelessWidget{

  String texto;
  Color color;
  VoidCallback onClick;
  var icono;
  bool widget;
  var elemento;

  Boton({
    this.texto,
    this.color,
    this.onClick,
    this.icono,
    this.widget = false,
    this.elemento,
  });

  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];
    if(widget){
      children = <Widget>[

        Expanded(
          flex: 1,
          child: elemento,
        )

      ];
    }else{
      children = <Widget>[
        Expanded(
          flex: 1,
          child: icono,
        ),
        Expanded(
          flex: 4,
          child: Text(
            texto,
            style: TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          flex: 1,
          child: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
        )
      ];
    }

    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: ButtonTheme(
            minWidth: 150.0,
            height: 45.0,
            buttonColor: color,
            child: FlatButton(
              onPressed: onClick,
              child: Row(
                children: children,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}