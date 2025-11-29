import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:flutter/material.dart'; 

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({
    super.key, 
    required this.text, 
    this.fillColor = tertiaryColor, 
    this.textColor = primaryColor, 
    this.width = double.infinity, 
    this.fontWeight = FontWeight.w200, 
    required this.onPressed,
    this.fontSize = 20, 
    this.overlayColor = const Color.fromARGB(10, 239, 136, 81), 
    this.height = 55, 
  });

  final Color fillColor; 
  final String text; 
  final Color textColor; 
  final double width; 
  final FontWeight fontWeight; 
  final dynamic onPressed; 
  final double fontSize; 
  final Color overlayColor; 
  final double height; 

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width, 
      child: FilledButton(
        onPressed: onPressed,         
        style: ButtonStyle( 
          backgroundColor: WidgetStateProperty.all(fillColor), 
          overlayColor: WidgetStatePropertyAll(overlayColor), 
          shadowColor: WidgetStatePropertyAll(const Color.fromARGB(0, 255, 255, 255)), 
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
            )
          )
        ),
        child: CustomNormalText(text: text, color: textColor, fontWeight: fontWeight, fontSize: fontSize,),    
      ),
    );
  }
}

class CustomIconFilledButton extends StatelessWidget {
  const CustomIconFilledButton({
    super.key, 
    required this.icon, 
    this.onPressed,  
    this.fillColor = tertiaryColor, 
    this.iconColor = primaryColor, 
    this.width = double.infinity, 
    this.fontWeight = FontWeight.w200, 
    this.borderColor = primaryColor, 
    this.radius = 10, 
    this.height = 55, 
    this.alignment = Alignment.center, 
    this.overlayColor = const Color.fromARGB(15, 232, 112, 48), 
  });

  final Color fillColor; 
  final Color iconColor; 
  final double width; 
  final double height; 
  final FontWeight fontWeight;  
  final Widget icon; 
  final dynamic onPressed; 
  final Color borderColor; 
  final double radius; 
  final Alignment alignment; 
  final Color overlayColor; 

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width, 
      child: IconButton.filled(
        alignment: alignment, 
        onPressed: onPressed,        
        style: OutlinedButton.styleFrom(
          alignment: alignment,
          side: BorderSide(color: borderColor, width: 2), 
          backgroundColor: fillColor, 
          shadowColor: const Color.fromARGB(0, 255, 255, 255),  
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius))  
          ),
          overlayColor: overlayColor, 
        ),
        icon: icon,  
        color: iconColor,
      ),
    );
  }
}

class CustomTextIconFilledButton extends StatelessWidget {
  const CustomTextIconFilledButton({
    super.key,
    required this.icon,
    required this.text,
    this.width = 160,
    this.height = 48,
    this.onPressed,
    this.radius = const BorderRadius.all(Radius.circular(10)), 
    this.iconColor = proffessionalBlack,
    this.fillColor = const Color.fromARGB(7, 0, 0, 0),
    this.padding = const EdgeInsets.symmetric(horizontal: 16), 
  });

  final Widget icon;
  final Widget text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color iconColor;
  final BorderRadiusGeometry radius;
  final Color fillColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(fillColor),
          shadowColor: WidgetStatePropertyAll(const Color.fromARGB(0, 255, 255, 255)),
          overlayColor: WidgetStatePropertyAll(const Color.fromARGB(15, 232, 112, 48)), 
          iconColor: WidgetStatePropertyAll(iconColor),
          side: WidgetStatePropertyAll(BorderSide(width: 0, color: const Color.fromARGB(0, 255, 255, 255))), 
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: radius, 
            ),
          ),
          padding: WidgetStatePropertyAll(padding), 
          alignment: Alignment.centerLeft, 
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, 
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12), 
            Expanded(child: text),
          ],
        ),
      ),
    );
  }
}
