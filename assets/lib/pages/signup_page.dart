import 'package:assets/pages/home_page.dart';
import 'package:assets/pages/login_page.dart';
import 'package:assets/entities/authentication/authenticator.dart';
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/responsive/section_alignment.dart';
import 'package:assets/entities/widgets/alerts/text_button_alert.dart';
import 'package:assets/entities/widgets/button/button.dart';
import 'package:assets/entities/widgets/logo.dart';
import 'package:assets/entities/widgets/text_field/text_field.dart';
import 'package:flutter/material.dart'; 
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:flutter_svg/svg.dart'; 
import 'package:assets/entities/widgets/auth_types/google_auth.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key}); 

  @override
  Widget build(BuildContext context) { 
    return Scaffold( 
      body: Stack( 
        children: [ 
          Container(  
            decoration: BoxDecoration(color: primaryColor), 
            child: AlignSections( 
              section1: Column( 
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Expanded(child: SignupUI(),),
                ],
              ), 
              section2: Center(child: SizedBox(width: 400, child: SignupUI())),   
            ),
          ),
          Positioned(top: 40, left: 30, child: Logo(),), 
        ],
      ),
    );
  }
}

class SignupUI extends StatelessWidget {
  const SignupUI({super.key});

  @override
  Widget build(BuildContext context) {
    final username = TextEditingController(); 
    final password = TextEditingController(); 
    final address = TextEditingController(); 
    
    TextEditingController alertInfo = TextEditingController();  

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

    /*var addressTextField = CustomTextField(
      controller: address, 
      hintText: "Address", 
      desktopText: '',
      fillColor: const Color.fromARGB(81, 227, 227, 227),
    ); */

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center( 
        child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false, 
            child: 
              Column(
                mainAxisAlignment: getScreenSize(context) == 'mobile' ? MainAxisAlignment.start : MainAxisAlignment.center, 
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20), 
                    child: Container(
                      alignment: Alignment.topLeft, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          CustomNormalText( 
                            text: 'Welcome To \nCivicConnect!',  
                            color: secondaryColor, 
                            fontSize: 22, 
                            fontWeight: FontWeight.w300,
                          ),  
                          CustomNormalText( 
                            text: "Create an Account", 
                            color: const Color.fromARGB(221, 51, 23, 2), 
                            fontSize: 48,
                            textAlign: TextAlign.left,
                          ), 
                        ],
                      ),
                    ),
                  ), 
                  LoginAccountButton(), 
                  SizedBox(height: 17,), 
                  Wrap(
                    direction: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: GoogleSignInButton(),
                      ), 
                      /*Padding(
                        padding: const EdgeInsets.all(9),
                        child: AppleSignInButton(),
                      ),*/
                    ],
                  ), 
                  SizedBox(height: 12,), 
                  CustomNormalText(text: 'OR', color: proffessionalBlack, fontWeight: FontWeight.w300,), 
    
                  Padding(
                    padding: const EdgeInsets.only(top: 15), 
                    child: SizedBox( 
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max, 
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [ 
                            usernameTextField,
                            SizedBox(height: 20,), 
                            passwordTextField,
                            SizedBox(height: 20,), 
                            Padding(
                              padding: const EdgeInsets.only(top: 25), 
                              child: CustomFilledButton( 
                                onPressed: () async {
                                  await signUp(context, username.text, password.text, alertInfo) ? (Navigator.of(context).push( 
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
                                fillColor: tertiaryColor,
                              ),
                            ), 
                          ],
                        ),
                      )
                    ),
                  ), 
                ],
              )
            ),
          ], 
        ),
      ),
    );
  }
}

class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 200),
      child: Expanded(
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
      ),
    );
  }
}

class LoginAccountButton extends StatelessWidget {
  const LoginAccountButton({
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
              pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),  
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
                    text: "Have An Account?", 
                    style: TextStyle(
                      color: proffessionalBlack,
                      fontSize: 16,
                    )
                  ), 
                  TextSpan(
                    text: " Login", 
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
      )
    );
  }
}