package com.gennissi.gps_pro

import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService;

class Application : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {

    override fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
    }

    override fun registerWith(registry: PluginRegistry?) {
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this));
    }

//    override fun registerWith(registry: PluginRegistry?) {
//        GeneratedPluginRegistrant.registerWith(registry)
//    }

//    override fun registerWith(registry: PluginRegistry?) {
//        GeneratedPluginRegistrant.registerWith(registry);
//    }
}