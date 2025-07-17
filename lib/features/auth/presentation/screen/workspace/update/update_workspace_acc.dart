import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/hosting_type.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';
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
  String? _hostingType;
  DateTime? _selectedExpiryDate;
  DateTime? _selectedEffectiveDate;
  final _formKey = GlobalKey<FormState>();
  late final _totalDevicesController = TextEditingController(
    text: '${_workspace.maxAllowedDevices}',
  );
  late final _subscribeFeeController = TextEditingController(
    text: _workspace.subscriptionFee,
  );

  Workspace get _workspaceData => _workspace.copyWith(
    license: getLicenseByString(_selectedPackage ?? _workspace.license.name),
    hostingType: getHostingByString(
      _hostingType ?? _workspace.hostingType.label,
    ),
    expiresOn: _selectedExpiryDate,
    effectiveFrom: _selectedEffectiveDate,
    subscriptionFee: _subscribeFeeController.text,
    maxAllowedDevices: int.tryParse(_totalDevicesController.text) ?? 1,
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = _workspaceData;

      // Update Client Workspace
      context.read<SystemWideBloc>().add(
        UpdateClient<Workspace>(documentId: _workspace.id, data: item),
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

  /// Update Specific Field [_modifySpecificField]
  void _modifySpecificField(Map<String, dynamic> data) {
    context.read<SystemWideBloc>().add(
      UpdateClient<Workspace>(documentId: _workspace.id, mapData: data),
    );
  }

  /// Update Workspace Status [_updateWorkspaceStatus]
  void _updateWorkspaceStatus(String status) {
    _workspace.copyWith(status: status);

    _modifySpecificField({'status': status});

    _toastMsg('status');
  }

  /// Update Workspace Role [_updateWorkspaceRole]
  void _updateWorkspaceRole(String role) {
    final obj = Workspace.getRoleByString(role);

    _workspace.copyWith(role: obj);

    _modifySpecificField({'role': role});

    _toastMsg('role');
  }

  /// Dispatches an event to reset workspace authorized device IDs for the clients workspace.
  ///
  /// If a specific [did] (device ID) is provided, it will be removed from the
  /// list of authorized devices. If [did] is null, the event will trigger
  /// removal of all authorized device IDs. [_resetAuthorizedDeviceIds]
  void _resetAuthorizedDeviceIds({String? did}) {
    context.read<SystemWideBloc>().add(
      ResetAuthorizedDeviceIds<String>(documentId: _workspace.id, data: did),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: _buildForm(context),
      ),
    );
  }

  _buildForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          dense: true,
          titleAlignment: ListTileTitleAlignment.center,
          title: Text(
            _workspace.workspaceName.toUppercaseFirstLetterEach,
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleLarge?.copyWith(
              color: kPrimaryLightColor,
            ),
          ),
          subtitle: Text(
            'Workspace Role & Status',
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.bodySmall,
          ),
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
      expandedAlignment: Alignment.center,
      title: Text(
        'Manage Workspace',
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          color: kPrimaryLightColor,
        ),
      ),
      subtitle: Text(
        _workspace.workspaceName.toUppercaseFirstLetterEach,
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.bodySmall,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
      children: <Widget>[
        if (_workspace.authorizedDeviceIds.isNotEmpty) ...[
          const SizedBox(height: 5.0),
          Text(
            'Authorized Devices Ids',
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.bodyLarge,
          ),
          SizedBox(height: 60, child: _buildAuthorizedDevicesChips()),
        ],
        const SizedBox(height: 20.0),
        SubscribeFeeAndHostingType(
          serverHosting: _workspace.hostingType.label,
          subscribeFeeController: _subscribeFeeController,
          onSubscribeFeeChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onHostingChanged: (s) => setState(() => _hostingType = s),
        ),
        const SizedBox(height: 20.0),
        LicenseAndTotalDevices(
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

  /// Main widget that includes reset button and chips list
  Widget _buildAuthorizedDevicesChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        context.resetAuthorizedDevicesIdsButton(
          onPressed: () => _resetAuthorizedDeviceIds(),
        ),
        Expanded(child: _buildDeviceChips()),
      ],
    );
  }

  /// Builds the scrollable list of authorized device chips
  Widget _buildDeviceChips() {
    final deviceIds = _workspace.authorizedDeviceIds;

    return CustomScrollBar(
      controller: ScrollController(),
      padding: EdgeInsets.only(top: 14),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: deviceIds.asMap().entries.map((entry) {
          return _buildChipCard(index: entry.key, deviceId: entry.value);
        }).toList(),
      ),
    );
  }

  /// Builds a single chip with delete functionality
  Widget _buildChipCard({required int index, required String deviceId}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        padding: EdgeInsets.zero,
        label: Text(
          deviceId,
          style: context.ofTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        deleteButtonTooltipMessage: 'Remove',
        backgroundColor: randomBgColors[index].withAlpha((0.3 * 255).toInt()),
        deleteIcon: const Icon(size: 16, Icons.clear, color: kTextColor),
        onDeleted: () => _resetAuthorizedDeviceIds(did: deviceId),
      ),
    );
  }
}

/*
git add .
git commit -m "Completed Assign-Work also known as AssignERP"
git branch -M main
git push -u origin main
* */
