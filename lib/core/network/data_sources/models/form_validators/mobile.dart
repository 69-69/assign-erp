import 'package:formz/formz.dart';

enum MobileNumberValidationError { invalid }

class MobileNumber extends FormzInput<String, MobileNumberValidationError> {
  const MobileNumber.pure() : super.pure('');

  const MobileNumber.dirty([super.value = '']) : super.dirty();

  @override
  MobileNumberValidationError? validator(String? value) {
    return int.tryParse(value ?? '')!=null && value!.length >= 10
        ? null
        : MobileNumberValidationError.invalid;
  }
}
