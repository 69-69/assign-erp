import 'package:assign_erp/core/util/str_util.dart';
import 'package:formz/formz.dart';

enum WorkspaceNameValidationError { invalid }

class WorkspaceName extends FormzInput<String, WorkspaceNameValidationError> {
  const WorkspaceName.pure() : super.pure('');

  const WorkspaceName.dirty([super.value = '']) : super.dirty();

  @override
  WorkspaceNameValidationError? validator(String? value) {
    return value.isNullOrEmpty ? WorkspaceNameValidationError.invalid : null;
  }
}

enum CompanyCategoryValidationError { invalid }

class CompanyCategory
    extends FormzInput<String, CompanyCategoryValidationError> {
  const CompanyCategory.pure() : super.pure('');

  const CompanyCategory.dirty([super.value = '']) : super.dirty();

  @override
  CompanyCategoryValidationError? validator(String? value) {
    return value.isNullOrEmpty ? CompanyCategoryValidationError.invalid : null;
  }
}
