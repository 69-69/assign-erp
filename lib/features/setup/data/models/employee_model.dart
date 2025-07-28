import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/features/setup/data/role/employee_role.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now();

/// Role-Based Access-Control [Employee]
class Employee extends Equatable {
  final String id;
  final String storeNumber;
  final String workspaceId;
  final String fullName;
  final String mobileNumber;
  final String username;

  /// Assign Roles to Users [role]
  final EmployeeRole role;
  final String email;
  final String status;

  final String passCode;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    this.id = '',
    required this.workspaceId,
    this.storeNumber = '', // fallback mainStore,
    this.username = '',
    required this.fullName,
    required this.mobileNumber,
    required this.role,
    required this.email,
    required this.status,
    this.passCode = '',
    this.createdBy = '',
    DateTime? createdAt,
    this.updatedBy = '',
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? _today,
       updatedAt = updatedAt ?? _today; // Set default value

  static const String cacheKey = 'employee_auth_cache';

  /// fromFirestore / fromJson Function [Employee.fromMap]
  factory Employee.fromMap(Map<String, dynamic> map, {String? id}) {
    return Employee(
      id: (id ?? map['id']) ?? '',
      workspaceId: map['workspaceId'] ?? '',
      storeNumber: map['storeNumber'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      username: map['username'].toString().emailToUsername,
      role: getRoleByString(map['role']),
      status: map['status'] ?? AccountStatus.disabled.label,
      passCode: map['passCode'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: toDateTimeFn(map['createdAt']),
      updatedBy: map['updatedBy'] ?? '',
      updatedAt: toDateTimeFn(map['updatedAt']),
    );
  }

  static EmployeeRole getRoleByString(String role) =>
      EmployeeRole.values.firstWhere(
        (e) => roleAsString(e) == role,
        orElse: () => EmployeeRole.unknown,
      );

  static String roleAsString(EmployeeRole e) => e.toString().split('.').last;

  // map template
  Map<String, dynamic> _mapTemp() => {
    'id': id,
    'workspaceId': workspaceId,
    'storeNumber': storeNumber,
    'username': email.emailToUsername,
    // Convert enum to string
    'role': roleAsString(role),
    'email': email,
    'fullName': fullName,
    'mobileNumber': mobileNumber,
    'passCode': passCode,
    'status': status,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedBy': updatedBy,
    'updatedAt': updatedAt,
  };

  /// Convert Employee to a map for storing in Firestore [toMap]
  Map<String, dynamic> toMap() {
    var newMap = _mapTemp();
    newMap['createdAt'] = createdAt.toISOString;
    newMap['updatedAt'] = updatedAt.toISOString;

    return newMap;
  }

  /// Convert Employee to toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var newMap = _mapTemp();
    newMap['createdAt'] = createdAt.millisecondsSinceEpoch;
    newMap['updatedAt'] = updatedAt.millisecondsSinceEpoch;

    return {'id': cacheKey, 'data': newMap};
  }

  Employee copyWith({
    String? id,
    String? storeNumber,
    String? username,
    String? fullName,
    String? mobileNumber,
    EmployeeRole? role,
    String? email,
    String? passCode,
    String? status,
    String? workspaceId,
    String? updatedBy,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      storeNumber: storeNumber ?? this.storeNumber,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      email: email ?? this.email,
      status: status ?? this.status,
      passCode: passCode ?? this.passCode,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  /// Check if 'CreatedAt' DateTime is within one week after it was created [isWithinOneWeek]
  bool isWithinOneWeek() {
    // Calculate the date and time one week from now
    DateTime oneWeekFromNow = _today.add(const Duration(days: 7));

    // Check if its greater than now/today but less than a week
    return createdAt.isAfter(_today) && createdAt.isBefore(oneWeekFromNow);
  }

  /// Verified Status [isActive]
  bool get isActive => status == AccountStatus.enabled.label;

  /// Formatted to Standard-DateTime in String [getCreatedAt]
  String get getCreatedAt => createdAt.toStandardDT;

  /// Formatted to Standard-DateTime in String [getUpdatedAt]
  String get getUpdatedAt => updatedAt.toStandardDT;

  /// Formatted to Standard-DateTime in String [getUpdatedAt]
  bool get isEmployee =>
      role != EmployeeRole.storeOwner ||
      role != EmployeeRole.developer ||
      role != EmployeeRole.tester;

  /// [findById]
  static Iterable<Employee> findById(List<Employee> employees, String id) =>
      employees.where((employee) => employee.id == id);

  static List<Employee> filterStatus(
    List<Employee> employees, {
    bool isActive = false,
  }) => employees
      .where((employee) => isActive ? employee.isActive : !employee.isActive)
      .toList();

  /// Check Permissions Based on Role
  bool canAccessAdminDashboard(Employee user) =>
      user.role == EmployeeRole.storeOwner;

  bool canEditContent(Employee user) =>
      user.role == EmployeeRole.storeOwner ||
      user.role == EmployeeRole.contentEditor;

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    role,
    email,
    username,
    fullName,
    mobileNumber,
    passCode,
    status,
    storeNumber,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
  ];

  /// ToList for PRODUCTS [itemAsList]
  List<String> itemAsList() => [
    email,
    id,
    fullName.toTitleCase,
    role.name.separateWord.toTitleCase,
    mobileNumber,
    storeNumber.toTitleCase,
    status.toTitleCase,
    getCreatedAt,
    createdBy.toTitleCase,
    updatedBy.toTitleCase,
    getUpdatedAt,
  ];

  static List<String> get dataTableHeader => const [
    'Email',
    'ID',
    'Name',
    'Role',
    'Mobile',
    'Store number',
    'Status',
    'Create At',
    'Created By',
    'Updated By',
    'Updated At',
  ];
}
