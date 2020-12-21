import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/layout/colores.dart';
import 'package:siap_monitoring/views/questionnaires/targets/targetsElemsList.dart';

import 'targetsElemsAdd.dart';

class UserTarget extends StatefulWidget {
  Map datos;
  GlobalKey<UserTargetState> keyUser;
  UserTarget({
    this.datos,
    Key key,
    this.keyUser,
  }) : super(key: key);

  @override
  UserTargetState createState() => UserTargetState(keyUser: keyUser);
}

class UserTargetState extends State<UserTarget> {
  GlobalKey<TargetsElemsListState> KeyList = GlobalKey();
  var keyUser = GlobalKey<UserTargetState>();

  UserTargetState({
    this.keyUser,
  });

  finishSurvey() {
    setState(() {});
  }

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
                    color: colores.fontColorBar),
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
            keyUser: keyUser,
          ),
          SizedBox(
            height: 10,
          ),
          TargetsElemsList(
            key: KeyList,
            keyUser: keyUser,
            targetsId: widget.datos['id'],
            usersTargetsId: widget.datos['utId'],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
