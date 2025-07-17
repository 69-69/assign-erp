import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/neumorphism.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:flutter/material.dart';

class CustomTab extends StatefulWidget {
  final List<Map<String, dynamic>> tabs;
  final TabController? controller;
  final double indicatorWeight;
  final List<Widget> children;
  final bool isScrollable;
  final bool isColoredTab;
  final bool isVerticalTab;
  final int length;
  final Function(int)? onTapChanged;
  final EdgeInsetsGeometry? padding;

  /// [openThisTab] Open the exact TabView, if provided, else defaulted to '0'
  final int openThisTab;

  const CustomTab({
    super.key,
    this.controller,
    required this.tabs,
    required this.length,
    required this.children,
    this.isColoredTab = true,
    this.isScrollable = false,
    this.isVerticalTab = false,
    this.openThisTab = 0,
    this.indicatorWeight = 6.0,
    this.onTapChanged,
    this.padding,
  });

  @override
  State<CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // late List<bool> _loadedTabs;
  Set<int> loadedTabs = {};
  bool _isNavigationRailVisible = true; // State variable for toggle

  @override
  void initState() {
    super.initState();
    _tabController =
        widget.controller ??
        TabController(
          vsync: this,
          length: widget.length,
          initialIndex: widget.openThisTab,
        );

    // Ensure the initial tab content is loaded
    loadedTabs.add(widget.openThisTab);
    // Initialize loaded state for tabs
    // _loadedTabs = List<bool>.generate(widget.length, (index) => false);

    // Listen to tab changes
    _listenToTabChanges();
  }

  void _listenToTabChanges() {
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return; // Wait until change is complete
      }
      if (widget.onTapChanged != null) {
        widget.onTapChanged!(_tabController.index);
      }
    });
  }

  void _toggleNavigationRail() {
    setState(() {
      _isNavigationRailVisible = !_isNavigationRailVisible; // Toggle visibility
    });
  }

  void _handleTabTap(int index) {
    if (!loadedTabs.contains(index)) {
      setState(() {
        // Only add the new tab index to loadedTabs, clearing previous indices
        loadedTabs.clear();
        loadedTabs.add(index);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.length,

      // isVerticalTab = true: create a vertical tabs (side)  else create horizontal tabs
      child: widget.isVerticalTab
          ? _buildVerticalTabs(context)
          : _buildHorizontalTabs(context),
    );
  }

  Row _buildVerticalTabs(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle button for NavigationRail visibility
            IconButton(
              icon: Icon(
                _isNavigationRailVisible
                    ? Icons.arrow_back
                    : Icons.arrow_forward,
              ),
              onPressed: _toggleNavigationRail,
            ),
            // Conditionally display the NavigationRail
            if (_isNavigationRailVisible) Expanded(child: _buildSideNavRail()),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // This is the main content.
        Expanded(child: _buildTabBarView()),
      ],
    );
  }

  // NavigationRail for vertical tabs
  NavigationRail _buildSideNavRail() {
    return NavigationRail(
      indicatorColor: kLightBlueColor,
      selectedIndex: _tabController.index,
      onDestinationSelected: (index) {
        _tabController.animateTo(index);
        _handleTabTap(index);
      },
      labelType: NavigationRailLabelType.all,
      // Set the visual properties for the selected destination
      selectedLabelTextStyle: const TextStyle(
        color: kPrimaryLightColor,
        fontWeight: FontWeight.bold,
      ),
      destinations: widget.tabs.map<NavigationRailDestination>((t) {
        return NavigationRailDestination(
          icon: Icon(t['icon']),
          label: Text(t['label'].toString().toUppercaseFirstLetterEach),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalTabs(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildColoredTabBar(context),
        // This is the main content.
        Expanded(child: _buildTabBarView()),
      ],
    );
  }

  /// This is the TabBarBar content
  Widget _buildColoredTabBar(BuildContext context) {
    return widget.isColoredTab
        ? ColoredBox(
            color: context.colorScheme.secondaryContainer, // kLightBlueColor
            child: _buildTabBar(context),
          ).addNeumorphism()
        : _buildTabBar(context);
  }

  /// This is the main TabBarView content
  TabBarView _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: List.generate(
        widget.length,
        (index) => loadedTabs.contains(index)
            ? widget.children[index]
            : _loaderPlaceholder(index),
      ),
    );
  }

  Align _loaderPlaceholder(int index) {
    return Align(
      key: ValueKey<int>(index),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: const EdgeInsets.all(5.0), child: context.loader),
          Expanded(child: Text('${widget.tabs[index]['label']} is loading...')),
        ],
      ),
    );
  }

  TabBar _buildTabBar(BuildContext context) {
    return TabBar(
      indicatorWeight: widget.indicatorWeight,
      controller: _tabController,
      isScrollable: widget.isScrollable,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: widget.isColoredTab
          ? context.ofTheme.textTheme.titleLarge?.copyWith(
              // color: kPrimaryColor,
              fontWeight: FontWeight.w400,
            )
          : context.ofTheme.textTheme.titleSmall,
      padding:
          widget.padding ?? const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      tabs: widget.tabs
          .map<Widget>(
            (t) => Tab(
              text: t['label'].toString().toUppercaseFirstLetterEach,
              icon: Icon(t['icon']),
            ),
          )
          .toList(),
      onTap: _handleTabTap,
    );
  }
}
