# mt_my_ledger

## Project Setup

This project uses the Google Gemini API to process text for recording transactions using natural language. To run the application, you need to have your own Gemini API Key.

### 1. Create a `.env` file

For security, the API Key is not stored directly in the source code. Instead, it is loaded from a `.env` file, which is ignored by Git and will not be committed to the repository.

Create a new file named `.env` in the root directory of the project (at the same level as the `pubspec.yaml` file).

### 2. Add Gemini API Key

Open the `.env` file and add the following line, replacing `YOUR_GEMINI_API_KEY_HERE` with your actual key.

```
GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE
```

### 3. How to get a Gemini API Key

You can get a free Gemini API Key from Google AI Studio.
1.  Go to Google AI Studio.
2.  Sign in with your Google account.
3.  Click on the **"Get API key"** button.
4.  Create a new API key in your Google Cloud project.
5.  Copy the generated key and paste it into your `.env` file.

## Building and Deploying for Web

Follow these steps to build the web application and deploy it to Firebase Hosting.

### 1. Prerequisites

*   Make sure you have the **Firebase CLI** installed. If not, follow the instructions in the official Firebase documentation.
*   Log in to your Firebase account through the terminal:
    ```bash
    firebase login
    ```
*   If you haven't already, set up your project for Firebase Hosting. Run `firebase init hosting` and choose `build/web` as your public directory when prompted.

### 2. Build the Web App

Run the following command in your terminal to build the project. Replace `YOUR_GEMINI_API_KEY_HERE` with the key from your `.env` file.

```bash
flutter build web --dart-define=GEMINI_API_KEY='YOUR_GEMINI_API_KEY_HERE'
```

This command compiles the application and places the output files into the `build/web` directory.

### 3. Deploy to Firebase Hosting

After the build is complete, run the following command to deploy the contents of the `build/web` directory to Firebase Hosting:
```bash
firebase deploy --only hosting
```

## Internationalization (i18n)

This application uses the `easy_localization` package for internationalization. Translation files are located in the `assets/translations/` directory.

### Updating or Adding Translations

To update existing translations or add new languages:

1.  **Edit Translation Files:** Modify the `.json` files in `assets/translations/` (e.g., `en.json`, `th.json`).
    *   For existing keys, update their corresponding translated strings.
    *   To add new strings, add a new key-value pair to all `.json` files.

2.  **Regenerate Keys (Important):** Whenever you add new keys to the JSON files, you must regenerate the `LocaleKeys` class so you can use them in your code.
    ```bash
    flutter pub run easy_localization:generate -S assets/translations -f keys -O lib/generated -o locale_keys.g.dart
    ```

3.  **Run `flutter pub get`:** After modifying `pubspec.yaml` (e.g., adding a new language), ensure all dependencies are up-to-date.
    ```bash
    flutter pub get
    ```

4.  **Analyze and Build:** Run the Dart analyzer to catch any potential issues, then rebuild or hot restart your application for changes to take effect.
    ```bash
    dart analyze
    flutter run # or hot restart if already running
    ```

### Adding a New Language

1.  **Create a new `.json` file:** For example, to add Spanish, create `assets/translations/es.json`.
2.  **Add translations:** Populate the new `es.json` file with all the required key-value pairs, translated into Spanish.
3.  **Update `main.dart`:** Add the new `Locale` to the `supportedLocales` list in the `EasyLocalization` widget.
    ```dart
    EasyLocalization(
      supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US'), Locale('es', 'ES')], // Add your new locale here
      path: 'assets/translations',
      fallbackLocale: const Locale('th', 'TH'),
      startLocale: const Locale('th', 'TH'),
      // ...
    ),
    ```
4.  **Update `SettingsScreen` (optional):** If you want to allow users to switch to this new language from within the app, add a `RadioListTile` for it in `lib/presentation/settings_screen.dart`.
5.  **Run `flutter pub get` and restart the app.**

