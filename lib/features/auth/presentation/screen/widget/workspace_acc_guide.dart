import 'package:assign_erp/core/widgets/text_to_speech.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/guide_desc.dart';
import 'package:flutter/material.dart';

class WorkspaceGuide extends StatelessWidget {
  final bool isWorkspace;
  final bool isForgotPassword;

  const WorkspaceGuide({
    super.key,
    required this.isWorkspace,
    this.isForgotPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      padding: const EdgeInsets.only(bottom: 100),
      child: isForgotPassword
          ? const _GuideToWorkspaceResetPassword()
          : (isWorkspace
                ? const _GuideToClientWorkspace()
                : const _EmployeeSignInGuide()),
    );
  }
}

class _GuideToClientWorkspace extends StatelessWidget {
  const _GuideToClientWorkspace();

  @override
  Widget build(BuildContext context) {
    return TextToSpeech(
      title: 'Setup Workspace for Client',
      subTitle: 'Guide to Client Workspace',
      guides: signInSteps,
    );
  }
}

class _EmployeeSignInGuide extends StatelessWidget {
  const _EmployeeSignInGuide();

  @override
  Widget build(BuildContext context) {
    return TextToSpeech(
      title: 'Sign-In Guide',
      subTitle: 'Employee Sign-In Instructions',
      guides: signInSteps,
    );
  }
}

class _GuideToWorkspaceResetPassword extends StatelessWidget {
  const _GuideToWorkspaceResetPassword();

  @override
  Widget build(BuildContext context) {
    return TextToSpeech(
      title: 'Reset Password Guide',
      subTitle: 'Workspace: Forgot Password Instructions',
      guides: resetSteps,
    );
  }
}
