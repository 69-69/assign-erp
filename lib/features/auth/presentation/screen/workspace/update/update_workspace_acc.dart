import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/hosting_type.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/bottom_sheet_header.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_dialog.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';
import 'package:assign_erp/features/agent/presentation/bloc/system_wide/system_wide_bloc.dart';
import 'package:assign_erp/features/auth/data/model/workspace_model.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/workspace_form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateWorkspacePopUp on BuildContext {
  Future<void> openUpdateWorkspacePopUp({required Workspace workspace}) =>
      showModalBottomSheet(
        context: this,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: kTransparentColor,
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
  late Workspace _workspace;

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

  @override
  void initState() {
    super.initState();
    _workspace = widget.workspace;
  }

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
      label: 'Success Message',
      '${_workspace.workspaceName.toTitleCase} $title updated',
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
  /// removal of all authorized device IDs. [_removeAuthorizedDeviceId]
  void _removeAuthorizedDeviceId({String? did}) {
    context.read<SystemWideBloc>().add(
      RemoveAuthorizedDeviceIds<String>(documentId: _workspace.id, data: did),
    );

    setState(() {
      final updatedDeviceIds = did != null
          ? _workspace.authorizedDeviceIds.where((id) => id != did).toList()
          : <String>[];

      _workspace = _workspace.copyWith(authorizedDeviceIds: updatedDeviceIds);
    });

    _toastMsg(
      did != null
          ? 'Device ID "$did" has been removed.'
          : 'Authorized device IDs have been cleared.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: DialogTitle(
        title: _workspace.workspaceName.toTitleCase,
        subtitle: 'Workspace Role & Status',
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _buildForm(context),
      ),
      actions: const [],
    );
  }

  _buildForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WorkspaceRoleAndStatus(
          key: const Key('edit-workspace-role-status'),
          serverRole: _workspace.role.name,
          serverStatus: _workspace.status,
          onRoleChanged: (v) =>
              v.isNullOrEmpty ? null : _updateWorkspaceRole(v!),
          onStatusChanged: (v) =>
              v.isNullOrEmpty ? null : _updateWorkspaceStatus(v!),
        ),

        if (_workspace.authorizedDeviceIds.isNotEmpty) ...[
          const SizedBox(height: 10.0),
          Text(
            'Authorized Devices Ids',
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.bodyLarge,
          ),
          SizedBox(height: 60, child: _buildAuthorizedDevicesChips()),
        ],
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
        _workspace.workspaceName.toTitleCase,
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.bodySmall,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
      children: <Widget>[
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
        context.confirmableActionButton(onPressed: _onSubmit),
      ],
    );
  }

  /// Main widget that includes reset button and chips list
  Widget _buildAuthorizedDevicesChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _buildDeviceChips()),
        context.resetAuthorizedDevicesIdsButton(
          onPressed: () => _removeAuthorizedDeviceId(),
        ),
      ],
    );
  }

  /// Builds the scrollable list of authorized device chips
  Widget _buildDeviceChips() {
    final deviceIds = _workspace.authorizedDeviceIds;

    return CustomScrollBar(
      showScrollUpButton: false,
      controller: ScrollController(),
      padding: EdgeInsets.only(top: 15),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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
        onDeleted: () async {
          final isConfirmed = await context.confirmUserActionDialog(
            onAccept: 'Remove IDs',
          );
          if (isConfirmed) _removeAuthorizedDeviceId(did: deviceId);
        },
      ),
    );
  }
}
