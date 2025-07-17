// ---------------------------
// ⚙️ Account Status Definitions
// ---------------------------

enum AccountStatus { enabled, disabled }

/* USAGE:
* final status = AccountStatus.enabled;
* print(status.label); // Output: enable
* */
extension AccountStatusExtension on AccountStatus {
  String get label {
    return switch (this) {
      AccountStatus.enabled => 'enable',
      AccountStatus.disabled => 'disable',
    };
  }
}

final accountStatusList = AccountStatus.values.map((e) => e.label).toList();

final workspaceStatusList = [
  'workspace status',
  ...AccountStatus.values.map((e) => e.label),
];

final employeeAccountStatusList = [
  'account status',
  ...AccountStatus.values.map((e) => e.label),
];

// ---------------------------
// 🔐 Authentication & Temporary Passcode
// ---------------------------

/// Current year used for passcode generation
final _currentYear = DateTime.now().year;

/// Temporary weak passcode (valid for 1 week).
/// A temporary weak passcode used for initial sign-in (Employee SignIn only).
/// When an employee signs in using [temporalWeakPasscode], they will be prompted
/// to create a new, permanent passcode or password.
final temporalWeakPasscode = 'Assign@$_currentYear';

/// 🏬 Default (Main) company store/shop ID for multi-stores locations
const mainStore = 'main';
