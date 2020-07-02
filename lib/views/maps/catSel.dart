import 'package:flutter/material.dart';
import 'map.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siap/models/translations.dart';

class CatSel extends StatefulWidget {

  List cats;
  var setCat;
  int catSel;
  bool edit;
  int catId;
  bool fix;


  CatSel({this.cats,this.setCat,this.catSel,this.edit = false,this.catId,this.fix = false});

  @override
  CatSelState createState() => CatSelState();
}

class CatSelState extends State<CatSel> {

  var selected;
  var selected2;

  bool ya = false;

  @override
  void initState() {
    selected = widget.catSel;
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    print('${widget.cats},${widget.setCat}');
    if(widget.edit && !ya){
      ya = true;
      selected = widget.catId;
    }

    List items = new List<DropdownMenuItem>();
    List cats = widget.cats;
    for(int i = 0;i<cats.length;i++){
      print('CAT: ${cats[i]}');
      var cat = cats[i];
      var item = DropdownMenuItem(
        child: Text(
          cat['name'],
          style: TextStyle(fontSize: 14),
        ),
        value: cat['id'],
      );
//      print(cat['id']);
      items.add(item);
    }

    String selName;
    if(widget.fix){
      for(int i = 0;i<cats.length;i++){
        var cat = cats[i];
        if(cat['id'] == selected){
          selName = cat['name'];
        }
      }
    }

    return !widget.fix?
    DropdownButtonFormField(
      items: items,
      value: selected,
      hint: Text(Translations.of(context).text('select')),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey,
                width: 1
            )
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0)
        ),
        isDense: true,
      ),
      onChanged: (value){
        print(value);
        setState(() {
          selected = value;
          widget.setCat(value);
        });
      },
    ):
    Text(selName);
  }
}

class BtnPhotos extends StatefulWidget {

  String photo;
  var setPhoto;
  bool editable;
  bool fix;
  BtnPhotos({this.photo,this.setPhoto,this.editable = true,this.fix = false});

  @override
  BtnPhotosState createState() => BtnPhotosState();
}

class BtnPhotosState extends State<BtnPhotos> {


  File image;
  Future tomarFoto() async {
    File picture = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 1000.0, maxHeight: 1000.0);

    if(picture != null){
      var directory = await getApplicationDocumentsDirectory(); // AppData folder path

      var path = '${directory.path}/fotos';

      var existeDirVisita = await Directory(path).exists();
      if(!existeDirVisita){
        await creaDirectorio(path);
      }

      String fileName = picture.path.split('/').last;
      String nomArch = 'fotografia_$fileName';
      picture.copy('${path}/${nomArch}');
      photo = nomArch;

      setState(() {
        image = picture;
      });
      widget.setPhoto(nomArch);
    }
  }

  Future selFoto() async {
    File picture = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1000.0, maxHeight: 1000.0);

    if(picture != null){
      var directory = await getApplicationDocumentsDirectory(); // AppData folder path

      var path = '${directory.path}/fotos';

      var existeDirVisita = await Directory(path).exists();
      if(!existeDirVisita){
        await creaDirectorio(path);
      }

      String fileName = picture.path.split('/').last;
      String nomArch = 'fotografia_$fileName';
      picture.copy('${path}/${nomArch}');
      photo = nomArch;

      setState(() {
        image = picture;
      });
      widget.setPhoto(nomArch);
    }
  }

  creaDirectorio(path) async {
    await Directory(path).create(recursive: true)
        .then((Directory directory){
//      print(directory.path);
    });
  }

  String photo;

  @override
  void initState() {
    photo = widget.photo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var btn = widget.editable && !widget.fix?Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: FlatButton(
            onPressed: tomarFoto,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: Color(0xFF2568D8)
                  )
              ),
              child: Icon(Icons.camera_enhance,color: Color(0xFF2568D8),),
            ),

          ),
        ),
        Expanded(
          flex:1,
          child: Container(),
        ),
        Expanded(
          flex: 2,
          child: FlatButton(
            onPressed: selFoto,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: Color(0xFF2568D8)
                  )
              ),
              child: Icon(Icons.photo_library,color: Color(0xFF2568D8),),
            ),

          ),
        )
      ],
    ):Container(width: 0,height: 0,);


    var imagen = FutureBuilder(
      future: getPhoto(),
      builder: (context,snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }
            return Column(
              children: <Widget>[
                Container(
                  height: 200,
                  child: Image.file(
                    snapshot.data[0],
                  ),
                ),
                Container(
                  child: widget.editable && !widget.fix?FlatButton(
                      onPressed: (){
                        setState(() {
                          photo = null;
                        });
                        widget.setPhoto(null);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.black
                          )
                        ),
                        child: Icon(Icons.delete,size: 20,color: Colors.red,),
                      )
                  ):Container(),
                )
              ],
            );
        }
        return null;
      },
    );


    return photo == null?btn:imagen;
  }

  Future<List> getPhoto() async {
    List lista = [];
    if(photo == null){
      return lista;
    }
    print(photo);
    var directory = await getApplicationDocumentsDirectory(); // AppData folder path
    var path = '${directory.path}/fotos';

    print('${path}/${photo}');
    File imagen = File('${path}/${photo}');

    lista.add(imagen);

    return lista;

  }


}
