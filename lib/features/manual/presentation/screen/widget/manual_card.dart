import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/neumorphism.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/url_launcher_helper.dart';
import 'package:assign_erp/features/manual/data/models/manual_model.dart';
import 'package:assign_erp/features/manual/presentation/screen/how_to_config_app/update/update_manual.dart';
import 'package:flutter/material.dart';

class ManualCard extends StatefulWidget {
  final List<Manual> manuals;
  final bool isEdit;

  const ManualCard({super.key, required this.manuals, required this.isEdit});

  @override
  State<ManualCard> createState() => _ManualCardState();
}

class _ManualCardState extends State<ManualCard> {
  late double maxCrossAxisExtent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMaxCrossAxisExtent();
  }

  void _updateMaxCrossAxisExtent() {
    // context.isMobile ? screenW :
    var screenW = context.screenWidth;
    maxCrossAxisExtent = (context.isPortraitMode ? screenW / 2 : screenW / 4);
  }

  @override
  Widget build(BuildContext context) {
    double pad = 20;

    return _buildBody(context, pad);
  }

  GridView _buildBody(BuildContext context, double pad) {
    return GridView.builder(
      primary: false,
      itemCount: widget.manuals.length,
      physics: const RangeMaintainingScrollPhysics(),
      padding: EdgeInsets.all(pad),
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
      itemBuilder: (context, index) {
        final manual = widget.manuals[index];
        final bgColor = userManualBgColrs[index];
        return _CardContent(
          manual: manual,
          isEdit: widget.isEdit,
          bgColor: bgColor,
        );
      },
    );
  }
}

class _CardContent extends StatelessWidget {
  final Manual manual;
  final Color bgColor;
  final bool isEdit;

  const _CardContent({
    required this.manual,
    required this.bgColor,
    required this.isEdit,
  });

  TextStyle get _titleStyle => const TextStyle(
    overflow: TextOverflow.ellipsis,
    color: Color.fromRGBO(255, 255, 255, 0.9),
  );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      runAlignment: WrapAlignment.center,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Manual', style: _titleStyle),
        if (!context.isMiniMobile) _buildTitle(context),
        _buildButton(context),
        if (!context.isMobile) _buildTextButton(),
      ],
    ).fluidGlassMorphism(bgColor: bgColor);
  }

  Widget _buildTitle(BuildContext context) => Text(
    manual.title.toUppercaseFirstLetterEach,
    style: _titleStyle.copyWith(fontWeight: FontWeight.bold),
    textScaler: TextScaler.linear(context.textScaleFactor),
  );

  Widget _buildButton(BuildContext context) =>
      isEdit ? _buildEditButton(context) : _buildPlayButton(context);

  Widget _buildEditButton(BuildContext context) => _buildActionButton(
    context,
    icon: Icons.edit_note,
    tooltip: 'Edit ${manual.title} manual',
    onPressed: () async => await context.openUpdateManual(manual: manual),
  );

  Widget _buildPlayButton(BuildContext context) => _buildActionButton(
    context,
    tooltip: manual.description,
    onPressed: () async => await _launchUrl(),
  );

  Widget _buildTextButton() => TextButton.icon(
    onPressed: () async => await _launchUrl(),
    label: Text('Watch Video', style: _titleStyle.copyWith(color: kLightColor)),
    icon: const Icon(Icons.link_outlined, color: kLightColor),
  );

  Widget _buildActionButton(
    BuildContext context, {
    IconData? icon,
    String? tooltip,
    required void Function() onPressed,
  }) => IconButton(
    onPressed: onPressed,
    tooltip: tooltip ?? manual.description,
    icon: Icon(icon ?? Icons.play_circle_outline),
    iconSize: context.screenWidth * 0.08,
    color: kDangerColor,
  );

  _launchUrl() async =>
      await UrlLaunchUtil.urlLauncher(url: manual.url, inApp: true);
}
