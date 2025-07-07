import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_status_enum.dart';
import 'package:assign_erp/features/index.dart';
import 'package:assign_erp/features/live_support/presentation/bloc/index.dart';
import 'package:assign_erp/features/setup/data/models/company_info_model.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required FirebaseFirestore fireStore,
    required AuthRepository authRepo,
  }) : _fireStore = fireStore,
       _authRepo = authRepo;

  final FirebaseFirestore _fireStore;
  final AuthRepository _authRepo;

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    /// Retrieves the default theme for the platform
    TextTheme textTheme = Theme.of(context).textTheme;

    ///NOTE:: Use with Google Fonts package to use downloadable fonts
    // TextTheme textTheme = createTextTheme(context, "Roboto", "Playfair Display");

    MaterialTheme theme = MaterialTheme(textTheme);

    final blocProviders = [
      _bloc<AuthBloc>(() => AuthBloc(authRepository: _authRepo)),
      _bloc<CompanyInfoBloc>(
        () => CompanyInfoBloc(firestore: _fireStore)
          ..add(GetSetup<CompanyInfo>()) /* Get Setup data on app startup */,
      ),
      _bloc<CompanyStoreBloc>(() => CompanyStoreBloc(firestore: _fireStore)),
      _bloc<CategoryBloc>(() => CategoryBloc(firestore: _fireStore)),
      _bloc<SupplierBloc>(() => SupplierBloc(firestore: _fireStore)),
      _bloc<EmployeeBloc>(() => EmployeeBloc(firestore: _fireStore)),
      _bloc<ProductBloc>(() => ProductBloc(firestore: _fireStore)),
      _bloc<OrderBloc>(() => OrderBloc(firestore: _fireStore)),
      _bloc<PurchaseOrderBloc>(() => PurchaseOrderBloc(firestore: _fireStore)),
      _bloc<MiscOrderBloc>(() => MiscOrderBloc(firestore: _fireStore)),
      _bloc<DeliveryBloc>(() => DeliveryBloc(firestore: _fireStore)),
      _bloc<SaleBloc>(() => SaleBloc(firestore: _fireStore)),
      _bloc<RequestForQuotationBloc>(
        () => RequestForQuotationBloc(firestore: _fireStore),
      ),
      _bloc<CustomerAccountBloc>(
        () => CustomerAccountBloc(firestore: _fireStore),
      ),
      _bloc<POSSaleBloc>(() => POSSaleBloc(firestore: _fireStore)),
      _bloc<POSOrderBloc>(() => POSOrderBloc(firestore: _fireStore)),
      _bloc<AgentClientBloc>(() => AgentClientBloc(firestore: _fireStore)),
      _bloc<MyAgentBloc>(() => MyAgentBloc(firestore: _fireStore)),
      // Software User Manual BlocProvider
      _bloc<HowToBloc>(() => HowToBloc(firestore: _fireStore)),
      // Live Support/Chat BlocProvider
      _bloc<ChatBloc>(() => ChatBloc(firestore: _fireStore)),
      _bloc<ChatOverviewBloc>(() => ChatOverviewBloc(firestore: _fireStore)),
    ];

    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: _authRepo)],
      child: MultiBlocProvider(
        providers: blocProviders,
        child: _AppView(
          theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        ),
      ),
    );
  }

  /// Creates a [BlocProvider] for a BLoC of type [T].
  ///
  /// The [create] function is responsible for instantiating the BLoC.
  /// It does not receive a [BuildContext].
  BlocProvider<T> _bloc<T extends StateStreamableSource<Object?>>(
    T Function() create,
  ) => BlocProvider<T>(create: (BuildContext context) => create());
}

class _AppView extends StatelessWidget {
  final ThemeData theme;

  const _AppView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: appName.replaceAll('.', ' '),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: theme,
      builder: (_, child) => _authStateChangesListener(child),
    );
  }

  BlocListener<AuthBloc, AuthState> _authStateChangesListener(Widget? child) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (_, state) {
        final route = _determineRouteFromState(state);
        if (route != null) {
          appRouter.go(route);
        }
      },
      child: child,
    );
  }

  String? _determineRouteFromState(AuthState state) {
    switch (state.authStatus) {
      case AuthStatusEnum.workspaceAuthenticated:
        return state.workspace != null ? '/${RouteNames.employeeSignIn}' : '/';

      case AuthStatusEnum.authenticated:
        if (state.workspace != null) {
          return state.employee != null
              ? '/${RouteNames.mainDashboard}'
              : '/${RouteNames.employeeSignIn}';
        }
        return null;

      case AuthStatusEnum.unauthenticated:
        return '/';

      case AuthStatusEnum.hasTemporalPasscode:
        return '/${RouteNames.changeTemporalPasscode}';

      case AuthStatusEnum.emailNotVerified:
        return '/${RouteNames.verifyWorkspaceEmail}';

      default:
        // Handle unexpected cases by returning null
        return null;
    }
  }
}

/* var blocProviders = [
      /// Auth BlocProvider
      BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: _authRepo)),

      /// Setup BlocProvider
      BlocProvider<CompanyInfoBloc>(
          create: (_) =>
              CompanyInfoBloc(firestore: _firestore)..add(GetSetup())),
      BlocProvider<CompanyStoreBloc>(
          create: (_) => CompanyStoreBloc(firestore: _firestore)),
      BlocProvider<CategoryBloc>(
          create: (_) => CategoryBloc(firestore: _firestore)),
      BlocProvider<SupplierBloc>(
          create: (_) => SupplierBloc(firestore: _firestore)),
      BlocProvider<EmployeeBloc>(
          create: (_) => EmployeeBloc(firestore: _firestore)),

      /// Inventory BlocProvider
      BlocProvider<ProductBloc>(
          create: (_) => ProductBloc(firestore: _firestore)),
      BlocProvider<OrderBloc>(create: (_) => OrderBloc(firestore: _firestore)),
      BlocProvider<PurchaseOrderBloc>(
        create: (_) => PurchaseOrderBloc(firestore: _firestore),
      ),
      BlocProvider<MiscOrderBloc>(
          create: (_) => MiscOrderBloc(firestore: _firestore)),
      BlocProvider<DeliveryBloc>(
          create: (_) => DeliveryBloc(firestore: _firestore)),
      BlocProvider<SaleBloc>(create: (_) => SaleBloc(firestore: _firestore)),
      BlocProvider<RequestForQuotationBloc>(
        create: (_) => RequestForQuotationBloc(firestore: _firestore),
      ),

      /// CRM BlocProvider
      BlocProvider<CustomerAccountBloc>(
          create: (_) => CustomerAccountBloc(firestore: _firestore)),

      /// P.O.S BlocProvider
      BlocProvider<POSSaleBloc>(
          create: (_) => POSSaleBloc(firestore: _firestore)),
      BlocProvider<POSOrderBloc>(
          create: (_) => POSOrderBloc(firestore: _firestore)),

      /// Clientele BlocProvider
      BlocProvider<AgentBloc>(create: (_) => AgentBloc(firestore: _firestore)),
    ];


    // Option-2
    final firestoreBlocs = <BlocProvider Function()>[
      () => BlocProvider(create: (_) => CompanyInfoBloc(firestore: _firestore)..add(GetSetup())),
      () => BlocProvider(create: (_) => CompanyStoreBloc(firestore: _firestore)),
      () => BlocProvider(create: (_) => CategoryBloc(firestore: _firestore)),
      // Add others here...
    ];

    final blocProviders = [
      BlocProvider(create: (_) => AuthBloc(authRepository: _authRepo)),
      ...firestoreBlocs.map((builder) => builder()),
    ];
    */

/* var repoProviders = [
      RepositoryProvider.value(value: _authRepo),
      RepositoryProvider.value(value: _usersRepo),
      RepositoryProvider.value(value: _companyInfoRepo),
      RepositoryProvider.value(value: _productsRepo),
      RepositoryProvider.value(value: _ordersRepo),
      RepositoryProvider.value(value: _deliveriesRepo),
      RepositoryProvider.value(value: _salesRepo),
      RepositoryProvider.value(value: _purchaseOrdersRepo),
      RepositoryProvider.value(value: _requestForQuoteRepo),
      RepositoryProvider.value(value: _miscOrdersRepo),
      RepositoryProvider.value(value: _companyStoresRepo),
      // RepositoryProvider.value(value: _employeeRepo),
      RepositoryProvider.value(value: _customersRepo),
      RepositoryProvider.value(value: _supplierRepo),
      RepositoryProvider.value(value: _posSaleRepo),
      RepositoryProvider.value(value: _posOrderRepo),
    ];
    /////
    required DataRepository employeeRepo,
    required DataRepository productsRepo,
    required DataRepository ordersRepo,
    required DataRepository miscOrdersRepo,
    required DataRepository purchaseOrdersRepo,
    required DataRepository deliveriesRepo,
    required DataRepository salesRepo,
    required DataRepository customersRepo,
    required DataRepository companyStoresRepo,
    required DataRepository companyInfoRepo,
    required DataRepository supplierRepo,
    required DataRepository requestForQuoteRepo,
    required DataRepository posSaleRepo,
    required DataRepository posOrderRepo,

    /////
    _employeeRepo = employeeRepo,
    _productsRepo = productsRepo,
    _ordersRepo = ordersRepo,
    _miscOrdersRepo = miscOrdersRepo,
    _purchaseOrdersRepo = purchaseOrdersRepo,
    _deliveriesRepo = deliveriesRepo,
    _salesRepo = salesRepo,
    _customersRepo = customersRepo,
    _companyStoresRepo = companyStoresRepo,
    _companyInfoRepo = companyInfoRepo,
    _requestForQuoteRepo = requestForQuoteRepo,
    _posSaleRepo = posSaleRepo,
    _posOrderRepo = posOrderRepo,
    _supplierRepo = supplierRepo;

    /////
    final DataRepository _employeeRepo;
    final DataRepository _productsRepo;
    final DataRepository _ordersRepo;
    final DataRepository _miscOrdersRepo;
    final DataRepository _purchaseOrdersRepo;
    final DataRepository _deliveriesRepo;
    final DataRepository _salesRepo;
    final DataRepository _customersRepo;
    final DataRepository _companyStoresRepo;
    final DataRepository _companyInfoRepo;
    final DataRepository _supplierRepo;
    final DataRepository _requestForQuoteRepo;
    final DataRepository _posSaleRepo;
    final DataRepository _posOrderRepo;
    */

/* class _AppView extends StatefulWidget {
  final ThemeData theme;

  const _AppView({required this.theme});

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState? get _navigator => _navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    return _buildMaterialApp();
  }


  _buildMaterialApp() {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: appName.replaceAll('.', ' '),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: widget.theme,
      onGenerateRoute: AppRoutes.onGenerateRoutes,
      builder: (_, child) => _buildBlocListener(child),
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
      },
    );
  }

  BlocListener<AuthBloc, AuthState> _buildBlocListener(Widget? child) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (_, state) {
        if (state is AuthAuthenticated) {

          if (state.employeeUser != null) {
            _navigator?.pushNamedAndRemoveUntil(
                RouteNames.mainDashboard, (route) => false);
          } else {
            _navigator?.pushNamedAndRemoveUntil(
                RouteNames.employeeSignIn, (route) => false);
          }
        }
        if (state is AuthUnauthenticated) {

          _navigator?.pushNamedAndRemoveUntil(
              RouteNames.onBoarding, (route) => false);
        }
        if (state is AuthEmailNotVerified) {
          _navigator?.pushNamedAndRemoveUntil(
              RouteNames.verifyWorkspaceEmail, (route) => false);
        }
      },
      child: child,
    );
  }
}*/
