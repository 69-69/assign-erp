import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/data_sources/local/printout_setup_cache_service.dart';
import 'package:assign_erp/features/setup/data/models/company_info_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company_info/company_info_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/company_info/widget/form_inputs.dart';
import 'package:assign_erp/features/setup/presentation/screen/company_info/widget/upload_company_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateCompanyInfo<T> on BuildContext {
  Future<void> openUpdateCompanyInfo({required CompanyInfo info}) =>
      openBottomSheet(isExpand: false, child: _UpdateCompany(info: info));
}

class _UpdateCompany extends StatelessWidget {
  final CompanyInfo info;

  const _UpdateCompany({required this.info});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: BlocBuilder<CompanyInfoBloc, SetupState<CompanyInfo>>(
        builder: (context, state) => _buildBody(context),
      ),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        title: Text(
          'Edit Company Info',
          textAlign: TextAlign.center,
          semanticsLabel: 'edit company info',
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kGrayColor,
          ),
        ),
        subtitle: Text(
          info.name.toUpperCase(),
          textAlign: TextAlign.center,
          semanticsLabel: info.name.toUppercaseFirstLetterEach,
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
      child: _UpdateCompanyBody(info: info),
    );
  }
}

class _UpdateCompanyBody extends StatefulWidget {
  final CompanyInfo info;

  const _UpdateCompanyBody({required this.info});

  @override
  State<_UpdateCompanyBody> createState() => _UpdateCompanyBodyState();
}

class _UpdateCompanyBodyState extends State<_UpdateCompanyBody> {
  // final SetupPrintOut _setupPrintOut = SetupPrintOut();
  final PrintoutSetupCacheService _printoutService =
      PrintoutSetupCacheService();

  CompanyInfo get _info => widget.info;
  late String? _uploadedLogoPath = _info.logo;

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: _info.name);
  late final _emailController = TextEditingController(text: _info.email);
  late final _phoneController = TextEditingController(text: _info.phone);
  late final _altPhoneController = TextEditingController(text: _info.altPhone);
  late final _faxNumberController = TextEditingController(
    text: _info.faxNumber,
  );
  late final _addressController = TextEditingController(text: _info.address);

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
      /// Update Company Info
      final item = _info.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        altPhone: _altPhoneController.text,
        address: _addressController.text,
        faxNumber: _faxNumberController.text,
        logo: _uploadedLogoPath ?? _info.logo,

        createdBy: _info.createdBy,
        updatedBy: context.employee!.fullName,
      );

      context.read<CompanyInfoBloc>().add(
        UpdateSetup<CompanyInfo>(documentId: _info.id, data: item),
      );

      await _saveToCache();

      if (mounted) {
        context.showAlertOverlay(
          '${_nameController.text.toUppercaseFirstLetterEach} successfully updated',
        );
        Navigator.pop(context);
      }
    }
  }

  // Update Company-info in cache
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
      await _printoutService.cacheSettings(settings);
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
          serverFilePath: _info.logo,
          uploadedFilePath: (s) {
            setState(() => _uploadedLogoPath = s);
          },
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(onPressed: _onSubmit),
      ],
    );
  }
}
