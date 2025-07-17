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

enum WorkspaceCategoryValidationError { invalid }

class WorkspaceCategory
    extends FormzInput<String, WorkspaceCategoryValidationError> {
  const WorkspaceCategory.pure() : super.pure('');

  const WorkspaceCategory.dirty([super.value = '']) : super.dirty();

  @override
  WorkspaceCategoryValidationError? validator(String? value) {
    return value.isNullOrEmpty
        ? WorkspaceCategoryValidationError.invalid
        : null;
  }
}
