import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class AssetFile {
  String? id;
  String? path;
  Future<Uint8List?>? thumbnail;
  AssetType? type;
  File? file;
  String? filename;
  String? downloadUrl;
  String? thumbnailUrl;

  AssetFile({
    this.id,
    this.path,
    this.thumbnail,
    this.type,
    this.file,
    this.filename,
    this.downloadUrl,
    this.thumbnailUrl,
  });

  factory AssetFile.fromMap(Map<String, dynamic> json) => AssetFile(
    path: json["path"],
    thumbnail: json["thumbnail"],
    type: json["type"],
    id: json["id"],
    file: json["file"],
    filename: json["filename"],
    downloadUrl: json["downloadUrl"],
    thumbnailUrl: json["thumbnailUrl"],
  );

  Map<String, dynamic> toMap() => {
    "path": path,
    "thumbnail": thumbnail,
    "type": type,
    "id": id,
    "file": file,
    "filename": filename,
    "downloadUrl": downloadUrl,
    "thumbnailUrl": thumbnailUrl,
  };

}
