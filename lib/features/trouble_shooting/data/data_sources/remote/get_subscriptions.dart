import 'package:assign_erp/features/trouble_shooting/data/models/subscription_model.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/bloc/tenant_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetSubscriptions {
  static Future<List<Subscription>> load() async {
    // Ensure to wait for the data to be loaded
    final state =
        await SubscriptionBloc(
              firestore: FirebaseFirestore.instance,
            ).stream.firstWhere((state) => state is TenantsLoaded<Subscription>)
            as TenantsLoaded<Subscription>;

    return state.data.isEmpty ? [] : state.data;
  }
}
