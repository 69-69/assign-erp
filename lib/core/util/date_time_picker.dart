import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:flutter/material.dart';

var _nowToday = DateTime.now();
/*getFormattedDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy, M, d').format(now);
  return formattedDate;
}*/

/// Date Picker [DatePicker]
class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    this.label,
    this.serverDate,
    this.restorationId,
    required this.selectedDate,
    this.validator,
    this.helperText,
    this.isButton = false,
  });

  final String? label;
  final bool isButton;
  final String? helperText;
  final String? serverDate;
  final String? restorationId;
  final Function(DateTime) selectedDate;
  final String? Function(String?)? validator;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

/// RestorationProperty objects can be used because of RestorationMixin.
class _DatePickerState extends State<DatePicker> with RestorationMixin {
  late final _textController =
      TextEditingController(text: widget.serverDate ?? '');

  // In this example, the restoration ID for the mixin is passed in through
  // the [StatefulWidget]'s constructor.
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(
    DateTime(_nowToday.year, _nowToday.month, _nowToday.day),
  );
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) => DatePickerDialog(
        restorationId: 'date_picker_dialog',
        initialEntryMode: DatePickerEntryMode.calendar,
        initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
        firstDate: DateTime(_nowToday.year),
        lastDate: DateTime(_nowToday.year + 3),
      ),
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;

        var selectedDate = '${_selectedDate.value.day}/'
            '${_selectedDate.value.month}/'
            '${_selectedDate.value.year}';

        _textController.text = selectedDate;

        // Return DateTime
        widget.selectedDate(_selectedDate.value);

        context.showAlertOverlay(
          'Selected: ${_selectedDate.value.day}/'
          '${_selectedDate.value.month}/'
          '${_selectedDate.value.year}',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isButton ? _buildIconButton() : _buildTextField(context);
  }

  IconButton _buildIconButton() {
    return IconButton(
      tooltip: 'Search by Date',
      onPressed: () => _restorableDatePickerRouteFuture.present(),
      icon: const Icon(Icons.date_range),
      style: IconButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        backgroundColor: kGrayColor.withAlpha((0.1 * 255).toInt()),
      ),
    );
  }

  _buildTextField(BuildContext context) {
    return TextFormField(
      controller: _textController,
      onTap: () => _restorableDatePickerRouteFuture.present(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.datetime,
      decoration: inputDecoration,
      validator: widget.validator ?? (String? v) => v == null ? "" : null,
    );
  }

  InputDecoration get inputDecoration {
    final helpText = widget.helperText != null ? '(${widget.helperText})' : '';

    return InputDecoration(
      labelText: widget.label ?? 'Date Picker $helpText',
      hintText: '01/26/${_nowToday.year}',
      // helperText: widget.helperText,
      suffixIcon: IconButton(
        tooltip: 'Click to show Calendar',
        icon: const Icon(Icons.date_range),
        onPressed: () => _restorableDatePickerRouteFuture.present(),
        style: IconButton.styleFrom(shape: const RoundedRectangleBorder()),
      ),
      // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      hintStyle: const TextStyle(
        fontWeight: FontWeight.normal,
      ),
    );
  }
}

/// Time Picker [TimePicker]
class TimePicker extends StatefulWidget {
  const TimePicker({
    super.key,
    this.serverTime,
    required this.selectedTime,
    required this.validator,
    this.helperText,
  });

  final String? serverTime;
  final String? helperText;
  final Function(String) selectedTime;
  final String? Function(String?)? validator;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  late final _textController =
      TextEditingController(text: widget.serverTime ?? '');

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _textController.text = picked.format(context);

        // Return input value
        widget.selectedTime(picked.format(context));

        context.showAlertOverlay('Selected: ${picked.format(context)}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildTextField(context);
  }

  _buildTextField(BuildContext context) {
    final helpText = widget.helperText != null ? '(${widget.helperText})' : '';

    return TextFormField(
      controller: _textController,
      onTap: () => _selectTime(context),
      keyboardType: TextInputType.datetime,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // cursorColor: kLightColor,
      // style: const TextStyle(color: kLightColor),
      decoration: inputDecoration.copyWith(
        hintText: 'Pick a Time $helpText',
        // helperText: widget.helperText,
      ),
      validator: widget.validator ?? (String? v) => v == null ? "" : null,
    );
  }

  InputDecoration get inputDecoration {
    return InputDecoration(
      isDense: false,
      // fillColor: kLightColor,
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(/*color: kLightColor, */ width: 1.0),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(/*color: kLightColor, */ width: 1.0),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),

      suffixIcon: IconButton(
        icon: const Icon(Icons.access_time),
        onPressed: () => _selectTime(context),
      ),
      hintStyle: const TextStyle(
        // color: kLightColor,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
