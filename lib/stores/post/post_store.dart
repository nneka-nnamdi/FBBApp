import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/models/asset_file/asset_file.dart';
import 'package:fight_blight_bmore/models/tags_model.dart';
import 'package:fight_blight_bmore/stores/error/error_store.dart';
import 'package:fight_blight_bmore/stores/user/user_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'post_store.g.dart';

class PostStore = _PostStore with _$PostStore;

abstract class _PostStore with Store {
  // store for handling errors
  final PostErrorStore postErrorStore = PostErrorStore();
  BuildContext? context;

  // constructor:---------------------------------------------------------------
  _PostStore() {
    _setupValidations();
  }

  @observable
  bool success = false;

  @observable
  bool loading = false;

  @observable
  Map<String, dynamic> propertyDetails = {};
  String documentId = '';

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  Future<void> _setupValidations() async {
    _disposers = [
      reaction((_) => name, validateName),
      reaction((_) => description, validateDescription),
      reaction((_) => address, validateAddress),
      reaction((_) => comment, validateComment),
      reaction((_) => flagReason, validateFlagReason),
    ];
  }

  // store variables:-----------------------------------------------------------
  @observable
  String name = '';

  @observable
  String description = '';

  @observable
  String address = '';

  @observable
  String comment = '';

  @observable
  String flagReason = '';

  @observable
  LatLng latLng = LatLng(0, 0);

  @observable
  String neighborhood = '';

  @observable
  List<TagModel> tags = [];

  @observable
  List<AssetFile> imageVideoList = [];

  @observable
  List<TagModel> arrayTags = [];

  @observable
  List media = [];

  @computed
  bool get canPostProperty =>
      !postErrorStore.hasErrorsInPost &&
      name.isNotEmpty &&
      description.isNotEmpty &&
      address.isNotEmpty &&
      tags.isNotEmpty;

  // actions:-------------------------------------------------------------------

  @action
  void setUrls(List<AssetFile> value) {
    imageVideoList = value;
  }

  @action
  void setName(String value) {
    name = value;
  }

  @action
  void setDescription(String value) {
    description = value;
  }

  @action
  void setAddress(String value) {
    address = value;
  }

  @action
  void setComment(String value) {
    comment = value;
  }

  @action
  void setFlagReason(String value) {
    flagReason = value;
  }

  @action
  void setNeighborhood(String value) {
    neighborhood = value;
  }

  @action
  void setTags(List<TagModel> value) {
    tags = value;
  }

  @action
  void validateName(String value) {
    if (value.isEmpty) {
      postErrorStore.name = Strings.emptyName;
    } else if (value.length > 100) {
      postErrorStore.name = Strings.validateName;
    } else {
      postErrorStore.name = null;
    }
  }

  @action
  void validateDescription(String value) {
    if (value.isEmpty) {
      postErrorStore.description = Strings.emptyDescription;
    } else if (value.length > 320) {
      postErrorStore.description = Strings.validateDescription;
    } else {
      postErrorStore.description = null;
    }
  }

  @action
  void validateAddress(String value) {
    if (value.isEmpty) {
      postErrorStore.address = Strings.emptyAddress;
    } else {
      postErrorStore.address = null;
    }
  }

  @action
  void validateComment(String value) {
    if (value.isEmpty) {
      postErrorStore.comment = Strings.emptyComment;
    } else {
      postErrorStore.comment = null;
    }
  }

  @action
  void validateFlagReason(String value) {
    if (value.isEmpty) {
      postErrorStore.flagReason = Strings.emptyFlagReason;
    } else {
      postErrorStore.flagReason = null;
    }
  }

  @action
  void clear() {
    name = '';
    description = '';
    address = '';
    neighborhood = '';
    tags = [];
    imageVideoList = [];
    comment = '';
  }

  //fetch tags method:-----------------------------------------------------------

  @action
  Future<List<TagModel>> getTags() async {
    loading = true;

    try {
      await FirebaseFirestore.instance
          .collection('tags')
          .doc('R1NZiRvD4D4C9rPt9QKY')
          .get()
          .then((snapshot) {
        if (snapshot.data()!.entries.first.value != null) {
          arrayTags.clear();
          snapshot.data()!.entries.first.value.forEach((element) {
            var tagModel = new TagModel();
            tagModel.fromMap(element);
            arrayTags.add(tagModel);
          });
        }
        arrayTags.sort((a, b) => (a.title == "Other")
            ? 1
            : (b.title == "Other" ? -1 : a.title.compareTo(b.title)));

        return arrayTags;
      });
      loading = false;
      return arrayTags;
    } on FirebaseException catch (e) {
      _handleError(e);
      loading = false;
      throw Exception(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
      throw Exception(e);
    }
  }

  //fetch properties method:-----------------------------------------------------------

  @action
  Future getProperties() async {
    loading = true;
    try {
      var result = await FirebaseFirestore.instance
          .collection('property')
          .orderBy('created_at', descending: true)
          // .where('is_flagged',
          //     isNotEqualTo:
          //        true) //.where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)'
          .get();
      loading = false;
      return result.docs.where((e) {
        return !e['is_flagged'];
      }).toList();
    } on FirebaseException catch (e) {
      loading = false;
      _handleError(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
      throw Exception(e);
    }
  }

  @action
  Future getNearestProperties(GeoFirePoint center) async {
    loading = true;
    try {
      GeoPoint userGeoPoint = center.geoPoint;

// distance in miles
      double distance = 2000;
      double lat = 0.0144927536231884;
      double lon = 0.0181818181818182;

      double greaterLat = userGeoPoint.latitude + (lat * distance);
      double greaterLon = userGeoPoint.longitude + (lon * distance);

      GeoPoint greaterGeoPoint = GeoPoint(greaterLat, greaterLon);
      var query = await FirebaseFirestore.instance
          .collection('property')
          .where("point.geopoint", isLessThan: greaterGeoPoint)
          .limit(10)
          .get();
      return query.docs;
    } on FirebaseException catch (e) {
      loading = false;
      _handleError(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
      throw Exception(e);
    }
  }

//fetch property details method:-----------------------------------------------------------

  @action
  Future getPropertyDetail(int propertyId, UserStore userStore) async {
    loading = true;
    try {
      var result = await FirebaseFirestore.instance
          .collection('property')
          .where('property_id', isEqualTo: propertyId)
          .get();
      await getTags();
      await userStore.getUserProfile();
      documentId = result.docs.first.id;
      print(documentId);
      loading = false;
      return result.docs.first.data();
    } on FirebaseException catch (e) {
      loading = false;
      _handleError(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
      throw Exception(e);
    }
  }

  // media upload/download/delete methods:-----------------------------------------------------------
  Future<void> downloadURL(String filePath) async {
    try {
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(filePath)
          .getDownloadURL();
      imageVideoList.last.filename = filePath;
      imageVideoList.last.downloadUrl = downloadURL;
      if (downloadURL == 'null') {
        imageVideoList.removeLast();
      }
      loading = false;
      return;
    } on FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }

  Future<void> uploadImage(String filePath) async {
    loading = true;
    File file = File(filePath);
    print(filePath);

    try {
      String filename =
          'images/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.png';
      await firebase_storage.FirebaseStorage.instance
          .ref(filename)
          .putFile(file);
      await downloadURL(filename);
      return;
    } on firebase_storage.FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }

  Future<void> uploadVideo(String filePath) async {
    loading = true;
    File file = File(filePath);
    loading = true;
    try {
      String filename =
          'videos/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await firebase_storage.FirebaseStorage.instance.ref(filename).putFile(
          file, firebase_storage.SettableMetadata(contentType: 'video/mp4'));
      await downloadURL(filename);
      await uploadThumbnail(filePath);
      loading = false;
      return;
    } on firebase_storage.FirebaseException catch (e) {
      loading = false;
      print(e.code);
    }
  }

  Future<void> uploadThumbnail(String filePath) async {
    Uint8List? data = await VideoThumbnail.thumbnailData(
      video: filePath,
      imageFormat: ImageFormat.PNG,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 50,
    );
    String filename =
        'thumbnails/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.png';
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref(filename);

    try {
      // Upload raw data.
      await ref.putData(data!);
      // Get raw data.
      String downloadedData = await ref.getDownloadURL();
      print(downloadedData);
      imageVideoList.last.thumbnailUrl = downloadedData;
    } on FirebaseException catch (e) {
      print(e);
      // e.g, e.code == 'canceled'
    }
  }

  Future<void> delete(String ref, int index) async {
    print('delete this file >>>>>> $ref');
    try {
      await firebase_storage.FirebaseStorage.instance.ref(ref).delete();
      imageVideoList.removeAt(index);
    } catch (e) {
      imageVideoList.removeAt(index);
    }
  }

  Future updateTreePlantation(bool isPlantation) async {
    loading = true;
    try {
      var result = await FirebaseFirestore.instance
          .collection('property')
          .doc(documentId)
          .update({'tree_plantation': isPlantation});
      propertyDetails['tree_plantation'] = isPlantation;
      loading = false;
      return result;
    } on FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }

  Future updateEviction(bool isEvictionReported, String evictionType) async {
    loading = true;
    try {
      var result = await FirebaseFirestore.instance
          .collection('property')
          .doc(documentId)
          .update({
        'is_evicted': isEvictionReported,
        'eviction_type': evictionType,
      });
      loading = false;
      return result;
    } on FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }

  Future flagPost() async {
    loading = true;
    try {
      await FirebaseFirestore.instance
          .collection('property')
          .doc(documentId)
          .set({'is_flagged': true, 'flag_reason': flagReason},
              SetOptions(merge: true));
      var _userStore = UserStore();
      await _userStore.getBookmarksFlaggedProperties();
      var bookmarkList =
          (_userStore.bookmarks.where((e) => e['property'] == documentId));
      if (bookmarkList.isNotEmpty) {
        loading = false;
        var foundBookmark = bookmarkList.first as DocumentSnapshot;
        return await FirebaseFirestore.instance
            .collection(
                'users/${FirebaseAuth.instance.currentUser?.uid}/bookmark_flag')
            .doc(foundBookmark.id)
            .update({
          'is_flagged': true,
          'flag_reason': flagReason,
        });
      } else {
        loading = false;
        return await FirebaseFirestore.instance
            .collection(
                'users/${FirebaseAuth.instance.currentUser?.uid}/bookmark_flag')
            .add(
          {
            'is_flagged': true,
            'flag_reason': flagReason,
            'property': documentId,
            'user': FirebaseAuth.instance.currentUser?.uid,
            'is_bookmarked': false,
            'property_id': propertyDetails['property_id'],
          },
        );
      }
    } on FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }

  @action
  Future updateTags() async {
    loading = true;
    try {
      var selectedTags = tags.map((e) => e.id).toList();
      await FirebaseFirestore.instance
          .collection('property')
          .doc(documentId)
          .update({'tags': selectedTags});
    } on FirebaseException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      loading = false;
      print(e);
      return null;
    }
  }

  Future addComment(String comment) async {
    loading = true;
    try {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      var userReferenceId = userData.docs.first.reference;
      var newComment = {
        'user': userReferenceId,
        'comment': comment,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
      var result = await FirebaseFirestore.instance
          .collection('property')
          .doc(documentId)
          .update({
        'comments': FieldValue.arrayUnion([newComment])
      });
      propertyDetails['comments'].add(newComment);
      loading = false;
      return result;
    } on FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }

  Future removePlaceholderImage() async {
    loading = true;
    try {

      var result = await FirebaseFirestore.instance
          .collection('property')
          .doc(documentId)
          .update({'media': []});
      imageVideoList.clear();
      loading = false;
      return result;
    } on FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }


  Future addMedia() async {
    loading = true;
    try {
      var mediaUpload = imageVideoList.map((e) {
        return {
          'thumbnail': e.thumbnailUrl,
          'mediaUrl': e.downloadUrl,
        };
      }).toList();
      var result = await FirebaseFirestore.instance
          .collection('property')
          .doc(documentId)
          .update({'media': FieldValue.arrayUnion(mediaUpload)});
      media.add(mediaUpload.first);
      imageVideoList.clear();
      loading = false;
      return result;
    } on FirebaseException catch (e) {
      print(e.code);
      loading = false;
    }
  }

  Future fetchBookmarkedProperties(UserStore userStore) async {
    loading = true;
    try {
      await userStore.getBookmarksFlaggedProperties();
      print(userStore.bookmarks);
      if (userStore.bookmarks.length == 0) {
        return [];
      }
      var properties = [];
      for (var bookmark in userStore.bookmarks) {
        var result = await FirebaseFirestore.instance
            .collection('property')
            .doc(bookmark['property'])
            .get();
        properties.add(result.data());
      }
      print(properties);
      loading = false;
      return properties;
    } on FirebaseException catch (e) {
      loading = false;
      _handleError(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
      throw Exception(e);
    }
  }

  Future searchProperties(String search) async {
    loading = true;
    try {
      var resultName = await FirebaseFirestore.instance
          .collection('property')
          .where('name', isEqualTo: search)
          .get();
      var resultAddress = await FirebaseFirestore.instance
          .collection('property')
          .where('address', isEqualTo: search)
          .get();
      var resultTags = await FirebaseFirestore.instance
          .collection('property')
          .where('tags', arrayContains: search)
          .get();
      var resultDescription = await FirebaseFirestore.instance
          .collection('property')
          .where('description', isEqualTo: search)
          .get();
      loading = false;
      List<QueryDocumentSnapshot<Map<String, dynamic>>> newList = [
        ...resultName.docs,
        ...resultAddress.docs,
        ...resultTags.docs,
        ...resultDescription.docs
      ].toSet().toList();
      return newList;
    } on FirebaseException catch (e) {
      loading = false;
      _handleError(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      loading = false;
      showDefaultSnackbar(Strings.somethingWentWrong);
      throw Exception(e);
    }
  }

  void _handleError(FirebaseException e) {
    if (e.code == 'network-request-failed') {
      showDefaultSnackbar(Strings.networkError);
    } else if (e.code == 'permission-denied') {
      FirebaseAuth.instance.signOut().then((value) {
        SharedPreferences.getInstance().then((preference) {
          preference.setBool(Preferences.is_logged_in, false);
          clear();
        });
      });
    }
    loading = false;
  }

  void showDefaultSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      clear();
      d();
    }
  }

  void validateAll() {
    validateName(name);
    validateDescription(description);
    validateAddress(address);
  }
}

class PostErrorStore = _PostErrorStore with _$PostErrorStore;

abstract class _PostErrorStore with Store {
  @observable
  String? name;

  @observable
  String? description;

  @observable
  String? address;

  @observable
  String? comment;

  @observable
  String? flagReason;

  @observable
  List<TagModel>? tags;

  @observable
  List<AssetFile>? imageVideoList;

  @computed
  bool get hasErrorsInPost =>
      name != null ||
      description != null ||
      address != null ||
      tags != null ||
      imageVideoList != null;
}
