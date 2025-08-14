import 'dart:typed_data';

import 'package:assign_erp/core/network/data_sources/models/print_util_model.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/request_for_quotation_model.dart';
import 'package:assign_erp/features/inventory_ims/data/models/print/print_rfq_model.dart';
import 'package:assign_erp/features/setup/data/models/supplier_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Print Request For Quotation [PrintRFQ]
class PrintRequestForQuotation {
  final List<RequestForQuotation> quotes;
  final Supplier supplier;

  PrintRequestForQuotation({required this.quotes, required this.supplier});

  void onPrintRFQ() {
    // Direct-Printing: This is where we print the document
    Printing.layoutPdf(
      // [onLayout] will be called multiple times
      // when the user changes the printer or printer settings
      onLayout: (PdfPageFormat format) async {
        // Any valid Pdf document can be returned here as a list of int
        return await _issuePrinting(format: PdfPageFormat.a4);
        // return buildPdf(format);
      },
    );
  }

  // Sample function to aggregate Request For Quotation data
  List<PrintItem> _generateRFQ() {
    final invoiceProducts = quotes.asMap().entries.map((entry) {
      // final index = entry.key;
      final order = entry.value;

      return PrintItem(
        sku: order.supplierId,
        productName: _toCap(order.productName),
        unitPrice: order.unitPrice,
        quantity: order.quantity,
        discountPercent: order.discountPercent,
        validityDate: order.getDeliveryDate,
        taxPercent: order.taxPercent,
        paymentTerms: 'Not Specified',
      );
    }).toList();
    return invoiceProducts;
  }

  Future<Uint8List> _issuePrinting({
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    List<PrintItem> invoiceProducts = _generateRFQ();

    /// this.first or first references List<Quotes>
    final rfq = PrintRFQ2(
      rfqNumber: quotes.first.rfqNumber,
      products: invoiceProducts,
      supplierEmail: supplier.email,
      supplierName: _toCap(supplier.name),
      supplierAddress: _toCap(supplier.address),
      supplierPhone: supplier.phone,
      contactPerson: _toCap(supplier.contactPersonName),
      // baseColor: PdfColors.teal,
      // accentColor: PdfColors.blueGrey900,
    );

    // Now you can use the `rfq` object as needed, e.g., to print or display it
    return await rfq.buildPdf(format);
  }

  String _toCap(String i) => i.toTitleCase;
}
