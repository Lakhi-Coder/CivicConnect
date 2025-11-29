import 'package:assets/Pages/signup_page.dart';
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/widgets/button/button.dart';
import 'package:assets/entities/widgets/logo.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/pages/place_holder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double kRowHeight = 56.0;
const double kRailItemWidth = 60.0;
const double kIconSlot = 40.0;
const double kIconSize = 24.0;
const double kLeftInset = 30.0;


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.desktopWidthToggle,
    required this.extendedWidthToggle,
    required this.drawerItems,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> drawerItems;
  final double desktopWidthToggle;
  final double extendedWidthToggle; 
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    double expandedDecorationCondition = desktopWidthToggle >= 120 && getScreenSize(context) == 'desktop' || getScreenSize(context) == 'mobile'? 5: 0; 
    return Column(
      children: [
        CustomLogoTitle(), 
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 450),
              child: ListView.builder(
                physics: ClampingScrollPhysics(),
                itemCount: drawerItems.length,
                itemBuilder: (context, index) { 
                  final item = drawerItems[index];
                  final bool isActive = index == selectedIndex;
              
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: expandedDecorationCondition),  
                    child: CustomDrawerTiles(
                      desktopWidthToggle: desktopWidthToggle,
                      icon: SvgPicture.asset(
                        item['iconPath'], 
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        colorFilter: ColorFilter.mode(
                          isActive ? primaryColor : const Color.fromARGB(173, 133, 97, 78),
                          BlendMode.srcIn,
                        ),
                      ),
                      title: item['title'],
                      buttonColor: isActive
                          ? primaryColor
                          : const Color.fromARGB(176, 144, 117, 102),
                      onTap: () => onSelect(index),
                      isActive: isActive,
                    ),
                  ); 
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: expandedDecorationCondition),  
          child: CustomDrawerTiles(
            desktopWidthToggle: desktopWidthToggle,
            icon: SvgPicture.asset(
              "graphics/icons/app_icons/off_icon.svg",
              fit: BoxFit.contain,
              alignment: Alignment.center,
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(172, 173, 72, 61),
                BlendMode.srcIn,
              ),
            ),
            title: "Sign Out",
            buttonColor: const Color.fromARGB(172, 173, 72, 61), 
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut(); 
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const SignupPage(),  
                    transitionDuration: Duration(seconds: 0), 
                  ),
                  (route) => false, 
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            }, 
          ),
        ),
        SizedBox(height: 20,) 
      ],
    );
  }
}

class CustomDrawerTiles extends StatelessWidget {
  const CustomDrawerTiles({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.desktopWidthToggle,
    this.buttonColor = const Color.fromARGB(176, 144, 117, 102),
    this.tabletListPositioning = true,
    this.desktopListPositioning = true,
    this.isActive = false,
  });

  final Widget icon;
  final String title;
  final VoidCallback onTap;
  final double desktopWidthToggle;
  final Color buttonColor;
  final bool tabletListPositioning;
  final bool desktopListPositioning;
  final bool isActive;

  bool get _isCollapsedDesktop => desktopWidthToggle <= 120;

  @override
  Widget build(BuildContext context) {
    final screen = getScreenSize(context);
    bool isCollapsed = desktopWidthToggle <= 120;
    if (screen != 'desktop') {
      isCollapsed = true;
    }

    final Color activeBg = tertiaryColor;

    if (isCollapsed && screen != 'mobile') {
      return Padding(
        padding: EdgeInsets.only(left: 22),
        child: Align(
          alignment: Alignment.centerLeft, 
          child: Tooltip(
            message: title,
            triggerMode: TooltipTriggerMode.longPress,
            child: SizedBox(
              width: 56,
              height: 56,
              child: CustomIconFilledButton(
                icon: SizedBox.square(
                  dimension: kIconSize, 
                  child: icon,
                ),
                onPressed: onTap,
                radius: 100,
                alignment: Alignment.center,
                overlayColor: tertiaryColor,
                fillColor: isActive ? activeBg : Colors.transparent,
                borderColor: Colors.transparent,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: kRowHeight,
      child: CustomTextIconFilledButton(
        icon: SizedBox(
          width: kIconSlot,
          height: kRowHeight,
          child: Center(
            child: SizedBox.square(
              dimension: kIconSize,
              child: icon,
            ),
          ),
        ),
        text: CustomNormalText(
          text: title,
          color: buttonColor, 
          fontSize: 16, 
          overflow: TextOverflow.ellipsis, 
        ),
        onPressed: onTap,
        radius: const BorderRadius.all(
          Radius.circular(10), 
        ),
        padding: const EdgeInsets.only(left: kLeftInset),
        fillColor: isActive ? activeBg : Colors.transparent,
      ),
    );
  }
}
