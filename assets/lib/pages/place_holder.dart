import 'package:assets/entities/color_pallete.dart';
import 'package:flutter/material.dart';

class PlaceHolderScreen extends StatelessWidget {
  const PlaceHolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor, 
      ),
      child: Expanded(child: const Placeholder()), 
    );
  }
}