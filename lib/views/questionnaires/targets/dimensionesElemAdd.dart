import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dimSelector.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';

class DimensionesElemAdd extends StatelessWidget {

  List dims;
  var lastDimElem = null;
  TextEditingController nameController = TextEditingController();
  String name;

  Map<int, GlobalKey<DimSelectorState>> triggers = {};
  DimensionesElemAdd({
    this.dims
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> selects = [];

    for(int i = 0; i < dims.length-1; i++){
      GlobalKey<DimSelectorState> key = GlobalKey();
      DimSelector dimSel = DimSelector(
        dimensionesId: dims[i]['id'],
        dimNom: dims[i]['nombre'],
        padre: dims[i]['nivel'] == 1?0:null,
        nivel: dims[i]['nivel'],
        chNivel: chNivel,
        key: key,
      );
      triggers[dims[i]['nivel']] = key;
      selects.add(
          Container(
            child: dimSel,
          )
      );
    }

    var nameField = TextField(
      controller: nameController,
      onChanged: (text){
        name = text;
      },
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: Translations.of(context).text("name"),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
          )
      ),
    );

    selects.add(nameField);
    return Column(
      children: selects,
    );
  }

  chNivel({int nivel, int valor}){
    int numDims = dims.length;
    if(nivel<numDims-1){
      print('valor: $valor, nivel:$nivel');
      triggers[nivel+1].currentState.chPadre(valor);
      lastDimElem = null;
    }else{
      lastDimElem = valor;
    }
  }

  insertDimElem({BuildContext context,int usersTargetsId, var reset}) async {
    DB db = DB.instance;
    SharedPreferences userData = await SharedPreferences.getInstance();

    if(name != null && name != '' && lastDimElem != null){
      int numDims = dims.length;
      Map<String,dynamic> datos = new Map();
      if(numDims == 1){
        datos['padre'] = 0;
      }else{
        datos['padre'] = lastDimElem;
      }
      datos['dimensionesId'] = dims[dims.length-1]['id'];
      datos['nombre'] = name;
      datos['creadoOffline'] = 1;
      var elemId = await db.insert('DimensionesElem', datos, true);


      Map<String,dynamic> mapTE = new Map();
      mapTE['targetsId'] = dims[dims.length-1]['elemId'];
      mapTE['usersTargetsId'] = usersTargetsId;
      mapTE['usersId'] = userData.getInt('userId');
      mapTE['dimensionesElemId'] = elemId;
      mapTE['creadoOffline'] = 1;
      var targetsElemId = await db.insert('TargetsElems', mapTE, true);
      reset;

      Navigator.of(context).pop();

    }

  }



}


