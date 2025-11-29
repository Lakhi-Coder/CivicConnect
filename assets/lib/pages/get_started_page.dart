import 'package:assets/pages/login_page.dart';
import 'package:assets/pages/signup_page.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/widgets/button/button.dart';
import 'package:assets/entities/widgets/logo.dart';
import 'package:flutter/material.dart'; 
import 'package:assets/entities/responsive/section_alignment.dart';
import 'package:assets/entities/color_pallete.dart'; 


class GetStartedScrn extends StatelessWidget {
  const GetStartedScrn({
    super.key
  });  

  @override
  Widget build(BuildContext context) { 
    var mobileVariation = BorderRadius.only( 
        bottomRight: Radius.circular(25), 
        bottomLeft: Radius.circular(25), 
    ); 
    var desktopVariation = BorderRadius.only( 
        topLeft: Radius.circular(25), 
        bottomLeft: Radius.circular(25), 
    ); 

    Widget image = Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: tertiaryColor,
          borderRadius: getScreenSize(context) == 'mobile' ? mobileVariation : mobileVariation,
        ),
      ),
    );


    return Scaffold(
      body: Stack(
        children: [
          Container( 
            decoration: BoxDecoration(color: tertiaryColor,), 
            child: AlignSections(
              section1: GetStartedUI() /*MobileViewGetStartedScreen(section1: image, section2: GetStartedUI(),)*/, 
              section2: GetStartedUI()/*NonMobileViewGetStartedScreen(section1: GetStartedUI(), section2: image,)*/, 
            ),
          ),
          Positioned(
            top: 40, 
            left: 35, 
            child: Logo()  
          )
        ],
      ),
    );
  }
}



class GetStartedUI extends StatelessWidget {
  const GetStartedUI({
    super.key, 
  });

  @override
  Widget build(BuildContext context) { 
    return Container(
      decoration: BoxDecoration( 
      color: tertiaryColor,  
      ), 
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.max, 
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Text(
                  'Get Started', 
                  style: TextStyle( 
                    fontSize: 40, 
                    color: primaryColor 
                  ),
                ), 
                SizedBox(height: 10,), 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: Text(
                    'We help users stay informed about local, state, and federal government activities.', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: translucentColor, fontSize: 17),   
                  ), 
                ), 
                SizedBox(height: 45,),  
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomFilledButton(
                      onPressed: (){
                        Navigator.of(context).push( 
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const SignupPage(),  
                            transitionDuration: Duration(seconds: 0), 
                          ), 
                        ); 
                      },
                      text: 'Signup',      
                      fillColor: primaryColor, 
                      textColor: tertiaryColor, 
                      fontWeight: FontWeight.w400,
                      width: 150, 
                    ),
                    SizedBox(width: 25,), 
                    SizedBox(
                      width: 64,
                      child: CustomIconFilledButton(
                        icon: Icon(Icons.login), 
                        fillColor: primaryColor, 
                        iconColor: tertiaryColor,  
                        onPressed: (){ 
                          Navigator.of(context).push( 
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),  
                              transitionDuration: Duration(seconds: 0), 
                            ), 
                          ); 
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ), 
    );
  }
}

