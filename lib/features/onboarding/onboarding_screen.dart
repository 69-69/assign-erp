import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/network/data_sources/local/index.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/features/onboarding/data/onboarding_data.dart';
import 'package:assign_erp/features/onboarding/screen/onboarding_content_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final _deviceInfoCache = DeviceInfoCache();
  late PageController _pageController;
  int currentPage = 0;

  /// When the next button is pressed if we are on first page
  /// we will go to second page, otherwise we will go to login page
  Future<void> _onNextButtonPressed() async {
    if (currentPage + 1 == OnBoardingData.boards.length) {
      await _goToWorkspaceSignIn();
    } else {
      int newPage = currentPage + 1;
      _pageController.animateToPage(
        newPage,
        duration: kAnimateDuration,
        curve: Curves.easeIn,
      );
    }
    setState(() {});
  }

  // Navigate to the given route & then remove all the previous routes
  Future<void> _goToWorkspaceSignIn() async {
    await _deviceInfoCache.setOnboarding();
    if (!mounted) return;
    context.goNamed(RouteNames.workspaceSignIn);
  }

  @override
  void initState() {
    _pageController = PageController();

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isGradientBg: true,

      /// Next button is inside [OnBoardingContentView] widget
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [buildAppBar(context)];
        },
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: _buildBody(),
        ),
      ),
      actions: [],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Row _buildBottomNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Tooltip(
            message: 'Sign in to Workspace',
            child: TextButton(
              onPressed: () async => await _goToWorkspaceSignIn(),
              child: const Text(
                'Workspace Sign In',
                semanticsLabel: 'Workspace Sign In',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: 'Contact Support Team',
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Need Help?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar buildAppBar(BuildContext context) {
    return SliverAppBar(
      snap: true,
      pinned: true,
      floating: true,
      leading: Tooltip(
        message: 'Skip Onboarding',
        child: TextButton(
          key: const Key("skipOnBoarding"),
          onPressed: () async => await _goToWorkspaceSignIn(),
          child: Text(
            'Skip',
            semanticsLabel: 'Skip',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kLightBlueColor,
            ),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active Page
            Text(
              '${currentPage + 1}',
              semanticsLabel: '${currentPage + 1}',
              style: context.textTheme.bodyLarge?.copyWith(
                color: kLightBlueColor,
              ),
            ),
            // Total Pages
            Text(
              '/${OnBoardingData.boards.length}',
              semanticsLabel: '${OnBoardingData.boards.length}',
              style: context.textTheme.bodyLarge?.copyWith(
                color: kGrayBlueColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Tooltip(
          message: 'Continue to Next Page',
          child: TextButton(
            key: const Key("nextOnBoarding"),
            onPressed: () async => await _onNextButtonPressed(),
            child: Text(
              'Next',
              semanticsLabel: 'Next',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kLightBlueColor,
              ),
            ),
          ),
        ),
      ],
      backgroundColor: kTransparentColor,
    );
  }

  Column _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Image
        Expanded(
          child: PageView.builder(
            itemBuilder: (context, index) {
              final board = OnBoardingData.boards[index];

              return OnBoardingContentView(
                board: board,
                currentIndex: index,
                onPressedNext: () async => await _onNextButtonPressed(),
              );
            },
            onPageChanged: (v) {
              currentPage = v;
              setState(() {});
            },
            controller: _pageController,
            itemCount: OnBoardingData.boards.length,
          ),
        ),
      ],
    );
  }
}
