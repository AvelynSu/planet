import 'package:flutter/material.dart';

import '../../custom_theme.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        color: Colors.black.withOpacity(0.2),
        child: CircularProgressIndicator(
          color: primary,
        ),
      ),
    );
  }
}
