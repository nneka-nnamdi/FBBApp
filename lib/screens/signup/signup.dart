import 'package:auto_size_text/auto_size_text.dart';
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

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  //text controllers:-----------------------------------------------------------
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _verifyPasswordController = TextEditingController();

  //focus node:-----------------------------------------------------------------
  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _usernameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _verifyPasswordFocusNode;

  //stores:---------------------------------------------------------------------
  final _store = FormStore();
  bool _obscurePasswordText = true;
  bool _obscureVerifyPasswordText = true;
  bool _validate = false;
  var dynamicLinkEmail = '';
  AppTheme appTheme = AppTheme.light();
  final _formKey = GlobalKey<FormState>();
  bool isSelectionOpen = false;
  String selectedUser = 'Select';

  late GlobalKey _key;
  late Offset buttonPosition;
  late Size buttonSize;
  late OverlayEntry _overlayEntry;
  late BorderRadius _borderRadius;
  List<String> users = [Strings.blightReporter, Strings.developer];
  final LayerLink _layerLink = LayerLink();

  // Toggles the password show status
  void _toggle(String password) {
    setState(() {
      if (password == Strings.password) {
        _obscurePasswordText = !_obscurePasswordText;
      } else {
        _obscureVerifyPasswordText = !_obscureVerifyPasswordText;
      }
    });
  }

  findButton() {
    RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
    print(buttonSize + buttonPosition);
  }

  void closeMenu() {
    if (isSelectionOpen) {
      _store.setAccountType(selectedUser);
      _overlayEntry.remove();
      setState(() {
        isSelectionOpen = !isSelectionOpen;
      });
    }
  }

  void openMenu() {
    findButton();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context)?.insert(_overlayEntry);
    setState(() {
      isSelectionOpen = !isSelectionOpen;
    });
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        top: buttonPosition.dy + buttonSize.height + 5,
        left: buttonPosition.dx + 25,
        width: buttonSize.width - 48,
        child: CompositedTransformFollower(
          link: this._layerLink,
          showWhenUnlinked: false,
          offset: Offset(25, buttonSize.height+10),
          child: Material(
            color: Colors.transparent,
            child: Container(
                height: users.length * 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: _borderRadius,
                    border:
                        Border.all(color: appTheme.primaryColor, width: 1.5)),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        selectedUser = users[0];
                        closeMenu();
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 6, left: 10),
                        alignment: Alignment.centerLeft,
                        width: buttonSize.width,
                        height: 40,
                        child: Text(
                          users[0],
                          style: semiBoldTextStyle(16,
                              fontFamily: FontFamily.sfProText,
                              color: appTheme.textColor),
                        ),
                      ),
                    ),
                    Divider(),
                    InkWell(
                      onTap: () {
                        selectedUser = users[1];
                        closeMenu();
                      },
                      child: Container(
                        padding: EdgeInsets.only(bottom: 6, left: 10),
                        alignment: Alignment.centerLeft,
                        width: buttonSize.width,
                        height: 40,
                        child: Text(
                          users[1],
                          style: semiBoldTextStyle(16,
                              fontFamily: FontFamily.sfProText,
                              color: appTheme.textColor),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    _borderRadius = BorderRadius.circular(4);
    _key = LabeledGlobalKey("button_icon");
    super.initState();
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _usernameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _verifyPasswordFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store.isLogin = false;
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
          SizedBox(height: 8.0),
          _buildTitleView(),
          _buildNameView(),
          _buildTextfieldTitle(Strings.userName),
          _buildUserName(),
          _buildTextfieldTitle(Strings.email),
          _buildEmailField(),
          _buildTextfieldTitle(Strings.password),
          _buildPasswordField(),
          _buildTextfieldTitle(Strings.verifyPassword),
          _buildVerifyPasswordField(),
          _buildAccountTypeField(),
          SizedBox(
            height: 30,
          ),
          _buildSignUpButton(),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Padding _buildTitleView() {
    return Padding(
      padding: EdgeInsets.only(left: 24.0, right: 24, top: 20, bottom: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 55,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              Strings.createAccount,
              style: normalTextStyle(20, fontFamily: FontFamily.sfProDisplay),
            ),
            TextButton(
              child: Image.asset(Assets.close),
              onPressed: () {
                DeviceUtils.hideKeyboard(context);
                closeMenu();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Container _buildNameView() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextfieldTitle(Strings.firstName),
                  _buildFirstName(),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextfieldTitle(Strings.lastName),
                  _buildLastName(),
                ],
              ),
            ),
          ],
        ));
  }

  Container _buildAccountTypeField() {
    return Container(
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
              ),
              child: _buildTextfieldTitle(Strings.accountType),
            ),
            _buildAccountTypeButton(),
          ],
        ));
  }

  Widget _buildTextfieldTitle(String text) {
    return Padding(
        padding: EdgeInsets.only(left: text == Strings.lastName ? 5.0 : 24.0),
        child: Text(
          text,
          style: normalTextStyle(16, fontFamily: FontFamily.sfProText),
        ));
  }

  Widget _buildFirstName() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Strings.firstName,
          inputType: TextInputType.name,
          textController: _firstNameController,
          focusNode: _firstNameFocusNode,
          inputAction: TextInputAction.next,
          textInputFormatter:
              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
          autoFocus: false,
          onChanged: (value) {
            _store.setFirstName(_firstNameController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_lastNameFocusNode);
          },
          validator: (value) {
            _store.validateFirstName(value);
          },
          errorText: _validate ? _store.formErrorStore.firstName : null,
          maxLength: 100,
          margin: EdgeInsets.only(
            left: 24,
            top: 8,
            bottom: 0,
            right: 5,
          ),
        );
      },
    );
  }

  Widget _buildLastName() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Strings.lastName,
          inputType: TextInputType.name,
          textController: _lastNameController,
          inputAction: TextInputAction.next,
          textInputFormatter:
              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
          focusNode: _lastNameFocusNode,
          autoFocus: false,
          onChanged: (value) {
            _store.setLastName(_lastNameController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_usernameFocusNode);
          },
          validator: (value) {
            _store.validateLastName(value);
          },
          errorText: _validate ? _store.formErrorStore.lastName : null,
          maxLength: 100,
          margin: EdgeInsets.only(
            left: 5,
            top: 8,
            bottom: 0,
            right: 24,
          ),
        );
      },
    );
  }

  Widget _buildUserName() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Strings.userName,
          inputType: TextInputType.name,
          textController: _userNameController,
          inputAction: TextInputAction.next,
          textInputFormatter:
              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
          focusNode: _usernameFocusNode,
          autoFocus: false,
          onChanged: (value) {
            _store.setUserName(_userNameController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_emailFocusNode);
          },
          validator: (value) {
            _store.validateUserName(value);
          },
          errorText: _validate ? _store.formErrorStore.userName : null,
          maxLength: 50,
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

  Widget _buildEmailField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Strings.emailRegisterHint,
          inputType: TextInputType.emailAddress,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          textInputFormatter: FilteringTextInputFormatter.allow(
              RegExp(r"[a-zA-Z0-9.@!#$%&'*+/=?^_`{|}~-]")),
          focusNode: _emailFocusNode,
          autoFocus: false,
          onChanged: (value) {
            _store.setUserId(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          validator: (value) {
            _store.validateUserEmail(value);
          },
          errorText: _validate ? _store.formErrorStore.userEmail : null,
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
            inputAction: TextInputAction.next,
            textInputFormatter: FilteringTextInputFormatter.allow(
                RegExp(r"[a-zA-Z0-9.@!#$%&'*+/=?^_`{|}~-]")),
            hint: Strings.passwordHint,
            isObscure: _obscurePasswordText,
            padding: EdgeInsets.only(top: 16.0),
            textController: _passwordController,
            focusNode: _passwordFocusNode,
            validator: (value) {
              _store.validatePassword(value);
            },
            errorText: _validate ? _store.formErrorStore.password : null,
            onChanged: (value) {
              _store.setPassword(_passwordController.text);
            },
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(_verifyPasswordFocusNode);
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
              onPressed: () => _toggle(Strings.password),
              icon: Container(
                  width: 100,
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    _obscurePasswordText ? Strings.show : Strings.hide,
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

  Widget _buildVerifyPasswordField() {
    return Observer(
      builder: (context) {
        return Stack(children: [
          TextFieldWidget(
            textInputFormatter: FilteringTextInputFormatter.allow(
                RegExp(r"[a-zA-Z0-9.@!#$%&'*+/=?^_`{|}~-]")),
            hint: Strings.verifyPasswordHint,
            isObscure: _obscureVerifyPasswordText,
            padding: EdgeInsets.only(top: 16.0),
            textController: _verifyPasswordController,
            focusNode: _verifyPasswordFocusNode,
            validator: (value) {
              _store.validateConfirmPassword(value);
            },
            errorText: _validate ? _store.formErrorStore.confirmPassword : null,
            onChanged: (value) {
              _store.setConfirmPassword(_verifyPasswordController.text);
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
              onPressed: () => _toggle(Strings.verifyPassword),
              icon: Container(
                  width: 100,
                  padding: EdgeInsets.only(right: 10.0),
                  child: AutoSizeText(
                    _obscureVerifyPasswordText ? Strings.show : Strings.hide,
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

  Widget _buildAccountTypeButton() {
    return CompositedTransformTarget(
      link: this._layerLink,
      child: Stack(
        key: _key,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: RoundedButtonWidget(
              width: MediaQuery.of(context).size.width * 0.5-20,
              buttonText: selectedUser,
              textSize: 16,
              align: Alignment.centerLeft,
              buttonColor: appTheme.primaryColor,
              textColor: Colors.white,
              onPressed: () async {
                setState(() {
                  if (isSelectionOpen) {
                    closeMenu();
                  } else {
                    openMenu();
                  }
                });
              },
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.only(top: 20.0, left: 5.0),
            child: Image.asset(
              isSelectionOpen ? Assets.up_arrow : Assets.down_arrow,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return RoundedButtonWidget(
      buttonText: Strings.create,
      buttonColor: appTheme.primaryColor,
      textColor: Colors.white,
      onPressed: () async {
        final valid = await _store.usernameCheck();

        if (_formKey.currentState!.validate()) {
          setState(() {
            _validate = true;
          });
        } else {
          setState(() {
            _validate = true;
          });
        }

        if (_store.canRegister && valid) {
          DeviceUtils.hideKeyboard(context);
          try {
            var result = await _store.register(
                _userEmailController.text, _passwordController.text);
            await _store.sendVerificationEmail();
            setState(() {
              _store.loading = false;
            });
            _showMyDialog();
            print(result.toString());
          } catch (e) {
            setState(() {
              _store.loading = false;
            });
            print(e.toString());
          }
        } else if (!valid) {
          _store.formErrorStore.userName = Strings.existingUsername;
        } else {
          if (_store.accountType.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Strings.emptyAccountType)));
          }
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
                  Strings.accountCreated,
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _verifyPasswordFocusNode.dispose();
    super.dispose();
  }
}
