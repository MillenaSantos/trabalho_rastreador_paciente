import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import 'main.dart'; // Certifique-se de que a classe LatLng está aqui

Future<void> initializeService(String patientCode) async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'location_channel',
      initialNotificationTitle: 'Monitoramento ativo',
      initialNotificationContent: 'Localização está sendo monitorada...',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: (_) => true,
    ),
  );

  await service.startService();

  // Espera um pouco para garantir que o serviço está pronto
  await Future.delayed(const Duration(seconds: 1));
  // Guarda o codigo do paciente pra ser inserido depois no realtime
  service.invoke("setPatientCode", {"patientCode": patientCode});
}

// pra encontrar a função
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Faz com que os plugins Flutter funcionem dentro do serviço em segundo plano
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();

  String? patientCode;

  service.on("setPatientCode").listen((event) {
    patientCode = event?['patientCode'];
    print("Código do paciente recebido: $patientCode");
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (patientCode == null) return;

    try {
      final position = await Geolocator.getCurrentPosition();

      //atualizar localização do paciente no realtime
      final dbRef = FirebaseDatabase.instance.ref();
      await dbRef.child('locations/$patientCode').set({
        'codigoPaciente': patientCode,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });

      //buscar area do paciente
      final firestore = FirebaseFirestore.instance;
      final snapshot =
          await firestore
              .collection('Patient')
              .where('code', isEqualTo: patientCode)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        print(doc);
        final docId = doc.id;
        final areaList = doc['area'] as List;

        final GeoPoint centerGeo = areaList[0];
        final GeoPoint edgeGeo = areaList[1];

        //centro do circulo
        final LatLng center = LatLng(centerGeo.latitude, centerGeo.longitude);
        //borda do circulo
        final LatLng edge = LatLng(edgeGeo.latitude, edgeGeo.longitude);

        //posicao atual
        final LatLng current = LatLng(position.latitude, position.longitude);

        //calcula o raio
        double radius = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          edge.latitude,
          edge.longitude,
        );

        bool inside = _isWithinRadius(current, center, radius);
        await firestore.collection('Patient').doc(docId).set({
          'status': inside ? 'active' : 'outOfArea',
          'lastStatusUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Erro ao enviar localização: $e");
    }
  });
}

//verifica se a distância entre a localização atual e o centro da área é < que o raio
bool _isWithinRadius(LatLng point, LatLng center, double radius) {
  final distance = Geolocator.distanceBetween(
    point.latitude,
    point.longitude,
    center.latitude,
    center.longitude,
  );
  return distance <= radius;
}
