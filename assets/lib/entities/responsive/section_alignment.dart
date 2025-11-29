import 'package:flutter/material.dart';
import 'media_query.dart';


class AlignSections extends StatelessWidget {
  const AlignSections({
    super.key, 
    required this.section1, 
    required this.section2, 
  });

  final Widget section1;
  final Widget section2;

  @override
  Widget build(BuildContext context) {
    if (getScreenSize(context) == 'mobile') { 
      return section1; 
    } else {
      return section2;
    }
  }
}

class MobileViewGetStartedScreen extends StatelessWidget {
  const MobileViewGetStartedScreen({
    super.key, 
    required this.section1, 
    required this.section2,  
    this.flex1 = 5, 
    this.flex2 = 6, 
  });

  final Widget section1; 
  final Widget section2; 
  
  final int flex1; 
  final int flex2; 

  @override
  Widget build(BuildContext context) {
    return TwoExpandAlignment(
      section1: section1, 
      section2: section2, 
      flex1: flex1,  
      flex2: flex2,
    );
  }
}

class NonMobileViewGetStartedScreen extends StatelessWidget {
  const NonMobileViewGetStartedScreen({
    super.key, 
    required this.section1, 
    required this.section2, 
    this.desktopWidth = 450, 
    this.flex1 = 1, 
    this.flex2 = 1, 
  }); 

  final Widget section1; 
  final Widget section2; 
  final int flex1; 
  final int flex2; 
  final double desktopWidth;  

  @override
  Widget build(BuildContext context) {
    if (getScreenSize(context) == 'tablet') { 
      return TwoExpandAlignment(
        section1: section1, 
        section2: section2,  
        flex1: flex1, 
        flex2: flex2, 
      );
    } else {
      return Row(
        children: [
          SizedBox(
            width: desktopWidth, 
            child: section1, 
          ), 
          section2, 
        ],
      );
    }
  }
}

class TwoExpandAlignment extends StatelessWidget {
  const TwoExpandAlignment({
    super.key, 
    required this.section1, 
    required this.section2,
    this.flex1 = 1, 
    this.flex2 = 1,
  });

  final Widget section1;  
  final int flex1;  

  final Widget section2;  
  final int flex2;  

  @override
  Widget build(BuildContext context) {
    final mobileForm = Column(
      children: [
        Expanded(flex: flex1, child: section1), 
        Expanded(flex: flex2, child: section2),
      ],
    );

    final desktopForm = Row(
      children: [
        Expanded(flex: flex1, child: section1),
        Expanded(flex: flex2, child: section2),
      ],
    );

    return getScreenSize(context) == 'mobile' ? mobileForm : desktopForm;
  }
}


class SpecificSectionAlignment extends StatelessWidget {
  const SpecificSectionAlignment({
    super.key, 
    this.flex1 = 1, 
    this.flex2 = 1,  
    this.mode = true,  
    required this.section1,  
    required this.section2, 
  });

  final bool mode;  
  final Widget section1; 
  final Widget section2; 
  final int flex1; 
  final int flex2; 

  @override
  Widget build(BuildContext context) {
    final rowForm = Row(
      children: [ 
        Expanded(flex: flex1,child: section1,), 
        Expanded(flex: flex2,child: section2,), 
      ]
    ); 

    final columnForm = Column(
      children: [
        Expanded(flex: flex1,child: section1,),  
        Expanded(flex: flex2,child: section2,), 
      ],
    ); 

    return mode == true ? rowForm : columnForm;  
  }
}