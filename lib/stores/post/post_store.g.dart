// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PostStore on _PostStore, Store {
  Computed<bool>? _$canPostPropertyComputed;

  @override
  bool get canPostProperty =>
      (_$canPostPropertyComputed ??= Computed<bool>(() => super.canPostProperty,
              name: '_PostStore.canPostProperty'))
          .value;

  final _$successAtom = Atom(name: '_PostStore.success');

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

  final _$loadingAtom = Atom(name: '_PostStore.loading');

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

  final _$propertyDetailsAtom = Atom(name: '_PostStore.propertyDetails');

  @override
  Map<String, dynamic> get propertyDetails {
    _$propertyDetailsAtom.reportRead();
    return super.propertyDetails;
  }

  @override
  set propertyDetails(Map<String, dynamic> value) {
    _$propertyDetailsAtom.reportWrite(value, super.propertyDetails, () {
      super.propertyDetails = value;
    });
  }

  final _$nameAtom = Atom(name: '_PostStore.name');

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  final _$descriptionAtom = Atom(name: '_PostStore.description');

  @override
  String get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  final _$addressAtom = Atom(name: '_PostStore.address');

  @override
  String get address {
    _$addressAtom.reportRead();
    return super.address;
  }

  @override
  set address(String value) {
    _$addressAtom.reportWrite(value, super.address, () {
      super.address = value;
    });
  }

  final _$commentAtom = Atom(name: '_PostStore.comment');

  @override
  String get comment {
    _$commentAtom.reportRead();
    return super.comment;
  }

  @override
  set comment(String value) {
    _$commentAtom.reportWrite(value, super.comment, () {
      super.comment = value;
    });
  }

  final _$flagReasonAtom = Atom(name: '_PostStore.flagReason');

  @override
  String get flagReason {
    _$flagReasonAtom.reportRead();
    return super.flagReason;
  }

  @override
  set flagReason(String value) {
    _$flagReasonAtom.reportWrite(value, super.flagReason, () {
      super.flagReason = value;
    });
  }

  final _$latLngAtom = Atom(name: '_PostStore.latLng');

  @override
  LatLng get latLng {
    _$latLngAtom.reportRead();
    return super.latLng;
  }

  @override
  set latLng(LatLng value) {
    _$latLngAtom.reportWrite(value, super.latLng, () {
      super.latLng = value;
    });
  }

  final _$neighborhoodAtom = Atom(name: '_PostStore.neighborhood');

  @override
  String get neighborhood {
    _$neighborhoodAtom.reportRead();
    return super.neighborhood;
  }

  @override
  set neighborhood(String value) {
    _$neighborhoodAtom.reportWrite(value, super.neighborhood, () {
      super.neighborhood = value;
    });
  }

  final _$tagsAtom = Atom(name: '_PostStore.tags');

  @override
  List<TagModel> get tags {
    _$tagsAtom.reportRead();
    return super.tags;
  }

  @override
  set tags(List<TagModel> value) {
    _$tagsAtom.reportWrite(value, super.tags, () {
      super.tags = value;
    });
  }

  final _$imageVideoListAtom = Atom(name: '_PostStore.imageVideoList');

  @override
  List<AssetFile> get imageVideoList {
    _$imageVideoListAtom.reportRead();
    return super.imageVideoList;
  }

  @override
  set imageVideoList(List<AssetFile> value) {
    _$imageVideoListAtom.reportWrite(value, super.imageVideoList, () {
      super.imageVideoList = value;
    });
  }

  final _$arrayTagsAtom = Atom(name: '_PostStore.arrayTags');

  @override
  List<TagModel> get arrayTags {
    _$arrayTagsAtom.reportRead();
    return super.arrayTags;
  }

  @override
  set arrayTags(List<TagModel> value) {
    _$arrayTagsAtom.reportWrite(value, super.arrayTags, () {
      super.arrayTags = value;
    });
  }

  final _$mediaAtom = Atom(name: '_PostStore.media');

  @override
  List<dynamic> get media {
    _$mediaAtom.reportRead();
    return super.media;
  }

  @override
  set media(List<dynamic> value) {
    _$mediaAtom.reportWrite(value, super.media, () {
      super.media = value;
    });
  }

  final _$getTagsAsyncAction = AsyncAction('_PostStore.getTags');

  @override
  Future<List<TagModel>> getTags() {
    return _$getTagsAsyncAction.run(() => super.getTags());
  }

  final _$getPropertiesAsyncAction = AsyncAction('_PostStore.getProperties');

  @override
  Future<dynamic> getProperties() {
    return _$getPropertiesAsyncAction.run(() => super.getProperties());
  }

  final _$getNearestPropertiesAsyncAction =
      AsyncAction('_PostStore.getNearestProperties');

  @override
  Future<dynamic> getNearestProperties(GeoFirePoint center) {
    return _$getNearestPropertiesAsyncAction
        .run(() => super.getNearestProperties(center));
  }

  final _$getPropertyDetailAsyncAction =
      AsyncAction('_PostStore.getPropertyDetail');

  @override
  Future<dynamic> getPropertyDetail(int propertyId, UserStore userStore) {
    return _$getPropertyDetailAsyncAction
        .run(() => super.getPropertyDetail(propertyId, userStore));
  }

  final _$updateTagsAsyncAction = AsyncAction('_PostStore.updateTags');

  @override
  Future<dynamic> updateTags() {
    return _$updateTagsAsyncAction.run(() => super.updateTags());
  }

  final _$_PostStoreActionController = ActionController(name: '_PostStore');

  @override
  void setUrls(List<AssetFile> value) {
    final _$actionInfo =
        _$_PostStoreActionController.startAction(name: '_PostStore.setUrls');
    try {
      return super.setUrls(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setName(String value) {
    final _$actionInfo =
        _$_PostStoreActionController.startAction(name: '_PostStore.setName');
    try {
      return super.setName(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDescription(String value) {
    final _$actionInfo = _$_PostStoreActionController.startAction(
        name: '_PostStore.setDescription');
    try {
      return super.setDescription(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAddress(String value) {
    final _$actionInfo =
        _$_PostStoreActionController.startAction(name: '_PostStore.setAddress');
    try {
      return super.setAddress(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setComment(String value) {
    final _$actionInfo =
        _$_PostStoreActionController.startAction(name: '_PostStore.setComment');
    try {
      return super.setComment(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFlagReason(String value) {
    final _$actionInfo = _$_PostStoreActionController.startAction(
        name: '_PostStore.setFlagReason');
    try {
      return super.setFlagReason(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNeighborhood(String value) {
    final _$actionInfo = _$_PostStoreActionController.startAction(
        name: '_PostStore.setNeighborhood');
    try {
      return super.setNeighborhood(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTags(List<TagModel> value) {
    final _$actionInfo =
        _$_PostStoreActionController.startAction(name: '_PostStore.setTags');
    try {
      return super.setTags(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateName(String value) {
    final _$actionInfo = _$_PostStoreActionController.startAction(
        name: '_PostStore.validateName');
    try {
      return super.validateName(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateDescription(String value) {
    final _$actionInfo = _$_PostStoreActionController.startAction(
        name: '_PostStore.validateDescription');
    try {
      return super.validateDescription(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateAddress(String value) {
    final _$actionInfo = _$_PostStoreActionController.startAction(
        name: '_PostStore.validateAddress');
    try {
      return super.validateAddress(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateComment(String value) {
    final _$actionInfo = _$_PostStoreActionController.startAction(
        name: '_PostStore.validateComment');
    try {
      return super.validateComment(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateFlagReason(String value) {
    final _$actionInfo = _$_PostStoreActionController.startAction(
        name: '_PostStore.validateFlagReason');
    try {
      return super.validateFlagReason(value);
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clear() {
    final _$actionInfo =
        _$_PostStoreActionController.startAction(name: '_PostStore.clear');
    try {
      return super.clear();
    } finally {
      _$_PostStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
success: ${success},
loading: ${loading},
propertyDetails: ${propertyDetails},
name: ${name},
description: ${description},
address: ${address},
comment: ${comment},
flagReason: ${flagReason},
latLng: ${latLng},
neighborhood: ${neighborhood},
tags: ${tags},
imageVideoList: ${imageVideoList},
arrayTags: ${arrayTags},
media: ${media},
canPostProperty: ${canPostProperty}
    ''';
  }
}

mixin _$PostErrorStore on _PostErrorStore, Store {
  Computed<bool>? _$hasErrorsInPostComputed;

  @override
  bool get hasErrorsInPost =>
      (_$hasErrorsInPostComputed ??= Computed<bool>(() => super.hasErrorsInPost,
              name: '_PostErrorStore.hasErrorsInPost'))
          .value;

  final _$nameAtom = Atom(name: '_PostErrorStore.name');

  @override
  String? get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String? value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  final _$descriptionAtom = Atom(name: '_PostErrorStore.description');

  @override
  String? get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String? value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  final _$addressAtom = Atom(name: '_PostErrorStore.address');

  @override
  String? get address {
    _$addressAtom.reportRead();
    return super.address;
  }

  @override
  set address(String? value) {
    _$addressAtom.reportWrite(value, super.address, () {
      super.address = value;
    });
  }

  final _$commentAtom = Atom(name: '_PostErrorStore.comment');

  @override
  String? get comment {
    _$commentAtom.reportRead();
    return super.comment;
  }

  @override
  set comment(String? value) {
    _$commentAtom.reportWrite(value, super.comment, () {
      super.comment = value;
    });
  }

  final _$flagReasonAtom = Atom(name: '_PostErrorStore.flagReason');

  @override
  String? get flagReason {
    _$flagReasonAtom.reportRead();
    return super.flagReason;
  }

  @override
  set flagReason(String? value) {
    _$flagReasonAtom.reportWrite(value, super.flagReason, () {
      super.flagReason = value;
    });
  }

  final _$tagsAtom = Atom(name: '_PostErrorStore.tags');

  @override
  List<TagModel>? get tags {
    _$tagsAtom.reportRead();
    return super.tags;
  }

  @override
  set tags(List<TagModel>? value) {
    _$tagsAtom.reportWrite(value, super.tags, () {
      super.tags = value;
    });
  }

  final _$imageVideoListAtom = Atom(name: '_PostErrorStore.imageVideoList');

  @override
  List<AssetFile>? get imageVideoList {
    _$imageVideoListAtom.reportRead();
    return super.imageVideoList;
  }

  @override
  set imageVideoList(List<AssetFile>? value) {
    _$imageVideoListAtom.reportWrite(value, super.imageVideoList, () {
      super.imageVideoList = value;
    });
  }

  @override
  String toString() {
    return '''
name: ${name},
description: ${description},
address: ${address},
comment: ${comment},
flagReason: ${flagReason},
tags: ${tags},
imageVideoList: ${imageVideoList},
hasErrorsInPost: ${hasErrorsInPost}
    ''';
  }
}
