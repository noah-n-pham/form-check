# Coordinate Alignment Troubleshooting Guide

## ✅ Fixed in Latest Code

### What Was Changed:
1. **Proper coordinate conversion** using `AVCaptureVideoPreviewLayer.layerPointConverted(fromCaptureDevicePoint:)`
   - This method properly handles video gravity (.resizeAspectFill)
   - Accounts for aspect ratio differences
   - Handles orientation transformations

2. **Video orientation set to portrait** with mirroring enabled
   - More natural viewing experience
   - Consistent with user expectations

3. **Vision image orientation set to `.right`**
   - Correct for front camera in portrait mode
   - Ensures Vision detects joints in proper orientation

## 📱 Correct Camera Setup for Squat Analysis

### Physical Setup:

```
         📱 Phone
         |  |
         |  | ← Front camera facing YOU
         |  |
         ↓  ↓
    
    YOU (sideways)
    👤
    
    [Side view of your body]
```

### Step-by-Step:
1. **Place phone** on a stand/prop 5-7 feet TO YOUR SIDE
2. **Height**: Chest level (captures full body)
3. **Camera facing**: Toward you (you see yourself on screen)
4. **Your position**: Stand sideways/profile to camera
5. **Full body visible**: Head to feet in frame

### What You Should See on Screen:
- Your side profile (like a profile photo)
- Full body from head to toes
- Camera is mirrored (like a mirror), so movements feel natural

## 🔧 Testing the Fix

### Build and Test:
1. Clean build: Cmd+Shift+K
2. Build and run: Cmd+R
3. Navigate to test view
4. Position yourself as described above

### What to Look For:

#### ✅ GOOD - Dots Are Accurate:
- Blue dots on shoulders (not offset)
- Green dots on hips (tracking correctly)
- Red dots on knees (following knee position)
- Yellow dots on ankles (precise placement)
- Dots move smoothly with your movements
- No lag or jitter when you move slowly

#### ⚠️ STILL ISSUES:

**If dots are offset by same amount (systematic offset):**
- Try `.leftMirrored` orientation instead of `.right`
- Update line 240 in CameraPoseManager.swift

**If dots are jittery/jumping:**
- Too far from camera (move closer to 5 feet)
- Poor lighting (add more light)
- Complex background (use plain wall)

**If dots are stretched/squished:**
- Preview layer aspect ratio issue
- Verify `.resizeAspectFill` is set

**If some dots are accurate but others aren't:**
- Vision detection issue (not coordinate conversion)
- Joint occlusion or poor visibility
- Improve lighting and positioning

## 🧪 Quick Tests to Diagnose

### Test 1: Shoulder Alignment
Stand still, arms at sides. Blue shoulder dots should be:
- ✅ Exactly on your shoulders
- ✅ Same distance from body center as your actual shoulders
- ✅ Moving perfectly with shoulder rotation

### Test 2: Knee Tracking
Squat down slowly. Red knee dots should:
- ✅ Stay on kneecap throughout movement
- ✅ Track forward/backward motion precisely
- ✅ Not drift or lag behind

### Test 3: Full Body Proportions
Stand in T-pose. All dots should:
- ✅ Form a realistic stick figure
- ✅ Match your actual body proportions
- ✅ Shoulders wider than hips, etc.

## 🔄 Alternative Orientations to Try

If dots are still not aligning after the fix, try these orientations:

### Option 1: `.leftMirrored` (Most common for front camera)
```swift
// In CameraPoseManager.swift, line ~240
orientation: .leftMirrored,
```

### Option 2: `.left` (If mirroring is causing issues)
```swift
orientation: .left,
```

### Option 3: `.upMirrored` (Alternative approach)
```swift
orientation: .upMirrored,
```

## 📊 Debug Information

### Add This to CameraTestViewController to Debug:

Add to `didUpdatePoseData`:

```swift
func didUpdatePoseData(_ data: PoseData) {
    // ... existing code ...
    
    // Debug coordinate values
    if let leftShoulder = data.jointPositions[.leftShoulder],
       let leftKnee = data.jointPositions[.leftKnee] {
        print("Shoulder: (\(Int(leftShoulder.x)), \(Int(leftShoulder.y)))")
        print("Knee: (\(Int(leftKnee.x)), \(Int(leftKnee.y)))")
        print("Screen size: \(view.bounds.width) x \(view.bounds.height)")
    }
}
```

### Expected Coordinate Ranges:
- X: 0 to screen width (e.g., 0-390 for iPhone)
- Y: 0 to screen height (e.g., 0-844 for iPhone)
- Shoulder Y < Knee Y < Ankle Y (top to bottom)

### If coordinates are out of range:
- > screen width/height = conversion issue
- Negative values = orientation issue
- All near zero = detection failing

## 🎯 Expected Behavior After Fix

### Accuracy Target:
- ✅ Dots within 10-20 pixels of actual joints
- ✅ Consistent alignment across all joints
- ✅ Smooth tracking during movement
- ✅ No systematic offset

### Performance Target:
- ✅ 13-16 FPS
- ✅ < 100ms latency (movement to dot update)
- ✅ No frame drops during movement

## 🔍 Root Cause Analysis

### Previous Issue:
Manual coordinate conversion didn't account for:
- Video gravity scaling
- Aspect ratio differences between camera (4:3) and screen (varies)
- Preview layer transformations

### New Solution:
Using `layerPointConverted(fromCaptureDevicePoint:)`:
- ✅ Handles all transformations automatically
- ✅ Accounts for .resizeAspectFill
- ✅ Works with any screen size/aspect ratio
- ✅ Apple's recommended approach

## 📝 Next Steps

1. **Test the fixed code** with the setup described above
2. **Verify dots align accurately** with your joints
3. **If still offset**, try alternative orientations listed above
4. **Report results** so we can fine-tune if needed

## 💡 Pro Tips

### Better Detection:
- **Lighting**: Bright, even lighting from front
- **Clothing**: Fitted clothing helps detection
- **Background**: Plain wall (no patterns)
- **Distance**: 5-7 feet is optimal
- **Position**: Perfectly sideways (not angled)

### Testing Position:
Stand in a squat position (bottom of squat) and stay still:
- All 8 joints should be clearly visible
- Dots should be stable (not jumping)
- Confidence should be > 0.7 for all joints

---

## ✅ Success Criteria

Before moving on, verify:
- [ ] All 8 dots appear
- [ ] Dots align with actual joints (< 20px offset)
- [ ] Dots track smoothly during movement
- [ ] No systematic offset pattern
- [ ] Confidence > 0.6 average
- [ ] FPS > 12

If all checked ✅, coordinates are working correctly! 🎉

If issues persist, try the alternative orientations or check the debug output.

