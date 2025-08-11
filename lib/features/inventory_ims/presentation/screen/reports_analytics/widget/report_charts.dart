import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/product/product_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductBloc(firestore: FirebaseFirestore.instance)
            ..add(GetInventories<Product>()),
      child: CustomScrollBar(
        controller: _scrollController,
        child: _buildBody(),
      ),
    );
  }

  BlocBuilder<ProductBloc, InventoryState<Product>> _buildBody() {
    return BlocBuilder<ProductBloc, InventoryState<Product>>(
      builder: (context, state) {
        return switch (state) {
          LoadingInventory<Product>() => context.loader,
          InventoriesLoaded<Product>(data: var results) =>
            results.isEmpty
                ? context.buildNoResult()
                : _buildReportContent(context, results),
          InventoryError<Product>(error: var error) => context.buildError(
            error,
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildReportContent(BuildContext context, List<Product> products) {
    const sizedBox = SizedBox(height: 20.0);
    var height = 300.0;

    return Container(
      margin: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context, 'Inventory Status'),
          SizedBox(
            height: height,
            child: BarChart(_buildInventoryChart(products)),
          ),
          sizedBox,
          _buildTitle(context, 'Sales Report'),
          SizedBox(height: height, child: BarChart(_buildSalesChart(products))),
          sizedBox,
          _buildTitle(context, 'Turnover Rates'),
          SizedBox(
            height: height,
            child: LineChart(_buildTurnoverRateChart(products)),
          ),
          sizedBox,
          _buildTitle(context, 'Sales Forecast'),
          SizedBox(
            height: height,
            child: LineChart(_buildForecastChart(products)),
          ),
        ],
      ),
    );
  }

  _buildTitle(BuildContext context, String label) => Text(
    label,
    textAlign: TextAlign.center,
    style: context.textTheme.titleLarge?.copyWith(
      color: kPrimaryColor,
      fontWeight: FontWeight.bold,
    ),
  );

  BarChartData _buildInventoryChart(List<Product> products) {
    return BarChartData(
      barGroups: products
          .map(
            (product) => BarChartGroupData(
              x: product.name.hashCode,
              barRods: [
                BarChartRodData(
                  toY: product.quantity.toDouble(),
                  color: kLightBlueColor,
                  width: 10.0,
                ),
              ],
            ),
          )
          .toList(),
      titlesData: const FlTitlesData(show: true),
      borderData: FlBorderData(show: false),
    );
  }

  BarChartData _buildSalesChart(List<Product> products) {
    return BarChartData(
      barGroups: products
          .map(
            (product) => BarChartGroupData(
              x: product.name.hashCode,
              barRods: [
                BarChartRodData(
                  toY: product.outOfStock.toDouble(),
                  color: kSuccessColor,
                  width: 10.0,
                ),
              ],
            ),
          )
          .toList(),
      titlesData: const FlTitlesData(show: true),
      borderData: FlBorderData(show: false),
    );
  }

  LineChartData _buildTurnoverRateChart(List<Product> products) {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: products
              .map(
                (product) => FlSpot(
                  product.name.hashCode.toDouble(),
                  product.turnoverRate,
                ),
              )
              .toList(),
          isCurved: true,
          color: kDangerColor,
          barWidth: 4.0,
          belowBarData: BarAreaData(show: false),
        ),
      ],
      titlesData: const FlTitlesData(show: true),
      borderData: FlBorderData(show: false),
    );
  }

  LineChartData _buildForecastChart(List<Product> products) {
    return LineChartData(
      lineBarsData: products.map((product) {
        return LineChartBarData(
          spots: product.historicalSales
              .asMap()
              .entries
              .map(
                (entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()),
              )
              .toList(),
          isCurved: true,
          color: kWarningColor,
          barWidth: 4.0,
          belowBarData: BarAreaData(
            show: true,
            color: kWarningColor.withAlpha((0.3 * 255).toInt()),
          ),
        );
      }).toList(),
      titlesData: const FlTitlesData(show: true),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: kLightBlueColor),
      ),
    );
  }
}
