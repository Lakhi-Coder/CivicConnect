import 'package:assets/pages/home_page.dart';
import 'package:assets/pages/signup_page.dart';
import 'package:assets/entities/authentication/authenticator.dart';
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/responsive/section_alignment.dart';
import 'package:assets/entities/widgets/alerts/text_button_alert.dart';
import 'package:assets/entities/widgets/auth_types/google_auth.dart';
import 'package:assets/entities/widgets/button/button.dart';
import 'package:assets/entities/widgets/logo.dart';
import 'package:assets/entities/widgets/text_field/text_field.dart';
import 'package:flutter/material.dart'; 
import 'package:assets/entities/widgets/text/custom_text.dart'; 
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatelessWidget { 
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) { 
    return Scaffold( 
      body: Stack( 
        children: [ 
          Container(  
            decoration: BoxDecoration(color: primaryColor), 
            child: AlignSections( 
              section1: Column(
                children: [
                  /*Expanded(child: SizedBox()), */
                  Expanded(child: LoginUI()),  
                ]
              ), 
              section2: Center(child: SizedBox(width: 400, child: LoginUI()))/*NonMobileViewGetStartedScreen(section1: LoginUI(), section2: SizedBox())  */
            ),
          ),
          Positioned(top: 40, left: 30, child: Logo(),), 
        ],
      ),
    );
  }
}

class LoginUI extends StatelessWidget {
  const LoginUI({super.key}); 

  @override
  Widget build(BuildContext context) {
    final username = TextEditingController(); 
    final password = TextEditingController(); 

    var usernameTextField = CustomTextField( 
      controller: username, 
      hintText: 'Username',   
      desktopText: '123@example.com',  
      fillColor: const Color.fromARGB(81, 227, 227, 227),   
    );

    var passwordTextField = CustomTextField( 
      controller: password,
      hintText: 'Password', 
      desktopText: 'example@12345678',    
      fillColor: const Color.fromARGB(81, 227, 227, 227), 
    );

    TextEditingController alertInfo = TextEditingController(); 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining( 
            hasScrollBody: false, 
            child: Column(
              mainAxisAlignment: getScreenSize(context) == 'mobile' ? MainAxisAlignment.start : MainAxisAlignment.center, 
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20), 
                  child: Container( 
                    alignment: Alignment.topLeft, 
                    height: 100, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomNormalText(
                          text: 'Welcome Back!', 
                          color: secondaryColor, 
                          fontSize: 22, 
                          fontWeight: FontWeight.w300,
                        ),  
                        CustomNormalText( 
                          text: "Login", 
                          color: brandColorBlack, 
                          fontSize: 48,
                          textAlign: TextAlign.left,
                        ), 
                      ],
                    ),
                  ),
                ), 
                SignupAccountButton(), 
                SizedBox(height: 15,), 
                Wrap(
                  direction: Axis.horizontal, 
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GoogleSignInButton(),
                    ), 
                    /*Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomTextIconFilledButton(  
                        text: CustomNormalText(text: 'Apple', fontSize: 18, color: lightProffessionalBlack,),  
                        icon: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SvgPicture.asset( 
                            'graphics/icons/authentication_icons/icons8-apple-inc.svg', 
                            width: 30, 
                            height: 30, 
                          ),
                        ),  
                      ),
                    ),*/
                  ],
                ), 
                SizedBox(height: 20,), 
                CustomNormalText(text: 'OR', color: proffessionalBlack, fontWeight: FontWeight.w300,), 
      
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox( 
                    child: SingleChildScrollView(
                      child: Column( 
                        mainAxisSize: MainAxisSize.max, 
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [ 
                          usernameTextField,
                          SizedBox(height: 20,), 
                          passwordTextField,
                          SizedBox(height: 10,), 
                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: CustomFilledButton( 
                              onPressed: () async {
                                await signIn(context, username.text, password.text, alertInfo) ? (Navigator.of(context).push( 
                                  PageRouteBuilder( 
                                    pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),  
                                    transitionDuration: Duration(seconds: 0), 
                                  ), 
                                ), 
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    CustomSnackBar(context: context, message: alertInfo.text) 
                                  ) 
                                ) : ScaffoldMessenger.of(context).showSnackBar(
                                    CustomSnackBar(context: context, message: alertInfo.text)
                                  ); 
                              },
                              text: 'Submit', 
                              fontWeight: FontWeight.w400,
                            ),
                          ),  
                        ],
                      ),
                    ), 
                  ),
                )
              ],
            ),
          ),
        ]
      ),
    );
  }
}

class SignupAccountButton extends StatelessWidget {
  const SignupAccountButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextButton(
        onPressed: (){
          Navigator.of(context).push( 
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const SignupPage(),  
              transitionDuration: Duration(seconds: 0), 
            ), 
          ); 
        }, 
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(primaryColor),  
          overlayColor: WidgetStatePropertyAll(const Color.fromARGB(0, 255, 161, 111)), 
        ),
        child: SizedBox(
          child: Center(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: "Need to Create Account?", 
                    style: TextStyle(
                      color: proffessionalBlack,
                      fontSize: 16,
                    )
                  ), 
                  TextSpan(
                    text: " Signup", 
                    style: TextStyle(
                      color: tertiaryColor,
                      fontSize: 16,
                    )
                  ), 
                ]
              ),
            ),
          )
        ),
      ),
    );
  }
}

