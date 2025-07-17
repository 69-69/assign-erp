import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/category_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/product_config/category_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/product_config/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddCategory<T> on BuildContext {
  Future<void> openAddCategory({Widget? header}) =>
      openBottomSheet(isExpand: false, child: _AddCategoryForm(header: header));
}

class _AddCategoryForm extends StatelessWidget {
  final Widget? header;

  const _AddCategoryForm({this.header});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: BlocBuilder<CategoryBloc, SetupState<Category>>(
        builder: (context, state) => _buildBody(context),
      ),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: Text(
        'Add Product Categories',
        semanticsLabel: 'Add Product Categories',
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
      child: _AddCategoryFormBody(),
    );
  }
}

class _AddCategoryFormBody extends StatefulWidget {
  const _AddCategoryFormBody();

  @override
  State<_AddCategoryFormBody> createState() => _AddCategoryFormBodyState();
}

class _AddCategoryFormBodyState extends State<_AddCategoryFormBody> {
  final ScrollController _scrollController = ScrollController();
  bool isMultipleCategories = false;
  final List<Category> _categories = [];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Category get _categoryData => Category(
    name: _nameController.text,
    createdBy: context.employee!.fullName,
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      /// Added Multiple Categories Simultaneously
      _categories.add(_categoryData);

      context.read<CategoryBloc>().add(
        AddSetup<List<Category>>(data: _categories),
      );

      _formKey.currentState!.reset();

      _clearFields();

      context.showAlertOverlay('Categories successfully created');
      Navigator.pop(context);
    }
  }

  /// Function for Adding Multiple Categories Simultaneously
  void _addCategoryToList() {
    if (_formKey.currentState!.validate()) {
      setState(() => isMultipleCategories = true);
      _categories.add(_categoryData);

      context.showAlertOverlay(
        '${_nameController.text.toUppercaseFirstLetterEach} added to batch',
      );
      _clearFields();
    }
  }

  void _clearFields() {
    _nameController.clear();
  }

  void _removeCategory(Category category) {
    setState(() => _categories.remove(category));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Wrap(
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          if (isMultipleCategories && _categories.isNotEmpty)
            _buildCategoryPreviewChips(),
          _buildBody(context),
        ],
      ),
    );
  }

  // Horizontal scrollable row of chips representing the List of batch of Categories
  Widget _buildCategoryPreviewChips() {
    return CustomScrollBar(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((o) {
          return o.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Chip(
                    padding: EdgeInsets.zero,
                    label: Text(
                      o.name.toUppercaseFirstLetterEach,
                      style: context.ofTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    deleteButtonTooltipMessage: 'Remove ${o.name}',
                    backgroundColor: kGrayColor.withAlpha((0.3 * 255).toInt()),
                    deleteIcon: const Icon(
                      size: 16,
                      Icons.clear,
                      color: kGrayColor,
                    ),
                    onDeleted: () => _removeCategory(o),
                  ),
                );
        }).toList(),
      ),
    );
  }

  Column _buildBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 20.0),
        CategoryTextField(
          controller: _nameController,
          onChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 10.0),
        context.elevatedIconBtn(
          Icons.add,
          onPressed: _addCategoryToList,
          label: 'Add to List',
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(
          label: isMultipleCategories
              ? 'Create All Categories'
              : 'Create Category',
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
