import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/debug_printify.dart';
import 'package:assign_erp/core/util/secret_hasher.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/bottom_sheet_header.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_dialog.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_acc/employee_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/staff_account/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension ForgotPasscodeDialog on BuildContext {
  Future<void> openForgotPasscode({required Employee employee}) =>
      showModalBottomSheet(
        context: this,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: kTransparentColor,
        builder: (_) => ForgotPasscode(employee: employee),
      );
}

class ForgotPasscode extends StatefulWidget {
  final Employee employee;
  const ForgotPasscode({super.key, required this.employee});

  @override
  State<ForgotPasscode> createState() => _ForgotPasscodeState();
}

class _ForgotPasscodeState extends State<ForgotPasscode> {
  final _formKey = GlobalKey<FormState>();
  final _passcodeController = TextEditingController();
  Employee get _employee => widget.employee;

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildAlertDialog(context),
    );
  }

  _buildAlertDialog(BuildContext context) {
    return CustomDialog(
      title: DialogTitle(
        title: 'Reset Passcode',
        subtitle: "This is a One-time Passcode",
      ),
      body: _buildFormBody(context),
      actions: [
        context.confirmableActionButton(
          label: 'Copy & Use Passcode',
          onPressed: _onSubmit,
        ),
      ],
    );
  }

  _buildFormBody(BuildContext context) {
    return Container(
      width: context.screenWidth,
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        trailing: const Icon(Icons.info_outline),
        title: Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            "Resets ${_employee.fullName.toTitleCase}'s account passcode to a temporary one. "
            "After signing in with this passcode, they will be required to create a new, secure passcode",
            // 'Use this at Employee Sign-In. After signing in with this passcode, you’ll be prompted to create your preferred passcode.',
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.bodyMedium,
          ),
        ),
        // Shows the passcode field wrapped in a BlocBuilder
        subtitle: TemporaryPasscode(
          controller: _passcodeController,
          onChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
      ),
    );
  }

  _onSubmit() async {
    await context.progressBarDialog(
      child: Text(
        "Your passcode has been reset to a temporary one. "
        "After signing in, you'll be required to create a new, secure passcode.",
        textAlign: TextAlign.center,
      ),
      request: _processPasscodeReset(),
      onSuccess: (_) =>
          context.showAlertOverlay('Copied & Passcode Reset successful'),
      onError: (error) => context.showAlertOverlay(
        'Passcode Reset failed',
        bgColor: kDangerColor,
      ),
    );
  }

  Future<void> _processPasscodeReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      final passcode = _passcodeController.text;

      await context.toClipboard(passcode); // Copy to clipboard
      final hashed = SecretHasher.hash(passcode);

      prettyPrint('data ', passcode);

      if (mounted) {
        context.read<EmployeeBloc>().add(
          UpdateSetup<Employee>(
            documentId: _employee.id,
            mapData: {'passCode': hashed},
          ),
        );

        // ✅ Simulate processing delay so dialog shows long enough
        await Future.delayed(kFProgressDelay);

        if (mounted) {
          context.read<AuthBloc>().add(AuthSignOutRequested());
        }
      }
    }
  }
}
