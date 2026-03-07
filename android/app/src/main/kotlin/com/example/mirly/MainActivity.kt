package com.example.mirly

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        MapKitFactory.setApiKey("0334d80f-e23e-46fe-b18a-440d3b8955bc")
        super.onCreate(savedInstanceState)
    }

}