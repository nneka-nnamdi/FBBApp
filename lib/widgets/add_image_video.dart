import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:flutter/material.dart';

class AddImageVideo extends StatelessWidget {
  const AddImageVideo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        child: Column(
          children: [
            Container(
              child: Image.asset(
                Assets.plus,
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
