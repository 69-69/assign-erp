import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:flutter/material.dart';

class CustomScaffold extends StatefulWidget {
  final bool noAppBar;
  final Widget body;
  final Widget? drawer;
  final Color? bgColor;
  final dynamic title;
  final String? subTitle;
  final Widget? backButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionBtnLocation;

  const CustomScaffold({
    super.key,
    required this.body,
    this.title,
    this.subTitle,
    this.actions,
    this.bgColor,
    this.drawer,
    this.backButton,
    this.noAppBar = false,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionBtnLocation,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  bool get _isLargeScreen => context.isLargeScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: widget.bgColor,
      appBar: widget.noAppBar ? null : _buildAppBar(context),
      body: SafeArea(child: widget.body),
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButtonLocation: widget.floatingActionBtnLocation,
      floatingActionButton: widget.floatingActionButton,
      drawer: widget.drawer,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: _buildLeading(context),
      leadingWidth: context.isMobile ? 65 : 180,
      toolbarHeight: kAppBarHeight,
      centerTitle: true,
      elevation: 20,
      scrolledUnderElevation: 20,
      // backgroundColor: context.primaryColor,
      title: widget.title is Widget ? widget.title : _buildTitle(context),
      actions: widget.actions,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.drawer != null) return null;
    if (widget.backButton != null) return widget.backButton;

    return Container(
      color: kTransparentColor,
      alignment: Alignment.center,
      margin: _isLargeScreen
          ? const EdgeInsets.fromLTRB(10, 20, 0, 20)
          : const EdgeInsets.only(left: 10),
      child: _buildDesktopLeadingContent(context),
    );
  }

  Widget _buildDesktopLeadingContent(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      spacing: 10,
      children: [
        const BackButton(color: kLightColor),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: const CircleAvatar(
            backgroundColor: kLightBlueColor,
            child: Icon(Icons.person, color: kPrimaryColor),
          ),
        ),
        if (_isLargeScreen) ...[_buildUserDetails(context)],
      ],
    );
  }

  Widget _buildUserDetails(BuildContext context) {
    final employee = context.employee;
    final clientName = employee?.fullName.toUppercaseFirstLetter ?? '';
    final roleName = employee?.role.name.toUppercaseFirstLetter ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          clientName,
          style: context.ofTheme.textTheme.bodyMedium?.copyWith(
            color: kLightBlueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            roleName,
            style: context.ofTheme.textTheme.labelSmall?.copyWith(
              color: kLightBlueColor,
            ),
          ),
        ),
      ],
    );
  }

  ListTile _buildTitle(BuildContext context) {
    return ListTile(
      dense: true,
      titleAlignment: ListTileTitleAlignment.center,
      title: Text(
        '${widget.title ?? appName}'.toUppercaseAllLetter,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: const TextStyle(
          color: kLightBlueColor,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.fade,
        ),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
      subtitle: Text(
        (widget.subTitle ?? appSubName).toUppercaseAllLetter,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: context.ofTheme.textTheme.titleSmall?.copyWith(
          fontSize: 10,
          color: kLightBlueColor,
          overflow: TextOverflow.fade,
        ),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
    );
  }
}

/*Drawer _drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.workspace?.clientName ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      context.workspace?.role.name ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }*/
