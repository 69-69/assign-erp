import 'package:equatable/equatable.dart';

class SupplierEvaluation extends Equatable {
  final String id; // Firestore ID or unique identifier
  final String supplierId;
  final String supplierName; // Optional for display
  final DateTime startDate;
  final DateTime endDate;

  final EvaluationScores scores;
  final double overallScore;

  final String comments;
  final String evaluatedBy; // userId or name
  final String evaluatorRole;

  final List<String> linkedPOIds;
  final List<String> linkedRFQIds;

  final DateTime createdAt;
  final DateTime updatedAt;

  const SupplierEvaluation({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.startDate,
    required this.endDate,
    required this.scores,
    required this.overallScore,
    required this.comments,
    required this.evaluatedBy,
    required this.evaluatorRole,
    required this.linkedPOIds,
    required this.linkedRFQIds,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    supplierId,
    supplierName,
    startDate,
    endDate,
    scores,
    overallScore,
    comments,
    evaluatedBy,
    evaluatorRole,
    linkedPOIds,
    linkedRFQIds,
    createdAt,
    updatedAt,
  ];
}

class EvaluationScores extends Equatable {
  final double deliveryTime;
  final double quality;
  final double communication;
  final double compliance;

  const EvaluationScores({
    required this.deliveryTime,
    required this.quality,
    required this.communication,
    required this.compliance,
  });

  /// Calculate average (overall) score
  double get average =>
      (deliveryTime + quality + communication + compliance) / 4;

  @override
  List<Object?> get props => [deliveryTime, quality, communication, compliance];
}

/*
## 🧩 Notes:

* `overallScore` can either be:

  * Stored explicitly (for snapshot in time), or
  * Derived from `scores.average` dynamically — up to you.
* `linkedPOIds` and `linkedRFQIds` are optional for traceability.
* You can use a **slider (1–5)** or **star widget** in UI for input.
* `evaluatedBy` and `evaluatorRole` help with accountability/audit trails.

---

## 🧠 Optional Enhancements:

* Add `evaluationType` (manual, automatic).
* Add `weight` to each category if they don't carry equal importance.
* Store `submittedAt` or `finalizedAt` for better workflow management.
*/
