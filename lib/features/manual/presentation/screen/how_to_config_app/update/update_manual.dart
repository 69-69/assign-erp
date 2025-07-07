import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/manual/data/models/manual_model.dart';
import 'package:assign_erp/features/manual/presentation/bloc/index.dart';
import 'package:assign_erp/features/manual/presentation/bloc/manual_bloc.dart';
import 'package:assign_erp/features/manual/presentation/screen/how_to_config_app/widgets/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateUserManualForm<T> on BuildContext {
  Future<void> openUpdateManual({required Manual manual}) =>
      openBottomSheet(isExpand: false, child: _UpdateManual(manual: manual));
}

class _UpdateManual extends StatelessWidget {
  final Manual manual;

  const _UpdateManual({required this.manual});

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
      title: ListTile(
        dense: true,
        title: Text(
          'Edit Manual',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kGrayColor,
          ),
        ),
        subtitle: Text(
          manual.title.toUppercaseFirstLetterEach,
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleMedium?.copyWith(
            color: kGrayColor,
          ),
        ),
      ),
      btnText: 'Delete',
      onPress: () => _onDeleteTap(context),
    );
  }

  Future<void> _onDeleteTap(BuildContext context) async {
    final isConfirmed = await context.confirmUserActionDialog();

    if (context.mounted && isConfirmed) {
      // Dispatch the delete event
      context.read<HowToBloc>().add(
        DeleteManual<Manual>(documentId: manual.id),
      );
      Navigator.pop(context);
    }
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      child: _UpdateManualBody(manual: manual),
    );
  }
}

class _UpdateManualBody extends StatefulWidget {
  final Manual manual;

  const _UpdateManualBody({required this.manual});

  @override
  State<_UpdateManualBody> createState() => _UpdateManualBodyState();
}

class _UpdateManualBodyState extends State<_UpdateManualBody> {
  Manual get _manual => widget.manual;

  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;

  late final _manualIdController = TextEditingController(text: _manual.id);
  late final _urlController = TextEditingController(text: _manual.url);

  late final _descController = TextEditingController(text: _manual.description);
  late final _titleController = TextEditingController(text: _manual.title);

  @override
  void dispose() {
    _manualIdController.dispose();
    _urlController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = _manual.copyWith(
        category: _selectedCategory ?? _manual.category,
        id: _manualIdController.text,
        url: _urlController.text,
        description: _descController.text,
        title: _titleController.text,
      );

      /// Update Manual
      context.read<HowToBloc>().add(
        UpdateManual<Manual>(documentId: _manual.id, data: item),
      );

      _formKey.currentState!.reset();
      context.showAlertOverlay(
        '${_manual.title} has been successfully updated',
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildBody(),
    );
  }

  Column _buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TitleCategoryInput(
          titleController: _titleController,
          serverCategory: _manual.category,
          onCategoryChange: (t) => setState(() => _selectedCategory = t),
          onTitleChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        UrlTextField(
          controller: _urlController,
          onChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        DescTextField(
          descController: _descController,
          onDescChanged: (v) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(onPressed: _onSubmit),
      ],
    );
  }
}
