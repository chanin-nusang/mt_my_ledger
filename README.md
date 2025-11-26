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
