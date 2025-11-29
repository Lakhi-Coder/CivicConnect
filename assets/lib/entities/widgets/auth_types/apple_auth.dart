import 'package:assets/pages/home_page.dart';
import 'package:assets/entities/authentication/authenticator.dart';
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/widgets/alerts/text_button_alert.dart';
import 'package:assets/entities/widgets/button/button.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class AppleSignInButton extends StatelessWidget {
  AppleSignInButton({
    super.key,
  });

  final TextEditingController googleController = TextEditingController(); 

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300), 
      child: CustomTextIconFilledButton(  
        onPressed: () async {
          final success = await loginGoogle(context, googleController);
      
          if (success) {
            if (context.mounted) {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                  transitionDuration: Duration.zero,
                ),
              );
      
              showDialog(
                context: context,
                builder: (context) => CustomTextAlert( 
                  text: googleController.text,
                  title: "Login Success",
                ),
              );
            }
          } else {
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) => CustomTextAlert( 
                  text: 'Sorry, try again', 
                  title: "Login Error",
                ),
              );
            }
          }
        }, 
        text: CustomNormalText(text: 'Google', fontSize: 18, color: lightProffessionalBlack,),
        icon: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SvgPicture.asset(
            'graphics/icons/authentication_icons/icons8-google.svg', 
            width: 30, 
            height: 30, 
          ),
        ), 
      ),
    );
  }
}