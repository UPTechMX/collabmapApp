import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siap/models/conexiones/DBEst.dart';

// singleton class to manage the database
class DB {

  Tablas tablas = Tablas();

  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "CM.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 2;

  // Make this a singleton class.
  DB._privateConstructor();
  static final DB instance = DB._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
//    print('aaa');
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    Tablas tablas = new Tablas();
    Map t = tablas.getTablas();
    for(var i in t.keys){
      print('crea tabla $i');
      await db.execute(t[i]);
    }
  }

  // Database helper methods:
  Future<int> insert(String tabla,Map map,bool imprime) async {
    Database db = await database;
    try{
      int id = await db.insert(tabla, map);
//      print('ID: $id');
      return id;
    }catch(e){
      if(imprime){
        print('Error $e');
        print(map);
      }
      return null;
    }
  }

  Future<List> queryTabla(String tabla,List cols,String where, List whereArgs) async {
    Database db = await database;
    List<Map> maps = await db.query(tabla,
        columns: cols,
        where: where,
        whereArgs: whereArgs);
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<int> delete(String tabla, String where, List<String> whereArgs) async {
    Database db = await database;
    return await db.delete(tabla, where: where, whereArgs: whereArgs);
  }

  Future<List> query(String query) async {
    Database db = await database;
    List<Map> maps = await db.rawQuery(query);
    if (maps.length > 0) {
      return maps;
    }
    return null;
  }

  Future<void> insertaLista(String tabla, List lista, bool eliminarAntes, bool imprime) async{
    if(eliminarAntes){
      this.delete(tabla,'1',[]);
      if(imprime){
        print('Borrando todo el contenido de la tabla $tabla');
      }
    }
    if(lista != null){
      if(imprime){
        print('si entra $tabla');
      }
      for(int i = 0;i<lista.length;i++){
        if(imprime){
          print('Se insertó el elemento  ${lista[i]} a la tabla $tabla');
        }

        await this.insert(tabla, lista[i],imprime);
      }
    }
  }

  Future<void> replaceLista({String tabla, List lista, bool imprime = false}) async{
    if(lista != null){
      if(imprime){
        print('si entra $tabla');
      }
      for(int i = 0;i<lista.length;i++){
        if(imprime){
          print('Se insertó el elemento  ${lista[i]} a la tabla $tabla');
        }
        await this.replace(tabla, lista[i]);
      }
    }
  }

  replace(String tabla,Map map) async {
    Database db = await database;
    String sql = 'REPLACE INTO `$tabla` ';
    String columnas = '';
    String args = '';
    var j = 0;
    for(var i in map.keys){
      if(j == 0){
        j++;
        columnas = '$columnas `$i` ';
        args = '$args ? ';
      }else{
       columnas = '$columnas, `$i` ';
       args = '$args, ? ';
      }
    }
    sql = '$sql($columnas) VALUES ($args)';
//    print(sql);
    List list = [];
    for(var i in map.keys){
      list.add(map[i]);
    }

    try{
      var resp = db.rawQuery(sql,list);
//      print('MAP $map');
        return(resp);
    }catch(e){
      print('Error $e');
//      print('ERROR MAP $map');
    }
  }

}




