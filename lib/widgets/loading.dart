import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final double dimension;
  final String assetName;

  const LoadingWidget({
    super.key,
    this.dimension = 40,
    this.assetName = 'assets/loading.json',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: Lottie.asset(assetName),
    );
  }
}

enum LottieAnimations {
  chilipaca('assets/chilipaca.json');

  final String path;

  const LottieAnimations(this.path);
}
