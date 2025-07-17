import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/data_sources/local/printout_setup_cache_service.dart';
import 'package:assign_erp/features/setup/data/models/company_info_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company/company_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/widget/form_inputs.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/widget/upload_company_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddCompanyInfo<T> on BuildContext {
  Future<void> openAddCompanyInfo({Widget? header}) => openBottomSheet(
    isExpand: false,
    child: _AddCompanyInfoForm(header: header),
  );
}

class _AddCompanyInfoForm extends StatelessWidget {
  final Widget? header;

  const _AddCompanyInfoForm({this.header});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: BlocBuilder<CompanyBloc, SetupState<Company>>(
        builder: (context, state) => _buildBody(context),
      ),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: Text(
        'Add Company Info',
        semanticsLabel: 'add company info',
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
      child: _AddCompanyInfoFormBody(),
    );
  }
}

class _AddCompanyInfoFormBody extends StatefulWidget {
  const _AddCompanyInfoFormBody();

  @override
  State<_AddCompanyInfoFormBody> createState() =>
      _AddCompanyInfoFormBodyState();
}

class _AddCompanyInfoFormBodyState extends State<_AddCompanyInfoFormBody> {
  String _uploadedLogoPath = '';
  final PrintoutSetupCacheService _printoutService =
      PrintoutSetupCacheService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _faxNumberController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _faxNumberController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      /// Add Company Info
      final item = Company(
        name: _nameController.text,
        logo: _uploadedLogoPath,
        email: _emailController.text,
        phone: _phoneController.text,
        altPhone: _altPhoneController.text,
        address: _addressController.text,
        faxNumber: _faxNumberController.text,
        createdBy: context.employee!.fullName,
      );

      context.read<CompanyBloc>().add(AddSetup<Company>(data: item));
      await _saveToCache();

      _formKey.currentState!.reset();

      if (mounted) {
        context.showAlertOverlay(
          '${_nameController.text.toUppercaseFirstLetterEach} successfully created',
        );
        Navigator.pop(context);
      }
    }
  }

  // Save Company-info to cache
  Future<void> _saveToCache() async {
    final settings = (await _printoutService.getSettings())?.copyWith(
      companyLogo: _uploadedLogoPath,
      companyName: _nameController.text,
      companyEmail: _emailController.text,
      companyPhone: '${_phoneController.text} | ${_altPhoneController.text}',
      companyAddress: _addressController.text,
      companyFax: _faxNumberController.text,
    );
    if (settings != null) {
      await _printoutService.setSettings(settings);
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
        CompanyNameAndEmailInput(
          nameController: _nameController,
          emailController: _emailController,
          onNameChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onEmailChanged: (s) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        PhoneAndAltPhoneInput(
          phoneController: _phoneController,
          altPhoneController: _altPhoneController,
          onPhoneChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onAltPhoneChanged: (s) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        FaxAndAddressTextField(
          addressController: _addressController,
          faxController: _faxNumberController,
          onFaxChanged: (s) => setState(() {}),
          onAddressChanged: (s) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        UploadCompanyLogo(
          uploadedFilePath: (s) {
            setState(() => _uploadedLogoPath = s);
          },
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(label: 'Create Info', onPressed: _onSubmit),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
