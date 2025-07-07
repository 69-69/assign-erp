import 'package:assign_erp/features/auth/domain/repository/auth_repository.dart';
import 'package:assign_erp/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

storeSwitcher(BuildContext context, {required String storeNumber}) {
  final signInBloc = SignInBloc(
    authRepository: RepositoryProvider.of<AuthRepository>(context),
  );

  signInBloc.add(SwitchStoresRequested(storeNumber: storeNumber));
}
