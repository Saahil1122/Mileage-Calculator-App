import 'package:flutter/material.dart';
import 'db_helper.dart'; // Ensure this file exists

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mileage Calculator',
      home: MileageCalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MileageCalculatorPage extends StatefulWidget {
  @override
  _MileageCalculatorPageState createState() => _MileageCalculatorPageState();
}

class _MileageCalculatorPageState extends State<MileageCalculatorPage> {
  final _distanceController = TextEditingController();
  final _fuelController = TextEditingController();
  String _selectedVehicle = 'Car';
  List<Map<String, dynamic>> _history = [];
  double? _calculatedMileage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await DBHelper().fetchAll();
    setState(() {
      _history = data;
    });
  }

  Future<void> _calculateAndSave() async {
    double distance = double.tryParse(_distanceController.text) ?? 0;
    double fuel = double.tryParse(_fuelController.text) ?? 1;

    if (fuel == 0 || distance <= 0) return;

    double mileage = distance / fuel;

    Map<String, dynamic> row = {
      'vehicleType': _selectedVehicle,
      'distance': distance,
      'fuel': fuel,
      'mileage': mileage,
      'date': DateTime.now().toString(),
    };

    await DBHelper().insertMileage(row);

    setState(() {
      _calculatedMileage = mileage;
    });

    _distanceController.clear();
    _fuelController.clear();
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mileage Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedVehicle,
              onChanged: (val) {
                setState(() {
                  _selectedVehicle = val!;
                });
              },
              items:
                  ['Car', 'Bike', 'Bus'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
            ),
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Distance Travelled (km)'),
            ),
            TextField(
              controller: _fuelController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Fuel Used (litres)'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _calculateAndSave,
              child: Text('Calculate Mileage'),
            ),
            if (_calculatedMileage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Mileage: ${_calculatedMileage!.toStringAsFixed(2)} km/l",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            SizedBox(height: 20),
            Text(
              "Calculation History",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            _history.isEmpty
                ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("No history yet"),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder: (_, i) {
                    final item = _history[i];
                    return ListTile(
                      title: Text(
                        "${item['vehicleType']} - ${item['mileage'].toStringAsFixed(2)} km/l",
                      ),
                      subtitle: Text(
                        "Distance: ${item['distance']} km, Fuel: ${item['fuel']} L\nDate: ${item['date']}",
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
