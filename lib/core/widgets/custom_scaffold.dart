import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/build_breadcrumbs.dart';
import 'package:assign_erp/core/widgets/profile_menu_dropdown.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final bool noAppBar;
  final Widget body;
  final Widget? drawer;
  final Color? bgColor;
  final dynamic title;
  final String? subTitle;
  final bool isGradientBg;
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
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionBtnLocation,
    this.noAppBar = false,
    this.isGradientBg = false,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  Color get _bgColor =>
      widget.bgColor ??
      (widget.isGradientBg
          ? kLightBlueColor
          : context.ofTheme.scaffoldBackgroundColor);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _bgColor,
      appBar: widget.noAppBar
          ? null
          : (widget.appBar ?? _buildAppBar(context, authState)),
      body: _buildBody(),
      bottomNavigationBar: widget.bottomNavigationBar ?? BuildBreadcrumbs(),
      floatingActionButtonLocation: widget.floatingActionBtnLocation,
      floatingActionButton: widget.floatingActionButton,
      drawer: widget.drawer,
    );
  }

  Widget _buildBody() {
    final uiBody = SafeArea(child: widget.body);

    return widget.isGradientBg
        ? Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  /*kPrimaryColor,
                    kPrimaryLightColor,
                    kLightBlueColor,*/
                  kPrimaryColor,
                  kLightBlueColor,
                  kLightBlueColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: uiBody,
          )
        : uiBody;
  }

  AppBar _buildAppBar(BuildContext context, AuthState authState) {
    bool canGoBack = Navigator.of(context).canPop();

    return AppBar(
      leading: canGoBack ? _buildLeading(context) : null,
      automaticallyImplyLeading: canGoBack,
      toolbarHeight: kAppBarHeight,
      centerTitle: true,
      elevation: 20,
      scrolledUnderElevation: 20,
      title: widget.title is Widget ? widget.title : _buildTitle(context),
      actions:
          widget.actions ??
          [
            ProfileMenuDropdown(
              workspace: authState.workspace,
              employee: authState.employee,
            ),
          ],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.drawer != null) return null;
    if (widget.backButton != null) return widget.backButton;

    return Container(
      color: kTransparentColor,
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(10, 20, 0, 20),
      child: const BackButton(color: kLightColor),
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
