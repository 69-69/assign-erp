import 'package:assign_erp/core/util/str_util.dart';
import 'package:formz/formz.dart';

enum NameValidationError { invalid }

class Name extends FormzInput<String, NameValidationError> {
  const Name.pure() : super.pure('');

  const Name.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String? value) {

    return value.isFullName ? null : NameValidationError.invalid;
  }
}
