import 'package:flutter/material.dart';

class Barra extends StatefulWidget with PreferredSizeWidget {
  @override
  BarraState createState() => BarraState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class BarraState extends State<Barra> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final conectando = Container(
      padding: EdgeInsets.only(top: 20, bottom: 15, right: 15, left: 15),
      width: 50,
      height: 30,
      child: CircularProgressIndicator(
        strokeWidth: 3,
      ),
    );

    return AppBar(
      title: Center(
        child: Image.asset(
          'images/icons/tacumbu/Tacumbu_ikatu.png',
          height: MediaQuery.of(context).size.height * .07,
        ),
      ),
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.amber),
      leading: Container(
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
//      actions: <Widget>[
//        IconButton(
//          icon: Icon(Icons.edit),
//          onPressed: (){
//            Scaffold.of(context).openDrawer();
//          },
//        )
//      ],
    );
  }
}
