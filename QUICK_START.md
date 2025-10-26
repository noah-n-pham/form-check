# FormCheck - Quick Start Guide

## 🎯 Project Status

### ✅ COMPLETE - Phase 1: Camera & Pose Detection
All camera and pose detection infrastructure is ready for integration!

### 📋 TODO - Phase 2: Form Analysis & UI (Your Team)
- Form analysis logic
- Visual overlays (skeleton, angles, feedback)
- Rep counter
- Session management

---

## 📁 File Structure

### **Core Data Models** (Ready to use)
```
DataModels.swift        - PoseData, FormAnalysisResult, RepCountData, SessionSummary, SquatState
Protocols.swift         - PoseDataDelegate, FormAnalysisDelegate
Constants.swift         - All threshold values and settings
```

### **Camera System** (Complete & Working)
```
CameraPoseManager.swift - Camera + Vision framework integration
CameraViewController.swift - Main camera view (ready for overlays)
```

### **Testing Tools** (Use these first!)
```
CameraTestViewController.swift - Visual testing with colored keypoints
HomeViewController.swift - Entry point (currently wired to test view)
```

### **Documentation**
```
CAMERA_SYSTEM_DOCS.md - Complete camera system documentation
TESTING_GUIDE.md - How to test the visual interface
QUICK_START.md - This file
```

---

## 🚀 Quick Start for Your Team

### 1️⃣ **Test the Camera System First**

```bash
# Build and run on physical device (camera required!)
# Home screen → "Start Squat Analysis" → Shows test view with colored dots
```

**You should see:**
- 🔵 Blue dots on shoulders
- 🟢 Green dots on hips
- 🔴 Red dots on knees
- 🟡 Yellow dots on ankles
- Debug info showing FPS and confidence

**If this works**, the camera and pose detection is ready! ✅

### 2️⃣ **Start Building in Parallel**

Your 3-person team can now work independently:

#### **Developer 1: Form Analysis**
**File to create**: `FormAnalyzer.swift`

```swift
import Foundation
import Vision

class FormAnalyzer {
    weak var delegate: FormAnalysisDelegate?
    
    func analyzePose(_ data: PoseData) -> FormAnalysisResult {
        // TODO: Calculate knee angle
        // TODO: Check knee position vs ankle
        // TODO: Calculate back angle
        // TODO: Detect squat depth
        // TODO: Determine squat state
        // TODO: Count reps
        
        return FormAnalysisResult(...)
    }
}
```

**Use these helpers**:
- `data.jointPositions[.leftKnee]` → CGPoint with screen coordinates
- `FormCheckConstants.GOOD_KNEE_ANGLE_MIN` → 80.0
- Calculate angles using joint positions (already in screen coords!)

#### **Developer 2: Visual Overlays**
**Files to create**: 
- `SkeletonOverlayView.swift` - Draw skeleton lines
- `AngleIndicatorView.swift` - Show angle arcs
- `FeedbackOverlayView.swift` - Display text feedback

```swift
class SkeletonOverlayView: UIView {
    func update(with poseData: PoseData, formResult: FormAnalysisResult) {
        // Draw lines between joints
        // Use green for good form, red for bad
        // Screen coordinates ready to use directly!
    }
}
```

**Integration point**:
```swift
// In CameraViewController
let skeletonView = SkeletonOverlayView()
addOverlayComponent(skeletonView)
```

#### **Developer 3: Integration & UI Polish**
**Tasks**:
1. Connect FormAnalyzer to CameraViewController
2. Wire up visual overlays
3. Create rep counter display
4. Build session summary screen
5. Add audio feedback
6. Polish transitions and UX

---

## 🔑 Key Concepts

### Data Flow
```
Camera Frame
    ↓
Vision Pose Detection
    ↓
PoseData (screen coordinates)
    ↓
Form Analyzer (your code)
    ↓
FormAnalysisResult
    ↓
Visual Overlays (your code)
```

### Available Joints
```swift
// Access via VNHumanBodyPoseObservation.JointName
.leftShoulder, .rightShoulder
.leftHip, .rightHip
.leftKnee, .rightKnee
.leftAnkle, .rightAnkle
```

### Using PoseData
```swift
func didUpdatePoseData(_ data: PoseData) {
    // Get joint position (already in screen coordinates!)
    if let knee = data.jointPositions[.leftKnee] {
        // Use directly: knee.x, knee.y
        kneeCircle.center = knee
    }
    
    // Check confidence
    if let confidence = data.confidences[.leftKnee] {
        // confidence is Float 0.0-1.0
        print("Knee confidence: \(confidence)")
    }
}
```

---

## 📐 Math Helpers You'll Need

### Calculate Angle Between 3 Points
```swift
func calculateAngle(point1: CGPoint, vertex: CGPoint, point2: CGPoint) -> Double {
    let vector1 = CGPoint(x: point1.x - vertex.x, y: point1.y - vertex.y)
    let vector2 = CGPoint(x: point2.x - vertex.x, y: point2.y - vertex.y)
    
    let dot = vector1.x * vector2.x + vector1.y * vector2.y
    let mag1 = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
    let mag2 = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)
    
    let cosine = dot / (mag1 * mag2)
    let angleRadians = acos(max(-1, min(1, cosine)))
    return angleRadians * 180 / .pi
}

// Usage:
let kneeAngle = calculateAngle(
    point1: hipPosition,
    vertex: kneePosition,
    point2: anklePosition
)
```

### Check if Knee is Past Ankle
```swift
func isKneePastAnkle(knee: CGPoint, ankle: CGPoint) -> Bool {
    let forwardDistance = knee.x - ankle.x
    return forwardDistance > FormCheckConstants.KNEE_FORWARD_THRESHOLD
}
```

---

## 🎨 UI Recommendations

### Color Scheme
- ✅ **Good Form**: `UIColor.systemGreen`
- ❌ **Bad Form**: `UIColor.systemRed`  
- ⚠️ **Warning**: `UIColor.systemOrange`
- 📊 **Info**: `UIColor.white.withAlphaComponent(0.9)`

### Layout
```
┌─────────────────────────────┐
│   Feedback Bar (top)        │  ← "Good form!" or "Knees too forward"
├─────────────────────────────┤
│                             │
│   Camera + Overlays         │  ← Skeleton, angles, keypoints
│   (fullscreen)              │
│                             │
├─────────────────────────────┤
│   Rep Counter (bottom)      │  ← "Reps: 5 | Good: 4 | Bad: 1"
└─────────────────────────────┘
```

---

## 🐛 Debugging Tips

### Check Pose Detection is Working
```swift
func didUpdatePoseData(_ data: PoseData) {
    print("🦴 Joints: \(data.jointPositions.count)")
    for (joint, position) in data.jointPositions {
        print("  \(joint): (\(position.x), \(position.y))")
    }
}
```

### Visualize Points (Quick Debug)
```swift
func addDebugDot(at position: CGPoint) {
    let dot = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    dot.backgroundColor = .red
    dot.center = position
    dot.layer.cornerRadius = 5
    view.addSubview(dot)
}
```

---

## 📞 Integration Points

### In CameraViewController

**Already implemented:**
- ✅ `currentPoseData` - Latest pose data
- ✅ `addOverlayComponent(_ view:)` - Add your UI
- ✅ `didUpdatePoseData(_:)` - Delegate callback

**Your team should add:**
```swift
// Add form analyzer
private let formAnalyzer = FormAnalyzer()

// In didUpdatePoseData:
func didUpdatePoseData(_ data: PoseData) {
    currentPoseData = data
    
    // YOUR CODE: Analyze form
    let formResult = formAnalyzer.analyzePose(data)
    currentFormResult = formResult
    
    // YOUR CODE: Update overlays
    skeletonView.update(with: data, formResult: formResult)
    feedbackView.update(with: formResult)
}
```

---

## ✅ Success Checklist

### Before You Start Coding:
- [ ] Run app on device
- [ ] See colored keypoints on your body
- [ ] FPS is 12+
- [ ] All 8 joints detected

### Phase 2 Goals:
- [ ] Calculate knee angle correctly
- [ ] Detect squat depth
- [ ] Count reps (up → down → up = 1 rep)
- [ ] Show visual feedback (skeleton, angles)
- [ ] Display text feedback
- [ ] Play audio alerts for bad form
- [ ] Show session summary on exit

---

## 🎉 You're Ready!

The camera and pose detection system is **complete and working**. Your team can now focus on:
1. Form analysis algorithms
2. Beautiful visual overlays
3. User experience polish

**Good luck at the hackathon! 🚀**

---

## 📚 Additional Resources

- `CAMERA_SYSTEM_DOCS.md` - Detailed camera system docs
- `TESTING_GUIDE.md` - Visual testing guide
- Apple Vision Framework: https://developer.apple.com/documentation/vision
- UIKit Drawing: https://developer.apple.com/documentation/uikit/drawing

**Questions?** Check the inline code comments - they're comprehensive!

