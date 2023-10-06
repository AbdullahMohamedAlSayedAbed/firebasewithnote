
import 'package:flutter/material.dart';

class CardView extends StatelessWidget {
  const CardView({
    super.key,
 required this.title, required this.image,
  });


  final String title;
  final String image;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.asset(
              image,
              height: 130,
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}
