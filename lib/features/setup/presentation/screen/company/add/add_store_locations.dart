import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/generate_new_uid.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/button/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dialog/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/dialog/form_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company/company_stores_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/widget/can_add_more_stores.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddStoreLocations<T> on BuildContext {
  Future<void> openAddStoreLocations({Widget? header}) => openBottomSheet(
    isExpand: false,
    child: FormBottomSheet(
      title: 'Add Store Locations',
      body: const _AddStoreFormBody(),
    ),
  );
}

class _AddStoreFormBody extends StatefulWidget {
  const _AddStoreFormBody();

  @override
  State<_AddStoreFormBody> createState() => _AddStoreFormBodyState();
}

class _AddStoreFormBodyState extends State<_AddStoreFormBody> {
  final ScrollController _scrollController = ScrollController();
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

      context.read<CompanyStoresBloc>().add(
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
        '${_nameController.text.toTitleCase} added to batch',
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

  void _removeStoreFromBatch(CompanyStores store) {
    setState(() => _stores.remove(store));
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
          if (isMultipleStores && _stores.isNotEmpty) ...[
            SizedBox(height: 60.0, child: _buildBatchPreviewChips()),
          ],
          _buildBody(context),
        ],
      ),
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
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: _newStoreNumber,
                    style: context.textTheme.titleLarge?.copyWith(
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
        if (context.canAddMoreStores) ...[
          const SizedBox(height: 20.0),

          context.elevatedIconBtn(
            Icons.add,
            onPressed: _addStoreToList,
            label: 'Add to List',
          ),
        ],
        const SizedBox(height: 20.0),
        context.confirmableActionButton(
          label: isMultipleStores ? 'Add Stores' : 'Add Store',
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  // Horizontal scrollable row of chips representing the List of batches
  Widget _buildBatchPreviewChips() {
    return CustomScrollBar(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _stores.map((o) {
          return o.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Chip(
                    padding: EdgeInsets.zero,
                    label: Text(
                      o.name.toTitleCase,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    deleteButtonTooltipMessage: 'Remove ${o.name}',
                    backgroundColor: kGrayColor.withAlpha((0.3 * 255).toInt()),
                    deleteIcon: const Icon(
                      size: 16,
                      Icons.clear,
                      color: kGrayColor,
                    ),
                    onDeleted: () => _removeStoreFromBatch(o),
                  ),
                );
        }).toList(),
      ),
    );
  }
}
