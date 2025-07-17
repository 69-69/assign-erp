import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/delayed_animation.dart';
import 'package:assign_erp/features/onboarding/data/onboarding_data.dart';
import 'package:flutter/material.dart';

const int delayedAmount = 500;

const _onBoardingButtonColors = [
  kDarkWarningColor,
  kBrightPrimaryColor,
  kPrimaryLightColor,
  kLightOrangeColor,
  kLightOrangeColor,
];

class OnBoardingContentView extends StatelessWidget {
  const OnBoardingContentView({
    super.key,
    required this.board,
    required this.currentIndex,
    required this.onPressedNext,
  });

  final OnBoardingModel board;
  final int currentIndex;
  final void Function() onPressedNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildImage(),

        /// Title, Subtitle, Button
        _buildTitle(context.ofTheme),
        if (context.isMobile && context.isLandscapeMode)
          ...[]
        else ...[
          DelayedAnimation(
            delay: delayedAmount + 2000,
            child: buildNextButton(context),
          ),
        ],
      ],
    );
  }

  _buildImage() {
    return Expanded(child: Image.asset(board.imageLink, fit: BoxFit.contain));
  }

  SizedBox buildNextButton(BuildContext context) {
    return SizedBox(
      width: context.screenWidth * 0.5,
      child: ElevatedButton.icon(
        onPressed: onPressedNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: _onBoardingButtonColors[currentIndex],
          // shape: const StadiumBorder(),
          padding: const EdgeInsets.all(10),
        ),
        iconAlignment: IconAlignment.end,
        icon: Row(
          children: List.generate(
            currentIndex + 1,
            (index) => Icon(
              Icons.adaptive.arrow_forward,
              color: currentIndex == index ? kLightColor : kGrayBlueColor,
              size: 13,
            ),
          ),
        ),
        label: Text('Next', style: TextStyle(color: kLightColor)),
      ),
    );
  }

  _buildTitle(ThemeData customTheme) {
    return Column(
      children: [
        DelayedAnimation(
          delay: delayedAmount + 500,
          child: Text(
            board.title,
            style: customTheme.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w500,
              color: kPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        DelayedAnimation(
          delay: delayedAmount + 1000,
          child: Text(
            board.subtitle,
            style: customTheme.textTheme.bodyLarge?.copyWith(
              color: kPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        // Button
      ],
    );
  }
}
