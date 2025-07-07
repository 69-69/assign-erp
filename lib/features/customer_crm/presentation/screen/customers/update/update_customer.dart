import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/customer_crm/data/models/customer_model.dart';
import 'package:assign_erp/features/customer_crm/presentation/bloc/create_acc/customer_acc_bloc.dart';
import 'package:assign_erp/features/customer_crm/presentation/bloc/customer_bloc.dart';
import 'package:assign_erp/features/customer_crm/presentation/screen/customers/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateCustomerForm<T> on BuildContext {
  Future<void> openUpdateCustomer({required Customer customer}) =>
      openBottomSheet(
        isExpand: false,
        child: _UpdateCustomer(customer: customer),
      );
}

class _UpdateCustomer extends StatelessWidget {
  final Customer customer;

  const _UpdateCustomer({required this.customer});

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
          'Edit Customer',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kGrayColor,
          ),
        ),
        subtitle: Text(
          customer.name.toUppercaseFirstLetterEach,
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
      child: _UpdateCustomerBody(customer: customer),
    );
  }
}

class _UpdateCustomerBody extends StatefulWidget {
  final Customer customer;

  const _UpdateCustomerBody({required this.customer});

  @override
  State<_UpdateCustomerBody> createState() => _UpdateCustomerBodyState();
}

class _UpdateCustomerBodyState extends State<_UpdateCustomerBody> {
  Customer get _customer => widget.customer;

  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedBirthday;

  late final _customerIdController = TextEditingController(
    text: _customer.customerId,
  );
  late final _nameController = TextEditingController(text: _customer.name);
  late final _emailController = TextEditingController(text: _customer.email);
  late final _phoneController = TextEditingController(text: _customer.phone);
  late final _altPhoneController = TextEditingController(
    text: _customer.altPhone,
  );
  late final _addressController = TextEditingController(
    text: _customer.address,
  );
  late final _companyNameController = TextEditingController(
    text: _customer.companyName,
  );

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

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = _customer.copyWith(
        storeNumber: _customer.storeNumber,
        name: _nameController.text,
        birthDay: _selectedBirthday ?? _customer.birthDay,
        customerId: _customerIdController.text,
        phone: _phoneController.text,
        altPhone: _altPhoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        companyName: _companyNameController.text,
        createdBy: _customer.createdBy,
        updatedBy: context.employee!.fullName,
      );

      /// Update Customer
      context.read<CustomerAccountBloc>().add(
        UpdateCustomer<Customer>(documentId: _customer.id, data: item),
      );

      _formKey.currentState!.reset();
      context.showAlertOverlay(
        'Customer with ID: ${_customer.id} has been successfully updated',
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
        CustomerNameAndBirthDayInput(
          nameController: _nameController,
          serverDate: _customer.getBirthDay,
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
        context.elevatedBtn(onPressed: _onSubmit),
      ],
    );
  }
}
