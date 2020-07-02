import 'package:flutter/material.dart';
import 'package:siap/models/layout/colores.dart';
import 'package:siap/views/questionnaires/targets/targetsElemsList.dart';

import 'targetsElemsAdd.dart';

class UserTarget extends StatefulWidget {

  Map datos;
  UserTarget({this.datos});

  @override
  UserTargetState createState() => UserTargetState();
}

class UserTargetState extends State<UserTarget> {

  GlobalKey<TargetsElemsListState> KeyList = GlobalKey();

  @override
  Widget build(BuildContext context) {
//    print('Datos: ${widget.datos}');
    Colores colores = Colores();
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                widget.datos['name'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colores.fontColorBar
                ),
              ),
            ),
            color: colores.colorBar,
            width: double.infinity,
            height: 40,
          ),
          TargetsElemsAdd(
            targetsId: widget.datos['id'],
            userTargetsId: widget.datos['utId'],
            addStructure: widget.datos['addStructure'],
            KeyList: KeyList,
          ),
          SizedBox(height: 10,),
          TargetsElemsList(
            key:KeyList,
            targetsId: widget.datos['id'],
            usersTargetsId: widget.datos['utId'],
          ),
          SizedBox(height: 10,),
        ],
      ),
    );
  }
}
