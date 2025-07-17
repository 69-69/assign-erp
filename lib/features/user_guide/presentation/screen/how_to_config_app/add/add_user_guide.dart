import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/user_guide/data/models/user_guide_model.dart';
import 'package:assign_erp/features/user_guide/presentation/bloc/index.dart';
import 'package:assign_erp/features/user_guide/presentation/bloc/user_guide_bloc.dart';
import 'package:assign_erp/features/user_guide/presentation/screen/how_to_config_app/widgets/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddGuideForm<T> on BuildContext {
  Future<void> openAddGuide({String? category}) =>
      openBottomSheet(isExpand: false, child: _AddGuide(category: category));
}

class _AddGuide extends StatelessWidget {
  final String? category;

  const _AddGuide({this.category});

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
        'Add User Guide',
        semanticsLabel: 'add user guide',
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
      child: _AddGuideBody(),
    );
  }
}

class _AddGuideBody extends StatefulWidget {
  const _AddGuideBody();

  @override
  State<_AddGuideBody> createState() => _AddGuideBodyState();
}

class _AddGuideBodyState extends State<_AddGuideBody> {
  final ScrollController _scrollController = ScrollController();
  bool isMultipleGuides = false;
  final List<UserGuide> _userGuides = [];
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

  UserGuide get _guideData => UserGuide(
    url: _urlController.text,
    title: _titleController.text,
    category: _selectedCategory,
    description: _descriptionController.text,
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      /// Added Multiple Products Simultaneously
      _userGuides.add(_guideData);

      // Create New Guide
      context.read<HowToBloc>().add(
        AddGuide<List<UserGuide>>(data: _userGuides),
      );

      _formKey.currentState!.reset();
      context.showAlertOverlay(
        '${_titleController.text.toUppercaseFirstLetterEach} successfully created',
      );

      Navigator.of(context).pop();
    }
  }

  /// Adds the current Guide form data to the batch list for later submission
  void _addGuideToList() {
    if (_formKey.currentState!.validate()) {
      setState(() => isMultipleGuides = true);
      _userGuides.add(_guideData);

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

  void _removeGuide(UserGuide guide) {
    setState(() => _userGuides.remove(guide));
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
          if (isMultipleGuides && _userGuides.isNotEmpty) ...[
            SizedBox(height: 60, child: _buildGuidePreviewChips()),
          ],
          _buildBody(),
        ],
      ),
    );
  }

  // Horizontal scrollable row of chips representing the List of batch of Guides
  Widget _buildGuidePreviewChips() {
    return CustomScrollBar(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _userGuides.map((o) {
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
                    onDeleted: () => _removeGuide(o),
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
        Text('Create Guide', style: context.ofTheme.textTheme.titleLarge),
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
          onPressed: _addGuideToList,
          label: 'Add to List',
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(
          label: isMultipleGuides ? 'Create All Guides' : 'Create Guide',
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
