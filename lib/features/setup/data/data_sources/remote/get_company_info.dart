import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/data/models/company_info_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company_info/company_info_bloc.dart';
import 'package:flutter/material.dart';

class GetCompanyInfo {
  static CompanyInfo? internalCache;

  static Future<CompanyInfo?> load() async {
    if(internalCache!=null && internalCache!.isNotEmpty){
      // Return cache if notEmpty
      return internalCache;
    }

    // Load all data initially to pass to the search delegate
    final info = CompanyInfoBloc(firestore: FirebaseFirestore.instance).stream;

    try {
      // Wait for the first occurrence of the InfoLoadedState<CompanyInfo> state
      final state = await info.firstWhere(
            (state) => state is SetupLoaded<CompanyInfo>,
      ) as SetupLoaded<CompanyInfo>;

      // Check if data is not empty and return the first item if available
      if (state.data.isNotEmpty) {
        // debugPrint('steve-today ${state.data.first}');
        internalCache = state.data.first;
        return state.data.first;
      } else {
        // Handle the case when data is empty
        // debugPrint('No data available');
        return CompanyInfo.notFound; // Or handle as appropriate for your use case
      }
    } catch (e) {
      // Handle potential errors
      debugPrint('Error occurred: $e');
      return CompanyInfo.notFound; // Or handle the error appropriately
    }
  }


  /*static Future<CompanyInfo?> load2() async {
    // Load all data initially to pass to the search delegate
    final info =  CompanyInfoBloc(firestore: FirebaseFirestore.instance).stream;

    // Ensure to wait for the data to be loaded
    // Wait for the first occurrence of the InfoLoadedState<CompanyInfo> state
    final state = await info.firstWhere(
          (state) => state is InfoLoadedState<CompanyInfo>,
    ) as InfoLoadedState<CompanyInfo>;

    return state.data.isEmpty? null : state.data.first;
  }*/
}


