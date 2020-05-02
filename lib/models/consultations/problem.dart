import '../conexiones/DB.dart';
import 'dart:io';

class Problem {

  String type;
  List points;
  int catId;
  String photo;
  int consultationsId;

  getInfo(pId) async {
    DB db = DB.instance;
    List problems = await db.query("SELECT * FROM problems WHERE id = $pId");
  }

  insertProb() async {
    DB db = DB.instance;
    Map dats = new Map();
    dats['type'] = type;
    dats['catId'] = catId;
    dats['photo'] = photo;
    dats['consultationsId'] = consultationsId;

    var pId = await db.insert('problems', dats,false);

    for(int i = 0;i<points.length;i++){

      Map dPoint = new Map();
      dPoint['problemsId'] = pId;
      dPoint['lat'] = points[i][0];
      dPoint['lng'] = points[i][1];

      db.insert('points', dPoint,false);

    }


  }


}