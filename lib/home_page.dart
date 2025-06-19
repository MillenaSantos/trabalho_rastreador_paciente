import 'package:flutter/material.dart';
import 'package:paciente/components/customButton.dart';
import 'package:paciente/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSendingPage extends StatelessWidget {
  final String patientCode;

  const LocationSendingPage({super.key, required this.patientCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 25, color: Colors.black),
                  children: [
                    const TextSpan(text: 'Código '),
                    TextSpan(
                      text: patientCode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enviando localização...',
                style: TextStyle(
                  fontSize: 22,
                  color: Color.fromARGB(255, 99, 89, 89),
                ),
              ),
              const SizedBox(height: 50),
              MyButton(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('patientCode');

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const MyHomePage(title: 'Monitoramento de Área'),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                text: 'Parar Monitoramento e Voltar',
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
