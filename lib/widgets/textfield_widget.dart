import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatefulWidget {
  final IconData? icon;
  final String? hint;
  final String? errorText;
  final bool isObscure;
  final bool isIcon;
  final TextInputType? inputType;
  final TextEditingController textController;
  final EdgeInsets padding;
  final Color hintColor;
  final Color iconColor;
  final Color borderColor;
  final FocusNode? focusNode;
  final ValueChanged? onFieldSubmitted;
  final ValueChanged? onChanged;
  final bool autoFocus;
  final TextInputAction? inputAction;
  final Widget? suffixIcon;
  final FormFieldValidator? validator;
  final bool? validate;
  final int maxLength;
  final int maxLines;
  final int minLines;
  final bool enabled;
  final EdgeInsets margin;
  final TextInputFormatter textInputFormatter;

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();

  TextFieldWidget({
    Key? key,
    this.icon,
    this.errorText,
    required this.textController,
    this.inputType,
    this.hint,
    this.isObscure = false,
    this.isIcon = true,
    this.padding = const EdgeInsets.all(0),
    this.hintColor = Colors.grey,
    this.iconColor = Colors.grey,
    this.borderColor = Colors.grey,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.autoFocus = false,
    this.inputAction,
    this.suffixIcon,
    this.validator,
    this.validate,
    this.maxLines = 1,
    this.minLines = 1,
    required this.textInputFormatter,
    required this.maxLength,
    required this.margin,
    this.enabled = true,
  }) : super(key: key);
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  final _fieldKey = GlobalKey<FormFieldState>();
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _hasError = widget.errorText?.isNotEmpty ?? false;
      });
    });
    ThemeData themeData = AppTheme.light().buildThemeData();
    return Stack(children: [
      Container(
        margin: this.widget.margin,
        child: TextFormField(
          key: _fieldKey,
          style: normalTextStyle(16, fontFamily: FontFamily.sfProText),
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            helperText: '',
            hintText: (widget.focusNode?.hasFocus ?? false) ? '' : widget.hint,
            hintStyle: normalTextStyle(
              16,
              fontFamily: FontFamily.sfProText,
              color: themeData.hintColor,
            ),
            counterText: '',
            errorBorder: themeData.inputDecorationTheme.errorBorder,
            border: themeData.inputDecorationTheme.border?.copyWith(borderSide: BorderSide(color: widget.borderColor == Colors.grey ? Color(0xFF808080): widget.borderColor)),
            enabledBorder: themeData.inputDecorationTheme.border?.copyWith(borderSide: BorderSide(color: widget.borderColor == Colors.grey ? Color(0xFF808080): widget.borderColor)),
            focusedBorder: themeData.inputDecorationTheme.border?.copyWith(borderSide: BorderSide(color: widget.borderColor == Colors.grey ? Color(0xFFE16726): widget.borderColor)),
            suffixIcon: widget.suffixIcon,
            contentPadding: EdgeInsets.all(10.0),
          ),
          keyboardType: this.widget.inputType,
          // inputFormatters: <TextInputFormatter>[
          //   this.textInputFormatter,
          // ],
          controller: widget.textController,
          focusNode: widget.focusNode,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: widget.onChanged,
          autofocus: widget.autoFocus,
          textInputAction: widget.inputAction,
          obscureText: this.widget.isObscure,
          maxLength: this.widget.maxLength,
          textCapitalization: TextCapitalization.none,
          validator: widget.validator,
          enabled: this.widget.enabled,
        ),
      ),
      if (_hasError) ...[
        Padding(
          padding: EdgeInsets.only(top: 60, bottom: 0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "${widget.errorText}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontFamily.sfProText,
                color: AppTheme.light().redColor,
                fontSize: 14,
              ),
            ),
          ),
        )
      ],
    ]);
  }
}
