# Android Auto Implementation

## Overview

This document describes the Android Auto support implementation added to the Koel Player mobile app.

## Changes Made

### 1. Android Manifest Updates

**File: `android/app/src/main/AndroidManifest.xml`**

Added the following declarations:

#### Android Auto Feature Declaration
```xml
<uses-feature android:name="android.hardware.automotive" android:required="false" />
```
This declares that the app supports automotive hardware but doesn't require it, allowing the app to work on both regular Android devices and Android Auto systems.

#### Automotive App Metadata
```xml
<meta-data
    android:name="com.google.android.gms.car.application"
    android:resource="@xml/automotive_app_desc" />
```
This metadata points to the automotive app descriptor that specifies the app's automotive capabilities.

### 2. Automotive App Descriptor

**File: `android/app/src/main/res/xml/automotive_app_desc.xml`** (NEW)

```xml
<?xml version="1.0" encoding="utf-8"?>
<automotiveApp>
    <uses name="media" />
</automotiveApp>
```

This descriptor indicates that the app provides media functionality for Android Auto.

### 3. Audio Handler Enhancements

**File: `lib/audio_handler.dart`**

Added media browsing support for Android Auto:

```dart
@override
Future<List<MediaItem>> getChildren(String parentMediaId,
    [Map<String, dynamic>? options]) async {
  // Root menu items for Android Auto
  if (parentMediaId == AudioService.recentRootId) {
    // Return recently played items
    return queue.value.take(10).toList();
  }

  if (parentMediaId == AudioService.browsableRootId) {
    // Return browsable categories
    return [
      MediaItem(
        id: '__queue__',
        album: '',
        title: 'Current Queue',
        playable: true,
        extras: {
          'isFolder': true,
        },
      ),
    ];
  }

  if (parentMediaId == '__queue__') {
    // Return current queue
    return queue.value;
  }

  return [];
}
```

This method allows Android Auto to browse through:
- Recently played items
- Current playback queue
- Browsable categories

### 4. Audio Service Configuration

**File: `lib/main.dart`**

Enhanced the `AudioService` initialization:

```dart
audioHandler = await AudioService.init(
  builder: () => KoelAudioHandler(),
  config: AudioServiceConfig(
    androidNotificationChannelId: 'dev.koel.app.channel.audio',
    androidNotificationChannelName: 'Koel audio playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: false,  // NEW: Keep service alive
    androidEnableQueue: true,              // NEW: Enable queue display
  ),
);
```

These additions ensure:
- The audio service remains active when paused (important for Android Auto)
- Queue information is properly exposed to Android Auto UI

## UI Improvements

### Enhanced Now Playing Screen

**File: `lib/ui/screens/now_playing.dart`**

Improvements made:
1. **Album Artwork Enhancement**
   - Added rounded corners (16px radius)
   - Added shadow effect for depth
   - Better padding and spacing

2. **Info Pane Improvements**
   - Increased spacing between elements
   - Better alignment of controls
   - Added padding for visual breathing room

3. **Bottom Controls**
   - Improved spacing and layout
   - Added tooltips for accessibility

### Enhanced Audio Controls

**File: `lib/ui/widgets/now_playing/audio_controls.dart`**

Improvements made:
1. **Play/Pause Button**
   - Larger size (68px)
   - Circular background with transparency
   - Better visual prominence

2. **Skip Controls**
   - Consistent sizing (52px)
   - Better spacing between buttons
   - Added tooltips for accessibility

3. **Overall Layout**
   - Added padding for better spacing
   - Centered alignment for visual balance

## How Android Auto Works

When a user connects their Android device running Koel Player to an Android Auto compatible vehicle:

1. **Discovery**: Android Auto detects the app through the `automotive_app_desc.xml` declaration
2. **Media Browser**: The car's infotainment system calls `getChildren()` to browse available content
3. **Playback Control**: All existing audio controls (play, pause, skip, etc.) work through the car's interface
4. **Queue Display**: The current queue is visible in the Android Auto UI
5. **Notifications**: Media notifications appear properly in the automotive interface

## Testing Android Auto

To test Android Auto support:

### With Android Auto Desktop Head Unit (DHU)

1. Install Android Auto DHU:
   ```bash
   sdkmanager --install "extras;google;auto"
   ```

2. Enable Developer Mode on Android device
3. Enable "Unknown sources" in Android Auto settings
4. Connect device via USB
5. Run DHU and test the app

### With Physical Vehicle

1. Install the app on Android device
2. Connect device to vehicle via USB or wireless Android Auto
3. Open Android Auto on the car's infotainment system
4. Navigate to the media section
5. Koel Player should appear as an available media source

### Verification Checklist

- [ ] App appears in Android Auto media sources
- [ ] Playback controls work (play, pause, skip)
- [ ] Album artwork displays correctly
- [ ] Current queue is browsable
- [ ] Voice commands work ("Ok Google, play music")
- [ ] Steering wheel controls function properly
- [ ] Media notifications appear correctly

## Benefits

1. **Safety**: Users can control music without touching their phone
2. **Integration**: Seamless integration with vehicle's infotainment system
3. **Voice Control**: "Ok Google" voice commands supported
4. **Large Display**: Album art and track info on larger screen
5. **Steering Wheel**: Control playback via steering wheel buttons

## Requirements

- Android device running Android 5.0 (API level 21) or higher ✓ (minSdkVersion: 21)
- Android Auto compatible vehicle or head unit
- USB cable or wireless Android Auto support

## Future Enhancements

Potential improvements for future releases:

1. **Browse by Category**: Add support for browsing by albums, artists, playlists
2. **Search Integration**: Implement search functionality for Android Auto
3. **Favorites**: Quick access to favorite tracks
4. **Recently Played**: Dedicated section for recently played items
5. **Custom Actions**: Add custom actions like "Shuffle All"

## References

- [Android Auto Developer Documentation](https://developer.android.com/training/cars/media)
- [audio_service Package](https://pub.dev/packages/audio_service)
- [MediaBrowserService](https://developer.android.com/reference/android/service/media/MediaBrowserService)
