import 'package:flutter/material.dart';

Widget CardMomento(String title, String subTitle) {
  return Card(
    child: Column(
      children: [
        Text(title),
        Text(subTitle),
      ],
    ),
    color: Colors.amber,
  );
}
