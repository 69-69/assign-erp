import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/index.dart';
import 'package:assign_erp/features/setup/presentation/bloc/product_config/category_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/product_config/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateCategory on BuildContext {
  Future openUpdateCategory({required Category category}) => openBottomSheet(
    isExpand: false,
    child: _UpdateCategoryForm(category: category),
  );
}

class _UpdateCategoryForm extends StatelessWidget {
  final Category category;

  const _UpdateCategoryForm({required this.category});

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
      title: ListTile(
        title: Text(
          'Edit Category',
          semanticsLabel: 'edit Category',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kGrayColor,
          ),
        ),
        subtitle: Text(
          category.name.toUpperCase(),
          semanticsLabel: category.name.toUppercaseFirstLetterEach,
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleMedium?.copyWith(
            color: kGrayColor,
          ),
        ),
      ),
      btnText: 'Close',
      onPress: () => Navigator.pop(context),
    );
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      child: _UpdateCategoryFormBody(category: category),
    );
  }
}

class _UpdateCategoryFormBody extends StatefulWidget {
  final Category category;

  const _UpdateCategoryFormBody({required this.category});

  @override
  State<_UpdateCategoryFormBody> createState() =>
      _UpdateCategoryFormBodyState();
}

class _UpdateCategoryFormBodyState extends State<_UpdateCategoryFormBody> {
  Category get _category => widget.category;

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: _category.name);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_formKey.currentState!.validate()) {
        final item = _category.copyWith(
          name: _nameController.text,
          createdBy: _category.createdBy,
          updatedBy: context.employee!.fullName,
        );

        /// Update Category
        context.read<CategoryBloc>().add(
          UpdateSetup<Category>(documentId: _category.id, data: item),
        );

        context.showAlertOverlay(
          '${_nameController.text.toUppercaseFirstLetterEach} successfully updated',
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildBody(context),
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
        context.elevatedBtn(onPressed: _onSubmit),
      ],
    );
  }
}
