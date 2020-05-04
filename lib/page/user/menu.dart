import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  MenuWidget(this.defaut);

  final Color defaut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff000000),
        image: DecorationImage(
          image: AssetImage("assets/images/food.jpg"),
          fit: BoxFit.cover,
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.4), BlendMode.dstATop),
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.25,
      child: Stack(children: <Widget>[
        Container(
            alignment: Alignment(0.0, 0.0),
            child: Text(
              "Food",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ))
      ]),
    );
  }
}
