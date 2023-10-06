import 'package:flutter/material.dart';

class ImageLogo extends StatelessWidget {
  const ImageLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 80,
      backgroundImage: AssetImage('images/flowers-19830_640.jpg'),
    );
  }
}
