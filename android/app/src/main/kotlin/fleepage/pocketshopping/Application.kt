package fleepage.pocketshopping

import android.os.Build
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService



//import com.google.firebase.messaging.FirebaseMessagingService

class Application : FlutterApplication(), PluginRegistrantCallback {

    override fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingService.setPluginRegistrant(this)
        //LocatorService.setPluginRegistrant(this)
        //FlutterMain.startInitialization(this)
        //AlarmService.setPluginRegistrant(this);


    }

    override fun registerWith(registry: PluginRegistry?) {
        io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));

        //AndroidAlarmManagerPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin"));
        //io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
        /*if (!registry!!.hasPlugin("io.flutter.plugins.sharedpreferences")) {
            SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences"));
        }

        if (!registry!!.hasPlugin("io.flutter.plugins.firebasemessaging")) {
            FirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging"))
        }*/
    }
}