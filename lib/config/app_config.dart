class AppConfig {
  static const String appName = "Virtual Glasses Try-On";
  static const String appVersion = "1.0.0";
  static const String firebaseProjectId = "well-care-hub";
  static const String hostingSite = "trialroom";

  // Add your Firebase configuration here if needed
  static const Map<String, dynamic> firebaseConfig = {
    "apiKey": "YOUR_API_KEY",
    "authDomain": "$firebaseProjectId.firebaseapp.com",
    "projectId": firebaseProjectId,
    "storageBucket": "$firebaseProjectId.appspot.com",
    "messagingSenderId": "YOUR_SENDER_ID",
    "appId": "YOUR_APP_ID",
    "measurementId": "G-MEASUREMENT_ID"
  };
}
