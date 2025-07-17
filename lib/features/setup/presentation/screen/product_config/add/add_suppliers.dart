import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/supplier_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/product_config/suppliers_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/product_config/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddSuppliers on BuildContext {
  Future openAddSuppliers({Widget? header}) => openBottomSheet(
    isExpand: false,
    child: _AddSuppliersForm(header: header),
  );
}

class _AddSuppliersForm extends StatelessWidget {
  final Widget? header;

  const _AddSuppliersForm({this.header});

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
      title: Text(
        'Add Suppliers',
        semanticsLabel: 'add Suppliers',
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
      child: _AddSuppliersFormBody(),
    );
  }
}

class _AddSuppliersFormBody extends StatefulWidget {
  const _AddSuppliersFormBody();

  @override
  State<_AddSuppliersFormBody> createState() => _AddSuppliersFormBodyState();
}

class _AddSuppliersFormBodyState extends State<_AddSuppliersFormBody> {
  final ScrollController _scrollController = ScrollController();
  bool isMultipleSuppliers = false;
  final List<Supplier> _suppliers = [];

  final _formKey = GlobalKey<FormState>();
  final _supplierNameController = TextEditingController();
  final _contactPersonNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _supplierNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Supplier get _supplierData => Supplier(
    supplierName: _supplierNameController.text,
    contactPersonName: _contactPersonNameController.text,
    phone: _phoneController.text,
    email: _emailController.text,
    address: _addressController.text,
    createdBy: context.employee?.fullName ?? 'unknown',
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      /// Added Multiple suppliers Simultaneously
      _suppliers.add(_supplierData);

      context.read<SupplierBloc>().add(
        AddSetup<List<Supplier>>(data: _suppliers),
      );

      _formKey.currentState!.reset();

      _clearFields();

      context.showAlertOverlay('Stores successfully created');
      Navigator.pop(context);
    }
  }

  /// Function for Adding Multiple Suppliers Simultaneously
  void _addSupplierToList() {
    if (_formKey.currentState!.validate()) {
      setState(() => isMultipleSuppliers = true);
      _suppliers.add(_supplierData);

      context.showAlertOverlay(
        '${_supplierNameController.text.toUppercaseFirstLetterEach} added to batch',
      );
      _clearFields();
    }
  }

  void _clearFields() {
    _supplierNameController.clear();
    _contactPersonNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _emailController.clear();
  }

  void _removeSupplier(Supplier supplier) {
    setState(() => _suppliers.remove(supplier));
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
          if (isMultipleSuppliers && _suppliers.isNotEmpty)
            _buildBatchPreviewChips(),
          _buildBody(context),
        ],
      ),
    );
  }

  // Horizontal scrollable row of chips representing the List of batches
  Widget _buildBatchPreviewChips() {
    return CustomScrollBar(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _suppliers.map((o) {
          return o.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Chip(
                    padding: EdgeInsets.zero,
                    label: Text(
                      o.supplierName.toUppercaseFirstLetterEach,
                      style: context.ofTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    deleteButtonTooltipMessage: 'Remove ${o.supplierName}',
                    backgroundColor: kGrayColor.withAlpha((0.3 * 255).toInt()),
                    deleteIcon: const Icon(
                      size: 16,
                      Icons.clear,
                      color: kGrayColor,
                    ),
                    onDeleted: () => _removeSupplier(o),
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
        AddressTextField(controller: _addressController),
        const SizedBox(height: 20.0),
        context.elevatedIconBtn(
          Icons.add,
          onPressed: _addSupplierToList,
          label: 'Add to List',
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(
          label: isMultipleSuppliers
              ? 'Create All Suppliers'
              : 'Create Supplier',
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
