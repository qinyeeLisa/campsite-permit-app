import 'package:camplified/Screens/Login/login_screen.dart';
import 'package:flutter/material.dart';

import 'or_divider.dart';
import 'social_icon.dart';

class SocialSignIn extends StatelessWidget {
  final Function? googleSignInCallback;
  
  const SocialSignIn({
    Key? key, this.googleSignInCallback,
  }) : super(key: key);

//temp8
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OrDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // SocialIcon(
            //   iconSrc: "assets/icons/facebook.svg",
            //   press: () {},
            // ),
            SocialIcon(
              iconSrc: "assets/icons/logo-google.svg",
              press: () => googleSignInCallback?.call(),
            ),
          ],
        ),
      ],
    );
  }
}