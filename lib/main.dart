import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:paciente/components/customButton.dart';
import 'package:paciente/components/customTextfield.dart';
import 'dart:async';

import 'package:paciente/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

Future<Position> _getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Serviço de localização está desabilitado.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Permissão de localização negada');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Permissão de localização permanentemente negada.');
  }

  return await Geolocator.getCurrentPosition();
}

Future<void> _updateLocationInRealtime(String patientCode) async {
  try {
    Position position = await _getCurrentLocation();

    final databaseRef = FirebaseDatabase.instance.ref();

    await databaseRef.child('locations/$patientCode').set({
      'codigoPaciente': patientCode,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Localização atualizada no Realtime Database com sucesso!');
  } catch (e) {
    print('Erro ao atualizar localização: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController patientCodController = TextEditingController();
  Timer? _timer;

  void _startLocationUpdating(String patientCode) {
    const interval = Duration(seconds: 5);
    _timer = Timer.periodic(interval, (timer) {
      _updateLocationInRealtime(patientCode);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 150),
              const Icon(Icons.person, size: 150),
              const SizedBox(height: 25),
              MyTextField(
                controller: patientCodController,
                hintText: 'Código do paciente',
                obscureText: false,
                required: true,
              ),
              const SizedBox(height: 25),
              MyButton(
                onTap: () {
                  if (patientCodController.text.isNotEmpty) {
                    _startLocationUpdating(patientCodController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LocationSendingPage(
                              patientCode: patientCodController.text,
                            ),
                      ),
                    );
                  }
                },
                text: 'Enviar',
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
