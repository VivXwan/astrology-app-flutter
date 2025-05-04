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
  // Single controllers for date and time
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  // Track the previous time value to detect backspace operations
  String _previousTimeValue = '';
  // Add 24-hour format toggle
  bool _use24HourFormat = false;
  // Focus nodes for controlling focus
  final FocusNode _timeFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Initialize time field
    _updateTimeDisplay();

    // Initialize date field
    if (widget.selectedDate != null) {
      _dateController.text = '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}';
    }
    
    // Set up focus change listener for time field
    _timeFocusNode.addListener(_onTimeFocusChange);
  }

  // Handle focus changes on time field
  void _onTimeFocusChange() {
    // When the time field loses focus, format it properly with seconds
    if (!_timeFocusNode.hasFocus) {
      _formatTimeWithSeconds();
    }
  }
  
  // Format time with seconds when field loses focus
  void _formatTimeWithSeconds() {
    if (_timeController.text.isEmpty) return;
    
    if (_use24HourFormat) {
      // For 24-hour format
      final pattern = RegExp(r'^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?$');
      final match = pattern.firstMatch(_timeController.text);
      if (match != null) {
        final hours = match.group(1)!;
        final minutes = match.group(2)!;
        // If seconds are missing, add them
        if (match.group(3) == null) {
          setState(() {
            _timeController.text = '$hours:$minutes:00';
            _previousTimeValue = _timeController.text;
          });
        }
        _validateAndUpdateTime24Hour(_timeController.text);
      }
    } else {
      // For 12-hour format
      final pattern = RegExp(r'^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?\s+(AM|PM)$');
      final match = pattern.firstMatch(_timeController.text);
      if (match != null) {
        final hours = match.group(1)!;
        final minutes = match.group(2)!;
        final ampm = match.group(4)!;
        // If seconds are missing, add them
        if (match.group(3) == null) {
          setState(() {
            _timeController.text = '$hours:$minutes:00 $ampm';
            _previousTimeValue = _timeController.text;
          });
        }
        _validateAndUpdateTime(_timeController.text);
      }
    }
  }

  // Helper to update time display based on current format
  void _updateTimeDisplay() {
    if (widget.selectedTime != null) {
      if (_use24HourFormat) {
        // 24-hour format
        final hour = widget.selectedTime!.hour.toString().padLeft(2, '0');
        final minute = widget.selectedTime!.minute.toString().padLeft(2, '0');
        _timeController.text = '$hour:$minute:00';
      } else {
        // 12-hour format with AM/PM
        final hour = widget.selectedTime!.hour;
        final minute = widget.selectedTime!.minute.toString().padLeft(2, '0');
        final isAM = hour < 12;
        final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
        _timeController.text = '${displayHour.toString().padLeft(2, '0')}:$minute:00 ${isAM ? 'AM' : 'PM'}';
      }
      _previousTimeValue = _timeController.text;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _timeFocusNode.removeListener(_onTimeFocusChange);
    _timeFocusNode.dispose();
    super.dispose();
  }

  void _formatDateInput(String value) {
    // Remove any non-digit characters from the input
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format with slashes
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += digitsOnly[i];
    }

    // Update the controller if the formatted text is different
    if (formatted != _dateController.text) {
      final cursorPosition = _dateController.selection.start;
      int newPosition = cursorPosition + (formatted.length - value.length);
      newPosition = newPosition.clamp(0, formatted.length);
      
      _dateController.text = formatted;
      _dateController.selection = TextSelection.fromPosition(TextPosition(offset: newPosition));
    }

    // Validate and parse the date if we have enough digits
    if (digitsOnly.length >= 8) {
      _validateAndUpdateDate(formatted);
    }
  }

  void _formatTimeInput(String value) {
    // Get the cursor position and determine if this is a backspace
    final int cursorPosition = _timeController.selection.start;
    final bool isBackspace = value.length < _previousTimeValue.length;
    
    // Store original value for comparison
    final String originalValue = value;
    
    // For 24-hour format, use a different approach
    if (_use24HourFormat) {
      // Remove any non-digit or colon characters
      String cleanValue = value.replaceAll(RegExp(r'[^\d:]'), '');
      
      // Remove existing colons for consistent formatting
      final plainDigits = cleanValue.replaceAll(':', '');
      
      // Format with colons
      String formatted = '';
      for (int i = 0; i < min(6, plainDigits.length); i++) {
        if (i == 2 || i == 4) formatted += ':';
        formatted += plainDigits[i];
      }
      
      // Calculate new cursor position
      int newCursorPosition;
      if (isBackspace) {
        newCursorPosition = cursorPosition;
      } else {
        newCursorPosition = cursorPosition + (formatted.length - originalValue.length);
      }
      newCursorPosition = newCursorPosition.clamp(0, formatted.length);
      
      // Update text and cursor
      if (_timeController.text != formatted) {
        _timeController.text = formatted;
        _timeController.selection = TextSelection.fromPosition(
          TextPosition(offset: newCursorPosition)
        );
      }
      
      // Save the current value for next comparison
      _previousTimeValue = _timeController.text;
      
      // Validate if we have enough digits
      if (plainDigits.length >= 4) {
        _validateAndUpdateTime24Hour(formatted);
      }
      
      return;
    }
    
    // For 12-hour format (existing code)
    // Detect backspace in AM/PM region
    bool isBackspaceInAmPm = false;
    String timeWithoutAmPm = value;
    
    // Check if backspacing in AM/PM region
    if (isBackspace) {
      final bool hadAM = _previousTimeValue.contains('AM');
      final bool hadPM = _previousTimeValue.contains('PM');
      
      // If previous value had AM/PM and current doesn't have complete AM/PM
      if ((hadAM && !value.contains('AM')) || (hadPM && !value.contains('PM'))) {
        // We're backspacing through the AM/PM
        isBackspaceInAmPm = true;
        
        // If we still have partial AM/PM (like 'A' or 'P'), remove it completely
        if (value.contains(' A') || value.contains(' P')) {
          timeWithoutAmPm = value.replaceAll(RegExp(r'\s+[AP]$'), '');
        } else if (value.endsWith('A') || value.endsWith('P')) {
          timeWithoutAmPm = value.replaceAll(RegExp(r'[AP]$'), '');
        }
      }
    }
    
    // If we're backspacing in AM/PM, don't reformat - just use the cleaned value
    if (isBackspaceInAmPm) {
      _timeController.text = timeWithoutAmPm;
      _timeController.selection = TextSelection.fromPosition(
        TextPosition(offset: timeWithoutAmPm.length)
      );
      _previousTimeValue = timeWithoutAmPm;
      return;
    }
    
    // Normal forward typing processing
    // Extract digits and AM/PM indicator
    String digits = '';
    bool hasAM = false;
    bool hasPM = false;
    String workingValue = value;
    
    // Check for complete AM/PM
    if (workingValue.contains('AM')) {
      hasAM = true;
      workingValue = workingValue.replaceAll('AM', '');
    } else if (workingValue.contains('PM')) {
      hasPM = true;
      workingValue = workingValue.replaceAll('PM', '');
    } 
    // Only check for A/P if we're typing forward, not backspacing
    else if (!isBackspace) {
      if (workingValue.endsWith('A')) {
        hasAM = true;
        workingValue = workingValue.substring(0, workingValue.length - 1);
      } else if (workingValue.endsWith('P')) {
        hasPM = true;
        workingValue = workingValue.substring(0, workingValue.length - 1);
      }
    }
    
    // Extract digits and colons
    digits = workingValue.replaceAll(RegExp(r'[^\d:]'), '');
    
    // Remove existing colons for consistent formatting
    final plainDigits = digits.replaceAll(':', '');
    
    // Format with colons
    String formatted = '';
    for (int i = 0; i < min(6, plainDigits.length); i++) {
      if (i == 2 || i == 4) formatted += ':';
      formatted += plainDigits[i];
    }
    
    // Add AM/PM suffix with a space, but only if specifically indicated
    if (formatted.isNotEmpty) {
      if (hasAM) {
        formatted += ' AM';
      } else if (hasPM) {
        formatted += ' PM';
      // // Default to AM if we have 4+ digits and no AM/PM specified
      // } else if (plainDigits.length >= 4 && !formatted.contains(' AM') && !formatted.contains(' PM')) {
      //   formatted += ' AM';
      }
    }
    
    // Calculate new cursor position
    int newCursorPosition;
    if (isBackspace) {
      // For backspace, keep cursor at the backspace position
      newCursorPosition = cursorPosition;
    } else {
      // For forward typing, account for added formatting
      newCursorPosition = cursorPosition + (formatted.length - originalValue.length);
    }
    newCursorPosition = newCursorPosition.clamp(0, formatted.length);
    
    // Update text and cursor
    if (_timeController.text != formatted) {
      _timeController.text = formatted;
      _timeController.selection = TextSelection.fromPosition(
        TextPosition(offset: newCursorPosition)
      );
    }
    
    // Save the current value for next comparison
    _previousTimeValue = _timeController.text;
    
    // Validate if we have enough digits
    if (plainDigits.length >= 4) {
      _validateAndUpdateTime(formatted);
    }
  }

  int min(int a, int b) {
    return a < b ? a : b;
  }

  void _validateAndUpdateDate(String value) {
    if (value.isEmpty) return;

    // Extract day, month, and year from the input
    final parts = value.split('/');
    if (parts.length != 3) return;

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (day < 1 || day > 31 || month < 1 || month > 12) return;

      try {
        final date = DateTime(year, month, day);
        widget.onDateSelected(date);
      } catch (e) {
        // Invalid date, ignore update
      }
    } catch (e) {
      // Parse error, ignore update
    }
  }

  // New method to validate 24-hour format time
  void _validateAndUpdateTime24Hour(String value) {
    if (value.isEmpty) return;

    // Extract hours, minutes, and seconds
    final pattern = RegExp(r'^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?$');
    final match = pattern.firstMatch(value);
    if (match == null) return;

    try {
      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      // If seconds are not provided, default to 0
      final seconds = match.group(3) != null ? int.parse(match.group(3)!) : 0;

      if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59 || seconds < 0 || seconds > 59) return;

      // Create TimeOfDay object
      final timeOfDay = TimeOfDay(hour: hours, minute: minutes);
      widget.onTimeSelected(timeOfDay);
    } catch (e) {
      // Parse error, ignore update
    }
  }

  void _validateAndUpdateTime(String value) {
    if (value.isEmpty) return;

    // Extract hours, minutes, seconds, and AM/PM
    final pattern = RegExp(r'^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?\s+(AM|PM)$');
    final match = pattern.firstMatch(value);
    if (match == null) return;

    try {
      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      // If seconds are not provided, default to 0
      final seconds = match.group(3) != null ? int.parse(match.group(3)!) : 0;
      final isAM = match.group(4) == 'AM';

      if (hours < 1 || hours > 12 || minutes < 0 || minutes > 59 || seconds < 0 || seconds > 59) return;

      int adjustedHours = hours;
      if (!isAM && hours != 12) {
        adjustedHours += 12;
      } else if (isAM && hours == 12) {
        adjustedHours = 0;
      }

      // Create TimeOfDay object
      final timeOfDay = TimeOfDay(hour: adjustedHours, minute: minutes);
      widget.onTimeSelected(timeOfDay);
    } catch (e) {
      // Parse error, ignore update
    }
  }

  void _selectDate() async {
    // Parse current date if available
    DateTime initialDate = DateTime.now();
    if (_dateController.text.isNotEmpty) {
      try {
        final parts = _dateController.text.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          initialDate = DateTime(year, month, day);
        }
      } catch (e) {
        // Use current date if parsing fails
      }
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      });
      widget.onDateSelected(pickedDate);
    }
  }

  void _selectTime() async {
    // Parse current time if available
    TimeOfDay initialTime = TimeOfDay.now();
    if (_timeController.text.isNotEmpty) {
      try {
        if (_use24HourFormat) {
          final parts = _timeController.text.split(':');
          if (parts.length >= 2) {
            final hours = int.parse(parts[0]);
            final minutes = int.parse(parts[1]);
            initialTime = TimeOfDay(hour: hours, minute: minutes);
          }
        } else {
          final pattern = RegExp(r'^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?\s+(AM|PM)$');
          final match = pattern.firstMatch(_timeController.text);
          if (match != null) {
            final hours = int.parse(match.group(1)!);
            final minutes = int.parse(match.group(2)!);
            final isAM = match.group(4) == 'AM';
            
            int adjustedHours = hours;
            if (!isAM && hours != 12) {
              adjustedHours += 12;
            } else if (isAM && hours == 12) {
              adjustedHours = 0;
            }
            
            initialTime = TimeOfDay(hour: adjustedHours, minute: minutes);
          }
        }
      } catch (e) {
        // Use current time if parsing fails
      }
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: _use24HourFormat,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      widget.onTimeSelected(pickedTime);
      
      // Update the displayed time according to the current format
      setState(() {
        if (_use24HourFormat) {
          final hour = pickedTime.hour.toString().padLeft(2, '0');
          final minute = pickedTime.minute.toString().padLeft(2, '0');
          _timeController.text = '$hour:$minute:00';
        } else {
          final hour = pickedTime.hour;
          final minute = pickedTime.minute.toString().padLeft(2, '0');
          final isAM = hour < 12;
          final displayHour = (hour > 12 ? hour - 12 : hour == 0 ? 12 : hour).toString().padLeft(2, '0');
          _timeController.text = '$displayHour:$minute:00 ${isAM ? 'AM' : 'PM'}';
        }
        _previousTimeValue = _timeController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Input
        TextField(
          controller: _dateController,
          decoration: InputDecoration(
            labelText: 'Date of Birth (DD/MM/YYYY)',
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: _selectDate,
            ),
          ),
          keyboardType: TextInputType.datetime,
          onChanged: _formatDateInput,
        ),
        SizedBox(height: 16),
        
        // Time Input with 24-hour Format Toggle
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time of Birth', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text('24h', style: TextStyle(fontSize: 14)),
                    Switch(
                      value: _use24HourFormat,
                      onChanged: (value) {
                        setState(() {
                          _use24HourFormat = value;
                          // Update the time display when format changes
                          _updateTimeDisplay();
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            TextField(
              controller: _timeController,
              focusNode: _timeFocusNode,
              decoration: InputDecoration(
                hintText: _use24HourFormat ? 'HH:MM' : 'HH:MM AM/PM',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: _selectTime,
                ),
              ),
              keyboardType: TextInputType.datetime,
              onChanged: _formatTimeInput,
              onEditingComplete: () {
                _formatTimeWithSeconds();
                FocusScope.of(context).unfocus();
              },
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ],
    );
  }
} 