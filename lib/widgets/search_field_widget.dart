import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchFieldWidget extends StatefulWidget {
  final IconData? icon;
  final TextInputType? inputType;
  final TextEditingController textController;
  final EdgeInsets padding;
  final Color hintColor;
  final Color iconColor;
  final FocusNode? focusNode;
  final ValueChanged? onFieldSubmitted;
  final ValueChanged? onChanged;
  final VoidCallback onPressed;
  final bool autoFocus;
  final TextInputAction? inputAction;
  final Widget? suffixIcon;
  final FormFieldValidator? validator;
  final GestureTapCallback? onTap;

  @override
  _SearchFieldWidgetState createState() => _SearchFieldWidgetState();

  SearchFieldWidget({
    Key? key,
    this.icon,
    required this.textController,
    this.inputType,
    this.padding = const EdgeInsets.all(0),
    this.hintColor = Colors.grey,
    this.iconColor = Colors.grey,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.autoFocus = false,
    this.inputAction,
    this.suffixIcon,
    this.validator,
    this.onTap,
    required this.onPressed,
  }) : super(key: key);
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  final _fieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    AppTheme appTheme = AppTheme.light();
    return Container(
      height: 80,
      padding: EdgeInsets.all(18),
      child: Card(
        elevation: 5,
        shadowColor: appTheme.textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: TextFormField(
          key: _fieldKey,
          style: normalTextStyle(16, fontFamily: FontFamily.sfProText),
          decoration: InputDecoration(
            counterText: '',
            prefixIcon: Icon(
              Icons.search,
              color: appTheme.primaryColor,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.close,
                color: appTheme.darkGreyColor,
              ),
              onPressed: widget.onPressed,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          keyboardType: TextInputType.name,
          controller: this.widget.textController,
          onChanged: widget.onChanged,
          textCapitalization: TextCapitalization.none,
          validator: this.widget.validator,
          onTap: this.widget.onTap,
        ),
      ),
    );
  }
}
