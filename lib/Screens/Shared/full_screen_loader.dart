import 'package:flutter/material.dart';

class FullScreenLoader {
  static void openLoadingDialog(BuildContext context, String text){
      showDialog(
      context: context,
      barrierDismissible: false, //Dialog cant be dismissed by tapping outside it
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  static stopLoading(BuildContext context){
    Navigator.of(context).pop();
  }
}
  
  