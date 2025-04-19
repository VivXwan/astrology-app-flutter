import 'package:flutter/material.dart';

class DateTimeInput extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay, double) onTimeSelected;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final double? timezoneOffset;

  const DateTimeInput({
    super.key,
    required this.onDateSelected,
    required this.onTimeSelected,
    this.selectedDate,
    this.selectedTime,
    this.timezoneOffset,
  });

  @override
  State<DateTimeInput> createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      widget.onDateSelected(picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // For now, using a fixed timezone offset
      // TODO: Implement proper timezone selection
      widget.onTimeSelected(picked, 5.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date of Birth
        ListTile(
          title: Text(
            widget.selectedDate == null
                ? 'Select Date of Birth'
                : 'Date: ${widget.selectedDate!.toString().split(' ')[0]}',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _pickDate(context),
        ),
        // Time of Birth
        ListTile(
          title: Text(
            widget.selectedTime == null
                ? 'Select Time of Birth'
                : 'Time: ${widget.selectedTime!.format(context)} (TZ: ${widget.timezoneOffset})',
          ),
          trailing: const Icon(Icons.access_time),
          onTap: () => _pickTime(context),
        ),
      ],
    );
  }
} 