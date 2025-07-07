import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/network/data_sources/remote/bloc/firestore_bloc.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/agent/presentation/bloc/client/agent_clients_bloc.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateWorkspacePopUp on BuildContext {
  Future<void> openUpdateWorkspacePopUp({required Workspace workspace}) =>
      showModalBottomSheet(
        context: this,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => WorkspaceScreen(workspace: workspace),
      );
}

class WorkspaceScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceScreen({super.key, required this.workspace});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  Workspace get _workspace => widget.workspace;

  String? _selectedPackage;
  DateTime? _selectedExpiryDate;
  DateTime? _selectedEffectiveDate;
  final _formKey = GlobalKey<FormState>();
  late final _totalDevicesController = TextEditingController(
    text: '${_workspace.maxAllowedDevices}',
  );

  Workspace get _workspaceData => _workspace.copyWith(
    license: getLicenseByString(_selectedPackage ?? _workspace.license.name),
    expiresOn: _selectedExpiryDate,
    effectiveFrom: _selectedEffectiveDate,
    maxAllowedDevices: int.tryParse(_totalDevicesController.text) ?? 1,
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = _workspaceData;

      // Update Client Workspace
      context.read<MyAgentBloc>().add(
        UpdateData<Workspace>(documentId: _workspace.id, data: item),
      );

      _toastMsg('workspace');

      Navigator.of(context).pop();
    }
  }

  void _toastMsg(String title) {
    context.showAlertOverlay(
      '${_workspace.workspaceName.toUppercaseFirstLetterEach} $title updated',
    );
  }

  void _modifySpecificField(Map<String, dynamic> data) {
    context.read<MyAgentBloc>().add(
      UpdateData<Workspace>(documentId: _workspace.id, mapData: data),
    );
  }

  /// Update Workspace Status
  void _updateWorkspaceStatus(String status) {
    _workspace.copyWith(status: status);

    _modifySpecificField({'status': status});

    _toastMsg('status');
  }

  /// Update Workspace Role
  void _updateWorkspaceRole(String role) {
    final obj = Workspace.getRoleByString(role);

    _workspace.copyWith(role: obj);

    _modifySpecificField({'role': role});

    _toastMsg('role');
  }

  @override
  Widget build(BuildContext context) {
    return _buildAlertDialog(context);
  }

  _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      icon: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: kLightColor.withAlpha((0.4 * 255).toInt()),
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: kTextColor),
        ),
      ),
      iconPadding: const EdgeInsets.only(right: 5, top: 5),
      backgroundColor: kLightColor.withAlpha((0.8 * 255).toInt()),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _buildFormBody(context),
      ),
    );
  }

  _buildFormBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Workspace Role & Status',
          style: context.ofTheme.textTheme.titleLarge,
        ),
        const SizedBox(height: 20.0),
        WorkspaceRoleAndStatus(
          key: const Key('edit-workspace-role-status'),
          serverRole: _workspace.role.name,
          serverStatus: _workspace.status,
          onRoleChanged: (v) =>
              v.isNullOrEmpty ? null : _updateWorkspaceRole(v!),
          onStatusChanged: (v) =>
              v.isNullOrEmpty ? null : _updateWorkspaceStatus(v!),
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
        'Manage this Account',
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleLarge,
      ),
      subtitle: Text(
        _workspace.workspaceName.toUppercaseFirstLetterEach,
        textAlign: TextAlign.center,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
      children: <Widget>[
        const SizedBox(height: 20.0),
        PackageAndTotalDevices(
          onPackageChange: (s) => setState(() => _selectedPackage = s),
          serverPackage: _workspace.license.name,
          totalDevicesController: _totalDevicesController,
          onTotalDevicesChanged: (i) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 20.0),
        ExpiryAndEffectiveDateInput(
          labelExpiry: "Expiry date",
          labelManufacture: "Effective date",
          serverExpiryDate: _workspace.getExpiresOn,
          serverEffectiveDate: _workspace.getEffectiveFrom,
          onExpiryChanged: (d) => setState(() => _selectedExpiryDate = d),
          onEffectiveChanged: (d) => setState(() => _selectedEffectiveDate = d),
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(onPressed: _onSubmit),
      ],
    );
  }
}
