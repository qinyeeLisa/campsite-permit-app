import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class CamperApplyPermitScreen extends StatefulWidget {
  const CamperApplyPermitScreen({super.key});

  @override
  State<CamperApplyPermitScreen> createState() =>
      _CamperApplyPermitScreenState();
}

class _CamperApplyPermitScreenState extends State<CamperApplyPermitScreen> {
  // Dropdown options
  final List<String> _locations = [
    'No Selection',
    'East Coast Park',
    'Pasir Ris Park',
    'West Coast Park',
    'Changi Beach Park'
  ];

  final List<String> _areas = [
    'No Selection',
    'North',
    'South',
    'East',
    'West'
  ];

  // Selected values
  String _selectedLocation = 'No Selection';
  String _selectedArea = 'No Selection';

  // Date fields
  DateTime? _startDate;
  DateTime? _endDate;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Function to pick a date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _submitPermitApplication() {
    // Handle submission logic
    if (_selectedLocation == 'No Selection' ||
        _selectedArea == 'No Selection') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location and an area.')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both start and end dates.')),
      );
      return;
    }

    // Example submission logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Permit application submitted successfully!')),
    );

    // Implement further submission logic such as sending data to a server
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permit Application"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Location Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              value: _selectedLocation,
              items: _locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLocation = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Area Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Campsite Area',
                border: OutlineInputBorder(),
              ),
              value: _selectedArea,
              items: _areas.map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Text(area),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedArea = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Start Date Picker
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, true),
                ),
              ),
              controller: TextEditingController(
                text: _startDate != null ? _dateFormat.format(_startDate!) : '',
              ),
            ),
            const SizedBox(height: 20),

            // End Date Picker
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'End Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, false),
                ),
              ),
              controller: TextEditingController(
                text: _endDate != null ? _dateFormat.format(_endDate!) : '',
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitPermitApplication,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
