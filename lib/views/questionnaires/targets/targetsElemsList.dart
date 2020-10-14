import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/views/questionnaires/targets/chkAction.dart';

class TargetsElemsList extends StatefulWidget {

  int targetsId;
  int usersTargetsId;

  TargetsElemsList({
    Key key,
    this.targetsId,
    this.usersTargetsId
  }):super(key:key);

  @override
  TargetsElemsListState createState() => TargetsElemsListState();
}

class TargetsElemsListState extends State<TargetsElemsList> {

  @override
  Widget build(BuildContext context) {
    getTargetsElems();
    return FutureBuilder(
      future: getTargetsElems(),
      builder: (context,snapshot){
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

            List chks = snapshot.data['targetsChecklist'];
//            print('CHKS: $chks');
            var hElems = <Widget>[];
            hElems.add(
                Expanded(
                  flex: 1,
                  child: Text(
                    Translations.of(context).text('name'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  ),
                )
            );
            for(int i = 0;i<chks.length;i++){
              hElems.add(
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      Translations.of(context).text(chks[i]['code']),
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                )
              );
            }
            List rows = <Widget>[];
            rows.add(
                Row(
                  children: hElems ,
                )
            );
            rows.add(
              SizedBox(height: 10,),
            );

            List tes = snapshot.data['TargetsElems'];

            for(int j = 0;j<tes.length;j++){
//              print('tes: ${tes[j]}');
              var bElems = <Widget>[];
              bElems.add(
                  Expanded(
                    flex: 1,
                    child: Text(
                      tes[j]['deName'],
                    ),
                  )
              );

              for(int i = 0;i<chks.length;i++){
                bElems.add(
                    Expanded(
                      flex: 1,
                      child: ChkAction(
                        datTE: tes[j],
                        datChk: chks[i],
                      ),
                    )
                );
              }
              rows.add(
                  Row(
                    children: bElems ,
                  )
              );
            }

            return Column(
              children: rows,
            );
          default:
            return Column();
        }

      },
    );
  }

  refresh(){
    print('refresh');
    setState(() {});
  }

  getTargetsElems() async {
    DB db = DB.instance;

//    SharedPreferences userData = await SharedPreferences.getInstance();
//    int userId = userData.getInt('userId');

    String sqlTC = '''
      SELECT tc.checklistId, c.nombre as cNom, 
			tc.frequency, f.code, c.id as cId
			FROM TargetsChecklist tc 
			LEFT JOIN Frequencies f ON f.id = tc.frequency
			LEFT JOIN Checklist c ON c.id = tc.checklistId
			WHERE  tc.targetsId = ${widget.targetsId}
			ORDER BY tc.frequency
    ''';

    List targetsChecklist = await db.query(sqlTC);
//    print('targetsChecklist : $targetsChecklist');

    String sqlTE = '''
        SELECT te.*, de.nombre as deName, de.id as deId
        FROM TargetsElems te 
        LEFT JOIN DimensionesElem de ON de.id = te.dimensionesElemId
        WHERE te.usersTargetsId = ${widget.usersTargetsId} ORDER BY name
    ''';

    List TargetsElems = await db.query(sqlTE);
    TargetsElems ??= [];
//    print('TargetsElems $TargetsElems');

    Map resp = Map();
    resp['targetsChecklist'] = targetsChecklist;
    resp['TargetsElems'] = TargetsElems;

//    print('Resp: $resp');
    return resp;
  }

}
