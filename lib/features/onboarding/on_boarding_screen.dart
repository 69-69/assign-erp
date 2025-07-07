import 'dart:async';

import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/animated_hexagon_grid.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/features/auth/presentation/screen/sign_in/workspace_sign_in_screen.dart';
import 'package:assign_erp/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  Timer? _timer;
  bool _hideSplashScreen = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  /// Start a timer to trigger the dialog after a delay
  void _startTimer() {
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() => _hideSplashScreen = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _hideSplashScreen ? _buildBody(context) : const SplashScreen();
  }

  CustomScaffold _buildBody(BuildContext context) {
    return CustomScaffold(
      backButton: const SizedBox.shrink(),
      bgColor: kWarningColor,
      body: CustomScrollBar(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 0, bottom: context.bottomInsetPadding),
        child: Container(
          decoration: const BoxDecoration(
            color: kGrayBlueColor,
            image: DecorationImage(image: AssetImage(appBg), fit: BoxFit.cover),
          ),
          child: const AnimatedHexagonGrid(child: WorkspaceSignInForm()),
        ),
      ),
    );
  }
}

/*class OnBoardingScreen2 extends StatefulWidget {
  const OnBoardingScreen2({super.key});

  @override
  State<OnBoardingScreen2> createState() => _OnBoardingScreen2State();
}

class _OnBoardingScreen2State extends State<OnBoardingScreen2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation1;
  late Animation<Offset> _animation2;
  bool _hideSplashScreen = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  /// Start a timer to trigger the dialog after a delay
  void _startTimer() {
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() => _hideSplashScreen = true);
    });
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation1 = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0.1),
    ).animate(_controller);

    _animation2 = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, 0),
    ).animate(_controller);
  }

  // Future<void> openBox() async {
  //   dataBox = await Hive.openBox<CacheData>(localCacheName);
  // }

  @override
  Widget build(BuildContext context) {
    return _hideSplashScreen
        ? CustomScaffold(
            backButton: const SizedBox.shrink(),
            body: Container(
              decoration: const BoxDecoration(
                color: kGrayBlueColor,
                image: DecorationImage(
                  image: AssetImage(appBg),
                  fit: BoxFit.cover,
                ),
              ),
              child: _buildBody(context),
            ),
          )
        : const SplashScreen();
  }

  AdaptiveLayout _buildBody(BuildContext context) {
    var screenWidth = context.screenWidth;
    return AdaptiveLayout(
      // isScrollable: false,
      isFormBuilder: false,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Stack(
              children: [
                _lightBlueBg(screenWidth),
                _darkBlueBg(screenWidth),
              ],
            ),
          ),
        ),
        Expanded(
          child: _buildRightColumn(screenWidth, context),
        )
      ],
    );
  }

  Container _buildRightColumn(double screenWidth, BuildContext context) {
    return Container(
      color: kGrayColor.withAlpha((0.9 * 255).toInt()),
      width: screenWidth,
      height: context.screenHeight,
      padding: const EdgeInsets.all(20),
      child: Text(
        'Need Help?',
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Positioned _lightBlueBg(double screenWidth) {
    var wh = screenWidth * 0.3;

    return Positioned.fill(
      child: SlideTransition(
        position: _animation1,
        child: CustomPaint(
          painter: HexagonPainter2(
            kLightBlueColor.withAlpha((0.9 * 255).toInt()),
          ),
          size: Size(wh, wh),
          child: Center(child: _showSignInButton()),
        ),
      ),
    );
  }

  Positioned _darkBlueBg(double screenWidth) {
    var wh = screenWidth * 0.1;
    var lightBlueBgSize = screenWidth * 0.3;
    // Calculate the offset to position the hexagon at the center of the screen
    double centerX = lightBlueBgSize;
    double centerY = (context.screenHeight - lightBlueBgSize) / 5;

    return Positioned(
      left: centerX,
      top: centerY,
      child: SlideTransition(
        position: _animation2,
        child: CustomPaint(
          painter: HexagonPainter2(kTransparentColor),
          size: Size(wh, wh),
          child: Image.asset(
            appLogo2,
            fit: BoxFit.contain,
            width: wh,
            semanticLabel: appName,
          ),
        ),
      ),
    );
  }

  FilledButton _showSignInButton() {
    return FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.all(18),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
      onPressed: () async => await context.openWorkspacePopUp(),
      child: Text(
        'Sign In to Workspace',
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: kLightBlueColor,
        ),
      ),
    );
  }
}

class HexagonPainter2 extends CustomPainter {
  final Color color;

  HexagonPainter2(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double width = size.width;
    final double height = size.height;
    final double sideLength = width / 2;
    // final double halfHeight = height / 2;
    final double radius = sideLength * cos(pi / 6);

    path.moveTo(width / 2, 0);
    path.lineTo(width, radius);
    path.lineTo(width, radius + sideLength);
    path.lineTo(width / 2, height);
    path.lineTo(0, radius + sideLength);
    path.lineTo(0, radius);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PassCodeForm extends StatelessWidget {
  const PassCodeForm({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.all(18),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        // backgroundColor: context.colorScheme.error,
      ),
      child: const Text('Enter Pass Code'),
      onPressed: () async => await _authorizeDialog(context),
    );
  }

  Future<void> _authorizeDialog(BuildContext context) async {
    TextEditingController txtController = TextEditingController();

    final isAuthorized = await context.confirmAction(
      Card.filled(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CustomTextField(
                  controller: txtController,
                  inputType: TextInputType.text,
                  labelText: 'Pass code',
                  onFieldSubmitted: (s) {
                    if (txtController.text.isNotEmpty) {
                      context.goNamed(s.isWork);
                    }
                  }),
            ),
          ],
        ),
      ),
      title: "Enter Store number",
      onAccept: "Authorize",
      onReject: "Cancel",
    );

    if (context.mounted && isAuthorized && txtController.text.isNotEmpty) {
      context.goNamed(txtController.text.isWork);
    }
  }
}*/
