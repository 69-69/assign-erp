import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/features/setup/data/models/attendance_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';

class AttendanceBloc extends SetupBloc<Attendance> {
  AttendanceBloc({required super.firestore})
    : super(
        collectionPath: employeeSessionLogsCollectionPath,
        fromFirestore: (data, id) => Attendance.fromMap(data, id: id),
        toFirestore: (log) => log.toMap(),
        toCache: (log) => log.toCache(),
      );
}
