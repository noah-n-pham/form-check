# Visual Testing Guide - Camera & Pose Detection

## ✅ New Component: CameraTestViewController

A complete visual testing interface for verifying camera and pose detection functionality.

## 🎯 Features

### 1. **Fullscreen Camera Preview**
- Front-facing camera at 1280x720 resolution
- 15 FPS pose detection
- Real-time pose tracking

### 2. **Colored Keypoint Overlays**
Visual feedback for detected joints using colored dots (10pt diameter):

- 🔵 **Blue** = Shoulders (left & right)
- 🟢 **Green** = Hips (left & right)  
- 🔴 **Red** = Knees (left & right)
- 🟡 **Yellow** = Ankles (left & right)

Each dot has:
- 10pt diameter circle
- Filled with joint-specific color
- White 2pt stroke for visibility
- CAShapeLayer for performance (reused, not recreated)

### 3. **Debug Overlay**
Semi-transparent info panel at top showing:
- **Joints Detected**: X / 8 (out of maximum 8)
- **Avg Confidence**: 0.00 - 1.00 range
- **FPS**: Real-time frame rate
- **Color Legend**: Quick reference for joint colors

### 4. **Performance Optimizations**
- ✅ CAShapeLayer reuse (not recreated every frame)
- ✅ Position updates only (no layer recreation)
- ✅ Minimal allocations per frame
- ✅ Background processing for video frames

### 5. **User Interface**
- Back button (bottom center) to return to home
- Clean, minimal UI - focus on testing
- Dark theme for camera overlay visibility

## 📱 How to Use

### Running the Test Interface

1. **Build & Run** on a physical device (camera required)
2. **Grant camera permission** when prompted
3. **Position yourself** 5-7 feet away from device
4. **Stand to the side** of the camera (profile view works best)
5. **Watch colored dots** appear on your joints

### What to Look For

#### ✅ Good Signs:
- All 8 dots appearing consistently
- Dots tracking your movement smoothly
- FPS around 15
- Average confidence > 0.6

#### ⚠️ Potential Issues:
- Missing dots = joints not detected (improve lighting/position)
- Low confidence < 0.5 = poor detection (adjust camera angle)
- Low FPS < 10 = performance issue
- Jittery dots = frame drops or occlusion

### Optimal Testing Setup

```
📱 Phone Position:
- Place on stand/prop 5-7 feet away
- Height: approximately waist/chest level
- Front camera facing you (side view)

👤 User Position:
- Stand sideways to camera
- Full body visible in frame
- Good lighting (avoid backlight)
- Clear background (no complex patterns)
```

## 🔧 Technical Details

### Architecture

```
┌────────────────────────────┐
│ CameraTestViewController   │
│  - Visual Test Interface   │
└──────────┬─────────────────┘
           │ uses
           ▼
┌────────────────────────────┐
│   CameraPoseManager        │
│  - Camera + Vision         │
└──────────┬─────────────────┘
           │ delegates
           ▼
┌────────────────────────────┐
│   PoseDataDelegate         │
│  - didUpdatePoseData()     │
└────────────────────────────┘
```

### Code Highlights

#### Reusable CAShapeLayer System
```swift
// Layers created once during setup
private var keypointLayers: [VNHumanBodyPoseObservation.JointName: CAShapeLayer] = [:]

// Only positions updated per frame (efficient!)
func updateKeypoints(with poseData: PoseData) {
    for (jointName, position) in poseData.jointPositions {
        guard let layer = keypointLayers[jointName] else { continue }
        layer.position = position  // Just update position!
        layer.isHidden = false
    }
}
```

#### FPS Calculation
```swift
private func calculateFPS() {
    let currentTime = CACurrentMediaTime()
    if lastUpdateTime > 0 {
        frameCount += 1
        let elapsed = currentTime - lastUpdateTime
        if elapsed >= 1.0 {
            currentFPS = Double(frameCount) / elapsed
            frameCount = 0
            lastUpdateTime = currentTime
        }
    } else {
        lastUpdateTime = currentTime
    }
}
```

## 🚀 Current Navigation

**Home Screen** → **CameraTestViewController** (temporarily)

The home screen button currently launches the test interface instead of the main camera view. This allows you to:
1. Verify camera setup works
2. Confirm pose detection is accurate
3. Test performance on target device
4. Debug coordinate conversion

### Switching Back to Production

When ready to use the main interface, update `HomeViewController.swift`:

```swift
@objc private func startButtonTapped() {
    // Switch back to production view
    let cameraVC = CameraViewController()  // Instead of CameraTestViewController()
    navigationController?.pushViewController(cameraVC, animated: true)
}
```

## 📊 Expected Performance

### Target Metrics:
- **FPS**: 13-16 (target: 15)
- **Detection Rate**: 6-8 joints consistently detected
- **Confidence**: 0.6-0.9 average
- **Latency**: < 100ms from detection to overlay update

### Device Requirements:
- iOS 16+
- Physical device with camera
- A12 Bionic or newer recommended

## 🐛 Troubleshooting

### No Camera Preview
- Check camera permissions in Settings
- Ensure running on physical device (not simulator)
- Check console for camera setup errors

### No Colored Dots Appearing
- Verify body is in frame (full body visible)
- Check lighting (improve if too dark)
- Try moving closer (4-6 feet optimal)
- Ensure profile/side view (not facing camera head-on)

### Low FPS (< 10)
- Close other apps
- Restart device
- Check device isn't overheating
- Reduce camera resolution (if needed)

### Dots Jumping/Jittery
- Improve lighting
- Remove complex background patterns
- Ensure no occlusion (nothing blocking body)
- Try different camera angle

## 💡 Tips for Best Results

1. **Lighting**: Natural daylight or bright indoor lighting works best
2. **Background**: Plain wall or simple background improves detection
3. **Clothing**: Fitted clothing helps (loose clothing can confuse detection)
4. **Position**: Side view with full body visible is ideal for squat analysis
5. **Distance**: 5-7 feet is optimal for full body detection

## ✅ Success Criteria

Before moving to form analysis, verify:
- [ ] All 8 joints detected consistently
- [ ] FPS stays above 12
- [ ] Average confidence > 0.6
- [ ] Dots track smoothly during movement
- [ ] No crashes or memory issues during 5+ minute session
- [ ] Coordinates look correct (dots on actual joint positions)

## 📝 Next Steps After Testing

Once the test interface shows good results:

1. **Form Analysis Team**: Start building form analysis logic
2. **UI Team**: Create production overlays (skeleton, angles, feedback)
3. **Integration Team**: Wire everything together in `CameraViewController`

The coordinate conversion is proven working if dots appear in correct positions! 🎉

## 🎬 Ready to Test!

Build on your device and verify the camera and pose detection system works correctly before building the form analysis components.

**Status**: Test interface complete and ready for device testing ✅

