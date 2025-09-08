# Google Maps API Setup Guide for ResQRoute

## Overview
This guide will help you configure Google Maps API for the ResQRoute Flutter app to enable map functionality and location services.

## Prerequisites
- Google Cloud Console account
- Flutter development environment set up
- ResQRoute project cloned and dependencies installed

## Step 1: Get Google Maps API Key

### 1.1 Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Note your project ID

### 1.2 Enable Required APIs
Enable the following APIs in Google Cloud Console:
- **Maps SDK for Android**
- **Maps SDK for iOS** (if building for iOS)
- **Places API** (for location search)
- **Directions API** (for navigation)
- **Geocoding API** (for address conversion)

### 1.3 Create API Key
1. Go to **APIs & Services > Credentials**
2. Click **Create Credentials > API Key**
3. Copy the generated API key
4. **Important**: Restrict the API key for security:
   - Click on the API key to edit
   - Under **Application restrictions**, select **Android apps**
   - Add your app's package name: `com.example.resqroute`
   - Add SHA-1 certificate fingerprint (get from Android Studio or keystore)

## Step 2: Configure Android App

### 2.1 Update gradle.properties
Open `android/gradle.properties` and replace the placeholder:
```properties
GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_API_KEY_HERE
```

### 2.2 Verify AndroidManifest.xml
The AndroidManifest.xml has been pre-configured with:
- Location permissions
- Google Maps API key placeholder
- Required metadata

## Step 3: Configure Environment Variables

### 3.1 Create .env file
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Update `.env` with your actual API keys:
   ```bash
   GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key
   GOOGLE_PLACES_API_KEY=your_actual_places_api_key
   GOOGLE_DIRECTIONS_API_KEY=your_actual_directions_api_key
   ```

### 3.2 Add .env to .gitignore
Ensure `.env` is in your `.gitignore` file to prevent committing API keys:
```
.env
```

## Step 4: Test Configuration

### 4.1 Build and Run
1. Clean and rebuild the project:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

2. Run the app:
   ```bash
   flutter run
   ```

### 4.2 Test Map Features
1. Navigate to **Interactive Map** from patient dashboard
2. Check if map loads without errors
3. Test location permissions
4. Verify current location functionality
5. Test hospital markers and search

## Step 5: Troubleshooting

### Common Issues and Solutions

#### 5.1 Map Not Loading
- **Symptom**: Gray screen or "For development purposes only" watermark
- **Solution**: 
  - Verify API key is correct
  - Check API restrictions in Google Cloud Console
  - Ensure Maps SDK for Android is enabled

#### 5.2 Location Not Working
- **Symptom**: Location permission errors or no current location
- **Solution**:
  - Grant location permissions in device settings
  - Check if location services are enabled
  - Verify location permissions in AndroidManifest.xml

#### 5.3 API Key Errors
- **Symptom**: Authentication errors in logs
- **Solution**:
  - Regenerate API key if compromised
  - Check API key restrictions
  - Verify package name matches in restrictions

#### 5.4 Build Errors
- **Symptom**: Gradle build failures
- **Solution**:
  - Run `flutter clean && flutter pub get`
  - Check NDK version compatibility
  - Verify all dependencies are up to date

## Step 6: Production Setup

### 6.1 Release API Key
1. Create a separate API key for production
2. Add production SHA-1 fingerprint to restrictions
3. Update production build configuration

### 6.2 Security Best Practices
- Never commit API keys to version control
- Use different API keys for development/production
- Regularly rotate API keys
- Monitor API usage in Google Cloud Console
- Set up billing alerts

## Configuration Status Check

The app includes a built-in configuration checker. When maps fail to load, you'll see:
- Configuration status for each API
- Setup instructions
- Quick validation button

## API Usage and Billing

### Free Tier Limits
- Maps SDK: 28,000 map loads per month
- Places API: Limited requests per month
- Directions API: Limited requests per month

### Monitoring Usage
1. Go to Google Cloud Console
2. Navigate to **APIs & Services > Dashboard**
3. Monitor API usage and quotas
4. Set up billing alerts

## Support

If you encounter issues:
1. Check the configuration status in the app
2. Review Google Cloud Console logs
3. Verify all APIs are enabled
4. Check API key restrictions
5. Ensure proper permissions are granted

## Security Notes

⚠️ **Important Security Reminders**:
- Never hardcode API keys in source code
- Use environment variables for API keys
- Restrict API keys to specific applications
- Monitor API usage regularly
- Rotate keys periodically

## Next Steps

After successful setup:
1. Test all map features thoroughly
2. Implement additional location services as needed
3. Add custom map styling if desired
4. Set up monitoring and alerts
5. Plan for production deployment

---

For more detailed information, refer to:
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Flutter Google Maps Plugin](https://pub.dev/packages/google_maps_flutter)
- [ResQRoute Technical Documentation](./README.md)
