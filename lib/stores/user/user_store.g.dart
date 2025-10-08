// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserStore on _UserStore, Store {
  final _$successAtom = Atom(name: '_UserStore.success');

  @override
  bool get success {
    _$successAtom.reportRead();
    return super.success;
  }

  @override
  set success(bool value) {
    _$successAtom.reportWrite(value, super.success, () {
      super.success = value;
    });
  }

  final _$loadingAtom = Atom(name: '_UserStore.loading');

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  final _$profileDataAtom = Atom(name: '_UserStore.profileData');

  @override
  Map<String, dynamic> get profileData {
    _$profileDataAtom.reportRead();
    return super.profileData;
  }

  @override
  set profileData(Map<String, dynamic> value) {
    _$profileDataAtom.reportWrite(value, super.profileData, () {
      super.profileData = value;
    });
  }

  final _$bookmarksAtom = Atom(name: '_UserStore.bookmarks');

  @override
  List<dynamic> get bookmarks {
    _$bookmarksAtom.reportRead();
    return super.bookmarks;
  }

  @override
  set bookmarks(List<dynamic> value) {
    _$bookmarksAtom.reportWrite(value, super.bookmarks, () {
      super.bookmarks = value;
    });
  }

  final _$firstNameAtom = Atom(name: '_UserStore.firstName');

  @override
  String get firstName {
    _$firstNameAtom.reportRead();
    return super.firstName;
  }

  @override
  set firstName(String value) {
    _$firstNameAtom.reportWrite(value, super.firstName, () {
      super.firstName = value;
    });
  }

  final _$lastNameAtom = Atom(name: '_UserStore.lastName');

  @override
  String get lastName {
    _$lastNameAtom.reportRead();
    return super.lastName;
  }

  @override
  set lastName(String value) {
    _$lastNameAtom.reportWrite(value, super.lastName, () {
      super.lastName = value;
    });
  }

  final _$userNameAtom = Atom(name: '_UserStore.userName');

  @override
  String get userName {
    _$userNameAtom.reportRead();
    return super.userName;
  }

  @override
  set userName(String value) {
    _$userNameAtom.reportWrite(value, super.userName, () {
      super.userName = value;
    });
  }

  final _$userEmailAtom = Atom(name: '_UserStore.userEmail');

  @override
  String get userEmail {
    _$userEmailAtom.reportRead();
    return super.userEmail;
  }

  @override
  set userEmail(String value) {
    _$userEmailAtom.reportWrite(value, super.userEmail, () {
      super.userEmail = value;
    });
  }

  final _$passwordAtom = Atom(name: '_UserStore.password');

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  final _$getUserProfileAsyncAction = AsyncAction('_UserStore.getUserProfile');

  @override
  Future<dynamic> getUserProfile() {
    return _$getUserProfileAsyncAction.run(() => super.getUserProfile());
  }

  final _$getBookmarksFlaggedPropertiesAsyncAction =
      AsyncAction('_UserStore.getBookmarksFlaggedProperties');

  @override
  Future<dynamic> getBookmarksFlaggedProperties() {
    return _$getBookmarksFlaggedPropertiesAsyncAction
        .run(() => super.getBookmarksFlaggedProperties());
  }

  final _$addBookMarkAsyncAction = AsyncAction('_UserStore.addBookMark');

  @override
  Future<dynamic> addBookMark(int propertyId, String documentId) {
    return _$addBookMarkAsyncAction
        .run(() => super.addBookMark(propertyId, documentId));
  }

  final _$removeBookMarkAsyncAction = AsyncAction('_UserStore.removeBookMark');

  @override
  Future<dynamic> removeBookMark(int propertyId) {
    return _$removeBookMarkAsyncAction
        .run(() => super.removeBookMark(propertyId));
  }

  final _$updateUserDataAsyncAction = AsyncAction('_UserStore.updateUserData');

  @override
  Future<dynamic> updateUserData() {
    return _$updateUserDataAsyncAction.run(() => super.updateUserData());
  }

  final _$_UserStoreActionController = ActionController(name: '_UserStore');

  @override
  void setFirstName(String value) {
    final _$actionInfo = _$_UserStoreActionController.startAction(
        name: '_UserStore.setFirstName');
    try {
      return super.setFirstName(value);
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLastName(String value) {
    final _$actionInfo = _$_UserStoreActionController.startAction(
        name: '_UserStore.setLastName');
    try {
      return super.setLastName(value);
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserName(String value) {
    final _$actionInfo = _$_UserStoreActionController.startAction(
        name: '_UserStore.setUserName');
    try {
      return super.setUserName(value);
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserEmail(String value) {
    final _$actionInfo = _$_UserStoreActionController.startAction(
        name: '_UserStore.setUserEmail');
    try {
      return super.setUserEmail(value);
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateFirstName(String value) {
    final _$actionInfo = _$_UserStoreActionController.startAction(
        name: '_UserStore.validateFirstName');
    try {
      return super.validateFirstName(value);
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateLastName(String value) {
    final _$actionInfo = _$_UserStoreActionController.startAction(
        name: '_UserStore.validateLastName');
    try {
      return super.validateLastName(value);
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateUserName(String value) {
    final _$actionInfo = _$_UserStoreActionController.startAction(
        name: '_UserStore.validateUserName');
    try {
      return super.validateUserName(value);
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateUserEmail(String value) {
    final _$actionInfo = _$_UserStoreActionController.startAction(
        name: '_UserStore.validateUserEmail');
    try {
      return super.validateUserEmail(value);
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validatePassword(String value) {
    final _$actionInfo = _$_UserStoreActionController.startAction(
        name: '_UserStore.validatePassword');
    try {
      return super.validatePassword(value);
    } finally {
      _$_UserStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
success: ${success},
loading: ${loading},
profileData: ${profileData},
bookmarks: ${bookmarks},
firstName: ${firstName},
lastName: ${lastName},
userName: ${userName},
userEmail: ${userEmail},
password: ${password}
    ''';
  }
}

mixin _$UserErrorStore on _UserErrorStore, Store {
  Computed<bool>? _$hasErrorsInUpdateProfileComputed;

  @override
  bool get hasErrorsInUpdateProfile => (_$hasErrorsInUpdateProfileComputed ??=
          Computed<bool>(() => super.hasErrorsInUpdateProfile,
              name: '_UserErrorStore.hasErrorsInUpdateProfile'))
      .value;

  final _$firstNameAtom = Atom(name: '_UserErrorStore.firstName');

  @override
  String? get firstName {
    _$firstNameAtom.reportRead();
    return super.firstName;
  }

  @override
  set firstName(String? value) {
    _$firstNameAtom.reportWrite(value, super.firstName, () {
      super.firstName = value;
    });
  }

  final _$lastNameAtom = Atom(name: '_UserErrorStore.lastName');

  @override
  String? get lastName {
    _$lastNameAtom.reportRead();
    return super.lastName;
  }

  @override
  set lastName(String? value) {
    _$lastNameAtom.reportWrite(value, super.lastName, () {
      super.lastName = value;
    });
  }

  final _$userNameAtom = Atom(name: '_UserErrorStore.userName');

  @override
  String? get userName {
    _$userNameAtom.reportRead();
    return super.userName;
  }

  @override
  set userName(String? value) {
    _$userNameAtom.reportWrite(value, super.userName, () {
      super.userName = value;
    });
  }

  final _$userEmailAtom = Atom(name: '_UserErrorStore.userEmail');

  @override
  String? get userEmail {
    _$userEmailAtom.reportRead();
    return super.userEmail;
  }

  @override
  set userEmail(String? value) {
    _$userEmailAtom.reportWrite(value, super.userEmail, () {
      super.userEmail = value;
    });
  }

  final _$passwordAtom = Atom(name: '_UserErrorStore.password');

  @override
  String? get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String? value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  @override
  String toString() {
    return '''
firstName: ${firstName},
lastName: ${lastName},
userName: ${userName},
userEmail: ${userEmail},
password: ${password},
hasErrorsInUpdateProfile: ${hasErrorsInUpdateProfile}
    ''';
  }
}
