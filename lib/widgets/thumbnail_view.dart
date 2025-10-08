import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/models/asset_file/asset_file.dart';
import 'package:fight_blight_bmore/widgets/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailView extends StatelessWidget {
  final VoidCallback delete;

  const ThumbnailView({
    Key? key,
    required this.delete,
    required this.thumbnail,
  }) : super(key: key);

  final AssetFile thumbnail;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            padding: EdgeInsets.all(3.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.8,
            child: thumbnail.type == AssetType.image
                ? thumbnail.downloadUrl == null
                    ? Center(child: CircularProgressIndicator())
                    : Image.network(
                        thumbnail.downloadUrl ?? '',
                        fit: BoxFit.cover,
                      )
                : Stack(children: [
                    Center(
                        child: thumbnail.thumbnailUrl == null
                            ? Center(child: CircularProgressIndicator())
                            : Image.network(
                                thumbnail.thumbnailUrl ?? '',
                                fit: BoxFit.fitWidth,
                                width: MediaQuery.of(context).size.width,
                              )),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 30,
                        child: FloatingActionButton(
                          onPressed: () {
                            if (thumbnail.type == AssetType.video) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                          pathUrl:
                                              thumbnail.downloadUrl ?? '')));
                            }
                          },
                          // Display the correct icon depending on the state of the player.
                          child: Icon(
                            Icons.play_arrow,
                          ),
                        ),
                      ),
                    ),
                  ])),
        Visibility(
          visible: !(thumbnail.downloadUrl?.contains('placeholder') ?? false),
          child: Align(
            child: GestureDetector(
                onTap: this.delete,
                child: Container(
                    padding: EdgeInsets.all(4),
                    width: 30,
                    child: Stack(children: [
                      Image.asset(Assets.circle),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(Assets.delete),
                      )
                    ]))),
            alignment: Alignment.topRight,
          ),
        ),
      ],
    );
  }
}
