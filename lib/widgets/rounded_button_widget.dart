import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:flutter/material.dart';

class RoundedButtonWidget extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Color textColor;
  final double? width;
  final VoidCallback onPressed;
  final Alignment? align;
  final double textSize;
  final EdgeInsets? padding;

  const RoundedButtonWidget({
    Key? key,
    this.width,
    this.align,
    this.textSize = 18,
    this.padding,
    required this.buttonText,
    required this.buttonColor,
    this.textColor = Colors.white,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: this.padding == null ? EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 0) : this.padding!,
      child: Container(
        width:
            this.width == null ? MediaQuery.of(context).size.width : this.width,
        height: 50,
        child: ElevatedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      side: BorderSide(color: buttonColor)))),
          onPressed: onPressed,
          child: Align(
            alignment: align == null ? Alignment.center : Alignment.centerLeft,
            child: AutoSizeText(
              buttonText,
              style: normalTextStyle(
                this.textSize,
                fontFamily: FontFamily.sfProText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
