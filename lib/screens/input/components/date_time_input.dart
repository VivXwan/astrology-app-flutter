import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DateTimeInput extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  const DateTimeInput({
    super.key,
    required this.onDateSelected,
    required this.onTimeSelected,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  State<DateTimeInput> createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  // Time controllers
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  bool _isAM = true;

  // Date controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize time fields
    if (widget.selectedTime != null) {
      final hour = widget.selectedTime!.hour;
      _isAM = hour < 12;
      _hoursController.text = (hour > 12 ? hour - 12 : hour == 0 ? 12 : hour).toString().padLeft(2, '0');
      _minutesController.text = widget.selectedTime!.minute.toString().padLeft(2, '0');
      _secondsController.text = '00';
    }

    // Initialize date fields
    if (widget.selectedDate != null) {
      _dateController.text = widget.selectedDate!.day.toString().padLeft(2, '0');
      _monthController.text = widget.selectedDate!.month.toString().padLeft(2, '0');
      _yearController.text = widget.selectedDate!.year.toString();
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _dateController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final hours = int.tryParse(_hoursController.text);
    final minutes = int.tryParse(_minutesController.text);
    
    if (hours != null && minutes != null) {
      int adjustedHours = hours;
      if (!_isAM && hours != 12) {
        adjustedHours += 12;
      } else if (_isAM && hours == 12) {
        adjustedHours = 0;
      }
      
      widget.onTimeSelected(TimeOfDay(hour: adjustedHours, minute: minutes));
    }
  }

  void _updateDate() {
    final day = int.tryParse(_dateController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);
    
    if (day != null && month != null && year != null) {
      try {
        final date = DateTime(year, month, day);
        widget.onDateSelected(date);
      } catch (e) {
        // Invalid date, ignore update
      }
    }
  }

  Widget _buildTimeInput(TextEditingController controller, String label, int maxValue) {
    return SizedBox(
      width: 60,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            final intValue = int.parse(value);
            if (intValue > maxValue) {
              controller.text = maxValue.toString().padLeft(2, '0');
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }
            _updateTime();
          }
        },
      ),
    );
  }

  Widget _buildDateInput(TextEditingController controller, String label, int maxValue, {int? maxLength}) {
    return SizedBox(
      width: maxLength != null ? 80 : 60,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLength ?? 2),
        ],
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            final intValue = int.parse(value);
            if (intValue > maxValue) {
              controller.text = maxValue.toString().padLeft(maxLength ?? 2, '0');
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }
            _updateDate();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date of Birth
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date of Birth',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildDateInput(_dateController, 'DD', 31),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('/', style: TextStyle(fontSize: 20)),
                  ),
                  _buildDateInput(_monthController, 'MM', 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('/', style: TextStyle(fontSize: 20)),
                  ),
                  _buildDateInput(_yearController, 'YYYY', 2100, maxLength: 4),
                ],
              ),
            ],
          ),
        ),
        // Time of Birth
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Time of Birth',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTimeInput(_hoursController, 'HH', 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(':', style: TextStyle(fontSize: 20)),
                  ),
                  _buildTimeInput(_minutesController, 'MM', 59),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(':', style: TextStyle(fontSize: 20)),
                  ),
                  _buildTimeInput(_secondsController, 'SS', 59),
                  const SizedBox(width: 16),
                  ToggleButtons(
                    isSelected: [_isAM, !_isAM],
                    onPressed: (index) {
                      setState(() {
                        _isAM = index == 0;
                        _updateTime();
                      });
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('AM'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('PM'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 