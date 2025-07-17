import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/color_convention_util.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/setup/data/data_sources/local/printout_setup_cache_service.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/printout_setup/preview_printout_colors.dart';
import 'package:flutter/material.dart';

// Define color palettes
final List<List<Color>> colorPalettes = [
  [Colors.blue, Colors.red, Colors.green, Colors.grey],
  [Colors.orange, Colors.purple, Colors.cyan, Colors.brown],
  [Colors.yellow, Colors.teal, Colors.pink, Colors.indigo],
  // [Colors.grey, Colors.brown, Colors.indigo],
];

class PrintoutColorPickerScreen extends StatefulWidget {
  const PrintoutColorPickerScreen({super.key});

  @override
  State<PrintoutColorPickerScreen> createState() =>
      _PrintoutColorPickerScreenState();
}

class _PrintoutColorPickerScreenState extends State<PrintoutColorPickerScreen> {
  int _selectedPaletteIndex = 0;
  List<Color> _selectedPalette = [];
  final PrintoutSetupCacheService _printoutService =
      PrintoutSetupCacheService();

  @override
  void initState() {
    super.initState();
    _loadSelectedColors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSelectedColors();
  }

  void _loadSelectedColors() async {
    final settings = await _printoutService.getSettings();

    if (settings != null) {
      setState(() {
        // Convert the list of color strings to List<Color>
        final matchedPalette = stringListToColors(settings.paletteColor);

        final matchPalettes =
            _findMatchingColorPalette(matchedPalette) ?? colorPalettes.first;
        _selectedPalette = matchPalettes;
        // If colors are not in colorPalettes, indexOf will return -1
        _selectedPaletteIndex = colorPalettes.indexOf(matchPalettes);
      });
    }
  }

  // Find and return the matching colors palette
  List<Color>? _findMatchingColorPalette(List<Color> colors) {
    String selectedColorsString = colorsToString(colors);

    for (List<Color> palette in colorPalettes) {
      // debugPrint('does: ${colorsToString(palette)}===$selectedColorsString');
      if (colorsToString(palette) == selectedColorsString) {
        return palette;
      }
    }
    // Return null if no matching palette is found
    return null;
  }

  Future<void> _handleSelectedPalette(int index, String label) async {
    setState(() {
      _selectedPaletteIndex = index;
      _selectedPalette = colorPalettes[index];
    });

    await _saveSelectedPalette(label);
  }

  Future<void> _saveSelectedPalette(String label) async {
    final settings = (await _printoutService.getSettings())?.copyWith(
      paletteColor: _selectedPalette.map((color) => color.toHex()).toList(),
    );
    if (settings != null) {
      await _printoutService.setSettings(settings);
    }
    if (mounted) {
      context.showAlertOverlay('You Selected Palette option $label');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: _buildBody(context),
    );
  }

  Column _buildBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPaletteTitle(context),
        _buildPalette(),
        divLine,
        if (_selectedPalette.isNotEmpty) ...{
          PreviewPrintoutColors(paletteColors: _selectedPalette),
        },
        const SizedBox(height: 50),
      ],
    );
  }

  ListTile _buildPaletteTitle(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(10.0),
      titleAlignment: ListTileTitleAlignment.center,
      title: Wrap(
        spacing: 5,
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Print Colors',
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildResetColorsButton(),
        ],
      ),
      subtitle: Text(
        "This color will be used for the header and footer of invoices, receipts, reports, etc...\nClick on any Palette to see various previews.",
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleSmall,
      ),
    );
  }

  RefreshButton _buildResetColorsButton() {
    return RefreshButton(
      tooltip: 'Reset Colors',
      callback: () async {
        final settings = (await _printoutService.getSettings())?.copyWith(
          paletteColor: [],
          headerColor: '',
          footerColor: '',
        );
        if (settings != null) {
          await _printoutService.setSettings(settings);
        }
        _loadSelectedColors();
      },
    );
  }

  _buildPalette() {
    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: colorPalettes.length,
      itemBuilder: (context, index) => _buildCard(index),
    );
  }

  _buildCard(int index) {
    // var width = (context.screenWidth / 2) / 3.3;
    final i = index + 1;
    final paletteColor = colorPalettes[index].first;

    var isSelected = _selectedPaletteIndex == index;
    var fadeColor = paletteColor.withAlpha((0.6 * 255).toInt());
    return Card(
      elevation: 20,
      color: paletteColor,
      child: ChoiceChip(
        tooltip: 'Palette $i',
        side: BorderSide(color: paletteColor),
        padding: EdgeInsets.zero,
        // symmetric(horizontal: width / 3.6, vertical: width / 2.4),
        showCheckmark: true,
        color: WidgetStatePropertyAll(fadeColor),
        selected: isSelected,
        backgroundColor: isSelected ? fadeColor : paletteColor,
        label: Text('Palette $i', overflow: TextOverflow.ellipsis),
        onSelected: (b) {
          if (!isSelected) {
            _handleSelectedPalette(index, '${index + 1}');
          }
        },
      ),
    );
  }
}

/*void _generatePdf() async {
    final pdf = pw.Document();
    final colors = convertToPdfColors(_selectedPalette);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: colors
              .map((color) => pw.Container(
                    width: 100,
                    height: 100,
                    color: color,
                  ))
              .toList(),
        ),
      ),
    );

    // Here you should implement saving or sharing the PDF
    // For example:
    // final outputFile = await savePdf(pdf);
    // shareFile(outputFile);
  }

  ElevatedButton(
          onPressed: () => _generatePdf(),
          child: const Text('Generate PDF'),
        ),*/
