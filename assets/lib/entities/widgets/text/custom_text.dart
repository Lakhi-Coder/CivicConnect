import 'package:assets/entities/color_pallete.dart';
import 'package:flutter/material.dart';

class CustomNormalText extends StatelessWidget {
  final String text;
  final Color color;
  final FontWeight fontWeight; 
  final double fontSize;  
  final TextAlign textAlign;  
  final dynamic maxLines; 
  final TextOverflow overflow; 

  const CustomNormalText({
    super.key,
    required this.text, 
    this.fontSize = 20, 
    this.textAlign = TextAlign.left, 
    this.color = secondaryColor, 
    this.fontWeight = FontWeight.w400, 
    this.overflow = TextOverflow.clip, 
    this.maxLines, 
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        color: color, 
        fontWeight: fontWeight,  
        fontSize: fontSize, 
        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, 
      ),
      child: Text(text, textAlign: textAlign), 
    );
  }
}

