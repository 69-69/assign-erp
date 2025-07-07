import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/index.dart';
import 'package:assign_erp/features/setup/presentation/bloc/product_config/suppliers_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/product_config/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateSupplier on BuildContext {
  Future openUpdateSupplier({required Supplier supplier}) => openBottomSheet(
    isExpand: false,
    child: _UpdateSupplierForm(supplier: supplier),
  );
}

class _UpdateSupplierForm extends StatelessWidget {
  final Supplier supplier;

  const _UpdateSupplierForm({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: BlocBuilder<SupplierBloc, SetupState<Supplier>>(
        builder: (context, state) => _buildBody(context),
      ),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: ListTile(
        title: Text(
          'Edit Supplier',
          semanticsLabel: 'edit Supplier',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kGrayColor,
          ),
        ),
        subtitle: Text(
          supplier.supplierName.toUppercaseFirstLetterEach,
          semanticsLabel: supplier.supplierName,
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
      child: _UpdateSupplierFormBody(supplier: supplier),
    );
  }
}

class _UpdateSupplierFormBody extends StatefulWidget {
  final Supplier supplier;

  const _UpdateSupplierFormBody({required this.supplier});

  @override
  State<_UpdateSupplierFormBody> createState() =>
      _UpdateSupplierFormBodyState();
}

class _UpdateSupplierFormBodyState extends State<_UpdateSupplierFormBody> {
  Supplier get _supplier => widget.supplier;

  final _formKey = GlobalKey<FormState>();
  late final _supplierNameController = TextEditingController(
    text: _supplier.supplierName,
  );
  late final _contactPersonNameController = TextEditingController(
    text: _supplier.contactPersonName,
  );
  late final _phoneController = TextEditingController(text: _supplier.phone);
  late final _emailController = TextEditingController(text: _supplier.email);
  late final _addressController = TextEditingController(
    text: _supplier.address,
  );

  @override
  void dispose() {
    _supplierNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_formKey.currentState!.validate()) {
        final item = _supplier.copyWith(
          supplierName: _supplierNameController.text,
          contactPersonName: _contactPersonNameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
          createdBy: _supplier.createdBy,
          updatedBy: context.employee!.fullName,
        );

        /// Update Suppliers
        context.read<SupplierBloc>().add(
          UpdateSetup<Supplier>(documentId: _supplier.id, data: item),
        );

        context.showAlertOverlay(
          '${_supplierNameController.text.toUppercaseFirstLetterEach} successfully updated',
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
        SupplierNameAndContactPersonNameInput(
          supplierNameController: _supplierNameController,
          contactPersonNameController: _contactPersonNameController,
          onSupplierNameChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onContactPersonNameChanged: (s) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        SupplierPhoneAndEmailInput(
          phoneController: _phoneController,
          emailController: _emailController,
          onEmailChanged: (s) => setState(() {}),
          onPhoneChanged: (s) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        AddressTextField(controller: _emailController),
        const SizedBox(height: 20.0),
        context.elevatedBtn(onPressed: _onSubmit),
      ],
    );
  }
}
