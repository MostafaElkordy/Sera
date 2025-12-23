package com.salma.sera

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.telephony.SmsManager
import android.telephony.SubscriptionManager
import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.salma.sera/sms"
    private val SMS_SENT = "SMS_SENT"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "sendSms") {
                val phone = call.argument<String>("phone")
                val message = call.argument<String>("message")
                val simSlot = call.argument<Int>("simSlot") ?: -1

                if (phone != null && message != null) {
                    sendSms(phone, message, simSlot, result)
                } else {
                    result.error("INVALID_ARGS", "Phone or message missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendSms(phone: String, message: String, simSlot: Int, result: MethodChannel.Result) {
        if (checkSelfPermission(android.Manifest.permission.SEND_SMS) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
             result.error("PERMISSION_DENIED", "SEND_SMS permission not granted at native level", null)
             return
        }

        try {
            // Unique action to prevent receiver cross-talk
            val uniqueAction = "SMS_SENT_${System.currentTimeMillis()}_${phone.hashCode()}"
            val sentIntent = Intent(uniqueAction)
            val sentPI = PendingIntent.getBroadcast(this, 0, sentIntent, PendingIntent.FLAG_IMMUTABLE)

            // Register loop-safe receiver
            registerReceiver(object : BroadcastReceiver() {
                override fun onReceive(arg0: Context, arg1: Intent) {
                    when (resultCode) {
                        Activity.RESULT_OK -> println("SMS_DEBUG: Part sent successfully to $phone")
                        SmsManager.RESULT_ERROR_GENERIC_FAILURE -> println("SMS_DEBUG: Generic failure to $phone")
                        SmsManager.RESULT_ERROR_NO_SERVICE -> println("SMS_DEBUG: No service for $phone")
                    }
                    try { unregisterReceiver(this) } catch (e: Exception) {}
                }
            }, IntentFilter(uniqueAction))

            val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
            val subscriptionInfoList = subscriptionManager.activeSubscriptionInfoList

            val smsManager = if (simSlot == -1) {
                SmsManager.getDefault()
            } else {
                 if (subscriptionInfoList != null && subscriptionInfoList.isNotEmpty()) {
                        var chosenSubId = -1
                        for (info in subscriptionInfoList) {
                            if (info.simSlotIndex == simSlot) {
                                chosenSubId = info.subscriptionId
                                break
                            }
                        }
                        if (chosenSubId == -1) chosenSubId = subscriptionInfoList[0].subscriptionId

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                             getSystemService(SmsManager::class.java).createForSubscriptionId(chosenSubId)
                        } else {
                            SmsManager.getSmsManagerForSubscriptionId(chosenSubId)
                        }
                    } else {
                        SmsManager.getDefault()
                    }
            }

            // USE MULTIPART ONLY IF NECESSARY
            // Arabic messages > 70 chars are multipart.
            val parts = smsManager.divideMessage(message)
            
            if (parts.size > 1) {
                val sentIntents = ArrayList<PendingIntent>()
                for (i in parts.indices) {
                    sentIntents.add(sentPI) 
                }
                smsManager.sendMultipartTextMessage(phone, null, parts, sentIntents, null)
                result.success("SMS Queued (Multipart: ${parts.size})")
            } else {
                // Single part - prefer simple API
                smsManager.sendTextMessage(phone, null, message, sentPI, null)
                result.success("SMS Queued (Single)")
            }
        } catch (e: Exception) {
            result.error("SEND_FAILED", e.message, null)
        }
    }
}
