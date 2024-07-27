import 'dart:async';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'GTemp.dart';
import 'GHume.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin<Home> {
  double humidity = 0, temperature = 0;
  bool isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _updateData();
    });
  }

  Future<void> _updateData() async {
    setState(() {
      isLoading = true;
    });

    final ref = FirebaseDatabase.instance.ref();
    final temp = await ref.child("Living Room/temperature/value").get();
    final humi = await ref.child("Living Room/humidity/value").get();

    if (temp.exists && humi.exists) {
      setState(() {
        temperature = double.parse(temp.value.toString());
        humidity = double.parse(humi.value.toString());
      });
    } else {
      setState(() {
        temperature = -1;
        humidity = -1;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _manualUpdate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Cargando..."),
            ],
          ),
        );
      },
    );

    await _updateData();

    Navigator.pop(context); // Cierra el diálogo de cargando
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gauge"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _manualUpdate();
            },
          ),

        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: GTemp(temperature: temperature)),
          const Divider(height: 5),
          Expanded(child: GHume(humidity: humidity)),
          const Divider(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildTemperatureMessage(),
                _buildHumidityMessage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureMessage() {
    if (temperature <= 0) {
      return const Text('Hace frío', style: TextStyle(color: Colors.blue));
    } else if (temperature <= 30) {
      return const Text('Temperatura agradable', style: TextStyle(color: Colors.green));
    } else {
      return const Text('Temperatura muy alta', style: TextStyle(color: Colors.red));
    }
  }

  Widget _buildHumidityMessage() {
    if (humidity < 0) {
      return const Text('Tiempo seco', style: TextStyle(color: Colors.brown));
    } else if (humidity < 50) {
      return const Text('Humedad media', style: TextStyle(color: Colors.yellow));
    } else {
      return const Text('Humedad alta', style: TextStyle(color: Colors.purple));
    }
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await _updateData();
  }
}
