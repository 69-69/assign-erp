import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/developer_info.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late double maxCrossAxisExtent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMaxCrossAxisExtent();
  }

  void _updateMaxCrossAxisExtent() {
    var screenW = context.screenWidth;
    maxCrossAxisExtent = context.isMobile
        ? screenW
        : (context.isPortraitMode ? screenW / 2 : screenW / 3);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      noAppBar: true,
      backButton: const SizedBox.shrink(),
      bgColor: context.ofTheme.primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildBody(context)),
          const DeveloperInfo(),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GridView.builder(
      primary: false,
      itemCount: context.isPortraitMode ? 9 : 6,
      physics: const RangeMaintainingScrollPhysics(),
      padding: context.isMobile
          ? const EdgeInsets.symmetric(vertical: 5)
          : const EdgeInsets.all(30),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        // mainAxisExtent: maxCrossAxisExtent,
        // Spacing between rows
        mainAxisSpacing: 20,
        // Spacing between columns
        crossAxisSpacing: 20,
        // Ratio between the width and height of grid items
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) =>
          index.isOdd ? _buildStack(context) : _buildCard(context),
    );
  }

  _buildCard(BuildContext context) {
    const subTitle =
        'P.O.S\nReports\nInventory\nCustomer\nWarehouse\nMulti-Location\nMobile & Desktop\nWeb\n...';

    return AnimatedContainer(
      // width: context.mediaShortSize / 1.3,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 4, color: kLightBlueColor),
          left: BorderSide(width: 4, color: kLightBlueColor),
          right: BorderSide(width: 4, color: kLightBlueColor),
          bottom: BorderSide(width: 4, color: kLightBlueColor),
        ),
        color: Color(0xD7BFBFBF),
      ),

      padding: const EdgeInsets.all(20.0),
      duration: kAnimateDuration,
      child: GridTile(
        child: Center(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            titleAlignment: ListTileTitleAlignment.center,
            title: Text(
              appName.toUppercaseAllLetter,
              textAlign: TextAlign.center,
              style: context.ofTheme.textTheme.titleLarge?.copyWith(
                color: kPrimaryColor,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
              textScaler: TextScaler.linear(context.textScaleFactor),
            ),
            subtitle: Text(
              subTitle,
              textAlign: TextAlign.center,
              style: context.ofTheme.textTheme.labelSmall?.copyWith(
                color: kLightBlueColor,
                overflow: TextOverflow.ellipsis,
              ),
              textScaler: TextScaler.linear(context.textScaleFactor),
            ),
          ),
        ),
      ),
    );
  }

  Stack _buildStack(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          appLogo,
          fit: BoxFit.scaleDown,
          width: context.screenWidth * 0.2,
          semanticLabel: appName,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Wrap(
            runSpacing: 4,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              const Text(
                "Getting $appName Ready...",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: kLightBlueColor),
              ),
              _buildDefaultProgressIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultProgressIndicator() {
    return const LinearProgressIndicator(
      semanticsLabel: 'loading',
      minHeight: 8,
      backgroundColor: kLightBlueColor,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
    );
  }
}
