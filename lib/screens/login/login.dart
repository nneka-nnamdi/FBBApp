import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/stores/form/form_store.dart';
import 'package:fight_blight_bmore/utils/apple_signin.dart';
import 'package:fight_blight_bmore/utils/device/device_utils.dart';
import 'package:fight_blight_bmore/utils/routes/routes.dart';
import 'package:fight_blight_bmore/widgets/loader_widget.dart';
import 'package:fight_blight_bmore/widgets/rounded_button_widget.dart';
import 'package:fight_blight_bmore/widgets/textfield_widget.dart';
import 'package:fight_blight_bmore/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AppTheme appTheme = AppTheme.light();
  bool _validateEmail = false;
  bool _validatePassword = false;

  //focus node:-----------------------------------------------------------------
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  //stores:---------------------------------------------------------------------
  final _store = FormStore();

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store.isLogin = true;
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
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 14.0),
          Padding(
            padding:
                EdgeInsets.only(left: 24.0, right: 24, top: 20, bottom: 20),
            child: Row(
              children: [
                Text(
                  Strings.loginOr,
                  style:
                      normalTextStyle(20, fontFamily: FontFamily.sfProDisplay),
                ),
                TextButton(
                  child: Text(
                    Strings.createAnAccount,
                    style: normalTextStyle(20,
                        fontFamily: FontFamily.sfProDisplay),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.signup);
                  },
                ),
              ],
            ),
          ),
          _buildTextfieldTitle(Strings.email),
          _buildEmailField(),
          _buildTextfieldTitle(Strings.password),
          _buildPasswordField(),
          _buildSignInButton(),
          _buildForgetPasswordButton(),
          SizedBox(height: 40.0),
          _buildGoogleLoginButton(),
          _buildFacebookButton(),
          if (appleSignInAvailable.isAvailable && Platform.isIOS)
            _buildAppleSignInButton(),
        ],
      ),
    );
  }

  Widget _buildTextfieldTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 24.0),
      child: Text(
        text,
        style: normalTextStyle(
          16,
          fontFamily: FontFamily.sfProText,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Strings.emailHint,
          inputType: TextInputType.emailAddress,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          focusNode: _emailFocusNode,
          textInputFormatter: FilteringTextInputFormatter.allow(
              RegExp(r"[a-zA-Z0-9.@!#$%&'*+/=?^_`{|}~-]")),
          autoFocus: false,
          onChanged: (value) {
            _store.setUserId(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _validateEmail ? _store.formErrorStore.userEmail : null,
          validator: (value) {
            _store.validateUserEmail(value);
          },
          maxLength: 100,
          margin: EdgeInsets.only(
            left: 24,
            top: 8,
            bottom: 0,
            right: 24,
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return Stack(children: [
          TextFieldWidget(
            hint: Strings.passwordHint,
            isObscure: _obscureText,
            padding: EdgeInsets.only(top: 16.0),
            textController: _passwordController,
            textInputFormatter: FilteringTextInputFormatter.allow(
                RegExp(r"[a-zA-Z0-9.@!#$%&'*+/=?^_`{|}~-]")),
            focusNode: _passwordFocusNode,
            validator: (value) {
              _store.validatePassword(value);
            },
            errorText:
                _validatePassword ? _store.formErrorStore.password : null,
            onChanged: (value) {
              _store.setPassword(_passwordController.text);
            },
            maxLength: 100,
            margin: EdgeInsets.only(
              left: 24,
              top: 8,
              bottom: 0,
              right: 24,
            ),
            suffixIcon: Container(
              width: 80,
              padding: EdgeInsets.all(5.0),
              child: IconButton(
                constraints: BoxConstraints(
                  maxWidth: 60,
                  minWidth: 60,
                ),
                onPressed: _toggle,
                icon: AutoSizeText(
                  _obscureText ? Strings.show : Strings.hide,
                  textAlign: TextAlign.end,
                  style: normalTextStyle(12,
                      fontFamily: FontFamily.sfProText,
                      color: appTheme.primaryColor),
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildSignInButton() {
    return RoundedButtonWidget(
      buttonText: Strings.logIn,
      buttonColor: appTheme.primaryColor,
      textColor: Colors.white,
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _validateEmail = true;
            _validatePassword = true;
          });
        } else {
          setState(() {
            _validateEmail = true;
            _validatePassword = true;
          });
        }
        if (_store.canLogin) {
          DeviceUtils.hideKeyboard(context);
          try {
            var result = await _store.login(
                _userEmailController.text, _passwordController.text);
            print(result.toString());
            setState(() {
              _store.loading = false;
            });
            if (result != null) {
              Navigator.of(context).pushReplacementNamed(Routes.tab);
            }
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

  Widget _buildForgetPasswordButton() {
    return Center(
      child: TextButton(
        child: Text(
          Strings.forgotPassword,
          style: normalTextStyle(16,
              fontFamily: FontFamily.sfProText, color: appTheme.primaryColor),
        ),
        onPressed: () async {
          DeviceUtils.hideKeyboard(context);
          Navigator.of(context).pushNamed(Routes.forgot_password,
              arguments: _userEmailController.text);
        },
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return Padding(
      padding: EdgeInsets.only(
        left: 11,
        right: 11,
        top: 12,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        // height: 80,
        child: TextButton(
          child: Image.asset(
            Assets.google_login,
            fit: BoxFit.fitHeight,
          ),
          onPressed: () async {
            DeviceUtils.hideKeyboard(context);
            try {
              var result = await _store.signInWithGoogle();
              print(result.toString());
              setState(() {
                _store.loading = false;
              });
              if (result != null) {
                Navigator.of(context).pushReplacementNamed(Routes.tab);
              }
            } catch (e) {
              setState(() {
                _store.loading = false;
              });
              print(e.toString());
            }
          },
        ),
      ),
    );
  }

  Widget _buildFacebookButton() {
    return Padding(
      padding: EdgeInsets.only(
        left: 11,
        right: 11,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
          child: Image.asset(
            Assets.facebook_login,
            fit: BoxFit.fitWidth,
          ),
          onPressed: () async {
            DeviceUtils.hideKeyboard(context);
            try {
              var result = await _store.signInWithFacebook();
              print(result.toString());
              setState(() {
                _store.loading = false;
              });
              if (result != null) {
                Navigator.of(context).pushReplacementNamed(Routes.tab);
              }
            } catch (e) {
              setState(() {
                _store.loading = false;
              });
              print(e.toString());
            }
          },
        ),
      ),
    );
  }

  Widget _buildAppleSignInButton() {
    return Padding(
      padding: EdgeInsets.only(
        left: 11,
        right: 11,
        bottom: 10,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        // height: 80,
        child: TextButton(
          child: Image.asset(
            Assets.apple_login,
            fit: BoxFit.fitHeight,
          ),
          onPressed: () async {
            DeviceUtils.hideKeyboard(context);
            try {
              var result = await _store.signInWithApple();
              print(result.toString());
              setState(() {
                _store.loading = false;
              });
              if (result != null) {
                Navigator.of(context).pushReplacementNamed(Routes.tab);
              }
            } catch (e) {
              setState(() {
                _store.loading = false;
              });
              print(e.toString());
            }
          },
        ),
      ),
    );
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _userEmailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
