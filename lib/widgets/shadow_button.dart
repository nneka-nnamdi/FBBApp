import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:flutter/material.dart';

class ShadowButton extends StatelessWidget {
  final Widget child;
  final double height;
  final double borderRadius;

  ShadowButton(
      {required this.child, required this.height, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.light().primaryColor.withOpacity(0.5),
            blurRadius: height / 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: this.child,
    );
  }
}
