import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/constants/hosting_type.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/util/date_time_picker.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
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
          items: workspaceRolesToList(),
          labelText: 'workspace role',
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
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (previous, current) =>
          previous.workspaceCategory != current.workspaceCategory,
      builder: (_, state) => _buildBody(context, state),
    );
  }

  CustomDropdown _buildBody(BuildContext context, SignInState state) {
    return CustomDropdown(
      items: worspaceCategories,
      labelText: 'Workspace category',
      serverValue: serverEntity,
      onValueChange: (String? v) {
        if (v != null) {
          context.read<SignInBloc>().add(WorkspaceCategoryChanged(v.trim()));
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
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (previous, current) =>
          (previous.workspaceCategory != current.workspaceCategory) ||
          previous.workspaceName != current.workspaceName,
      builder: (cxt, state) => state.workspaceCategory.isValid
          ? _workspaceNameFormField(cxt, state)
          : const SizedBox.shrink(),
    );
  }

  _workspaceNameFormField(BuildContext context, SignInState state) {
    return CustomTextField(
      key: const Key('reg_Workspace_name_Form_Input_textField'),
      keyboardType: TextInputType.text,
      onChanged: (name) =>
          context.read<SignInBloc>().add(WorkspaceNameChanged(name.trim())),
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
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (previous, current) =>
          (previous.workspaceName != current.workspaceName) ||
          previous.clientName != current.clientName,
      builder: (cxt, state) => state.workspaceName.isValid
          ? _nameFormField(cxt, state)
          : const SizedBox.shrink(),
    );
  }

  _nameFormField(BuildContext context, SignInState state) {
    return CustomTextField(
      key: const Key('reg_client_name_Form_Input_textField'),
      keyboardType: TextInputType.name,
      autofillHints: const [AutofillHints.name],
      onChanged: (clientName) =>
          context.read<SignInBloc>().add(ClientNameChanged(clientName.trim())),
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
    return BlocBuilder<SignInBloc, SignInState>(
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

  _mobileFormField(BuildContext context, SignInState state) {
    return CustomTextField(
      key: const Key('reg_name_Form_Input_textField'),
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      onChanged: (number) =>
          context.read<SignInBloc>().add(SignInMobileChanged(number.trim())),
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

  BlocBuilder<SignInBloc, SignInState> _buildCheck() {
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (prev, cur) =>
          (prev.mobileNumber != cur.mobileNumber) || prev.email != cur.email,
      builder: (context, state) => state.mobileNumber.isValid
          ? _emailFormField(context, state)
          : const SizedBox.shrink(),
    );
  }

  BlocBuilder<SignInBloc, SignInState> _buildNoCheck() {
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (prev, cur) => prev.email != cur.email,
      builder: (context, state) => _emailFormField(context, state),
    );
  }

  _emailFormField(BuildContext context, SignInState state) {
    return CustomTextField(
      key: const Key('sign_inForm_emailInput_textField'),
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      onChanged: (email) =>
          context.read<SignInBloc>().add(SignInEmailChanged(email.trim())),
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

// Password
class PasswordInput extends StatefulWidget {
  final String label;

  /// Check if email is valid before showing Password Input Field [checkEmail]
  final bool checkEmail;

  const PasswordInput({
    super.key,
    this.label = 'Workspace password',
    this.checkEmail = true,
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
    return widget.checkEmail ? _buildCheck() : _buildNoCheck();
  }

  BlocBuilder<SignInBloc, SignInState> _buildCheck() {
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (prev, cur) =>
          (prev.email != cur.email) || (prev.password != cur.password),
      builder: (context, state) => state.email.isValid
          ? _passwordFormField(context, state)
          : const SizedBox.shrink(),
    );
  }

  BlocBuilder<SignInBloc, SignInState> _buildNoCheck() {
    return BlocBuilder<SignInBloc, SignInState>(
      buildWhen: (prev, cur) => prev.password != cur.password,
      builder: (context, state) => _passwordFormField(context, state),
    );
  }

  _passwordFormField(BuildContext context, SignInState state) {
    return CustomTextField(
      key: const Key('auth_Form_passwordInput_textField'),
      maxLines: 1,
      maxLength: 20,
      obscureText: _secureText,
      autofillHints: const [AutofillHints.password],
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (password) {
        // onSubmit trigger button Click/Press
        dispatchPasswordChangeEvent(password.trim());
      },
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
    context.read<SignInBloc>().add(SignInPasswordChanged(password.trim()));
  }
}

// Workspace Button
class WorkspaceSignInButton extends StatelessWidget {
  const WorkspaceSignInButton({super.key, required this.onPressed});

  final Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return _buildButton(
          context,
          inProgress: state.status.isInProgress,
          onPress: (state.email.isValid && state.password.isValid)
              ? () {
                  onPressed.call(true);
                  context.read<SignInBloc>().add(WorkspaceSignInRequested());
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
  }) => context.elevatedBtn(
    label: inProgress ? "Please wait..." : "Sign In",
    onPressed: onPress,
  );
}

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
  }) => context.elevatedBtn(
    label: inProgress ? "Please wait..." : "Sign In",
    onPressed: onPress,
  );
}

// Change Employee TemporalPasscode Button
class ChangeEmployeeTemporalPasscodeButton extends StatelessWidget {
  const ChangeEmployeeTemporalPasscodeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return _buildButton(
          context,
          inProgress: state.status.isInProgress,
          onPress: state.password.isValid
              ? () {
                  context.read<SignInBloc>().add(
                    ChangeTemporalPasscodeRequested(),
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
  }) => context.elevatedBtn(
    label: inProgress ? "Please wait..." : "Create New Password",
    onPressed: onPress,
  );
}

class SignUpButton extends StatelessWidget {
  const SignUpButton({super.key, required this.onPressed});

  final Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
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
      Future.delayed(kFAnimateDuration, () async {
        if (context.mounted) {
          onPressed.call(true);
          context.read<SignInBloc>().add(CreateWorkspaceRequested());
        }
      });

  _buildButton(
    BuildContext context, {
    bool inProgress = false,
    required void Function()? onPress,
  }) => context.elevatedBtn(
    label: inProgress ? "Please wait..." : "Setup New  Workspace",
    onPressed: onPress,
  );
}

class UpdateWorkspacePasswordButton extends StatelessWidget {
  const UpdateWorkspacePasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
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
      Future.delayed(wAnimateDuration, () async {
        if (context.mounted) {
          context.read<SignInBloc>().add(UpdateWorkspacePasswordRequested());
        }
      });

  _buildButton(
    BuildContext context, {
    bool inProgress = false,
    required void Function()? onPress,
  }) => context.elevatedBtn(
    label: inProgress ? "Updating..." : "Change Workspace Password",
    onPressed: onPress,
  );
}

class ForgotWorkspacePasswordButton extends StatelessWidget {
  const ForgotWorkspacePasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return _buildButton(
          context,
          inProgress: state.status.isInProgress,
          onPress: state.email.isValid
              ? () => context.read<SignInBloc>().add(
                  WorkspacePasswordRecoveryRequested(),
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
  }) => context.elevatedBtn(
    label: inProgress ? "Please wait..." : "Send Reset Link",
    onPressed: onPress,
  );
}
