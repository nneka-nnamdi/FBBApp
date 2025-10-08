import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fight_blight_bmore/constants/app_utils.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/stores/error/error_store.dart';
import 'package:fight_blight_bmore/stores/user/user_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobx/mobx.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:validators/validators.dart';
import 'package:crypto/crypto.dart';
import 'package:fight_blight_bmore/constants/flavor_settings.dart';

part 'form_store.g.dart';

class FormStore = _FormStore with _$FormStore;

abstract class _FormStore with Store {
  // store for handling form errors
  final FormErrorStore formErrorStore = FormErrorStore();

  final firestoreInstance = FirebaseFirestore.instance;

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();
  FirebaseAuth auth = FirebaseAuth.instance;
  BuildContext? context;
  bool isLogin = false;

  _FormStore() {
    _setupValidations();
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  Future<void> _setupValidations() async {
    _disposers = [
      reaction((_) => firstName, validateFirstName),
      reaction((_) => lastName, validateLastName),
      reaction((_) => userName, validateUserName),
      reaction((_) => userEmail, validateUserEmail),
      reaction((_) => password, validatePassword),
      reaction((_) => confirmPassword, validateConfirmPassword)
    ];

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    FirebaseAuth.instance.idTokenChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }



  Future<ActionCodeSettings> getActionCodeSettings(String email) async {
    final settings = await getFlavorSettings();
    print('API URL ${settings.url}');
    var actionCodeSettings = ActionCodeSettings(
        url: "${settings.url}$email",
        dynamicLinkDomain: settings.dynamicLinkDomain,
        androidPackageName: settings.androidPackageName,
        androidInstallApp: true,
        androidMinimumVersion: "12",
        iOSBundleId: settings.iOSBundleId,
        handleCodeInApp: true);
    return actionCodeSettings;
  }

  // store variables:-----------------------------------------------------------
  @observable
  String firstName = '';

  @observable
  String lastName = '';

  @observable
  String userName = '';

  @observable
  String userEmail = '';

  @observable
  String password = '';

  @observable
  String confirmPassword = '';

  @observable
  String accountType = '';

  @observable
  bool success = false;

  @observable
  bool loading = false;

  @computed
  bool get canLogin =>
      !formErrorStore.hasErrorsInLogin &&
      userEmail.isNotEmpty &&
      password.isNotEmpty;

  @computed
  bool get canRegister =>
      !formErrorStore.hasErrorsInRegister &&
      userEmail.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      userName.isNotEmpty &&
      accountType.isNotEmpty;

  @computed
  bool get canForgetPassword =>
      !formErrorStore.hasErrorInForgotPassword && userEmail.isNotEmpty;

  @computed
  bool get canResetPassword =>
      !formErrorStore.hasErrorInResetPassword &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty;

  bool isPasswordValid(String password) {
    // if (!password.contains(RegExp(r"[a-z]"))) return false;
    if (!password.contains(RegExp(r"[A-Z]"))) return false;
    if (!password.contains(RegExp(r"[0-9]"))) return false;
    // if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  // actions:-------------------------------------------------------------------
  @action
  void setFirstName(String value) {
    firstName = value;
  }

  @action
  void setLastName(String value) {
    lastName = value;
  }

  @action
  void setUserName(String value) {
    userName = value;
  }

  @action
  void setUserId(String value) {
    userEmail = value;
  }

  @action
  void setPassword(String value) {
    password = value;
  }

  @action
  void setConfirmPassword(String value) {
    confirmPassword = value;
  }

  @action
  void setAccountType(String value) {
    accountType = value;
  }

  @action
  void validateFirstName(String value) {
    if (value.isEmpty) {
      formErrorStore.firstName = Strings.emptyFirstName;
    } else {
      formErrorStore.firstName = null;
    }
  }

  @action
  void validateLastName(String value) {
    if (value.isEmpty) {
      formErrorStore.lastName = Strings.emptyLastName;
    } else {
      formErrorStore.lastName = null;
    }
  }

  @action
  void validateUserName(String value) {
    if (value.isEmpty) {
      formErrorStore.userName = Strings.emptyUserName;
    } else {
      formErrorStore.userName = null;
    }
  }

  @action
  void validateUserEmail(String value) {
    if (value.isEmpty) {
      formErrorStore.userEmail = Strings.emptyEmail;
    } else if (!isEmail(value)) {
      formErrorStore.userEmail = Strings.validateEmail;
    } else {
      formErrorStore.userEmail = null;
    }
  }

  @action
  void validatePassword(String value) {
    if (value.isEmpty) {
      formErrorStore.password = Strings.emptyPassword;
    } else if (value.length < 8) {
      formErrorStore.password = Strings.maxLengthPassword;
    } else if (!isPasswordValid(value) && !isLogin) {
      formErrorStore.password = Strings.validatePassword;
    } else {
      formErrorStore.password = null;
    }
  }

  @action
  void validateConfirmPassword(String value) {
    if (value.isEmpty) {
      formErrorStore.confirmPassword = Strings.emptyConfirmPassword;
    } else if (value.length < 8) {
      formErrorStore.confirmPassword = Strings.maxLengthConfirmPassword;
    } else if (value != password) {
      formErrorStore.confirmPassword = Strings.passwordNotMatched;
    } else if (!isPasswordValid(value)) {
      formErrorStore.confirmPassword = Strings.validateConfirmPassword;
    } else {
      formErrorStore.confirmPassword = null;
    }
  }

  void showDefaultSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @action
  Future register(String email, String password) async {
    loading = true;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
      throw Exception(e);
    }
  }

  @action
  Future sendVerificationEmail() async {
    loading = true;
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      try {
        ActionCodeSettings actionCodeSettings =
            await getActionCodeSettings(user.email ?? '');
        print(actionCodeSettings.url);
        await _saveNewUser();
        await user.sendEmailVerification(actionCodeSettings);
      } on FirebaseAuthException catch (e) {
        _handleAuthError(e);
      } catch (e) {
        print('Exception >>> $e');
        showDefaultSnackbar(Strings.somethingWentWrong);
        loading = false;
      }
    } else {
      loading = false;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      formErrorStore.password = Strings.weakPassword;
    } else if (e.code == 'email-already-in-use') {
      formErrorStore.userEmail = Strings.existingAccount;
    } else if (e.code == 'network-request-failed') {
      showDefaultSnackbar(Strings.networkError);
    } else if (e.code == 'user-not-found') {
      formErrorStore.userEmail = Strings.noUserFound;
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      formErrorStore.password = Strings.wrongPassword;
      print('Wrong password provided for that user.');
    }
    loading = false;
    throw Exception(e);
  }

  @action
  Future resendVerificationCode(String email) async {
    loading = true;
    try {
      ActionCodeSettings actionCodeSettings =
          await getActionCodeSettings(email);
      await FirebaseAuth.instance.sendSignInLinkToEmail(
          email: email, actionCodeSettings: actionCodeSettings);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
    }
  }

  @action
  Future login(String email, String password) async {
    loading = true;
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user!.emailVerified) {
        await updateLoggedIn();
        return userCredential;
      } else {
        loading = false;
        formErrorStore.userEmail = Strings.emailVerifyError;
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
    }
  }

  Future _saveNewUser() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    print(firebaseUser);
    await firestoreInstance.collection('users').doc(firebaseUser?.uid).set({
      "user_id": firebaseUser?.uid,
      "first_name": firstName,
      "last_name": lastName,
      "username": userName,
      "email": userEmail,
      "account_type": accountType,
      "is_verified": false,
      "created_at": DateTime.now().millisecondsSinceEpoch,
      "updated_at": DateTime.now().millisecondsSinceEpoch,
      "login_type": "Password",
      "logged_in": DateTime.now().millisecondsSinceEpoch,
      "timezone": DateTime.now().timeZoneName,
      "timezone_offset": '${DateTime.now().timeZoneOffset.inHours}',
    }, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((Object error) {
      print('error:  $error');
    });
  }

  Future _saveSocialNewUser(UserCredential userCredential, String loginType) async {
    UserStore _userStore = UserStore();
    final result = await _userStore.getUserProfile();
    await updateLoggedIn();
    if (result != null && result.length > 0) {
      return;
    }
    var firebaseUser = FirebaseAuth.instance.currentUser;
    print(firebaseUser);
    print(userCredential);
    var displayName = userCredential.user?.displayName;
    var username = displayName?.replaceAll(' ', '') ?? userCredential.user?.email?.substring(0, userCredential.user?.email?.indexOf('@')) ?? '';
    await firestoreInstance.collection('users').doc(firebaseUser?.uid).set({
      "user_id": firebaseUser?.uid,
      "first_name":
          userCredential.additionalUserInfo?.profile?['given_name'] ?? '',
      "last_name":
          userCredential.additionalUserInfo?.profile?['family_name'] ?? '',
      "username": username,
      "email": userCredential.user?.email,
      "account_type": Strings.blightReporter,
      "is_verified": userCredential.user?.emailVerified,
      "created_at": DateTime.now().millisecondsSinceEpoch,
      "updated_at": DateTime.now().millisecondsSinceEpoch,
      "login_type": loginType,
      "timezone": DateTime.now().timeZoneName,
      "timezone_offset": '${DateTime.now().timeZoneOffset.inHours}',
      "profile_image": userCredential.user?.photoURL ?? '',
      "logged_in": DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((Object error) {
      print('error:  $error');
    });
  }

  @action
  Future<UserCredential?> signInWithFacebook() async {
    loading = true;
    // Trigger the sign-in flow
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
if (loginResult.accessToken != null) {
  // Create a credential from the access token
  final OAuthCredential facebookAuthCredential =
  FacebookAuthProvider.credential(loginResult.accessToken!.token);

  // Once signed in, return the UserCredential
  var userCredential = await FirebaseAuth.instance
      .signInWithCredential(facebookAuthCredential);
  await _saveSocialNewUser(userCredential, 'Facebook');
  return userCredential;
}
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
      throw Exception(e);
    }
  }

  Future<bool> usernameCheck() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: userName)
          .get();
      print(result);
      return result.docs.isEmpty;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(e.toString());
      return true;
    }
  }

  @action
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth != null) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        // Once signed in, return the UserCredential
        final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
        await _saveSocialNewUser(userCredential, 'Google');
        return userCredential;
      }

    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar('${e.toString()}');
      throw Exception(e);
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
     await _saveSocialNewUser(userCredential, 'Apple');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }

  @action
  Future forgotPassword(String email) async {
    loading = true;
    try {
      ActionCodeSettings actionCodeSettings =
          await getActionCodeSettings(email);
      print(actionCodeSettings.url);
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: email, actionCodeSettings: actionCodeSettings);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
    }
  }

  @action
  Future confirmPasswordReset(String code, String newPassword) async {
    loading = true;
    try {
      await FirebaseAuth.instance.verifyPasswordResetCode(code);
      await FirebaseAuth.instance
          .confirmPasswordReset(code: code, newPassword: newPassword);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      loading = false;
      return showDefaultSnackbar(Strings.somethingWentWrong);
    }
  }

  @action
  updateVerifyEmail() async {
    try {
    var document = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    await FirebaseFirestore.instance.collection('users').doc(document.docs.first.id).update({'is_verified': true});
    } on FirebaseException catch (e) {
      print(e.toString());
    }
  }

  @action
  updateLoggedIn() async {
    try {
      var document = await FirebaseFirestore.instance
          .collection('users')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (document.docs.length > 0) {
        await FirebaseFirestore.instance.collection('users').doc(document.docs.first.id).update({'logged_in': DateTime.now().millisecondsSinceEpoch,});
      }
    } on FirebaseException catch (e) {
      print(e.toString());
    }

  }

  @action
  Future logout() async {
    loading = true;
    try {
      return await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    }
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }

  void validateAll() {
    validateFirstName(firstName);
    validateLastName(lastName);
    validateUserName(userName);
    validateConfirmPassword(confirmPassword);
    validatePassword(password);
    validateUserEmail(userEmail);
  }
}

class FormErrorStore = _FormErrorStore with _$FormErrorStore;

abstract class _FormErrorStore with Store {
  @observable
  String? firstName;

  @observable
  String? lastName;

  @observable
  String? userName;

  @observable
  String? userEmail;

  @observable
  String? password;

  @observable
  String? confirmPassword;

  @observable
  String? accountType;

  @computed
  bool get hasErrorsInLogin => userEmail != null || password != null;

  @computed
  bool get hasErrorsInRegister =>
      firstName != null ||
      lastName != null ||
      userName != null ||
      userEmail != null ||
      password != null ||
      confirmPassword != null ||
      accountType != null;

  @computed
  bool get hasErrorInForgotPassword => userEmail != null;

  @computed
  bool get hasErrorInResetPassword =>
      password != null || confirmPassword != null;
}
