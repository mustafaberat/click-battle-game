package com.arusoft.clickbattle;

import android.os.Build;
import android.os.Bundle;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Edge-to-edge ekran desteğini Android 10+ için etkinleştir
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            WindowCompat.setDecorFitsSystemWindows(getWindow(), false);

            // Karanlık mod desteği: Status bar ikonlarını tema uyumlu hale getir
            WindowInsetsControllerCompat insetsController = 
                new WindowInsetsControllerCompat(getWindow(), getWindow().getDecorView());
            insetsController.setAppearanceLightStatusBars(true);
        }
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        // Flutter engine konfigürasyonu burada yapılabilir
    }
}
