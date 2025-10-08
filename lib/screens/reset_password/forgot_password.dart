import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
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

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _userEmailController = TextEditingController();
  AppTheme appTheme = AppTheme.light();
  bool _validateEmail = false;

  //stores:---------------------------------------------------------------------
  final _store = FormStore();
  FocusNode _emailFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _userEmailController.text =
            ModalRoute.of(context)?.settings.arguments as String;
        _store.setUserId(_userEmailController.text);
        isInit = true;
      }
    }
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
        ));
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
            child: Row(
              children: [
                Text(
                  Strings.resetPasswordOr,
                  style:
                      normalTextStyle(20, fontFamily: FontFamily.sfProDisplay),
                ),
                TextButton(
                  child: Text(
                    Strings.login,
                    style: normalTextStyle(20,
                        fontFamily: FontFamily.sfProDisplay),
                  ),
                  onPressed: () {
                    DeviceUtils.hideKeyboard(context);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          _buildTextfieldTitle(Strings.email),
          _buildEmailField(),
          _buildResetButton(),
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

  Widget _buildEmailField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Strings.email,
          inputType: TextInputType.emailAddress,
          focusNode: _emailFocusNode,
          textController: _userEmailController,
          inputAction: TextInputAction.go,
          textInputFormatter: FilteringTextInputFormatter.allow(
              RegExp(r"[a-zA-Z0-9.@!#$%&'*+/=?^_`{|}~-]")),
          autoFocus: false,
          onChanged: (value) {
            _store.setUserId(_userEmailController.text);
          },
          validator: (value) {
            _store.validateUserEmail(value);
          },
          errorText: _validateEmail ? _store.formErrorStore.userEmail : null,
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

  Widget _buildResetButton() {
    return RoundedButtonWidget(
      buttonText: Strings.reset,
      buttonColor: appTheme.primaryColor,
      textColor: Colors.white,
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _validateEmail = true;
          });
        } else {
          setState(() {
            _validateEmail = true;
          });
        }
        if (_store.canForgetPassword) {
          DeviceUtils.hideKeyboard(context);
          try {
            var result = await _store.forgotPassword(_userEmailController.text);
            print(result.toString());
            _showMyDialog();
            setState(() {
              _store.loading = false;
            });
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
                        Navigator.of(context).pushNamed(Routes.login);
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
                  Strings.resetPasswordLinkSent,
                  textAlign: TextAlign.center,
                  style: normalTextStyle(18, fontFamily: FontFamily.sfProText),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  _userEmailController.text,
                  textAlign: TextAlign.center,
                  style: boldTextStyle(16, fontFamily: FontFamily.sfProText),
                ),
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
    _userEmailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }
}
