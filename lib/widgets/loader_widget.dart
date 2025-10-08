import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoaderWidget extends StatelessWidget {
  final child;

  final state;

  LoaderWidget({this.child, this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        state
            ? new Stack(
                children: [
                  new Opacity(
                    opacity: 0.3,
                    child: const ModalBarrier(
                        dismissible: false, color: Colors.grey),
                  ),
                  new Center(
                    child: new CircularProgressIndicator(),
                  ),
                ],
              )
            : Container()
      ],
    );
  }
}
