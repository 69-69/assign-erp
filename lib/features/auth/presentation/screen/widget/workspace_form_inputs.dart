import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/constants/hosting_type.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:assign_erp/core/util/date_time_picker.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/auth/data/role/workspace_role.dart';
import 'package:assign_erp/features/auth/presentation/bloc/sign_in/workspace/workspace_sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

/// Expiry & Effective Date Picker [ExpiryAndEffectiveDateInput]
class ExpiryAndEffectiveDateInput extends StatelessWidget {
  const ExpiryAndEffectiveDateInput({
    super.key,
    this.labelExpiry,
    this.labelManufacture,
    this.onQuantityChanged,
    required this.onExpiryChanged,
    required this.onEffectiveChanged,
    this.serverExpiryDate,
    this.serverEffectiveDate,
  });

  final String? serverExpiryDate;
  final String? serverEffectiveDate;
  final String? labelExpiry;
  final String? labelManufacture;
  final ValueChanged? onQuantityChanged;
  final Function(DateTime) onExpiryChanged;
  final Function(DateTime) onEffectiveChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DatePicker(
          serverDate: serverEffectiveDate,
          label: labelManufacture,
          restorationId: 'Effective date',
          selectedDate: onEffectiveChanged,
        ),
        DatePicker(
          serverDate: serverExpiryDate,
          label: labelExpiry,
          restorationId: 'Expiry date',
          selectedDate: onExpiryChanged,
        ),
      ],
    );
  }
}

/// Subscription License & Number-of-Device TextField/Dropdown [LicenseAndTotalDevices]
class LicenseAndTotalDevices extends StatelessWidget {
  const LicenseAndTotalDevices({
    super.key,
    required this.totalDevicesController,
    this.onTotalDevicesChanged,
    required this.onPackageChange,
    this.serverPackage,
  });

  final Function(String?) onPackageChange;
  final String? serverPackage;

  final TextEditingController totalDevicesController;
  final ValueChanged? onTotalDevicesChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextField(
          labelText: 'Total Devices',
          onChanged: onTotalDevicesChanged,
          controller: totalDevicesController,
          keyboardType: TextInputType.number,
        ),
        CustomDropdown(
          key: key,
          items: subscriptionLicensesToList(),
          labelText: 'license type',
          serverValue: serverPackage,
          onValueChange: (String? v) => onPackageChange(v),
        ),
      ],
    );
  }
}

/// Subscription Fee & Hosting Type Dropdown [SubscribeFeeAndHostingType]
class SubscribeFeeAndHostingType extends StatelessWidget {
  const SubscribeFeeAndHostingType({
    super.key,
    required this.subscribeFeeController,
    this.onSubscribeFeeChanged,
    required this.onHostingChanged,
    this.serverHosting,
  });

  final Function(String?) onHostingChanged;
  final String? serverHosting;

  final TextEditingController subscribeFeeController;
  final ValueChanged? onSubscribeFeeChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SubscriptionFee(
          onSubscribeFeeChanged: onSubscribeFeeChanged,
          subscribeFeeController: subscribeFeeController,
        ),
        CustomDropdown(
          key: key,
          items: hostingTypeList,
          labelText: 'hosting type',
          serverValue: serverHosting,
          onValueChange: (String? v) => onHostingChanged(v),
        ),
      ],
    );
  }
}

/// Subscription Fee TextField [SubscriptionFee]
class SubscriptionFee extends StatelessWidget {
  const SubscriptionFee({
    super.key,
    required this.onSubscribeFeeChanged,
    required this.subscribeFeeController,
  });

  final TextEditingController subscribeFeeController;
  final ValueChanged? onSubscribeFeeChanged;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Subscription Fee',
      onChanged: onSubscribeFeeChanged,
      controller: subscribeFeeController,
      keyboardType: TextInputType.number,
      inputDecoration: InputDecoration(
        hintText: 'Subscription Fee',
        label: const Text(
          'Subscription Fee',
          semanticsLabel: 'Subscription Fee',
        ),
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.payments, size: 15),
      ),
    );
  }
}

/// Workspace Account Role & Status Dropdown [WorkspaceRoleAndStatus]
class WorkspaceRoleAndStatus extends StatelessWidget {
  const WorkspaceRoleAndStatus({
    super.key,
    this.serverStatus,
    required this.onStatusChanged,
    required this.onRoleChanged,
    this.serverRole,
  });

  final Function(String?) onRoleChanged;
  final String? serverRole;
  final Function(String?) onStatusChanged;
  final String? serverStatus;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomDropdown(
          items: workspaceStatusList,
          labelText: workspaceStatusList.first,
          serverValue: serverStatus,
          onValueChange: (String? v) => onStatusChanged(v),
        ),
        CustomDropdown(
          key: key,
          items: workspaceRoleList,
          labelText: workspaceRoleList.first,
          serverValue: serverRole,
          onValueChange: (String? v) => onRoleChanged(v),
        ),
      ],
    );
  }
}

/// Workspace Category Dropdown [workspace Category]
class WorkspaceCategory extends StatelessWidget {
  const WorkspaceCategory({super.key, this.serverEntity});

  final String? serverEntity;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      buildWhen: (previous, current) =>
          previous.workspaceCategory != current.workspaceCategory,
      builder: (_, state) => _buildBody(context, state),
    );
  }

  CustomDropdown _buildBody(BuildContext context, WorkspaceSignInState state) {
    return CustomDropdown(
      items: worspaceCategories,
      labelText: 'Workspace category',
      serverValue: serverEntity,
      onValueChange: (String? v) {
        if (v != null) {
          context.read<WorkspaceSignInBloc>().add(
            WorkspaceCategoryChanged(v.trim()),
          );
        }
      },
      inputDecoration: InputDecoration(
        errorText: state.workspaceName.displayError != null
            ? 'Choose workspace category'
            : null,
      ),
    );
  }
}

// Workspace name
class WorkspaceNameInput extends StatelessWidget {
  const WorkspaceNameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      buildWhen: (previous, current) =>
          (previous.workspaceCategory != current.workspaceCategory) ||
          previous.workspaceName != current.workspaceName,
      builder: (cxt, state) => state.workspaceCategory.isValid
          ? _workspaceNameFormField(cxt, state)
          : const SizedBox.shrink(),
    );
  }

  _workspaceNameFormField(BuildContext context, WorkspaceSignInState state) {
    return CustomTextField(
      key: const Key('reg_Workspace_name_Form_Input_textField'),
      keyboardType: TextInputType.text,
      onChanged: (name) => context.read<WorkspaceSignInBloc>().add(
        WorkspaceNameChanged(name.trim()),
      ),
      inputDecoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(1.0),
        hintText: "Enter workspace name",
        label: const Text('Workspace name', semanticsLabel: 'Workspace name'),
        alignLabelWithHint: true,
        fillColor: kGrayColor.withAlpha((0.1 * 255).toInt()),
        errorText: state.workspaceName.displayError != null
            ? 'Enter workspace name. Ex: Cash firms'
            : null,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.business, size: 15),
      ),
    );
  }
}

// Name
class NameInput extends StatelessWidget {
  const NameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      buildWhen: (previous, current) =>
          (previous.workspaceName != current.workspaceName) ||
          previous.clientName != current.clientName,
      builder: (cxt, state) => state.workspaceName.isValid
          ? _nameFormField(cxt, state)
          : const SizedBox.shrink(),
    );
  }

  _nameFormField(BuildContext context, WorkspaceSignInState state) {
    return CustomTextField(
      key: const Key('reg_client_name_Form_Input_textField'),
      keyboardType: TextInputType.name,
      autofillHints: const [AutofillHints.name],
      onChanged: (clientName) => context.read<WorkspaceSignInBloc>().add(
        ClientNameChanged(clientName.trim()),
      ),
      inputDecoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(1.0),
        hintText: "Enter client name",
        label: const Text('Client name', semanticsLabel: 'Client name'),
        alignLabelWithHint: true,
        fillColor: kGrayColor.withAlpha((0.1 * 255).toInt()),
        errorText: state.clientName.displayError != null
            ? 'Invalid Client name'
            : null,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.person, size: 15),
      ),
    );
  }
}

// MobileNumber
class MobileNumberInput extends StatelessWidget {
  const MobileNumberInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      buildWhen: (prev, cur) =>
          (prev.clientName != cur.clientName) ||
          prev.mobileNumber != cur.mobileNumber,
      builder: (context, state) {
        return state.clientName.isValid
            ? _mobileFormField(context, state)
            : const SizedBox.shrink();
      },
    );
  }

  _mobileFormField(BuildContext context, WorkspaceSignInState state) {
    return CustomTextField(
      key: const Key('reg_name_Form_Input_textField'),
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      onChanged: (number) => context.read<WorkspaceSignInBloc>().add(
        SignInMobileChanged(number.trim()),
      ),
      inputDecoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(1.0),
        hintText: "Enter mobile number",
        label: const Text('Mobile number', semanticsLabel: 'Mobile number'),
        alignLabelWithHint: true,
        fillColor: kGrayColor.withAlpha((0.1 * 255).toInt()),
        errorText: state.mobileNumber.displayError != null
            ? 'Invalid Mobile number'
            : null,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.phone, size: 15),
      ),
    );
  }
}

// Email
class EmailInput extends StatelessWidget {
  final bool checkMobileNumber;
  final String label;

  const EmailInput({
    super.key,
    this.checkMobileNumber = false,
    this.label = 'Workspace email',
  });

  @override
  Widget build(BuildContext context) {
    return checkMobileNumber ? _buildCheck() : _buildNoCheck();
  }

  BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState> _buildCheck() {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      buildWhen: (prev, cur) =>
          (prev.mobileNumber != cur.mobileNumber) || prev.email != cur.email,
      builder: (context, state) => state.mobileNumber.isValid
          ? _emailFormField(context, state)
          : const SizedBox.shrink(),
    );
  }

  BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState> _buildNoCheck() {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      buildWhen: (prev, cur) => prev.email != cur.email,
      builder: (context, state) => _emailFormField(context, state),
    );
  }

  _emailFormField(BuildContext context, WorkspaceSignInState state) {
    return CustomTextField(
      key: const Key('sign_inForm_emailInput_textField'),
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      onChanged: (email) => context.read<WorkspaceSignInBloc>().add(
        SignInEmailChanged(email.trim()),
      ),
      inputDecoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(1.0),
        hintText: label,
        label: Text(label, semanticsLabel: label),
        alignLabelWithHint: true,
        fillColor: kGrayColor.withAlpha((0.1 * 255).toInt()),
        errorText: state.email.displayError != null ? 'Invalid email' : null,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.email, size: 15),
      ),
    );
  }
}

/// This PasswordInput is for either Employee or Workspace during Sign-In [PasswordInput]
class PasswordInput extends StatefulWidget {
  final String label;

  /// Check if FormTextField is valid before showing Password Input Field [checkPrevious]
  final bool checkPrevious;

  const PasswordInput({
    super.key,
    this.checkPrevious = true,
    this.label = 'Workspace password',
  });

  @override
  State<PasswordInput> createState() => PasswordInputState();
}

class PasswordInputState extends State<PasswordInput> {
  bool _secureText = true;

  // Show / hide password
  void showHide() => setState(() => _secureText = !_secureText);

  @override
  Widget build(BuildContext context) {
    return widget.checkPrevious ? _buildCheck() : _buildNoCheck();
  }

  /// Check if email is valid before showing Password Input Field [_buildCheck]
  BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState> _buildCheck() {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      buildWhen: (prev, cur) =>
          (prev.email != cur.email) || (prev.password != cur.password),
      builder: (context, state) => state.email.isValid
          ? _passwordFormField(context, state)
          : const SizedBox.shrink(),
    );
  }

  /// Don't check if email is valid, before showing Password Input Field [_buildNoCheck]
  BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState> _buildNoCheck() {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      buildWhen: (prev, cur) => prev.password != cur.password,
      builder: (context, state) => _passwordFormField(context, state),
    );
  }

  _passwordFormField(BuildContext context, WorkspaceSignInState state) {
    return CustomTextField(
      key: const Key('auth_Form_passwordInput_textField'),
      maxLines: 1,
      maxLength: 20,
      obscureText: _secureText,
      autofillHints: const [AutofillHints.password],
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (password) =>
          dispatchPasswordChangeEvent(password.trim()),
      onChanged: (password) => dispatchPasswordChangeEvent(password.trim()),
      // validator: (v) => v!.length < 4 ? "Enter valid password" : null,
      inputDecoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(1.0),
        fillColor: kGrayColor.withAlpha((0.1 * 255).toInt()),
        hintText: widget.label,
        label: Text(widget.label, semanticsLabel: widget.label),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.lock, size: 15),
        errorText: state.password.displayError != null
            ? 'Invalid password'
            : null,
        alignLabelWithHint: true,
        suffixIcon: IconButton(
          onPressed: showHide,
          icon: Icon(
            _secureText ? Icons.visibility_off : Icons.visibility,
            color: _secureText ? kGrayColor : kTextColor,
            semanticLabel: 'visibility icon',
          ),
        ),
        /*border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),*/
      ),
    );
  }

  void dispatchPasswordChangeEvent(String password) {
    context.read<WorkspaceSignInBloc>().add(
      SignInPasswordChanged(password.trim()),
    );
  }
}

/// Employee's Passcode [TemporaryPasscodeInput]
/// Temporary Employee Passcode required during employee sign-in process,
/// after the organization's workspace sign-in.
class TemporaryPasscodeInput extends StatefulWidget {
  const TemporaryPasscodeInput({super.key});

  @override
  State<TemporaryPasscodeInput> createState() => _TemporaryPasscodeInputState();
}

class _TemporaryPasscodeInputState extends State<TemporaryPasscodeInput> {
  bool _secureText = true;
  final TextEditingController _controller = TextEditingController();
  final String helperText =
      'Generate temporary passcode for employee access to the organization\'s workspace.';

  void showHide() => setState(() => _secureText = !_secureText);

  // Generates a Temporary passcode and dispatching to the Bloc
  void _generateAndDispatchPasscode() {
    final temp = '$kTemporaryPasscodeLength'.generateUID(type: UIDType.numeric);
    final passcode = '$kTemporaryPasscodePrefix$temp';

    // Update the TextField and trigger the Bloc event
    setState(() => _controller.text = passcode);
    _dispatchPasscodeChangeEvent(passcode);
  }

  @override
  void initState() {
    super.initState();

    // Generate and dispatch the initial passcode once the widget is built
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _generateAndDispatchPasscode(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      buildWhen: (prev, cur) =>
          (prev.password != cur.password) ||
          (prev.temporaryPasscode != cur.temporaryPasscode),
      builder: (context, state) {
        return state.password.isValid
            ? _buildPasscodeField(context, state)
            : const SizedBox.shrink();
      },
    );
  }

  /// Builds the CustomTextField widget for the passcode input
  Widget _buildPasscodeField(BuildContext context, WorkspaceSignInState state) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: Text(
          'Employee passcode required after organizational workspace sign-in',
          style: context.ofTheme.textTheme.bodyMedium?.copyWith(
            color: kBgLightColor, // Styling for the text
          ),
        ),
      ),
      // Shows the passcode field wrapped in a BlocBuilder
      subtitle: CustomTextField(
        key: const Key('auth_pass_code_textField'),
        controller: _controller,
        obscureText: _secureText,
        maxLines: 1,
        maxLength: 20,
        autofillHints: const [AutofillHints.password],
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        onChanged: _dispatchPasscodeChangeEvent,
        onFieldSubmitted: _dispatchPasscodeChangeEvent,
        inputDecoration: _buildInputDecoration(context, state),
      ),
    );
  }

  // Builds the input decoration for the passcode field (either temporal or regular)
  InputDecoration _buildInputDecoration(
    BuildContext context,
    WorkspaceSignInState state,
  ) {
    final label = 'Temporal Passcode';

    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.all(1.0),
      fillColor: kGrayColor.withAlpha((0.1 * 255).toInt()),
      label: Text(label, semanticsLabel: label),
      helperText: helperText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: true,
      prefixIcon: Icon(Icons.pin, size: 15),
      errorText: state.password.displayError != null
          ? 'Invalid passcode'
          : null,
      suffixIcon: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _toggleVisibility(),
            const SizedBox(width: 4),
            _generateButton(context),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _generateButton(BuildContext context) {
    return context.elevatedButton(
      'Generate',
      tooltip: helperText,
      color: kLightColor,
      bgColor: kDangerColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      onPressed: _generateAndDispatchPasscode,
    );
  }

  IconButton _toggleVisibility() {
    return IconButton(
      onPressed: showHide,
      icon: Icon(
        _secureText ? Icons.visibility_off : Icons.visibility,
        color: _secureText ? kGrayColor : kTextColor,
        semanticLabel: 'visibility icon',
      ),
    );
  }

  // Dispatches the PasscodeChanged event to the SignInBloc with the updated passcode
  void _dispatchPasscodeChangeEvent(String passcode) {
    context.read<WorkspaceSignInBloc>().add(
      TemporaryPasscodeChanged(passcode.trim()),
    );
  }
}

// Workspace Button
class WorkspaceSignInButton extends StatelessWidget {
  const WorkspaceSignInButton({super.key, required this.onPressed});

  final Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      builder: (context, state) {
        return _buildButton(
          context,
          inProgress: state.status.isInProgress,
          onPress: (state.email.isValid && state.password.isValid)
              ? () {
                  onPressed.call(true);
                  context.read<WorkspaceSignInBloc>().add(SignInRequested());
                }
              : null,
        );
      },
    );
  }

  _buildButton(
    BuildContext context, {
    bool inProgress = false,
    required void Function()? onPress,
  }) => context.confirmableActionButton(
    label: inProgress ? "Please wait..." : "Sign In",
    onPressed: onPress,
  );
}

class SignUpButton extends StatelessWidget {
  const SignUpButton({super.key, required this.onPressed});

  final Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      builder: (context, state) {
        return _buildButton(
          context,
          inProgress: state.status.isInProgress,
          onPress: state.isValid
              ? () async {
                  await _workspaceAction(context);
                }
              : null,
        );
      },
    );
  }

  _workspaceAction(BuildContext context) async {
    await context.progressBarDialog(
      child: const Text(
        'Please wait...\nSetting-up New Workspace\n'
        'You\'ll be Logged out after Setup is done!\n'
        'Please check your email and click on the verification link to complete the process',
        textAlign: TextAlign.center,
      ),
      request: _setupWorkspace(context),
      onSuccess: (_) => context.showAlertOverlay('Setup was successful'),
      onError: (error) =>
          context.showAlertOverlay('Setup failed', bgColor: kDangerColor),
    );
  }

  Future<dynamic> _setupWorkspace(BuildContext context) =>
      // Simulate delayed to complete Workspace SignUp/Setup
      Future.delayed(kFProgressDelay, () async {
        if (context.mounted) {
          onPressed.call(true);
          context.read<WorkspaceSignInBloc>().add(CreateRequested());
        }
      });

  _buildButton(
    BuildContext context, {
    bool inProgress = false,
    required void Function()? onPress,
  }) => context.confirmableActionButton(
    label: inProgress ? "Please wait..." : "Create Workspace",
    onPressed: onPress,
  );
}

class UpdateWorkspacePasswordButton extends StatelessWidget {
  const UpdateWorkspacePasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      builder: (context, state) {
        return _buildButton(
          context,
          inProgress: state.status.isInProgress,
          onPress: state.password.isValid
              ? () async => await _setupWorkspace(context)
              : null,
        );
      },
    );
  }

  Future<dynamic> _setupWorkspace(BuildContext context) =>
      // Simulate delayed to complete Workspace Password Update
      Future.delayed(kRProgressDelay, () async {
        if (context.mounted) {
          context.read<WorkspaceSignInBloc>().add(UpdatePasswordRequested());
        }
      });

  _buildButton(
    BuildContext context, {
    bool inProgress = false,
    required void Function()? onPress,
  }) => context.confirmableActionButton(
    label: inProgress ? "Updating..." : "Change Workspace Password",
    onPressed: onPress,
  );
}

class ForgotWorkspacePasswordButton extends StatelessWidget {
  const ForgotWorkspacePasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceSignInBloc, WorkspaceSignInState>(
      builder: (context, state) {
        return _buildButton(
          context,
          inProgress: state.status.isInProgress,
          onPress: state.email.isValid
              ? () => context.read<WorkspaceSignInBloc>().add(
                  PasswordRecoveryRequested(),
                )
              : null,
        );
      },
    );
  }

  _buildButton(
    BuildContext context, {
    bool inProgress = false,
    required void Function()? onPress,
  }) => context.confirmableActionButton(
    label: inProgress ? "Please wait..." : "Send Reset Link",
    onPressed: onPress,
  );
}

/*
class TemporalPasscodeInput extends StatefulWidget {
  final String label;

  /// Check if previous FormTextField is valid before showing Passcode Input Field [autoGeneratePasscode]
  final bool checkPrevious;
  final bool autoGeneratePasscode;

  const TemporalPasscodeInput({
    super.key,
    required this.label,
    this.checkPrevious = false,
    this.autoGeneratePasscode = false,
  });

  @override
  State<TemporalPasscodeInput> createState() => _TemporalPasscodeInputState();
}

class _TemporalPasscodeInputState extends State<TemporaryPasscodeInput> {
  bool _secureText = true;
  final TextEditingController _controller = TextEditingController();
  final String helperText =
      'Generate Temporary passcode for employee access to the organization\'s workspace.';

  String get _label => widget.label;

  // Whether previous validation (like email/password) should be checked before showing passcode field
  bool get _checkPrevious => widget.checkPrevious;

  // Whether the passcode should be auto-generated
  bool get _autoGenerate => widget.autoGeneratePasscode;

  void showHide() => setState(() => _secureText = !_secureText);

  // Generates a Temporary passcode by appending a random UID to a predefined prefix
  String _generateTemporaryPasscode() {
    final tempCode = '$kTemporaryPasscodeLength'.generateUID(
      type: UIDType.numeric,
    );
    return '$kTemporaryPasscodePrefix$tempCode';
  }

  @override
  void initState() {
    super.initState();
    // If auto-generation is enabled, generate a passcode
    if (_autoGenerate) {
      _controller.text = _generateTemporaryPasscode();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show passcode field or Temporary passcode tile based on autoGenerate flag
    return _autoGenerate
        ? _buildTemporaryPasscodeTile()
        : _buildPasscodeBlocBuilder();
  }

  /// Builds Temporary passcode input section
  _buildTemporaryPasscodeTile() {
    return ListTile(
      dense: true,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          'Employee passcode required after organizational workspace sign-in',
          style: context.ofTheme.textTheme.bodyMedium?.copyWith(
            color: kBgLightColor, // Styling for the text
          ),
        ),
      ),
      // Shows the passcode field wrapped in a BlocBuilder
      subtitle: _buildPasscodeBlocBuilder(),
    );
  }

  /// Builds the BlocBuilder for handling state changes of the SignInBloc
  Widget _buildPasscodeBlocBuilder() {
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (prev, curr) {
        // Checks whether passcode, password, or email state has changed
        final passcodeChanged = prev.passcode != curr.passcode;
        final passwordChanged = prev.password != curr.password;
        final emailChanged = prev.email != curr.email;

        // Only trigger a rebuild if relevant state changes occur
        return passcodeChanged || passwordChanged || emailChanged;
      },
      builder: (context, state) {
        // Determine if the passcode field should be displayed based on the autoGenerate flag or form validation
        final shouldRender =
            _checkPrevious && (state.email.isValid || state.password.isValid);
        return shouldRender
            ? _buildPasscodeField(
                context,
                state,
              ) // Show passcode field if shouldRender is true
            : const SizedBox.shrink();
      },
    );
  }

  /// Builds the CustomTextField widget for the passcode input
  Widget _buildPasscodeField(BuildContext context, SignInState state) {
    return CustomTextField(
      key: const Key('auth_pass_code_textField'),
      controller: _controller,
      obscureText: _secureText,
      maxLines: 1,
      maxLength: 20,
      autofillHints: const [AutofillHints.password],
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onChanged: _dispatchPasscodeChangeEvent,
      onFieldSubmitted: _dispatchPasscodeChangeEvent,
      inputDecoration: _buildInputDecoration(context, state),
    );
  }

  // Builds the input decoration for the passcode field (either Temporary or regular)
  InputDecoration _buildInputDecoration(
    BuildContext context,
    SignInState state,
  ) {
    final isTemporary = _autoGenerate; // Check if it's a Temporary passcode
    final label = isTemporary ? 'Temporary Passcode' : _label;

    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.all(1.0),
      fillColor: kGrayColor.withAlpha((0.1 * 255).toInt()),
      hintText: isTemporary ? null : label,
      label: Text(label, semanticsLabel: label),
      helperText: isTemporary ? helperText : null,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: true,
      prefixIcon: Icon(isTemporary ? Icons.pin : Icons.lock, size: 15),
      errorText: state.password.displayError != null ? 'Invalid $label' : null,
      suffixIcon: isTemporary
          ? SizedBox(
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _toggleVisibility(),
                  context.elevatedButton(
                    'Generate',
                    tooltip: helperText,
                    color: kLightColor,
                    bgColor: kDangerColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () => setState(
                      () => _controller.text = _generateTemporaryPasscode(),
                    ),
                  ),
                ],
              ),
            )
          : _toggleVisibility(),
    );
  }

  IconButton _toggleVisibility() {
    return IconButton(
      onPressed: showHide,
      icon: Icon(
        _secureText ? Icons.visibility_off : Icons.visibility,
        color: _secureText ? kGrayColor : kTextColor,
        semanticLabel: 'visibility icon',
      ),
    );
  }

  // Dispatches the PasscodeChanged event to the SignInBloc with the updated passcode
  void _dispatchPasscodeChangeEvent(String passcode) {
    context.read<SignInBloc>().add(
      PasscodeChanged(passcode.trim()),
    ); // Update the passcode in the state
  }
}
*/

/*
// Employee Button
class EmployeeSignInButton extends StatelessWidget {
  const EmployeeSignInButton({super.key, this.onChanged});

  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return _buildButton(
          context,
          inProgress: state.status.isInProgress,
          onPress: (state.email.isValid && state.password.isValid)
              ? () => context.read<SignInBloc>().add(EmployeeSignInRequested())
              : null,
        );
      },
    );
  }

  _buildButton(
    BuildContext context, {
    bool inProgress = false,
    required void Function()? onPress,
  }) => context.confirmableActionButton(
    label: inProgress ? "Please wait..." : "Sign In",
    onPressed: onPress,
  );
}

// Change Employee TemporaryPasscode Button
class ChangeEmployeeTemporaryPasscodeButton extends StatelessWidget {
  const ChangeEmployeeTemporaryPasscodeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return _buildButton(
          context,
          inProgress: state.status.isInProgress,
          onPress: state.passcode.isValid
              ? () {
                  context.read<SignInBloc>().add(
                    ChangeTemporaryPasscodeRequested(),
                  );
                }
              : null,
        );
      },
    );
  }

  _buildButton(
    BuildContext context, {
    bool inProgress = false,
    required void Function()? onPress,
  }) => context.confirmableActionButton(
    label: inProgress ? "Please wait..." : "Create New Password",
    onPressed: onPress,
  );
}*/
