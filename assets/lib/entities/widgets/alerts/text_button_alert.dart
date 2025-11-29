import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/widgets/button/button.dart';
import 'package:flutter/material.dart';


class CustomTextAlert extends StatelessWidget {
  const CustomTextAlert({
    super.key,
    required this.text,
    required this.title, 
  });

  final String text;
  final String title; 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(  
      backgroundColor: primaryColor,  
      title: Text(title), 
      content: Text(text),  
      actions: [
        SizedBox(
          width: 86, 
          height: 50, 
          child: CustomFilledButton( 
            text: 'OK', 
            onPressed: (){
              Navigator.pop(context); 
            } 
          )
        )
      ],
    );
  }
}

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required BuildContext context,
    required String message,
    double? width,
    Color? background,
  }) : super(
    backgroundColor: background ?? const Color.fromARGB(0, 255, 255, 255),
    elevation: 0,
    width: width ?? (MediaQuery.of(context).size.width < 600 ? double.infinity : 600), 
    behavior: SnackBarBehavior.floating,  
    content: Container(
      decoration: BoxDecoration(
        color: tertiaryColor, 
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 5),
            blurRadius: 10,
            color: Color.fromARGB(20, 30, 30, 30),
          )
        ],
        borderRadius: MediaQuery.of(context).size.width > 600? BorderRadius.all(Radius.circular(200)) : BorderRadius.all(Radius.circular(20)), 
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15), 
        child: Text(
          message,
          style: const TextStyle(
            color: primaryColor, 
            fontSize: 15,
          ),
        ),
      ),
    ),
  );
}
