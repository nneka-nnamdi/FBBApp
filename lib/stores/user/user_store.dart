import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/di/service_locator.dart';
import 'package:fight_blight_bmore/services/navigation_service.dart';
import 'package:fight_blight_bmore/stores/error/error_store.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/utils/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

part 'user_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  // repository instance
  // final Repository _repository;

  // store for handling form errors
  final UserErrorStore userErrorStore = UserErrorStore();

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();

  // bool to check if current user is logged in
  bool isLoggedIn = false;

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  // empty responses:-----------------------------------------------------------

  _UserStore() {
    _setupValidations();
  }

  Future<void> _setupValidations() async {
    _disposers = [
      reaction((_) => firstName, validateFirstName),
      reaction((_) => lastName, validateLastName),
      reaction((_) => userName, validateUserName),
      reaction((_) => userEmail, validateUserEmail),
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

  // store variables:-----------------------------------------------------------
  @observable
  bool success = false;

  @observable
  bool loading = false;

  @observable
  Map<String, dynamic> profileData = {};
  @observable
  var bookmarks = [];

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
  void setUserEmail(String value) {
    userEmail = value;
  }

  @action
  void validateFirstName(String value) {
    if (value.isEmpty) {
      userErrorStore.firstName = Strings.emptyFirstName;
    } else {
      userErrorStore.firstName = null;
    }
  }

  @action
  void validateLastName(String value) {
    if (value.isEmpty) {
      userErrorStore.lastName = Strings.emptyLastName;
    } else {
      userErrorStore.lastName = null;
    }
  }

  @action
  void validateUserName(String value) {
    if (value.isEmpty) {
      userErrorStore.userName = Strings.emptyUserName;
    } else {
      userErrorStore.userName = null;
    }
  }

  @action
  void validateUserEmail(String value) {
    if (value.isEmpty) {
      userErrorStore.userEmail = Strings.emptyEmail;
    } else if (!isEmail(value)) {
      userErrorStore.userEmail = Strings.validateEmail;
    } else {
      userErrorStore.userEmail = null;
    }
  }

  @action
  void validatePassword(String value) {
    if (value.isEmpty) {
      userErrorStore.password = Strings.emptyPassword;
    } else if (value.length < 8) {
      userErrorStore.password = Strings.maxLengthPassword;
    } else {
      userErrorStore.password = null;
    }
  }

  @action
  Future getUserProfile() async {
    loading = true;
    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      profileData = result.docs.first.data();
      await getBookmarksFlaggedProperties();
      print('Profile Data--- $profileData');
      return result.docs.first.data();
    } on FirebaseException catch (e) {
      print('---$e');
      throw Exception(e);
    } catch (e) {
      loading = false;
      print('---$e');
      _handleError(e);
      return [];
    }
  }

  @action
  Future getBookmarksFlaggedProperties() async {
    loading = true;
    try {
      var result = await FirebaseFirestore.instance
          .collection(
              'users/${FirebaseAuth.instance.currentUser?.uid}/bookmark_flag')
          .get();
      bookmarks = result.docs;
      return bookmarks;
      //ADMIN MODULE
      // var result = await FirebaseFirestore.instance
      //     .collection('users')
      //     .get();
      // List results = [];
      // for(var data in result.docs) {
      //   print('${data.id}');
      //   var flagData = await FirebaseFirestore.instance.collection('users/${data.id}/flags').get();
      //   results.add(flagData.docs);
      // }
      return result.docs;
    } on FirebaseException catch (e) {
      print('---$e');
      throw Exception(e);
    } catch (e) {
      loading = false;
      print('---$e');
      return [];
    }
  }

  @action
  Future addBookMark(int propertyId, String documentId) async {
    loading = true;
    try {
      await FirebaseFirestore.instance
          .collection(
              'users/${FirebaseAuth.instance.currentUser?.uid}/bookmark_flag')
          .add({
        'property_id': propertyId,
        'is_flagged': false,
        'flag_reason': '',
        'is_bookmarked': true,
        'property': documentId,
        'user': FirebaseAuth.instance.currentUser?.uid,
      });
      return await getBookmarksFlaggedProperties();
    } on FirebaseException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      print(e);
      return [];
    }
  }

  @action
  Future removeBookMark(int propertyId) async {
    loading = true;
    try {
      var result = await FirebaseFirestore.instance
          .collection(
              'users/${FirebaseAuth.instance.currentUser?.uid}/bookmark_flag')
          .where('property_id', isEqualTo: propertyId)
          .get();
      if (!(result.docs.first.data()['is_flagged'])) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('bookmark_flag')
            .doc(result.docs.first.reference.id)
            .delete();
      } else {
        var foundBookmark = result.docs.first;
        return await FirebaseFirestore.instance
            .collection(
            'users/${FirebaseAuth.instance.currentUser?.uid}/bookmark_flag')
            .doc(foundBookmark.id)
            .update({
          'is_bookmarked': false,
        });
      }
      loading = false;
      return await getBookmarksFlaggedProperties();
    } on FirebaseException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      print(e);
      return [];
    }
  }

  @action
  Future updateUserData() async {
    loading = true;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'first_name': firstName,
        'last_name': lastName,
        'username': userName,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    } on FirebaseException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      print(e);
      return [];
    }
  }

  Future<void> uploadProfileImage(String filePath) async {
    loading = true;
    File file = File(filePath);
    print(filePath);

    try {
      String filename =
          'profile_images/${FirebaseAuth.instance.currentUser!.uid}.png';
      await firebase_storage.FirebaseStorage.instance
          .ref(filename)
          .putFile(file);
      return await downloadURL(filename);
    } on firebase_storage.FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }

  Future downloadURL(String filePath) async {
    loading = true;
    try {
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(filePath)
          .getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'profile_image': downloadURL,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
      loading = false;
      return downloadURL;
    } on FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }

  // general methods:-----------------------------------------------------------

  void _handleError(e) {
    SharedPreferences.getInstance().then((preference) {
      print('---------------${preference.getBool(Preferences.is_logged_in)}');
      if (preference.getBool(Preferences.is_logged_in) ?? false) {
        FirebaseAuth.instance.signOut().then((value) {
          SharedPreferences.getInstance().then((preference) {
            preference.setBool(Preferences.is_logged_in, false);
            PostStore().clear();
            final NavigationService _navigationService =
                getIt<NavigationService>();
            _navigationService.navigateReplacementTo(Routes.login);
          });
        });
      }
    });

    loading = false;
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}

class UserErrorStore = _UserErrorStore with _$UserErrorStore;

abstract class _UserErrorStore with Store {
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

  @computed
  bool get hasErrorsInUpdateProfile =>
      firstName != null ||
      lastName != null ||
      userName != null ||
      userEmail != null ||
      password != null;
}
