import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/models/translations.dart';

class DimSelector extends StatefulWidget {
  int dimensionesId;
  int padre;
  String dimNom;
  int nivel;
  var chNivel;

  GlobalKey<DimSelectorState> keyDimSel;

  DimSelector({
    Key key,
    this.dimensionesId,
    this.padre = null,
    this.dimNom,
    this.nivel,
    this.chNivel,
    this.keyDimSel,
  }) : super(key: key);

  @override
  DimSelectorState createState() => DimSelectorState(
      dimensionesId: dimensionesId, dimNom: dimNom, padre: padre);
}

class DimSelectorState extends State<DimSelector> {
  int dimensionesId;
  int padre;
  String dimNom;

  var chNextPadre;
  var selected;

  DimSelectorState(
      {this.dimensionesId, this.padre = null, this.dimNom, this.chNextPadre});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDimensionesElem(padre: padre),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text(Translations.of(context).text('waiting'));
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            List elementos = snapshot.data;
//              print('ELEMENTOS ${widget.nivel}: $elementos');
            var items = <DropdownMenuItem>[];
            for (int i = 0; i < elementos.length; i++) {
              var item = DropdownMenuItem(
                child: Text(
                  elementos[i]['nombre'],
                  style: TextStyle(fontSize: 14),
                ),
                value: elementos[i]['id'],
              );
              items.add(item);
            }

            return Container(
              padding: EdgeInsets.all(5),
              child: DropdownButton(
                items: items,
                value: selected,
                hint: Text('$dimNom'),
                onChanged: (value) {
                  setState(() {
                    selected = value;
                  });
                  widget.chNivel(nivel: widget.nivel, valor: value);
                },
              ),
            );
          default:
            return Column();
        }
      },
    );
  }

  Future getDimensionesElem({int padre = null}) async {
    if (padre != null) {
      DB db = DB.instance;

      List dimensionesElem = await db.query(
          "SELECT * FROM DimensionesElem WHERE padre = ${padre} AND dimensionesId = ${dimensionesId}");
      dimensionesElem ??= [];

      return dimensionesElem;
    } else {
      return [];
    }
  }

  chPadre(newPadre) {
    setState(() {
      selected = null;
      padre = newPadre;
    });
    widget.chNivel(nivel: widget.nivel, valor: null);
  }
}
