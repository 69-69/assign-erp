import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/customer_crm/data/models/customer_model.dart';
import 'package:assign_erp/features/customer_crm/presentation/bloc/create_acc/customer_acc_bloc.dart';
import 'package:assign_erp/features/customer_crm/presentation/bloc/customer_bloc.dart';
import 'package:assign_erp/features/customer_crm/presentation/screen/customers/add/add_customer.dart';
import 'package:assign_erp/features/customer_crm/presentation/screen/customers/update/update_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// All Customers
///
class ListCustomers extends StatefulWidget {
  const ListCustomers({super.key});

  @override
  State<ListCustomers> createState() => _ListCustomersState();
}

class _ListCustomersState extends State<ListCustomers> {
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  BlocBuilder<CustomerAccountBloc, CustomerState<Customer>> _buildBody() {
    return BlocBuilder<CustomerAccountBloc, CustomerState<Customer>>(
      builder: (context, state) {
        return switch (state) {
          LoadingCustomers<Customer>() => context.loader,
          CustomerLoaded<Customer>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Add New Customer',
                    onPressed: () => context.openAddCustomer(),
                  )
                : _buildCard(context, results),
          CustomerError<Customer>(error: final error) => context.buildError(
            error,
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildCard(BuildContext context, List<Customer> customers) {
    final todayCustomers = Customer.filterCustomersByDate(customers);
    final pastCustomers = Customer.filterCustomersByDate(
      customers,
      isSameDay: false,
    );

    return DynamicDataTable(
      skip: true,
      toggleHideID: true,
      headers: Customer.dataTableHeader,
      anyWidget: _buildAnyWidget(customers),
      rows: todayCustomers.map((o) => o.itemAsList()).toList(),
      childrenRow: pastCustomers.map((o) => o.itemAsList()).toList(),
      onEditTap: (row) async => await _onEditTap(context, customers, row),
      onDeleteTap: (row) async => await _onDeleteTap(customers, row),
    );
  }

  _buildAnyWidget(List<Customer> customers) {
    return context.buildTotalItems(
      'Refresh Customers',
      label: 'Customers',
      count: customers.length,
      onPressed: () {
        // Refresh Customers Data
        context.read<CustomerAccountBloc>().add(RefreshCustomers<Customer>());
      },
    );
  }

  Future<void> _onEditTap(
    BuildContext context,
    List<Customer> customers,
    List<String> row,
  ) async {
    final customer = Customer.findCustomerById(customers, row.first).first;

    await context.openUpdateCustomer(customer: customer);
  }

  Future<void> _onDeleteTap(List<Customer> customers, List<String> row) async {
    final customer = Customer.findCustomerById(customers, row.first).first;

    final isConfirmed = await context.confirmUserActionDialog();

    if (mounted && isConfirmed) {
      // Dispatch the delete event
      context.read<CustomerAccountBloc>().add(
        DeleteCustomer(documentId: customer.id),
      );
    }
  }
}
