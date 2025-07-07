import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/barcode_scanner.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/inventory_ims/data/models/delivery_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/delivery/delivery_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/deliveries/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateDeliveryForm on BuildContext {
  Future<void> openUpdateDelivery({required Delivery delivery}) =>
      openBottomSheet(
        isExpand: false,
        child: _UpdateDelivery(delivery: delivery),
      );
}

class _UpdateDelivery extends StatelessWidget {
  final Delivery delivery;

  const _UpdateDelivery({required this.delivery});

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
          'Edit Delivery',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
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
      child: _UpdateDeliveryBody(delivery: delivery),
    );
  }
}

class _UpdateDeliveryBody extends StatefulWidget {
  final Delivery delivery;

  const _UpdateDeliveryBody({required this.delivery});

  @override
  State<_UpdateDeliveryBody> createState() => _UpdateDeliveryBodyState();
}

class _UpdateDeliveryBodyState extends State<_UpdateDeliveryBody> {
  Delivery get _delivery => widget.delivery;

  String? _selectedOrderNumber;
  String? _selectedDeliveryStatus;
  String? _selectedDeliveryType;

  final _formKey = GlobalKey<FormState>();

  late final _barcodeController = TextEditingController(
    text: _delivery.barcode,
  );
  late final _deliveryPersonController = TextEditingController(
    text: _delivery.deliveryPerson,
  );
  late final _deliveryPhoneController = TextEditingController(
    text: _delivery.deliveryPhone,
  );
  late final _remarksController = TextEditingController(
    text: _delivery.remarks,
  );

  @override
  void dispose() {
    _deliveryPersonController.dispose();
    _barcodeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = _delivery.copyWith(
        orderNumber: _selectedOrderNumber ?? _delivery.orderNumber,
        barcode: _barcodeController.text,
        deliveryPhone: _deliveryPhoneController.text,
        deliveryPerson: _deliveryPersonController.text,
        status: _selectedDeliveryStatus ?? _delivery.status,
        deliveryType: _selectedDeliveryType ?? _delivery.deliveryType,
        remarks: _remarksController.text,
        storeNumber: _delivery.storeNumber,
        createdBy: _delivery.createdBy,
        updatedBy: context.employee!.fullName,
      );

      /// Update Delivery
      context.read<DeliveryBloc>().add(
        UpdateInventory<Delivery>(documentId: _delivery.id, data: item),
      );

      _isDelivered(_selectedDeliveryStatus);

      context.showAlertOverlay('Delivery successfully updated');

      Navigator.pop(context);
    }
  }

  /// Update Delivery Status
  void _updateStatus(status) {
    _delivery.copyWith(status: status);
    setState(() => _selectedDeliveryStatus = status);

    /// Update Delivery Status
    context.read<DeliveryBloc>().add(
      UpdateInventory<Delivery>(
        documentId: _delivery.id,
        mapData: {'status': status},
      ),
    );

    _isDelivered(status);

    context.showAlertOverlay('Changes saved');
  }

  /// Update OrderStatus & record new Sales once the order(s) have been successfully delivered
  void _isDelivered(status) {
    if (status == 'delivered' && _delivery.orderNumber.isNotEmpty) {
      context.read<DeliveryBloc>().isDelivered(_delivery.orderNumber);
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
        Text(
          'Update Delivery Status',
          style: context.ofTheme.textTheme.titleLarge,
        ),
        const SizedBox(height: 10.0),
        DeliveryStatusDropdown(
          serverStatus: _delivery.status,
          onChange: (s) => _updateStatus(s),
        ),
        divLine,
        _formBody(),
      ],
    );
  }

  ExpansionTile _formBody() {
    return ExpansionTile(
      dense: true,
      title: Text(
        'Modify this Delivery',
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleLarge,
      ),
      subtitle: Text(
        'ID ${_delivery.id}'.toUppercaseAllLetter,
        textAlign: TextAlign.center,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
      children: [
        const SizedBox(height: 20),
        OrderNumberDropdown(
          serverValue: _delivery.orderNumber,
          onChanged: (orderNumber, productName) =>
              setState(() => _selectedOrderNumber = orderNumber),
        ),
        const SizedBox(height: 20),
        DeliveryStatusAndTypesDropdown(
          serverStatus: _delivery.status,
          serverType: _delivery.deliveryType,
          onTypeChange: (t) => setState(() => _selectedDeliveryType = t),
          onStatusChange: (s) => setState(() => _selectedDeliveryStatus = s),
        ),
        const SizedBox(height: 20.0),
        DeliveryPersonAndPhoneInput(
          deliveryPersonController: _deliveryPersonController,
          deliveryPhoneController: _deliveryPhoneController,
        ),
        const SizedBox(height: 20.0),
        RemarksTextField(controller: _remarksController),
        const SizedBox(height: 20.0),
        BarcodeScannerWithTextField(
          controller: _barcodeController,
          onChanged: (t) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(onPressed: _onSubmit),
      ],
    );
  }
}
