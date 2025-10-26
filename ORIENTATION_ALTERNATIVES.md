# Orientation Quick Reference

## Current Status
- **Orientation**: `.left`
- **Video Mirrored**: `true`
- **Y-flip**: No

## If .left Doesn't Work, Try These:

### Option 1: .up with Y-flip
```swift
// Line ~240 in CameraPoseManager.swift
orientation: .up,

// Line ~307 in convertVisionPointToScreen
let captureDevicePoint = CGPoint(x: visionPoint.x, y: 1.0 - visionPoint.y)
```

### Option 2: Remove video mirroring
```swift
// Line ~195 in CameraPoseManager.swift - COMMENT OUT:
// if connection.isVideoMirroringSupported {
//     connection.isVideoMirrored = true
// }

// Then try orientation .right with NO Y-flip
orientation: .right,

// Line ~307:
let captureDevicePoint = visionPoint
```

### Option 3: .right with Y-flip
```swift
// Line ~240:
orientation: .right,

// Line ~307:
let captureDevicePoint = CGPoint(x: visionPoint.x, y: 1.0 - visionPoint.y)
```

## Testing Matrix

| Setting | Vertical OK? | Horizontal OK? | Notes |
|---------|-------------|----------------|-------|
| `.right`, no flip | ❌ (inverted) | ? | First attempt |
| `.leftMirrored`, no flip | ? | ❌ (inverted) | Second attempt |
| `.left`, no flip | ? | ? | **CURRENT - test this** |
| `.up`, with Y-flip | ? | ? | Try if .left fails |
| `.right`, no mirror, no flip | ? | ? | Alternative approach |

## How to Test Each Setting

### Vertical Test (Y-axis):
1. Stand straight
2. Slowly squat down
3. **PASS**: Dots move down as you squat
4. **FAIL**: Dots move up as you squat

### Horizontal Test (X-axis):
1. Stand straight, arms at sides
2. Raise your left arm out to the side
3. **PASS**: Left shoulder dot moves in same direction as your arm
4. **FAIL**: Dot moves opposite direction

### Full Alignment Test:
1. Stand in T-pose (arms out)
2. Check all 8 dots
3. **PASS**: Each dot is on its actual joint (< 30px offset)
4. **FAIL**: Dots are offset, mirrored, or inverted

## Quick Debug Snippet

Add to CameraTestViewController.didUpdatePoseData:

```swift
if let leftShoulder = data.jointPositions[.leftShoulder],
   let rightShoulder = data.jointPositions[.rightShoulder],
   let leftKnee = data.jointPositions[.leftKnee] {
    
    print("Left Shoulder: (\(Int(leftShoulder.x)), \(Int(leftShoulder.y)))")
    print("Right Shoulder: (\(Int(rightShoulder.x)), \(Int(rightShoulder.y)))")
    print("Left Knee: (\(Int(leftKnee.x)), \(Int(leftKnee.y)))")
    print("Screen: \(Int(view.bounds.width)) x \(Int(view.bounds.height))")
    
    // Check relationships
    print("Shoulder above knee? \(leftShoulder.y < leftKnee.y ? "✅" : "❌")")
}
```

## Success Criteria

All must be true:
- [ ] Squat down → dots move down
- [ ] Stand up → dots move up  
- [ ] Move left arm → left shoulder dot moves with it
- [ ] Move right arm → right shoulder dot moves with it
- [ ] All dots within 30px of actual joints
- [ ] No systematic offset pattern
- [ ] Smooth tracking during movement

## Most Common Working Configurations

### iPhone Portrait Mode (Front Camera):
**Most likely**: `.left` with no flip, video mirrored
**Alternative**: `.up` with Y-flip, video mirrored

### If Nothing Works:
Try removing video mirroring entirely and use `.right` with no flip.
The preview won't be mirrored (less natural) but coordinates should work.

---

**Fill in what works for you:**
- Device: ___________________
- Orientation: ___________________
- Y-flip: Yes / No
- Video mirrored: Yes / No

