import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/constants/collection_type_enum.dart';
import 'package:assign_erp/features/user_guide/data/models/user_guide_model.dart';
import 'package:assign_erp/features/user_guide/presentation/bloc/user_guide_bloc.dart';

class HowToBloc extends GuideBloc<UserGuide> {
  HowToBloc({required super.firestore})
    : super(
        collectionType: CollectionType.global,
        collectionPath: userGuideDBCollectionPath,
        fromFirestore: (data, id) => UserGuide.fromMap(data, id: id),
        toFirestore: (guide) => guide.toMap(),
        toCache: (guide) => guide.toCache(),
      );
}
