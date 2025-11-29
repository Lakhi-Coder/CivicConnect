import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key, 
    required this.hintText, 
    this.fillColor = const Color.fromARGB(183, 234, 10, 10),
    required this.controller, 
    this.desktopText = '',
    this.onSubmitted, 
  });

  final String hintText; 
  final Color fillColor; 
  final TextEditingController controller;  
  final String desktopText;
  final ValueChanged<String>? onSubmitted; 

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        getScreenSize(context) != 'mobile' ? CustomNormalText(text: hintText, fontSize: 16, color: proffessionalBlack, fontWeight: FontWeight.w400,) : const SizedBox(), 
        getScreenSize(context) != 'mobile' ? const SizedBox(height: 8,) : const SizedBox(), 
        TextField(
          style: TextStyle(color: tertiaryColor), 
          controller: controller, 
          onSubmitted: onSubmitted, 
          decoration: InputDecoration( 
            filled: true, 
            fillColor: fillColor,  
            hintText: getScreenSize(context) == 'mobile' ? hintText : desktopText, 
            hintFadeDuration: const Duration(milliseconds: 100),
            hintStyle: const TextStyle(color: Color.fromARGB(86, 37, 37, 37)), 
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromARGB(0, 178, 178, 178)
              )
            ), 
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100), 
              borderSide: BorderSide(
                color: tertiaryColor 
              )
            )
          ), 
        ),
      ],
    ); 
  }
}


class CustomSearchBar extends StatefulWidget {
  CustomSearchBar({
    super.key, 
    required this.onSubmitted,  
    required this.controller, 
  });
  
  TextEditingController controller = TextEditingController(); 
  final ValueChanged<String> onSubmitted; 
  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState(onSubmitted); 
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  final ValueChanged<String> _onSubmitted;  

  _CustomSearchBarState(ValueChanged<String> onSubmitted) : _onSubmitted = onSubmitted;  

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus; 
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(  
        color: secondaryColor.withAlpha(30),   
        borderRadius: BorderRadius.circular(50), 
        border: Border.all(
          color: _isFocused ? tertiaryColor.withAlpha(200) : secondaryColor.withAlpha(10), 
          width: 1,
        ), 
      ),
      child: TextField(
        controller: widget.controller,
          focusNode: _focusNode,
          style: TextStyle(color: tertiaryColor), 
          cursorColor: tertiaryColor.withAlpha(150), 
          onSubmitted: _onSubmitted,
          decoration: InputDecoration( 
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14, right: 6),
              child: Opacity(
                opacity: _isFocused ? 0.5 : 0.2,
                child: SvgPicture.asset( 
                  'graphics/icons/app_icons/search_bar_icon.svg', 
                  width: 25,
                  height: 25,
                  colorFilter: _isFocused? ColorFilter.mode(
                    tertiaryColor, 
                    BlendMode.srcIn,  
                  ): null,
                ),
              ),
            ), 
            hintText: 'Search...', 
            hintStyle: TextStyle(color: secondaryColor, fontSize: 14),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          ),
        ),
    );
  }
}
