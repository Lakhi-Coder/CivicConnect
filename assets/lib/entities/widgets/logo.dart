import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';
import '../color_pallete.dart';


class Logo extends StatelessWidget {
  const Logo({
    super.key, 
    this.widthHeight = 56, 
  });

  final double widthHeight;  


  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container( 
          decoration: BoxDecoration( 
            color: tertiaryColor, 
            borderRadius: BorderRadius.all( 
              Radius.circular(40) 
            )
          ),
          height: widthHeight,   
          width: widthHeight,   
        ),
        SizedBox(
          width: widthHeight - 19,
          height: widthHeight - 19,
          child: SizedBox( 
            child: Image.asset('graphics/icons/civic_connect_app_icon.png')
            ),
        ), 
      ],
    );
  }
}

class CustomLogoTitle extends StatelessWidget {
  const CustomLogoTitle({
    super.key,
    this.widthHeight = 60, 
    this.fontSize = 23, 
  });
  final double widthHeight; 
  final double fontSize; 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        children: [
          Padding( 
            padding: const EdgeInsets.only(left: 20, right: 12),  
            child: Logo(
              widthHeight: widthHeight,  
            ),
          ),
          Flexible(
            child: CustomNormalText(
              text: 'CivicConnect', 
              color: tertiaryColor, 
              fontSize: fontSize, 
              overflow: TextOverflow.ellipsis,
            ),
          ), 
        ],
      ),
    );
  }
}