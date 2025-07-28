import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/network/data_sources/models/permission_item_model.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/horizontal_line.dart';
import 'package:assign_erp/features/setup/data/models/role_permission_model.dart';
import 'package:assign_erp/features/setup/presentation/screen/manage_roles/widget/form_inputs.dart';
import 'package:flutter/material.dart';

class PermissionSelector extends StatefulWidget {
  final List<PermissionItem> permissions;
  final Set<RolePermission>? initialPermissions;
  final void Function(Set<RolePermission>) onSelected;
  final String displayName;
  final Color? sectionColor;
  final bool selectAllByDefault;

  const PermissionSelector({
    super.key,
    required this.permissions,
    required this.onSelected,
    required this.displayName,
    this.sectionColor,
    this.initialPermissions,
    this.selectAllByDefault = false,
  });

  @override
  State<PermissionSelector> createState() => _PermissionSelectorState();
}

class _PermissionSelectorState extends State<PermissionSelector> {
  late List<bool> _selectedStates;
  PermissionMode _mode = PermissionMode.select;

  List<PermissionItem> get _permissions => widget.permissions;

  Set<RolePermission>? get _initialPermissions => widget.initialPermissions;

  late List<PermissionItem> _filteredPermissions;
  final TextEditingController _searchController = TextEditingController();

  String get _displayName => widget.displayName.toTitleCase;

  @override
  void initState() {
    super.initState();
    _initSelectedStates();

    _initFilter();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelected(_getSelectedValues());
    });
  }

  void _initSelectedStates() {
    if ((_initialPermissions == null || _initialPermissions!.isEmpty) &&
        widget.selectAllByDefault) {
      // New role: select all by default
      _selectedStates = List.filled(_permissions.length, true);
    } else {
      // Existing role: map from stored RolePermissions
      _selectedStates = _permissions.map((permissionItem) {
        final perm = RolePermission(
          module: permissionItem.module,
          permission: permissionItem.permissionName,
        );
        return _initialPermissions?.contains(perm) ?? false;
      }).toList();
    }
  }

  void _updateAllPermissions(bool enable) {
    setState(
      () => _selectedStates = List.filled(_selectedStates.length, enable),
    );
  }

  void _initFilter() {
    _filteredPermissions = List.from(_permissions);

    _searchController.addListener(
      () => _filterPermissions(_searchController.text),
    );
  }

  void _filterPermissions(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredPermissions = List.from(_permissions);
      } else {
        final q = query.toLowerCase();
        _filteredPermissions = _permissions.where((item) {
          return item.title.toLowerCase().contains(q) ||
              item.subtitle.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  Set<RolePermission> _getSelectedValues() {
    final selected = <RolePermission>{};
    for (int i = 0; i < _selectedStates.length; i++) {
      if (_selectedStates[i]) {
        final item = _permissions[i];
        selected.add(
          RolePermission(module: item.module, permission: item.permissionName),
        );
      }
    }
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    // final grouped = _groupBy(_permissions, (PermissionItem item) => item.group);
    final selectedLength = _getSelectedValues().length;
    final grouped = _groupBy(
      _filteredPermissions,
      (PermissionItem p) => p.module,
    );

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          "$_displayName Permissions ${selectedLength > 0 ? "($selectedLength)" : ""}", // ad selected length
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _PermissionRadioTile(
          title: "Allow all $_displayName permissions for this role",
          value: PermissionMode.allowAll,
          groupValue: _mode,
          onChanged: (value) {
            setState(() {
              _mode = value!;
              _updateAllPermissions(true);
              widget.onSelected(_getSelectedValues());
            });
          },
        ),
        _PermissionRadioTile(
          title: "Select specific $_displayName permissions for this role",
          value: PermissionMode.select,
          groupValue: _mode,
          onChanged: (value) {
            setState(() {
              _mode = value!;
              _updateAllPermissions(false);
              widget.onSelected(_getSelectedValues());
            });
          },
        ),
        const SizedBox(height: 10),
        FilterPermissions(controller: _searchController),
        const SizedBox(height: 10),

        // Permission Toggles
        Expanded(child: _buildListView(grouped)),
      ],
    );
  }

  ListView _buildListView(Map<String, List<PermissionItem>> grouped) {
    return ListView(
      primary: false,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            _ModuleName(name: entry.key, sectionColor: widget.sectionColor),
            HorizontalLine(width: 0.8),

            /*..._permissions.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;*/
            ...entry.value.map((PermissionItem item) {
              final index = _permissions.indexOf(item);

              return _SwitchListCard(
                item: item,
                isSelected: _selectedStates[index],
                onChanged: _mode == PermissionMode.select
                    ? (value) {
                        setState(() => _selectedStates[index] = value);
                        widget.onSelected(_getSelectedValues());
                        // _printPermissions(); // ✅ log current state
                      }
                    : null,
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  // Grouping utility
  Map<K, List<T>> _groupBy<T, K>(List<T> list, K Function(T) keySelector) {
    final Map<K, List<T>> map = {};
    for (final item in list) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /*void _printPermissions() {
    debugPrint("🔘 Mode: $_mode");
    debugPrint("✅ Selected States: $_selectedStates");
    debugPrint("🎯 Selected Permissions: ${_getSelectedValues()}");
  }
*/
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ModuleName extends StatelessWidget {
  final String name;
  final Color? sectionColor;

  const _ModuleName({required this.name, this.sectionColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(
        name.toUpperCase(),
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: sectionColor ?? context.ofTheme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _SwitchListCard extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  final PermissionItem item;
  final bool isSelected;

  const _SwitchListCard({
    required this.item,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      dense: true,
      title: Text(
        item.title,
        style: context.ofTheme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: context.ofTheme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade700,
        ),
      ),
      value: isSelected,
      onChanged: onChanged,
    );
  }
}

class _PermissionRadioTile extends StatelessWidget {
  final String title;
  final PermissionMode value;
  final PermissionMode groupValue;
  final ValueChanged<PermissionMode?> onChanged;

  const _PermissionRadioTile({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.groupValue,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<PermissionMode>.adaptive(
      dense: true,
      value: value,
      groupValue: groupValue,
      title: Text(title),
      onChanged: onChanged,
    );
  }
}

/*

class KeepAlivePermissionSelector extends StatefulWidget {
  final PermissionSelector child;

  const KeepAlivePermissionSelector({super.key, required this.child});

  @override
  State<KeepAlivePermissionSelector> createState() =>
      _KeepAlivePermissionSelectorState();
}

class _KeepAlivePermissionSelectorState
    extends State<KeepAlivePermissionSelector>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

 ==============


class _AssignPermissionsToRoleState extends State<AssignPermissionsToRole> {
  get _permissionDetails => widget.permissionDetails;

  PermissionMode _mode = PermissionMode.allowAll;
  late List<bool> _permissions;

  @override
  void initState() {
    super.initState();
    // Initially allow all
    _permissions = List.filled(widget.permissionDetails.length, true);
  }

  void _updatePermissions(bool enableAll) {
    setState(() {
      for (int i = 0; i < _permissions.length; i++) {
        _permissions[i] = enableAll;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        /// Radio Buttons
        PermissionRadioTile(
          value: PermissionMode.allowAll,
          groupValue: _mode,
          title: "Allow all Point of Sale permissions for this role",
          onChanged: (value) => setState(() {
            _mode = value!;
            _updatePermissions(true);
          }),
        ),
        PermissionRadioTile(
          value: PermissionMode.select,
          groupValue: _mode,
          title: "Select Point of Sale permissions for this role",
          onChanged: (value) => setState(() => _mode = value!),
        ),
        const SizedBox(height: 16),

        /// Permissions toggles
        Expanded(
          child: ListView.builder(
            itemCount: widget.permissionDetails.length,
            itemBuilder: (context, index) {
              return SwitchListTile(
                dense: true,
                title: Text(
                  _permissionDetails[index]['title']!,
                  style: context.ofTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(_permissionDetails[index]['subtitle']!),
                value: _permissions[index],
                onChanged: _mode == PermissionMode.select
                    ? (value) => setState(() => _permissions[index] = value)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

final List<Map<String, String>> _permissionDetails = [
  {
    "title": "Manage orders at all locations",
    "subtitle": "View and edit orders made and fulfilled at all locations.",
  },
  {
    "title": "Manage sales attribution for orders",
    "subtitle":
    "Add, edit, or remove staff attributed to sales on completed.",
  },
  {
    "title": "Edit customer details",
    "subtitle": "Edit contact, address, note, tags, and options.orders.",
  },
  {
    "title": "Manage a customer's store credit",
    "subtitle": "Add or remove store credit from a customer's account.",
  },
];*/
