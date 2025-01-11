#!/bin/bash

# Clean and get dependencies
flutter clean
flutter pub get

# Run the app in Chrome with port 8080
flutter run -d chrome --web-port=8080 