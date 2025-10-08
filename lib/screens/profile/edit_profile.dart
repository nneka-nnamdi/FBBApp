import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/app_utils.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/stores/user/user_store.dart';
import 'package:fight_blight_bmore/widgets/no_border_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  AppTheme appTheme = AppTheme.light();
  UserStore _userStore = UserStore();
  Map<String, dynamic> userData = {};
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  FocusNode _firstNameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _userNameFocusNode = FocusNode();

  bool _validate = false;

  String _getImageUrl(String url) {
    if (url.contains('graph.facebook.com')) {
      url = url + '?type=large';
    }
    return url;
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0.4,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Color(0xFFF8F8F8),
      title: Text(
        Strings.editProfile,
        style: semiBoldTextStyle(16,
            fontFamily: FontFamily.sfProDisplay, color: Colors.black),
      ),
      leading: Padding(
          padding: EdgeInsets.all(10.0),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Image.asset(Assets.back),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder(
        future: _userStore.getUserProfile(),
        builder: (contxt, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              print(snapshot.data);
              userData = snapshot.data is Map<String, dynamic> ? snapshot.data as Map<String, dynamic> : {};
              _firstNameController.text = userData['first_name'] ?? '';
              _lastNameController.text = userData['last_name'] ?? '';
              _userNameController.text = userData['username'] ?? '';
              _emailController.text = userData['email'] ?? '';
              _userStore.setFirstName(_firstNameController.text);
              _userStore.setLastName(_lastNameController.text);
              _userStore.setUserName(_userNameController.text);
              _userStore.setUserEmail(_emailController.text);
              return Column(children: [
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                   await _showActionSheet(contxt);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 0),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          color: appTheme.greyColor,
                          border:
                              Border.all(width: 1, color: appTheme.greyColor),
                          borderRadius: BorderRadius.all(Radius.circular(75))),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: (userData['profile_image'] != null &&
                                userData['profile_image'] != '')
                            ? Image.network(
                                _getImageUrl(userData['profile_image']),
                                fit: BoxFit.fill,
                              )
                            : Image.asset(
                                Assets.camera,
                                height: 10,
                                width: 10,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  userData['username'] ?? '',
                  textAlign: TextAlign.end,
                  style: semiBoldTextStyle(
                    17,
                    fontFamily: FontFamily.sfProText,
                  ),
                  maxLines: 2,
                  softWrap: true,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Logged in ${getElapsedTime(userData['logged_in'] ?? 0)}',
                  textAlign: TextAlign.end,
                  style: normalTextStyle(
                    12,
                    fontFamily: FontFamily.sfProText,
                    color: appTheme.textColor,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildFirstName(context),
                                _buildLastNameField(context),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                            _buildUsername(context),
                            _buildEmailField(context),
                            _buildSaveButton(context),
                            _buildSocialButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            } else {
              return Container();
            }
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Container _buildFirstName(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width / 2 - 20,
      child: NoBorderTextField(
        textInputFormatter:
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        hintText: Strings.firstName,
        inputType: TextInputType.name,
        editingController: _firstNameController,
        inputAction: TextInputAction.next,
        focusNode: _firstNameFocusNode,
        autoFocus: false,
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: appTheme.textColor, width: 1.0)),
        onChanged: (value) {
          _userStore.setFirstName(_firstNameController.text);
        },
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(_lastNameFocusNode);
        },
        validator: (value) {
          _userStore.validateFirstName(value);
        },
        maxLength: 250,
        errorText: _validate ? _userStore.userErrorStore.firstName : null,
      ),
    );
  }

  Container _buildLastNameField(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width / 2 - 20,
      child: NoBorderTextField(
        textInputFormatter:
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        hintText: Strings.lastName,
        inputType: TextInputType.name,
        focusNode: _lastNameFocusNode,
        editingController: _lastNameController,
        inputAction: TextInputAction.next,
        autoFocus: false,
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: appTheme.textColor, width: 1.0)),
        onChanged: (value) {
          _userStore.setLastName(_lastNameController.text);
        },
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(_userNameFocusNode);
        },
        validator: (value) {
          _userStore.validateLastName(value);
        },
        maxLength: 250,
        errorText: _validate ? _userStore.userErrorStore.lastName : null,
      ),
    );
  }

  Container _buildUsername(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 30,
      child: NoBorderTextField(
        textInputFormatter:
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        hintText: Strings.userName,
        inputType: TextInputType.name,
        focusNode: _userNameFocusNode,
        editingController: _userNameController,
        inputAction: TextInputAction.done,
        autoFocus: false,
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: appTheme.textColor, width: 1.0)),
        onChanged: (value) {
          _userStore.setUserName(_userNameController.text);
        },
        validator: (value) {
          _userStore.validateUserName(value);
        },
        onFieldSubmitted: (value) {
        },
        maxLength: 50,
        errorText: _validate ? _userStore.userErrorStore.userName : null,
      ),
    );
  }

  Container _buildEmailField(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 30,
      child: AbsorbPointer(
        absorbing: true,
        child: NoBorderTextField(
          textInputFormatter:
              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
          hintText: Strings.email,
          inputType: TextInputType.name,
          editingController: _emailController,
          inputAction: TextInputAction.done,
          autoFocus: false,
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: appTheme.textColor, width: 1.0)),
          onChanged: (value) {
            _userStore.setUserEmail(_emailController.text);
          },
          validator: (value) {
            _userStore.validateUserEmail(value);
          },
          maxLength: 250,
          errorText: _validate ? _userStore.userErrorStore.userEmail : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton() {
    return Visibility(
      visible: ifSocialLogin(),
      child: Padding(
        padding: const EdgeInsets.only(top: 25.0, bottom: 15),
        child: Image.asset(getAssetName()),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      height: 50,
      width: MediaQuery.of(context).size.width - 30,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              width: 1.5,
              color: appTheme.primaryColor,
              style: BorderStyle.solid,
            ),
          ),
          onPressed: () async {
            await _userStore.updateUserData();
            await _userStore.getUserProfile();
            setState(() {});
          },
          child: Text(
            Strings.save,
            style: normalTextStyle(16,
                fontFamily: FontFamily.sfProDisplay,
                color: appTheme.primaryColor),
          )),
    );
  }

  Future<void> _showActionSheet(BuildContext context) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext ctx) => CupertinoActionSheet(
        title: Text(Strings.titleProfileActionSheet),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
              child: Text(
                Strings.takePhoto,
                style: normalTextStyle(20,
                    fontFamily: FontFamily.sfProDisplay,
                    color: appTheme.blueColor),
              ),
              onPressed: () async {
                ImagePicker()
                    .pickImage(source: ImageSource.camera)
                    .then((value) {
                      _userStore.loading = true;
                  _userStore
                      .uploadProfileImage(value!.path)
                      .then((value) => setState(() {}));
                });
                Navigator.of(ctx).pop();
              }),
          CupertinoActionSheetAction(
            child: Text(
              Strings.photoLibrary,
              style: normalTextStyle(20,
                  fontFamily: FontFamily.sfProDisplay,
                  color: appTheme.blueColor),
            ),
            onPressed: () async {
              ImagePicker()
                  .pickImage(source: ImageSource.gallery)
                  .then((value) {
                _userStore
                    .uploadProfileImage(value!.path)
                    .then((value) => setState(() {}));
              });
              Navigator.of(ctx).pop();
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            Strings.cancel,
            style: normalTextStyle(20,
                fontFamily: FontFamily.sfProDisplay, color: appTheme.redColor),
          ),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }

  //general methods: -----------------------------------------------------------
  getAssetName() {
    var assetName = '';
    switch (_userStore.profileData['login_type']) {
      case 'Google':
        assetName = Assets.loggedGoogle;
        break;
      case 'Facebook':
        assetName = Assets.loggedFacebook;
        break;
      case 'Apple':
        assetName = Assets.loggedApple;
        break;
    }
    return assetName;
  }

  ifSocialLogin() {
    return _userStore.profileData['login_type'] != 'Password' && _userStore.profileData['login_type'] != null;
  }
}
