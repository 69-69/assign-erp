import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';

class ProductBloc extends InventoryBloc<Product> {

  ProductBloc({required super.firestore})
      : super(
          collectionPath: productsDBCollectionPath,
          fromFirestore: (data, id) => Product.fromMap(data, id),
          toFirestore: (product) => product.toMap(),
          toCache: (product) => product.toCache(),
        );
/*final DataRepository _dataRepository;

  ProductBloc({required DataRepository dataRepository})
      : _dataRepository = dataRepository,
        super(
          dataRepository: dataRepository,
          collectionPath: productsDBCollectionPath,
          fromFirestore: (data, id) => Product.fromMap(data, id),
          toFirestore: (product) => product.toMap(),
          toCache: (product) => product.toCache(),
        );*/
}
