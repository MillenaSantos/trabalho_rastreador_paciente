import 'package:flutter/material.dart';

class LocationSendingPage extends StatelessWidget {
  final String patientCode;

  const LocationSendingPage({super.key, required this.patientCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                ),
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
          ],
        ),
      ),
    );
  }
}
