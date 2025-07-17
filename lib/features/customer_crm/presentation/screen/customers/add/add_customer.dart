import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/generate_new_uid.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/customer_crm/data/models/customer_model.dart';
import 'package:assign_erp/features/customer_crm/presentation/bloc/create_acc/customer_acc_bloc.dart';
import 'package:assign_erp/features/customer_crm/presentation/bloc/customer_bloc.dart';
import 'package:assign_erp/features/customer_crm/presentation/screen/customers/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddCustomerForm<T> on BuildContext {
  Future<void> openAddCustomer({Widget? header}) =>
      openBottomSheet(isExpand: false, child: _AddCustomer(header: header));
}

class _AddCustomer extends StatelessWidget {
  final Widget? header;

  const _AddCustomer({this.header});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: header ?? _buildHeader(context),
      child: _buildBody(context),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: Text(
        'New Customer',
        semanticsLabel: 'new Customer',
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
      child: _AddCustomerBody(),
    );
  }
}

class _AddCustomerBody extends StatefulWidget {
  const _AddCustomerBody();

  @override
  State<_AddCustomerBody> createState() => _AddCustomerBodyState();
}

class _AddCustomerBodyState extends State<_AddCustomerBody> {
  bool _isEnabledCustomerId = false;

  DateTime? _selectedBirthday;
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateCustomerID();
  }

  @override
  void dispose() {
    _altPhoneController.dispose();
    _customerIdController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEditCustomerId() =>
      setState(() => _isEnabledCustomerId = !_isEnabledCustomerId);

  void _generateCustomerID() async {
    await 'customer'.getShortUID(
      onChanged: (s) => setState(() => _customerIdController.text = s),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = Customer(
        name: _nameController.text,
        birthDay: _selectedBirthday,
        customerId: _customerIdController.text,
        phone: _phoneController.text,
        altPhone: _altPhoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        companyName: _companyNameController.text,
        storeNumber: context.employee!.storeNumber,
        createdBy: context.employee!.fullName,
      );

      // Create New Customer
      /// Pass 'documentId' as auto, for Firestore to auto-assign unique document-Id
      context.read<CustomerAccountBloc>().add(
        AddCustomer<Customer>(data: item),
      );

      _formKey.currentState!.reset();
      context.showAlertOverlay(
        '${_nameController.text.toUppercaseFirstLetterEach} successfully created',
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
        Text('Customer Info', style: context.ofTheme.textTheme.titleLarge),
        const SizedBox(height: 20.0),
        CustomerIdInput(
          customerIdController: _customerIdController,
          enableCustomer: _isEnabledCustomerId,
          onCustomerEdited: _toggleEditCustomerId,
          onCustomerIdChanged: (t) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        CustomerNameAndBirthDayInput(
          nameController: _nameController,
          onDateChanged: (t) => setState(() => _selectedBirthday = t),
          onNameChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        PhoneAndAltPhoneInput(
          altPhoneController: _altPhoneController,
          phoneController: _phoneController,
          onPhoneChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onAltPhoneChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        EmailAndCompanyNameInput(
          emailController: _emailController,
          companyNameController: _companyNameController,
          onCompanyNameChanged: (t) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onEmailChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        AddressTextField(
          addressController: _addressController,
          onAddressChanged: (v) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(label: 'Add New Customer', onPressed: _onSubmit),
      ],
    );
  }
}
