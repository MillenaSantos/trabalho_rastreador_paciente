import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paciente/background_service.dart';
import 'package:paciente/components/customButton.dart';
import 'package:paciente/components/customTextfield.dart';
import 'package:paciente/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

//const fetchLocationTask = "fetchLocation";

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoramento de Área',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Monitoramento de Área'),
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

  @override
  void initState() {
    super.initState();
    _loadSavedCode(); // Chama a função ao iniciar
  }

  void _loadSavedCode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('patientCode');

    if (savedCode != null && savedCode.isNotEmpty) {
      await initializeService(savedCode);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LocationSendingPage(patientCode: savedCode),
          ),
        );
      }
    }
  }

  Future<bool> _requestLocationPermission() async {
    print("ENTREI");
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    return false;
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
              const Icon(Icons.person_pin_circle, size: 150),
              const SizedBox(height: 25),
              MyTextField(
                controller: patientCodController,
                hintText: 'Código do paciente',
                obscureText: false,
                required: true,
              ),
              const SizedBox(height: 25),
              MyButton(
                onTap: () async {
                  patientCodController.text =
                      patientCodController.text.toUpperCase();
                  final code = patientCodController.text.trim();
                  if (code.isNotEmpty) {
                    bool temPermissao = await _requestLocationPermission();
                    if (!temPermissao) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Permissão de localização necessária.'),
                        ),
                      );
                      return;
                    }

                    await initializeService(code);

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('patientCode', code);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LocationSendingPage(patientCode: code),
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
