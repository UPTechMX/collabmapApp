import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/models/conexiones/api.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'dimSelector.dart';
import 'package:siap_monitoring/models/layout/colores.dart';
import 'targetsElemsList.dart';
import 'dimensionesElemAdd.dart';

class TargetsElemsAdd extends StatelessWidget {

  int targetsId;
  int userTargetsId;
  int lastDimElem ;
  int addStructure = 0;

  GlobalKey<TargetsElemsListState> KeyList = GlobalKey();

  Map<int, GlobalKey<DimSelectorState>> triggers = {};
  List dims = List();

  TargetsElemsAdd({
    this.targetsId,
    this.userTargetsId,
    this.addStructure,
    this.KeyList,
    this.lastDimElem : null,
  });

  @override
  Widget build(BuildContext context) {
    Colores colores = Colores();
    return FutureBuilder(
      future: getDimensiones(),
      builder: (context,snapshot){
        List<Widget> rows = [];
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text(Translations.of(context).text('waiting'));
          case ConnectionState.done:
            if (snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }
            dims = snapshot.data;

//            print('DATA : ${snapshot.data}');
            if(snapshot.data.length == 0){
              return Container(
                height: 100,
                child: Center(
                  child: Text(Translations.of(context).text('empty')),
                ),
              );
            }
            int numCols = 3;
            List row;

            for(int i = 0; i < dims.length; i++){
              if(i%numCols == 0){
                row = <Widget>[];
              }
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

              row.add(
                Expanded(
                  flex: 1,
                  child: dimSel,
                )
              );

              if(i%numCols == numCols-1 || i == dims.length -1){
                rows.add(
                  Row(
                    children: row,
                  )
                );
              }
            }

            List botones = <Widget>[];
            Widget useSelected = Expanded(
              flex: 4,
              child: RaisedButton(
                onPressed: (){
                  if(lastDimElem == null){
                    emergente(
                      context: context,
                      actions: <Widget>[],
                      content: Text(Translations.of(context).text('needTarget')),
                    );
                  }else{
                    addTargetsElems(context: context);
                  }
                },
                child: Text(Translations.of(context).text('useSelected')),
                color: colores.colorBar,
              ),
            );

            Widget addNew = Expanded(
              flex: 4,
              child: addStructure == 1?
              RaisedButton(
                onPressed: (){

                  var dimElemAdd = DimensionesElemAdd(
                    dims: dims,
                  );

                  List<Widget> actions = [
                    FlatButton(
                      child: Text(Translations.of(context).text('cancel')),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(Translations.of(context).text('ok')),
                      onPressed: () {
                        dimElemAdd.insertDimElem(context: context,usersTargetsId: userTargetsId,reset:  KeyList.currentState.refresh());
                      },
                    )
                  ];

                  emergente(
                    content: dimElemAdd,
                    actions:actions,
                    context: context,
                  );
//                  KeyList.currentState.refresh();
                },
                child: Text(Translations.of(context).text('addToList')),
                color: colores.colorBar,
              ):Container(),
            );

            botones.add(useSelected);
            botones.add(Expanded(
              flex: 1,
              child: Container(),
            ));
            botones.add(addNew);

            rows.add(Row(
              children: botones,
            ));

            return Container(
//              padding: EdgeInsets.all(15),
              child: Column(
                children: rows,
              ),
            );
          default:
            return Column();
        }

      },
    );
  }

  void addTargetsElems({BuildContext context}) async {
    DB db = DB.instance;

    SharedPreferences userData = await SharedPreferences.getInstance();
    int userId = userData.getInt('userId');

//    this.targetsId,this.userTargetsId,this.addStructure
    var exists = await db.query("SELECT * FROM TargetsElems WHERE usersId = $userId AND dimensionesElemId = $lastDimElem");
//    print('Exists: $exists');
    if(exists != null){
      emergente(
        context: context,
        actions: <Widget>[],
        content: Text(Translations.of(context).text('TrgtExist'))
      );
    }else{

      Map<String,dynamic> datos = Map();
      datos['targetsId'] = targetsId;
      datos['usersId'] = userId;
      datos['usersTargetsId'] = userTargetsId;
      datos['dimensionesElemId'] = lastDimElem;
      datos['creadoOffline'] = 1;

      var r = await db.insert('TargetsElems', datos, true);
      KeyList.currentState.refresh();
      print(r);
    }

  }

  Future getDimensiones() async {
    DB db = DB.instance;
    var dimensiones = await db.query("SELECT * FROM Dimensiones WHERE type = 'structure' AND elemId = ${this.targetsId} ");
    return dimensiones;
  }

  chNivel({int nivel, int valor}){
    int numDims = dims.length;
    if(nivel<numDims){
      triggers[nivel+1].currentState.chPadre(valor);
      lastDimElem = null;
    }else{
      lastDimElem = valor;
    }
  }

}

