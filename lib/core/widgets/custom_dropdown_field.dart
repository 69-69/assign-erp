import 'package:assign_erp/core/util/str_util.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

/// Form text field [CustomDropdown]
class CustomDropdown extends StatelessWidget {
  final bool isMenu;
  final Widget? icon;
  final List<String> items;
  final String? serverValue;
  final String labelText;
  final String? helperText;
  final InputDecoration? inputDecoration;
  final String? Function(String?)? validator;
  final void Function(String?) onValueChange;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.labelText,
    required this.onValueChange,
    this.inputDecoration,
    this.serverValue,
    this.helperText,
    this.validator,
    this.icon,
    this.isMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    return isMenu ? _buildDropdownMenu() : _buildDropdownButton(context);
  }

  DropdownButtonFormField<String> _buildDropdownButton(BuildContext context) {
    final defaultVal =
        (!serverValue.isNullOrEmpty && items.contains(serverValue))
        ? serverValue
        : items.first;
    final helpText = helperText != null ? '($helperText)' : '';

    return DropdownButtonFormField<String>(
      isExpanded: true,
      isDense: true,
      // padding: EdgeInsets.zero,
      icon: icon,
      decoration:
          inputDecoration ??
          InputDecoration(
            isDense: true,
            labelText: '${labelText.toUppercaseFirstLetterEach} $helpText',
            // helperText: helperText,
            labelStyle: const TextStyle(overflow: TextOverflow.ellipsis),
          ),
      items: items.map<DropdownMenuItem<String>>((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(
            e.toUppercaseFirstLetterEach,
            softWrap: true,
            overflow: TextOverflow.fade,
          ),
        );
      }).toList(),
      onChanged: (value) => onValueChange.call(value),
      value: defaultVal,
      validator:
          validator ??
          (String? val) {
            String v = val ?? ''.toLowercaseAllLetter;
            String label = items.first.toLowercaseAllLetter;

            if (v.isEmpty || v.contains(label)) {
              return 'Please enter $labelText';
            }
            return null;
          },
    );
  }

  DropdownMenu<String> _buildDropdownMenu() {
    final defaultVal =
        (!serverValue.isNullOrEmpty && items.contains(serverValue))
        ? serverValue
        : items.first;
    final helpText = helperText != null ? '($helperText)' : '';

    return DropdownMenu<String>(
      trailingIcon: icon,
      hintText: '$labelText $helpText',
      initialSelection: defaultVal,
      dropdownMenuEntries: items
          .map((item) => DropdownMenuEntry(value: item, label: item))
          .toList(),
      //enableFilter: true,
      requestFocusOnTap: true,
      enableSearch: true,
      searchCallback: (List<DropdownMenuEntry<String>> entries, String query) {
        if (query.isEmpty || query.contains(items.first)) {
          return null;
        }
        final int index = entries.indexWhere(
          (DropdownMenuEntry<String> entry) => entry.label == query,
        );

        return index != -1 ? index : null;
      },
      onSelected: (value) => onValueChange(value),
      width: null,
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        labelStyle: TextStyle(overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class CustomDropdownSearch<T> extends StatelessWidget {
  final String labelText;
  final String? helperText;
  final IconData? trailingIcon;
  final void Function(T?)? onChanged;
  final Function(T)? itemAsString;
  final String? Function(T?)? validator;
  final Function(T, String) filterFn;
  final Future<List<T>> Function(String, LoadProps?)? asyncItems;

  const CustomDropdownSearch({
    super.key,
    required this.labelText,
    required this.filterFn,
    this.helperText,
    this.itemAsString,
    this.asyncItems,
    this.onChanged,
    this.validator,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDropdownSearch();
  }

  _buildDropdownSearch() {
    final helpText = helperText != null ? '($helperText)' : '';

    return DropdownSearch<T>(
      autoValidateMode: AutovalidateMode.onUserInteraction,
      popupProps: const PopupProps.menu(showSearchBox: true),
      filterFn: (obj, filter) => filterFn(obj, filter),
      // for filtering by user string
      compareFn: (obj1, obj2) => obj1 == obj2,
      // for selection comparison
      items: asyncItems!,
      // FutureOr<List<T>> Function(String, LoadProps?)? items
      // Future<List<T>> Function(String)? items,
      itemAsString: (T obj) => itemAsString!(obj),
      onChanged: (T? obj) => onChanged!(obj),
      suffixProps: DropdownSuffixProps(
        dropdownButtonProps: DropdownButtonProps(
          iconOpened: Icon(trailingIcon ?? Icons.arrow_drop_up, size: 24.0),
          iconClosed: Icon(trailingIcon ?? Icons.arrow_drop_down, size: 24.0),
        ),
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(labelText: '$labelText $helpText'),
      ),
      validator:
          validator ?? (T? obj) => obj == null ? 'Please $labelText' : null,
    );
  }
}
