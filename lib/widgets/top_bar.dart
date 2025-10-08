import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.45,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.background),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Padding(
                padding: EdgeInsets.only(left: 15.0, bottom: 15.0),
                child: Image.asset(Assets.logo)),
          ),
        ],
      ),
    );
  }
}
