package com.beh.teleeye

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Notification
import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createDefaultNotificationChannel()
        createCallkitNotificationChannels()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Required for launchMode="singleTask" so plugins that rely on
        // the latest intent (FCM click, CallKit accept, deep links) can read it.
        setIntent(intent)
    }

    private fun createDefaultNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channelId = "basic_channel"
        val channelName = "Basic notifications"
        val channelDescription = "Notification channel for basic messages"

        val manager = getSystemService(NotificationManager::class.java) ?: return
        val existing = manager.getNotificationChannel(channelId)
        if (existing != null) return

        val channel = NotificationChannel(
            channelId,
            channelName,
            NotificationManager.IMPORTANCE_HIGH
        )
        channel.description = channelDescription
        manager.createNotificationChannel(channel)
    }

    private fun createCallkitNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(NotificationManager::class.java) ?: return

        // flutter_callkit_incoming uses these fixed IDs internally.
        val incomingId = "callkit_incoming_channel_id"
        val missedId = "callkit_missed_channel_id"
        val ongoingId = "callkit_ongoing_channel_id"

        if (manager.getNotificationChannel(incomingId) == null) {
            val channel = NotificationChannel(
                incomingId,
                "Incoming Call",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            channel.enableVibration(true)
            channel.setSound(null, null) // plugin plays its own ringtone
            manager.createNotificationChannel(channel)
        }

        if (manager.getNotificationChannel(missedId) == null) {
            val channel = NotificationChannel(
                missedId,
                "Missed Call",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            channel.enableVibration(true)
            manager.createNotificationChannel(channel)
        }

        if (manager.getNotificationChannel(ongoingId) == null) {
            val channel = NotificationChannel(
                ongoingId,
                "Ongoing Call",
                NotificationManager.IMPORTANCE_LOW
            )
            channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            channel.setSound(null, null)
            manager.createNotificationChannel(channel)
        }
    }
}
