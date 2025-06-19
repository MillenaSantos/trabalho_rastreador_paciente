package com.example.paciente

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle // Importar Bundle
import android.app.NotificationChannel // Importar NotificationChannel
import android.app.NotificationManager // Importar NotificationManager
import android.os.Build // Importar Build

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Certifique-se de chamar o método para criar o canal de notificação
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "location_channel" // DEVE ser o mesmo que em AndroidConfiguration
            val channelName = "Monitoramento de Localização" // Nome visível ao usuário
            val importance = NotificationManager.IMPORTANCE_LOW // Escolha a importância adequada

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = "Este canal é usado para notificações do serviço de monitoramento de localização."
            }

            val notificationManager: NotificationManager =
                getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
}