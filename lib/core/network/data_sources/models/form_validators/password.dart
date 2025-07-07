import 'package:formz/formz.dart';
import 'package:assign_erp/core/constants/app_constant.dart';

enum PasswordValidationError { invalid }

class Password extends FormzInput<String, PasswordValidationError> {
  /// {@macro password}
  const Password.pure() : super.pure('');
  /// {@macro password}
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String? value) {
    return passwordRegExp.hasMatch(value ?? '')
        ? null
        : PasswordValidationError.invalid;
  }

}