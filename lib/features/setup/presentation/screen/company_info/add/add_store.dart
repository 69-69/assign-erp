import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/generate_new_uid.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company_info/company_store_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/company_info/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddStore<T> on BuildContext {
  Future<void> openAddStore({Widget? header}) =>
      openBottomSheet(isExpand: false, child: _AddStoreForm(header: header));
}

class _AddStoreForm extends StatelessWidget {
  final Widget? header;

  const _AddStoreForm({this.header});

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
      title: Text(
        'Add Store',
        semanticsLabel: 'add store',
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
      child: _AddStoreFormBody(),
    );
  }
}

class _AddStoreFormBody extends StatefulWidget {
  const _AddStoreFormBody();

  @override
  State<_AddStoreFormBody> createState() => _AddStoreFormBodyState();
}

class _AddStoreFormBodyState extends State<_AddStoreFormBody> {
  String _newStoreNumber = '';
  bool isMultipleStores = false;
  final List<CompanyStores> _stores = [];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateStoreNumber();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  CompanyStores get _storeData => CompanyStores(
    storeNumber: _newStoreNumber,
    name: _nameController.text,
    phone: _phoneController.text,
    location: _locationController.text,
    remarks: _remarksController.text,
    createdBy: context.employee?.fullName ?? 'unknown',
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      /// Added Multiple stores Simultaneously
      _stores.add(_storeData);

      context.read<CompanyStoreBloc>().add(
        AddSetup<List<CompanyStores>>(data: _stores),
      );

      _formKey.currentState!.reset();

      _clearFields();

      context.showAlertOverlay('Stores successfully created');
      Navigator.pop(context);
    }
  }

  /// Function for Adding Multiple Stores Simultaneously
  void _addStoreToList() {
    if (_formKey.currentState!.validate()) {
      setState(() => isMultipleStores = true);
      _stores.add(_storeData);

      context.showAlertOverlay(
        '${_nameController.text.toUppercaseFirstLetterEach} added to batch',
      );
      _clearFields();
      _generateStoreNumber();
    }
  }

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _locationController.clear();
    _remarksController.clear();
  }

  void _generateStoreNumber() async {
    await 'store'.getShortUID(
      onChanged: (s) => setState(() => _newStoreNumber = s),
    );
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
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Store Number:\n',
                style: context.ofTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: _newStoreNumber,
                    style: context.ofTheme.textTheme.titleLarge?.copyWith(
                      color: kDangerColor,
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              child: context.buildRefreshButton(
                'Refresh Store number',
                onPressed: _generateStoreNumber,
              ),
            ),
          ],
        ),
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
        context.elevatedIconBtn(
          Icons.add,
          onPressed: _addStoreToList,
          label: 'Add to List',
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(
          label: isMultipleStores ? 'Create All Stores' : 'Create Store',
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
