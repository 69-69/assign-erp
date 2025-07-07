import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:assign_erp/features/setup/data/models/index.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company_info/company_store_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/company_info/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateStore<T> on BuildContext {
  Future<void> openUpdateStore({required CompanyStores store}) =>
      openBottomSheet(isExpand: false, child: _UpdateStoreForm(store: store));
}

class _UpdateStoreForm extends StatelessWidget {
  final CompanyStores store;

  const _UpdateStoreForm({required this.store});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: BlocBuilder<CompanyStoreBloc, SetupState<CompanyStores>>(
        builder: (context, state) => _buildBody(context),
      ),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: ListTile(
        title: Text(
          'Edit Store',
          semanticsLabel: 'edit store',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleSmall?.copyWith(
            color: kGrayColor,
          ),
        ),
        subtitle: Text(
          store.name.toUppercaseFirstLetterEach,
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleSmall?.copyWith(
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
      child: _UpdateStoreFormBody(store: store),
    );
  }
}

class _UpdateStoreFormBody extends StatefulWidget {
  final CompanyStores store;

  const _UpdateStoreFormBody({required this.store});

  @override
  State<_UpdateStoreFormBody> createState() => _UpdateStoreFormBodyState();
}

class _UpdateStoreFormBodyState extends State<_UpdateStoreFormBody> {
  CompanyStores get _store => widget.store;

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: _store.name);
  late final _phoneController = TextEditingController(text: _store.phone);
  late final _locationController = TextEditingController(text: _store.location);
  late final _remarksController = TextEditingController(text: _store.remarks);

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_formKey.currentState!.validate()) {
        final item = _store.copyWith(
          name: _nameController.text,
          phone: _phoneController.text,
          location: _locationController.text,
          remarks: _remarksController.text,
          createdBy: _store.createdBy,
          updatedBy: context.employee!.fullName,
        );

        /// Update store
        context.read<CompanyStoreBloc>().add(
          UpdateSetup<CompanyStores>(documentId: _store.id, data: item),
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
        StoreNameAndLocationInput(
          nameController: _nameController,
          locationController: _locationController,
          onNameChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onLocationChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        PhoneTextField(
          controller: _phoneController,
          onChanged: (s) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        RemarksTextField(controller: _remarksController),
        const SizedBox(height: 20.0),
        context.elevatedBtn(onPressed: _onSubmit),
      ],
    );
  }
}
