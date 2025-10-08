import 'package:auto_size_text/auto_size_text.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/services/navigation_service.dart';
import 'package:fight_blight_bmore/stores/form/form_store.dart';
import 'package:fight_blight_bmore/utils/device/device_utils.dart';
import 'package:fight_blight_bmore/utils/routes/routes.dart';
import 'package:fight_blight_bmore/widgets/loader_widget.dart';
import 'package:fight_blight_bmore/widgets/rounded_button_widget.dart';
import 'package:fight_blight_bmore/widgets/textfield_widget.dart';
import 'package:fight_blight_bmore/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  AppTheme appTheme = AppTheme.light();
  bool _validateNewPassword = false;
  bool _validateConfirmPassword = false;

  //focus node:-----------------------------------------------------------------
  late FocusNode _newPasswordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  //stores:---------------------------------------------------------------------
  final _store = FormStore();

  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureTextConfirm = true;

  @override
  void initState() {
    super.initState();
    _newPasswordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleConfirm() {
    setState(() {
      _obscureTextConfirm = !_obscureTextConfirm;
    });
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _store.context = context;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: LoaderWidget(
        child: Scaffold(
          primary: true,
          body: _buildBody(),
        ),
        state: _store.loading,
      ),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TopBar(),
          Flexible(flex: 1, child: _buildRightSide()),
        ],
      ),
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 14.0),
          Padding(
            padding:
                EdgeInsets.only(left: 24.0, right: 24, top: 20, bottom: 20),
            child: Text(
              Strings.resetYourPassword,
              style: normalTextStyle(20, fontFamily: FontFamily.sfProDisplay),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 24.0),
            child: Text(
              (ModalRoute.of(context)?.settings.arguments != null)
                  ? (ModalRoute.of(context)?.settings.arguments
                          as ScreenArguments)
                      .email
                  : '',
              style: boldTextStyle(16, fontFamily: FontFamily.sfProText),
            ),
          ),
          SizedBox(height: 14.0),
          _buildTextfieldTitle(Strings.newPassword),
          _buildNewPasswordField(),
          _buildTextfieldTitle(Strings.reEnterNewPassword),
          _buildConfirmPasswordField(),
          _buildResetPasswordButton(),
        ],
      ),
    );
  }

  Widget _buildTextfieldTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 24.0),
      child: Text(
        text,
        style: normalTextStyle(16, fontFamily: FontFamily.sfProText),
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return Observer(
      builder: (context) {
        return Stack(children: [
          TextFieldWidget(
            hint: Strings.newPassword,
            isObscure: _obscureText,
            padding: EdgeInsets.only(top: 16.0),
            textController: _newPasswordController,
            inputAction: TextInputAction.next,
            focusNode: _newPasswordFocusNode,
            textInputFormatter: FilteringTextInputFormatter.allow(
                RegExp(r"[a-zA-Z0-9.@!#$%&'*+/=?^_`{|}~-]")),
            validator: (value) {
              _store.validatePassword(value);
            },
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
            },
            errorText:
                _validateNewPassword ? _store.formErrorStore.password : null,
            onChanged: (value) {
              _store.setPassword(_newPasswordController.text);
            },
            maxLength: 100,
            margin: EdgeInsets.only(
              left: 24,
              top: 8,
              bottom: 0,
              right: 24,
            ),
            suffixIcon: IconButton(
              constraints: BoxConstraints(
                maxWidth: 60,
                minWidth: 60,
              ),
              onPressed: _toggle,
              icon: Container(
                  width: 100,
                  padding: EdgeInsets.only(right: 10.0),
                  child: AutoSizeText(
                    _obscureText ? Strings.show : Strings.hide,
                    textAlign: TextAlign.end,
                    style: normalTextStyle(12,
                        fontFamily: FontFamily.sfProText,
                        color: appTheme.primaryColor),
                  )),
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return Observer(
      builder: (context) {
        return Stack(children: [
          TextFieldWidget(
            hint: Strings.reEnterNewPassword,
            isObscure: _obscureTextConfirm,
            padding: EdgeInsets.only(top: 16.0),
            textController: _confirmPasswordController,
            textInputFormatter: FilteringTextInputFormatter.allow(
                RegExp(r"[a-zA-Z0-9.@!#$%&'*+/=?^_`{|}~-]")),
            focusNode: _confirmPasswordFocusNode,
            validator: (value) {
              _store.validateConfirmPassword(value);
            },
            errorText: _validateConfirmPassword
                ? _store.formErrorStore.confirmPassword
                : null,
            onChanged: (value) {
              _store.setConfirmPassword(_confirmPasswordController.text);
            },
            maxLength: 100,
            margin: EdgeInsets.only(
              left: 24,
              top: 8,
              bottom: 0,
              right: 24,
            ),
            suffixIcon: IconButton(
              constraints: BoxConstraints(
                maxWidth: 60,
                minWidth: 60,
              ),
              onPressed: _toggleConfirm,
              icon: Container(
                  width: 100,
                  padding: EdgeInsets.only(right: 10.0),
                  child: AutoSizeText(
                    _obscureTextConfirm ? Strings.show : Strings.hide,
                    textAlign: TextAlign.end,
                    style: normalTextStyle(12,
                        fontFamily: FontFamily.sfProText,
                        color: appTheme.primaryColor),
                  )),
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildResetPasswordButton() {
    return RoundedButtonWidget(
      buttonText: Strings.reset,
      buttonColor: appTheme.primaryColor,
      textColor: Colors.white,
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _validateNewPassword = true;
            _validateConfirmPassword = true;
          });
        } else {
          setState(() {
            _validateNewPassword = true;
            _validateConfirmPassword = true;
          });
        }
        if (_store.canResetPassword) {
          DeviceUtils.hideKeyboard(context);
          try {
            await _store.confirmPasswordReset(
              (ModalRoute.of(context)?.settings.arguments != null)
                  ? (ModalRoute.of(context)?.settings.arguments
                          as ScreenArguments)
                      .oobCode
                  : '',
              _newPasswordController.text,
            );
            setState(() {
              _store.loading = false;
            });
            _showMyDialog();
          } catch (e) {
            setState(() {
              _store.loading = false;
            });
            print(e.toString());
          }
        } else {
          setState(() {
            _store.loading = false;
          });
          // set error text
        }
      },
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 20.0,
          title: Container(
            height: 120,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 70,
                    height: 70,
                    child: Image.asset(Assets.tick),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 50,
                    height: 50,
                    child: TextButton(
                      child: Image.asset(Assets.close),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(Routes.login);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  Strings.passwordChanged,
                  textAlign: TextAlign.center,
                  style: normalTextStyle(18, fontFamily: FontFamily.sfProText),
                ),
                // SizedBox(
                //   height: 15,
                // ),
                // TextButton(
                //   onPressed: () async {
                //     Navigator.of(context).pushReplacementNamed(Routes.login);
                //   },
                //   child: Text(
                //     "Log In",
                //     textAlign: TextAlign.end,
                //     style: TextStyle(
                //       fontWeight: FontWeight.w500,
                //       fontSize: 17,
                //       color: Color(0xFFE16726),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        );
      },
    );
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
