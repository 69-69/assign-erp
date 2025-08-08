import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/network/data_sources/remote/bloc/firestore_bloc.dart';
import 'package:assign_erp/core/network/data_sources/remote/bloc/short_id_bloc.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/features/inventory_ims/data/models/short_id_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

extension GenerateUID on String {
  static final _dbCollectionPaths = {
    'user': workspaceAccDBCollectionPath,
    'product': productsDBCollectionPath,
    'order': ordersDBCollectionPath,
    'purchase': purchaseOrdersDBCollectionPath,
    'misc': miscOrdersDBCollectionPath,
    'rfq': requestPriceQuoteDBCollectionPath,
    'sale': salesDBCollectionPath,
    'delivery': deliveryDBCollectionPath,
    'invoice': invoiceDBCollectionPath,
    'customer': customersDBCollectionPath,
    'store': companyStoreDBCollectionPath,
    'pOrder': posOrdersDBCollectionPath,
    'pSale': posSalesDBCollectionPath,
  };

  String get _dbCollectionPath => _dbCollectionPaths[this] ?? 'unknownPath';

  Future<String> _checkReturn() async {
    final shortIdBloc = ShortIDBloc(
      _dbCollectionPath,
      firestore: FirebaseFirestore.instance,
    );
    shortIdBloc.add(GetShortID<ShortUID>());

    final allData =
        await shortIdBloc.stream.firstWhere(
              (state) => state is SingleDataLoaded<ShortUID>,
            )
            as SingleDataLoaded<ShortUID>;

    return allData.data.shortId;
  }

  Future<String?> _generateAndHandleId({Function(String)? onChanged}) async {
    final newId = await _checkReturn();

    if (newId.isNotEmpty) {
      final prefix = isNotEmpty ? substring(0, 3).toUpperCaseAll : '';
      final formattedId = '$prefix-$newId';

      if (onChanged != null) {
        onChanged(formattedId);
      } else {
        return formattedId;
      }
    }
    return null;
  }

  Future<String?> getShortStr() async => _generateAndHandleId();

  Future<void> getShortUID({required Function(String) onChanged}) async =>
      await _generateAndHandleId(onChanged: onChanged);

  /*String get _replaceSpecialCharsWithRandomNumbers {
    // Create a random number generator
    final Random random = Random();

    // Define a regular expression to match non-alphanumeric characters
    RegExp regExp = RegExp(r'[^a-zA-Z0-9]');

    // Use a function to replace matches with random numbers
    String result = replaceAllMapped(regExp, (Match match) {
      return random.nextInt(10).toString();
    });

    return result;
  }*/
}
