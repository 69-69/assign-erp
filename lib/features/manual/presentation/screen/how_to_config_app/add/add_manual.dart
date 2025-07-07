import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/features/manual/data/models/manual_model.dart';
import 'package:assign_erp/features/manual/presentation/bloc/index.dart';
import 'package:assign_erp/features/manual/presentation/bloc/manual_bloc.dart';
import 'package:assign_erp/features/manual/presentation/screen/how_to_config_app/widgets/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddManualForm<T> on BuildContext {
  Future<void> openAddManual({String? category}) =>
      openBottomSheet(isExpand: false, child: _AddManual(category: category));
}

class _AddManual extends StatelessWidget {
  final String? category;

  const _AddManual({this.category});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: _buildBody(context),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: Text(
        'Add User Manual',
        semanticsLabel: 'add user manual',
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          color: kGrayColor,
        ),
      ),
      btnText: 'Close',
      onPress: () => Navigator.pop(context),
    );
  }

  _buildBody(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      child: _AddManualBody(),
    );
  }
}

class _AddManualBody extends StatefulWidget {
  const _AddManualBody();

  @override
  State<_AddManualBody> createState() => _AddManualBodyState();
}

class _AddManualBodyState extends State<_AddManualBody> {
  final ScrollController _scrollController = ScrollController();
  bool isMultipleManuals = false;
  final List<Manual> _manuals = [];
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = '';
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Manual get _manualData => Manual(
    url: _urlController.text,
    title: _titleController.text,
    category: _selectedCategory,
    description: _descriptionController.text,
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      /// Added Multiple Products Simultaneously
      _manuals.add(_manualData);

      // Create New Manual
      context.read<HowToBloc>().add(AddManual<List<Manual>>(data: _manuals));

      _formKey.currentState!.reset();
      context.showAlertOverlay(
        '${_titleController.text.toUppercaseFirstLetterEach} successfully created',
      );

      Navigator.of(context).pop();
    }
  }

  /// Adds the current manual form data to the batch list for later submission
  void _addManualToList() {
    if (_formKey.currentState!.validate()) {
      setState(() => isMultipleManuals = true);
      _manuals.add(_manualData);

      context.showAlertOverlay(
        '${_titleController.text.toUppercaseFirstLetterEach} added to batch',
      );
      _clearFields();
    }
  }

  void _clearFields() {
    _titleController.clear();
    _urlController.clear();
    _descriptionController.clear();
    _selectedCategory = '';
  }

  void _removeManual(Manual manual) {
    setState(() => _manuals.remove(manual));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Wrap(
        // runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          if (isMultipleManuals && _manuals.isNotEmpty) ...{
            SizedBox(height: 60, child: _buildManualPreviewChips()),
          },
          _buildBody(),
        ],
      ),
    );
  }

  // Preview Manuals added to list
  Widget _buildManualPreviewChips() {
    return CustomScrollBar(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _manuals.map((o) {
          return o.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Chip(
                    padding: EdgeInsets.zero,
                    label: Text(
                      o.title.toUppercaseFirstLetterEach,
                      style: context.ofTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    deleteButtonTooltipMessage: 'Remove ${o.title}',
                    backgroundColor: kGrayColor.withAlpha((0.3 * 255).toInt()),
                    deleteIcon: const Icon(
                      size: 16,
                      Icons.clear,
                      color: kGrayColor,
                    ),
                    onDeleted: () => _removeManual(o),
                  ),
                );
        }).toList(),
      ),
    );
  }

  Column _buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Create Manual', style: context.ofTheme.textTheme.titleLarge),
        TitleCategoryInput(
          titleController: _titleController,
          onCategoryChange: (t) => setState(() => _selectedCategory = t),
          onTitleChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        UrlTextField(
          controller: _urlController,
          onChanged: (t) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        DescTextField(
          descController: _descriptionController,
          onDescChanged: (v) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        context.elevatedIconBtn(
          Icons.add,
          onPressed: _addManualToList,
          label: 'Add to List',
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(
          label: isMultipleManuals ? 'Create All Manuals' : 'Create Manual',
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
