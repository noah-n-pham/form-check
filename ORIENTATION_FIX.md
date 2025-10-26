# Y-Axis Inversion Fix

## ✅ What Was Fixed

Removed the Y-coordinate flip in the conversion because:
- Vision orientation is set to `.right`
- The `.right` orientation already handles coordinate transformation
- `layerPointConverted(fromCaptureDevicePoint:)` handles the final conversion
- Double-flipping was causing the inversion

### Changed:
```swift
// OLD (was causing double-flip):
let captureDevicePoint = CGPoint(x: visionPoint.x, y: 1.0 - visionPoint.y)

// NEW (let Vision orientation and AVFoundation handle it):
let captureDevicePoint = visionPoint
```

## 🧪 Test Now

1. **Rebuild** the app (Cmd+Shift+K, then Cmd+R)
2. **Position yourself** (sideways, 5-7 feet from camera)
3. **Slowly squat down**

### Expected Behavior:
- ✅ When you squat DOWN → dots move DOWN on screen
- ✅ When you stand UP → dots move UP on screen
- ✅ Dots stay aligned with your actual joints

## 🔧 If Still Not Perfect

If the inversion persists or coordinates are still wrong, try these orientation combinations:

### Option 1: Try `.leftMirrored` orientation
In `CameraPoseManager.swift`, line ~240, change:

```swift
// FROM:
orientation: .right,

// TO:
orientation: .leftMirrored,
```

### Option 2: Try `.up` orientation
```swift
orientation: .up,
```

### Option 3: Try `.left` orientation  
```swift
orientation: .left,
```

### Option 4: Add back Y-flip with `.up` orientation
If you try `.up` and dots are inverted, add Y-flip back:

```swift
// In detectPose method (line ~240):
orientation: .up,

// In convertVisionPointToScreen (line ~307):
let captureDevicePoint = CGPoint(x: visionPoint.x, y: 1.0 - visionPoint.y)
```

## 📊 Quick Test Matrix

Try these combinations systematically:

| Orientation | Y-Flip | Try If... |
|------------|--------|-----------|
| `.right` | No flip | **Current setting** (try first) |
| `.leftMirrored` | No flip | Points still inverted |
| `.up` | With flip (1.0 - y) | Left/right seem wrong |
| `.left` | No flip | Mirror seems wrong |

## 🎯 Correct Behavior Checklist

When working correctly:
- [ ] Squat down → dots move down
- [ ] Stand up → dots move up
- [ ] Raise arm → corresponding dot moves up
- [ ] Lower arm → corresponding dot moves down
- [ ] Dots align with actual joint positions
- [ ] No offset or drift during movement

## 💡 Understanding Camera Orientations

### Front Camera in Portrait Mode:
- **Physical camera**: Captures landscape by default
- **Orientation parameter**: Tells Vision how to interpret the image
- **`.right`**: Image rotated 90° clockwise
- **`.left`**: Image rotated 90° counter-clockwise
- **`.leftMirrored`**: Rotated 90° counter-clockwise + mirrored
- **`.up`**: No rotation (landscape)

### Why Different Devices May Need Different Settings:
- Camera hardware varies by device
- AVFoundation handles orientation differently on iPad vs iPhone
- Front camera mounting position affects coordinate system

## 🐛 Debug Helper

Add this to `CameraTestViewController.didUpdatePoseData` to see coordinate values:

```swift
// Add after updateKeypoints(with: data)
if let shoulder = data.jointPositions[.leftShoulder],
   let knee = data.jointPositions[.leftKnee] {
    print("Shoulder Y: \(Int(shoulder.y)), Knee Y: \(Int(knee.y))")
    // Shoulder Y should be LESS than Knee Y (shoulder higher on screen)
}
```

### What to Look For:
- **Correct**: Shoulder Y (e.g., 150) < Knee Y (e.g., 400)
- **Inverted**: Shoulder Y (e.g., 700) > Knee Y (e.g., 300)

## ✅ Final Verification

Once you find the right setting:

1. **Stand straight** → All dots aligned vertically
2. **Squat down slowly** → All dots move down together
3. **Stand up** → All dots move up together
4. **Bend forward** → Hip/shoulder dots move horizontally
5. **Return upright** → Dots return to vertical alignment

If all tests pass ✅, the coordinate system is working correctly!

---

## 📝 Notes

The current fix (`.right` orientation with no Y-flip) should work for most iPhones in portrait mode with front camera. If you need to use a different setting, update this document with what worked for your specific device setup.

**Device tested on**: _________________  
**Working orientation**: _________________  
**Y-flip needed**: Yes / No

