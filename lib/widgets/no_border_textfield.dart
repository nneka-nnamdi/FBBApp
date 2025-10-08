import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoBorderTextField extends StatefulWidget {
  NoBorderTextField({
    Key? key,
    required this.editingController,
    required this.hintText,
    required this.maxLength,
    this.textInputAction,
    this.onChanged,
    required this.validator,
    this.onFieldSubmitted,
    this.autoFocus,
    this.focusNode,
    this.inputAction,
    this.suffixIcon,
    this.validate,
    this.errorText,
    this.border = InputBorder.none,
    required this.inputType,
    this.maxLines = 1,
    this.enabled = true,
    required this.textInputFormatter,
  }) : super(key: key);

  final TextEditingController editingController;
  final String hintText;
  final String? errorText;
  final int maxLength;
  final int maxLines;
  final ValueChanged? onFieldSubmitted;
  final ValueChanged? onChanged;
  final bool? autoFocus;
  final bool enabled;
  final FocusNode? focusNode;
  final InputBorder? border;
  final TextInputAction? inputAction;
  final IconButton? suffixIcon;
  final FormFieldValidator validator;
  final bool? validate;
  final TextInputAction? textInputAction;
  final TextInputType inputType;
  final TextInputFormatter textInputFormatter;

  @override
  _NoBorderTextFieldState createState() => _NoBorderTextFieldState();
}

class _NoBorderTextFieldState extends State<NoBorderTextField> {
  final AppTheme appTheme = AppTheme.light();

  final ThemeData themeData = AppTheme.light().buildThemeData();

  final _fieldKey = GlobalKey<FormFieldState>();

  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _hasError = widget.errorText?.isNotEmpty ?? false;
      });
    });
    return Stack(children: [
      TextFormField(
        key: _fieldKey,
        style: normalTextStyle(16, fontFamily: FontFamily.sfProText),
        decoration: InputDecoration(
          helperText: '',
          hintText: (widget.focusNode?.hasFocus ?? false) ? '' : widget.hintText,
          hintStyle: normalTextStyle(
            16,
            fontFamily: FontFamily.sfProText,
            color: appTheme.hintColor,
          ),
          enabled: this.widget.enabled,
          // errorText: this.widget.errorText,
          // errorStyle: themeData.inputDecorationTheme.errorStyle,
          counterText: '',
          border: widget.border,
          focusedBorder: widget.border,
          enabledBorder: widget.border,
          errorBorder: widget.border,
          disabledBorder: widget.border,
          contentPadding: EdgeInsets.all(5),
        ),
        keyboardType: TextInputType.name,
        // inputFormatters: <TextInputFormatter>[
        //   this.textInputFormatter,
        // ],
        controller: this.widget.editingController,
        onChanged: widget.onChanged,
        maxLength: widget.maxLength,
        maxLines: this.widget.maxLines,
        textCapitalization: TextCapitalization.none,
        validator: this.widget.validator,
        focusNode: widget.focusNode,
        textInputAction: this.widget.textInputAction,
      ),
      if (_hasError) ...[
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 0),
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
