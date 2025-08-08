import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/date_time_picker.dart';
import 'package:assign_erp/core/util/debug_printify.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/core/widgets/dialog/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/file_doc_manager.dart';
import 'package:flutter/material.dart';

class DynamicDataTable extends StatefulWidget {
  /// Skip / Exclude / Hide the first value of each row [skip]
  final bool skip;

  /// The LIST Position to skip in row [skipPos]
  /// Especially, if you don't need to show ID field
  final int skipPos;

  /// Show or Hide Sensitive ID [showIDToggle]
  /// Use [showIDToggle], [skip] must be set to TURE
  final bool showIDToggle;

  /// Add Widget to DataTable Top [anyWidget]
  final Widget? anyWidget;

  /// Any Widget Alignment [anyWidgetAlignment]
  final WrapAlignment anyWidgetAlignment;

  /// Edit / Update button icon [editIcon]
  final IconData? editIcon;

  /// Delete button icon [deleteIcon]
  final IconData? deleteIcon;

  /// Optional button icon [optButtonIcon]
  final IconData? optButtonIcon;

  /// Edit / Update button label [editLabel]
  final String? editLabel;

  /// Optional Button [optButtonLabel]
  final String? optButtonLabel;

  /// Delete button label [deleteLabel]
  final String? deleteLabel;

  /// DataTable header [headers]
  final List<String> headers;

  /// Main LIST of rows in the DataTable [rows]
  final List<List<String>> rows;

  /// Add LIST of children below the DataTable [childrenRow]
  final List<List<String>>? childrenRow;
  final Function(String, List<String>)? onCellTap;

  /// Optional Button onClick Action [onOptButtonTap]
  final Function(List<String>)? onOptButtonTap;

  /// If single CheckBox is selected Action [onChecked]
  final Function(bool?, List<String>)? onChecked;

  /// If All CheckBoxes are selected Action [onAllChecked]
  final Function(bool, List<bool>, List<List<String>>)? onAllChecked;
  final Function(List<String>)? onEditTap;
  final Function(List<String>)? onDeleteTap;

  const DynamicDataTable({
    super.key,
    required this.headers,
    required this.rows,
    this.childrenRow,
    this.skip = false,
    this.skipPos = 1,
    this.showIDToggle = false,
    this.anyWidget,
    this.editIcon,
    this.deleteIcon,
    this.optButtonIcon,
    this.editLabel,
    this.deleteLabel,
    this.optButtonLabel,
    this.onCellTap,
    this.onEditTap,
    this.onDeleteTap,
    this.onOptButtonTap,
    this.onChecked,
    this.onAllChecked,
    this.anyWidgetAlignment = WrapAlignment.start,
  });

  @override
  State<DynamicDataTable> createState() => _DynamicDataTableState();
}

class _DynamicDataTableState extends State<DynamicDataTable> {
  bool _allSelectedStatus = false;
  late List<bool> _selectedRowsStatus;
  bool _allVisibleRowIds = false;

  // Track the index of the row with visible ID
  int? _visibleRowIdIndex;

  final ScrollController _horScrollController = ScrollController();
  final ScrollController _verScrollController = ScrollController();

  // Toggle Specific Row Id
  void _toggleHideID(int index) {
    setState(() {
      if (_visibleRowIdIndex == index) {
        _visibleRowIdIndex = null; // Hide if the same row is tapped again
      } else {
        _visibleRowIdIndex = index; // Show specific row ID
      }
    });
  }

  // Toggle All Row IDs
  void _allToggleHideID() =>
      setState(() => _allVisibleRowIds = !_allVisibleRowIds);

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int get totalRows => widget.rows.length + (widget.childrenRow?.length ?? 0);

  @override
  void initState() {
    super.initState();
    _initializeSelectedRows();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeSelectedRows() =>
      _selectedRowsStatus = List<bool>.filled(totalRows, false);

  void _toggleAllSelection(bool? value) {
    setState(() {
      _allSelectedStatus = value ?? false;
      for (int i = 0; i < _selectedRowsStatus.length; i++) {
        _selectedRowsStatus[i] = _allSelectedStatus;
      }

      // Notify if a callback is provided
      if (widget.onAllChecked != null) {
        widget.onAllChecked!(
          _allSelectedStatus,
          _selectedRowsStatus,
          _getSelectedRows(),
        );
      }
    });
  }

  // Update Search query/term
  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text);
  }

  /// Search Func. for rows [_searchFunc]
  List<List<String>> _searchRowsFunc() {
    return widget.rows
        .where(
          (row) => row.any(
            (cell) => cell.toLowercaseAll.contains(_searchQuery.toLowercaseAll),
          ),
        )
        .toList();
  }

  /// Search Func. for ChildRows [_searchChildRowsFunc]
  List<List<String>> _searchChildRowsFunc() {
    return widget.childrenRow
            ?.where(
              (row) => row.any(
                (cell) =>
                    cell.toLowercaseAll.contains(_searchQuery.toLowercaseAll),
              ),
            )
            .toList() ??
        [];
  }

  /// Get all checked or selected rows by _buildParentCheckbox()
  List<List<String>> _getSelectedRows() {
    final selectedRows = <List<String>>[];

    // Ensure the list sizes match
    if (_selectedRowsStatus.isEmpty) return selectedRows;

    int index = 0;

    // Iterate over regular rows
    for (int i = 0; i < widget.rows.length; i++) {
      if (index < _selectedRowsStatus.length && _selectedRowsStatus[index]) {
        selectedRows.add(widget.rows[i]);
      }
      index++;
    }

    // Iterate over child rows
    for (int j = 0; j < (widget.childrenRow?.length ?? 0); j++) {
      if (index < _selectedRowsStatus.length && _selectedRowsStatus[index]) {
        selectedRows.add(widget.childrenRow![j]);
      }
      index++;
    }

    // debugPrint('data-steve: $selectedRows');
    return selectedRows;
  }

  /*List<List<String>> _getSelectedRows2() {
    final selectedRows = <List<String>>[];

    // Ensure that the _selectedRows list is properly sized
    if (_selectedRowsStatus.isEmpty || widget.rows.isEmpty) {
      return selectedRows;
    }

    for (int i = 0; i < _selectedRowsStatus.length; i++) {
      if (i < widget.rows.length && _selectedRowsStatus[i]) {
        selectedRows.add(widget.rows[i]);
      }
    }

    return selectedRows;
  }*/

  void _updateSelectedRowsForNewRowCount() {
    if (_selectedRowsStatus.length != totalRows) {
      // Adjust the size of _selectedRows to match the number of rows
      _initializeSelectedRows();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horScrollController.dispose();
    _verScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure _selectedRows list is correctly sized
    _updateSelectedRowsForNewRowCount();

    final filteredRows = _searchRowsFunc();
    final filteredChildRows = _searchChildRowsFunc();

    return CustomScrollBar(
      controller: _verScrollController,
      child: Wrap(
        alignment: widget.anyWidgetAlignment,
        children: [
          _AnyWidget(
            headers: widget.headers,
            anyWidget: widget.anyWidget,
            selectedRows: _getSelectedRows,
          ),
          _SearchTextField(
            controller: _searchController,
            onPressed: () {
              _searchController.clear();
            },
          ),
          CustomScrollBar(
            controller: _horScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 20.0),
            child: _buildBody(context, filteredRows, filteredChildRows),
          ),
        ],
      ),
    );
  }

  DataTable _buildBody(
    BuildContext context,
    List<List<String>> filteredRows,
    List<List<String>> filteredChildRows,
  ) {
    return DataTable(
      showCheckboxColumn: false,
      border: const TableBorder(verticalInside: BorderSide(width: 0.1)),
      headingRowColor: const WidgetStatePropertyAll(kGrayBlueColor),
      columns: _buildDataColumns(context),
      rows: [
        ..._buildDataRows(context, rows: filteredRows),
        if (widget.childrenRow != null)
          ..._buildDataRows(
            context,
            rows: filteredChildRows,
            startIndex: filteredRows.length,
            color: WidgetStatePropertyAll(
              kDangerColor.withAlpha((0.1 * 255).toInt()),
            ),
          ),
      ],
    );
  }

  /// Skip / Exclude / Hide the first value of each row in the `List<List<String>>`
  /// In this case: hiding the ID value from the UI
  Iterable<String> _excludeTheFirstValue(List<String> list) =>
      widget.skip ? list.skip(widget.skipPos) : list;

  /// Build DataTable Header [_buildDataColumn]
  List<DataColumn> _buildDataColumns(BuildContext context) {
    final columns = [
      // Toggle All CheckBoxes
      DataColumn(
        tooltip: 'Select multiple orders',
        label: _buildParentCheckbox(),
      ),

      // Toggle All Hide Row-IDs Icon
      if (widget.showIDToggle) ...{
        DataColumn(
          tooltip: 'Show ${widget.headers.first}',
          label: _makeVisibleAllRowIDs(context),
        ),
      },

      // Skip the first header: ...widget.headers.skip(1)
      ..._excludeTheFirstValue(
        widget.headers,
      ).map((header) => _buildDataColumn(header)),

      if (widget.onOptButtonTap != null) ...{
        _buildDataColumn(widget.optButtonLabel ?? 'Other'),
      },

      if (widget.onEditTap != null) ...{
        _buildDataColumn(widget.editLabel ?? 'Edit'),
      },

      if (widget.onDeleteTap != null) ...{
        _buildDataColumn(widget.deleteLabel ?? 'Delete'),
      },
    ];
    return columns;
  }

  /// Parent checkbox (Multiple check)
  Checkbox _buildParentCheckbox() {
    return Checkbox(
      value: _allSelectedStatus,
      side: const BorderSide(width: 3.0, color: kLightColor),
      onChanged: _toggleAllSelection,
    );
  }

  TextButton _makeVisibleAllRowIDs(BuildContext context) {
    return TextButton.icon(
      iconAlignment: IconAlignment.end,
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      icon: Icon(
        _allVisibleRowIds ? Icons.visibility : Icons.visibility_off,
        color: _allVisibleRowIds ? kLightColor : kLightBlueColor,
      ),
      onPressed: () => _allToggleHideID(),
      label: Text(
        widget.headers.first.toUpperCaseAll,
        style: context.textTheme.titleMedium?.copyWith(color: kLightColor),
        // textScaler: TextScaler.linear(context.textScaleFactor),
      ),
    );
  }

  /// Build Header Card [_buildDataColumn]
  DataColumn _buildDataColumn(String title) => DataColumn(
    tooltip: title,
    label: Text(
      title.toUpperCaseAll,
      style: context.textTheme.titleMedium?.copyWith(color: kLightColor),
    ),
  );

  /// Build DataTable Body [_buildDataRows]
  List<DataRow> _buildDataRows(
    BuildContext context, {
    int startIndex = 0,
    required List<List<String>> rows,
    WidgetStateProperty<Color?>? color,
  }) {
    return rows.asMap().entries.map((entry) {
      final index = startIndex + entry.key;
      final row = entry.value;

      // Return an empty DataRow if index is out of bounds
      if (index >= _selectedRowsStatus.length) {
        return const DataRow(cells: []);
      }

      return DataRow(
        selected: _selectedRowsStatus[index],
        onSelectChanged: (bool? selected) {
          setState(() {
            _selectedRowsStatus[index] = selected ?? false;

            // Update _allSelected based on the selection state
            // _allSelected = _selectedRows.every((isSelected) => isSelected);
          });
        },
        cells: [
          // Individual Checkboxes
          _buildEachCheckBox(index, row),

          // toggleHideID
          if (widget.showIDToggle) ...{
            DataCell(
              _ToggleSecretButton(
                id: row.first,
                index: index,
                isToggle: (_visibleRowIdIndex == index || _allVisibleRowIds),
                onPressed: () => _toggleHideID(index),
              ),
            ),
          },

          // Data to display: Skip the first value in each row: ...row.skip(1)
          ..._excludeTheFirstValue(row).map((cell) {
            return DataCell(
              showEditIcon: false,
              cell.isNullOrEmpty
                  ? _buildPlaceholder(context)
                  : context.copyPasteText(str: cell),
              onTap: () {
                if (widget.onCellTap != null) {
                  widget.onCellTap!(cell, row);
                }
              },
            );
          }),
          // onOptButtonTap
          if (widget.onOptButtonTap != null) ...{
            DataCell(
              _OptButton(
                icon: widget.optButtonIcon,
                label: widget.optButtonLabel,
                onTap: () {
                  widget.onOptButtonTap!(row);
                },
              ),
            ),
          },
          // onEditTap
          if (widget.onEditTap != null) ...{
            DataCell(
              _EditButton(
                icon: widget.editIcon,
                label: widget.editLabel,
                onTap: () {
                  widget.onEditTap!(row);
                },
              ),
            ),
          },
          // onDeleteTap
          if (widget.onDeleteTap != null) ...{
            DataCell(
              _DeleteButton(
                icon: widget.deleteIcon,
                label: widget.deleteLabel,
                onTap: () {
                  widget.onDeleteTap!(row);
                },
              ),
            ),
          },
        ],
        color: color,
      );
    }).toList();
  }

  /// Placeholder for empty cell [_buildPlaceholder]
  _buildPlaceholder(BuildContext context) {
    final pColor = context.colorScheme.error;
    return Tooltip(
      message: "Your update will replace this information.",
      decoration: const BoxDecoration(color: kDangerColor),
      child: Placeholder(
        strokeWidth: 0.2,
        fallbackHeight: 0.0,
        color: pColor,
        child: Text('Awaiting Update', style: TextStyle(color: pColor)),
      ),
    );
  }

  // Build individual checkboxes
  DataCell _buildEachCheckBox(int index, List<String> row) {
    return DataCell(
      Checkbox(
        value: _selectedRowsStatus[index],
        side: const BorderSide(width: 1.0),
        onChanged: (bool? selected) {
          setState(() {
            if (selected == true) {
              // Uncheck all except the currently selected
              for (int i = 0; i < _selectedRowsStatus.length; i++) {
                _selectedRowsStatus[i] = (i == index);
              }
            } else {
              // Allow unchecking the currently selected box
              _selectedRowsStatus[index] = false;
            }
          });
          // Notify if a callback is provided
          if (widget.onChecked != null) {
            widget.onChecked!(selected, row);
          }
          // setState(() => _selectedRowsStatus[index] = selected ?? false);
        },
      ),
    );
  }
}

/// [_SearchTextField]
class _SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function()? onPressed;

  const _SearchTextField({this.controller, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.screenWidth,
      padding: const EdgeInsets.all(20.0),
      child: CustomTextField(
        controller: controller,
        keyboardType: TextInputType.text,
        inputDecoration: InputDecoration(
          labelText: 'Search...by date | any...',
          prefixIcon: const Icon(Icons.search, color: kGrayColor),
          suffixIcon: Wrap(
            children: [
              if (controller!.text.isNotEmpty) ...{
                IconButton(
                  tooltip: 'Clear Search',
                  color: kGrayColor,
                  onPressed: onPressed,
                  icon: const Icon(Icons.clear),
                  style: IconButton.styleFrom(
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
              },
              DatePicker(
                isButton: true,
                restorationId: 'filter by date',
                selectedDate: (DateTime d) => controller?.text = d.dateOnly,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnyWidget extends StatelessWidget {
  final Widget? anyWidget;
  final List<String> headers;
  final List<List<String>> Function() selectedRows;

  const _AnyWidget({
    required this.anyWidget,
    required this.headers,
    required this.selectedRows,
  });

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    final exportBtn = _ExportButton(
      headers: headers,
      selectedRowsFunc: selectedRows,
    );

    return anyWidget == null
        ? Padding(padding: EdgeInsets.only(right: 20), child: exportBtn)
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [?anyWidget, const SizedBox(width: 10.0), exportBtn],
            ),
          );
  }
}

/// [_ToggleSecretButton] For security, secrets (e.g.: ID, ref) are hidden, unless toggled
class _ToggleSecretButton extends StatelessWidget {
  final bool isToggle;
  final int index;
  final String id;
  final void Function()? onPressed;

  const _ToggleSecretButton({
    required this.onPressed,
    required this.isToggle,
    required this.id,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      iconAlignment: IconAlignment.end,
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      icon: Icon(
        isToggle ? Icons.visibility : Icons.visibility_off,
        color: isToggle ? kGrayBlueColor : kGrayColor,
      ),
      onPressed: onPressed,
      label: isToggle ? context.copyPasteText(str: id) : const Text('***'),
    );
  }
}

/// Export data into Excel-sheet
class _ExportButton extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> Function() selectedRowsFunc;

  const _ExportButton({required this.headers, required this.selectedRowsFunc});

  @override
  Widget build(BuildContext context) {
    return _buildEditBtn(context);
  }

  Widget _buildEditBtn(BuildContext context) {
    final List<List<String>> selectedRows = selectedRowsFunc();

    return selectedRows.isEmpty
        ? const SizedBox.shrink()
        : context.elevatedIconBtn(
            Icon(Icons.file_download, color: kPrimaryAccentColor),
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: kPrimaryAccentColor),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            tooltip: 'Export Data to Excel or PDF',
            onPressed: () async {
              final isExcel = await _buildPreference(context);
              prettyPrint('isExcel', isExcel);
              if (isExcel == null) return;

              if (isExcel == true) {
                await FileDocManager.exportDataToExcel(
                  headers: headers,
                  data: selectedRows,
                );
              } else {
                await FileDocManager.exportDataToPdf(
                  headers: headers,
                  data: selectedRows,
                );
              }
            },
            label: 'Export',
            color: kPrimaryAccentColor,
          );
  }

  // choice
  Future<dynamic> _buildPreference(BuildContext context) async {
    return await context.confirmAction<dynamic>(
      Text('Export data to Excel or PDF?'),
      title: 'Confirm Export',
      onAccept: 'Excel',
      onReject: 'PDF',
      anyAction: 'Cancel',
    );
  }
}

/// Optional-Action Button
class _OptButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final void Function() onTap;

  const _OptButton({required this.onTap, this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return _buildEditBtn(context);
  }

  ElevatedButton _buildEditBtn(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kWarningColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon ?? Icons.print, color: kWarningColor),
      label: Text(
        label ?? 'Other',
        style: const TextStyle(color: kWarningColor),
        // textScaler: TextScaler.linear(context.textScaleFactor),
      ),
    );
  }
}

/// Edit-Action Button
class _EditButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final void Function() onTap;

  const _EditButton({required this.onTap, this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return _buildEditBtn(context);
  }

  ElevatedButton _buildEditBtn(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon ?? Icons.edit, color: kPrimaryAccentColor),
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kPrimaryAccentColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      onPressed: onTap,
      label: Text(
        label ?? 'Edit',
        style: const TextStyle(color: kPrimaryAccentColor),
        // textScaler: TextScaler.linear(context.textScaleFactor),
      ),
    );
  }
}

/// Delete-Action Button
class _DeleteButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap, this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return _buildDeleteBtn(context);
  }

  ElevatedButton _buildDeleteBtn(BuildContext context) {
    return ElevatedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: context.colorScheme.error,
      ),
      icon: Icon(icon ?? Icons.delete, color: kLightColor),
      onPressed: onTap,
      label: Text(
        label ?? 'Delete',
        style: const TextStyle(color: kLightColor),
        // textScaler: TextScaler.linear(context.textScaleFactor),
      ),
    );
  }
}

/// Raw Table
/// Raw DataTable
/* Generic DATATABLE
class DynamicDataTable<T> extends StatefulWidget {
  final bool skip;
  final int skipPos;
  final bool toggleHideID;
  final Widget? anyWidget;
  final List<String> headers;
  final List<T> rows;
  final List<T>? childRows;
  final Function(T)? onCellTap;
  final Function(T)? onEditTap;
  final Function(T)? onDeleteTap;
  final List<String> Function(T) getRowCells;

  const DynamicDataTable({
    super.key,
    required this.headers,
    required this.rows,
    required this.getRowCells,
    this.childRows,
    this.onCellTap,
    this.onEditTap,
    this.onDeleteTap,
    this.skip = false,
    this.skipPos = 1,
    this.toggleHideID = false,
    this.anyWidget,
  });

  @override
  State<DynamicDataTable> createState() => _DynamicDataTableState<T>();
}

class _DynamicDataTableState<T> extends State<DynamicDataTable<T>> {
  bool _allSelected = false;
  late List<bool> _selectedRows;
  bool _allVisibleRowIds = false;
  int? _visibleRowIdIndex;

  void _toggleHideID(int index) {
    setState(() {
      if (_visibleRowIdIndex == index) {
        _visibleRowIdIndex = null;
      } else {
        _visibleRowIdIndex = index;
      }
    });
  }

  void _allToggleHideID() => setState(() => _allVisibleRowIds = !_allVisibleRowIds);

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int get totalRows => widget.rows.length + (widget.childRows?.length ?? 0);

  @override
  void initState() {
    super.initState();
    _initializeSelectedRows();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeSelectedRows() => _selectedRows = List<bool>.filled(totalRows, false);

  void _toggleAllSelection(bool? value) {
    setState(() {
      _allSelected = value ?? false;
      for (int i = 0; i < _selectedRows.length; i++) {
        _selectedRows[i] = _allSelected;
      }
    });
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text);
  }

  List<T> _searchRowsFunc() {
    return widget.rows
        .where((row) => widget.getRowCells(row).any(
          (cell) => cell.toLowerCase().contains(_searchQuery.toLowerCase()),
    ))
        .toList();
  }

  List<T> _searchChildRowsFunc() {
    return widget.childRows
        ?.where((row) => widget.getRowCells(row).any(
          (cell) => cell.toLowerCase().contains(_searchQuery.toLowerCase()),
    ))
        .toList() ??
        [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedRows.length != totalRows) {
      _initializeSelectedRows();
    }

    final filteredRows = _searchRowsFunc();
    final filteredChildRows = _searchChildRowsFunc();

    return Container(
      padding: EdgeInsets.only(
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.anyWidget ?? const SizedBox.shrink(),
          _SearchTextField(controller: _searchController),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  border: const TableBorder(
                    verticalInside: BorderSide(width: 0.1),
                  ),
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                  columns: _buildDataColumns(context),
                  rows: [
                    ..._buildDataRows(context, rows: filteredRows),
                    if (widget.childRows != null)
                      ..._buildDataRows(
                        context,
                        rows: filteredChildRows,
                        startIndex: filteredRows.length,
                        color: MaterialStateProperty.all(Colors.red[50]),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Iterable<String> _excludeTheFirstValue(List<String> list) =>
      widget.skip ? list.skip(widget.skipPos) : list;

  List<DataColumn> _buildDataColumns(BuildContext context) {
    final columns = [
      DataColumn(
        tooltip: 'Check to focus',
        label: Checkbox(
          value: _allSelected,
          side: const BorderSide(width: 2.0),
          onChanged: _toggleAllSelection,
        ),
      ),
      if (widget.toggleHideID)
        DataColumn(
          tooltip: 'Show ${widget.headers.first}',
          label: _makeVisibleAllRowIDs(context),
        ),
      ..._excludeTheFirstValue(widget.headers)
          .map((header) => _buildDataColumn(header)),
      _buildDataColumn('Edit'),
      _buildDataColumn('Delete'),
    ];
    return columns;
  }

  TextButton _makeVisibleAllRowIDs(BuildContext context) {
    return TextButton.icon(
      iconAlignment: IconAlignment.end,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      icon: Icon(
        _allVisibleRowIds ? Icons.visibility : Icons.visibility_off,
        color: _allVisibleRowIds ? Colors.blueGrey : Colors.grey,
      ),
      onPressed: () => _allToggleHideID(),
      label: Text(
        widget.headers.first.toUpperCase(),
      ),
    );
  }

  DataColumn _buildDataColumn(String title) => DataColumn(
    tooltip: title,
    label: Text(
      title.toUpperCase(),
    ),
  );

  List<DataRow> _buildDataRows(
      BuildContext context, {
        int startIndex = 0,
        required List<T> rows,
        WidgetStateProperty<Color?>? color,
      }) {
    return rows.asMap().entries.map((entry) {
      final index = startIndex + entry.key;
      final row = entry.value;
      final cells = widget.getRowCells(row);

      if (index >= _selectedRows.length) {
        return const DataRow(cells: []);
      }

      return DataRow(
        selected: _selectedRows[index],
        onSelectChanged: (bool? selected) {
          setState(() => _selectedRows[index] = selected ?? false);
        },
        cells: [
          _buildCheckBox(index),
          if (widget.toggleHideID)
            _buildToggleHideID(context, cells.first, index),
          ..._excludeTheFirstValue(cells).map(
                (cell) {
              return DataCell(
                SelectableText(cell),
                showEditIcon: false,
                onTap: () {
                  if (widget.onCellTap != null) {
                    widget.onCellTap!(row);
                  }
                },
              );
            },
          ),
          if (widget.onEditTap != null)
            DataCell(
              _EditButton(onTap: () {
                widget.onEditTap!(row);
              }),
            ),
          if (widget.onDeleteTap != null)
            DataCell(
              _DeleteButton(onTap: () {
                widget.onDeleteTap!(row);
              }),
            ),
        ],
        color: color,
      );
    }).toList();
  }

  DataCell _buildCheckBox(int index) {
    return DataCell(
      Checkbox(
        value: _selectedRows[index],
        side: const BorderSide(width: 1.0),
        onChanged: (bool? selected) {
          setState(() => _selectedRows[index] = selected ?? false);
        },
      ),
    );
  }

  DataCell _buildToggleHideID(BuildContext context, String id, int index) {
    bool isToggle = (_visibleRowIdIndex == index || _allVisibleRowIds);

    return DataCell(
      TextButton.icon(
        iconAlignment: IconAlignment.end,
        style:  ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        icon: Icon(
          isToggle ? Icons.visibility : Icons.visibility_off,
          color: isToggle ? Colors.blueGrey : Colors.grey,
        ),
        onPressed: () => _toggleHideID(index),
        label: isToggle
            ? SelectableText(id)
            : Text(
          '***',
        ),
      ),
    );
  }
}

*/

/* USAGE
* Widget _buildCard(List<Sale> sales, BuildContext context) {
    return context.columnBuilder(
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return DynamicTable(
          rowIndex: index,
          headers: _dataTableHeader,
          rows: [
            [
              (sale.productId),
              (sale.orderNumber),
              '${sale.quantity}',
              'GH ${sale.totalAmount}',
              (sale.createdAt.toStandardDT),
            ],
          ],
        );
      },
    );
  }*/
/*class DynamicTable extends StatelessWidget {
  final int rowIndex;
  final List<String> headers;
  final List<List<String>> rows;
  final Function(String)? data;

  const DynamicTable({
    super.key,
    required this.rows,
    required this.headers,
    required this.rowIndex,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
      children: [
        if (rowIndex == 0) ...{_buildTableHeader()},
        ..._buildTableRows(context),
      ],
    );
  }

  /// Table Header [_buildTableHeader]
  TableRow _buildTableHeader() {
    return TableRow(
      children: headers.map((header) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          margin: EdgeInsets.zero,
          color: Colors.grey[300],
          child: Text(
            header,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  /// Table Body [_buildTableRows]
  List<TableRow> _buildTableRows(BuildContext context) {
    return rows.map((row) {
      return TableRow(
        children: row.map((cell) {
          return TableRowInkWell(
            onTap: () {
              debugPrint('I am dynamic table');
            },
            child: Container(
              color: Colors.red,
              padding: const EdgeInsets.all(8.0),
              child: context.copyPasteText(str: cell),
            ),
          );
        }).toList(),
      );
    }).toList();
  }
}*/

/*
class DynamicDataTable2 extends StatelessWidget {

  final List<String> headers;
  final List<List<String>> rows;
  final List<List<String>>? childRows;
  final Function(String, List<String>)? onCellTap;

  const DynamicDataTable2({
    super.key,
    required this.headers,
    required this.rows,
    this.childRows,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
            showCheckboxColumn: false,
            headingRowColor: const WidgetStatePropertyAll(kGrayBlueColor),
            columns: _buildDataColumns(context),
            rows: [
              ..._buildDataRows(context, rows),
              ..._buildDataRows(
                context,
                childRows!,
                color:
                    WidgetStatePropertyAll(context.colorScheme.errorContainer),
              ),
            ].toList()),
      ),
    );
  }

  /// Builds the header columns for the DataTable
  List<DataColumn> _buildDataColumns(BuildContext context) =>
      headers.map((header) {
        final title = header.toUppercaseAllLetter;
        return DataColumn(
          tooltip: title,
          label: Text(
            title,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: kLightColor,
            ),
            textScalar: TextScaler.linear(context.textScaleFactor),
          ),
        );
      }).toList();

  /// Builds the rows for the DataTable
  List<DataRow> _buildDataRows(
    BuildContext context,
    List<List<String>> rows, {
    WidgetStateProperty<Color?>? color,
  }) {
    return rows.map((row) {
      List<DataCell> cells = row.map((cell) {
        return DataCell(
          SelectionArea(
            child: Text(
              cell,
              textScaler: TextScaler.linear(context.textScaleFactor),
            ),
          ),
          showEditIcon: true,
          placeholder: false,
          onTap: () {
            if (onCellTap != null) {
              onCellTap!(cell, row);
            }
          },
        );
      }).toList();

      // Ensure the row has the same number of cells as there are headers
      while (cells.length < headers.length) {
        cells.add(const DataCell(SizedBox.shrink()));
      }

      return DataRow(cells: cells, color: color);
    }).toList();
  }
}*/

/*class DynamicTable2 extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;

  const DynamicTable2({
    super.key,
    required this.headers,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: context.primaryColor),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
      },
      children: [
        if (headers.getFirstIndex == 0) ...{_buildHeaderRow()},
        ..._buildDataRows(),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      children: headers
          .map((header) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  header,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ))
          .toList(),
    );
  }

  List<TableRow> _buildDataRows() {
    return rows.map((row) {
      return TableRow(
        children: row.map((cell) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              cell,
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      );
    }).toList();
  }
}

class DataTableWithSearchInput extends StatefulWidget {
  const DataTableWithSearchInput({super.key});

  @override
  State<DataTableWithSearchInput> createState() =>
      _DataTableWithSearchInputState();
}

class _DataTableWithSearchInputState extends State<DataTableWithSearchInput> {
  TextEditingController filterController = TextEditingController();
  final List<Map<String, String>> _allData = [
    {"Column1": "Row1-Column1", "Column2": "Row1-Column2"},
    {"Column1": "Row2-Column1", "Column2": "Row2-Column2"},
    {"Column1": "Row3-Column1", "Column2": "Row3-Column2"},
  ];
  late List<Map<String, String>> _filteredData;

  @override
  void initState() {
    super.initState();
    _filteredData = _allData;
    filterController.addListener(() {
      setState(() {
        _filteredData = _allData
            .where((row) => row.values.any((element) => element
                .toLowerCase()
                .contains(filterController.text.toLowerCase())))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: filterController,
            decoration: const InputDecoration(
              labelText: 'Filter',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Column 1')),
                DataColumn(label: Text('Column 2')),
              ],
              rows: _filteredData
                  .map(
                    (row) => DataRow(cells: [
                      DataCell(Text(row['Column1']!)),
                      DataCell(Text(row['Column2']!)),
                    ]),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    filterController.dispose();
    super.dispose();
  }
}*/
