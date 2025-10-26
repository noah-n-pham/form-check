# Form Quality Rating System (0-100)

## Overview

Replaced binary good/bad rep counting with a **science-based form quality rating system** that provides objective, quantitative feedback on squat form.

---

## System Design

### Scoring Algorithm

**Start with perfect score (100 points)** and deduct points based on biomechanical deviations:

#### 1. Knee Angle (40 points max) - Depth Assessment
**Optimal Range:** 70° - 95°
- **70°** = Deep squat (below parallel)
- **95°** = At-parallel depth
- **>95°** = Shallow/quarter squat

**Deductions:**
- **Too deep (<70°):** Deduct deviation/2.0, max 15 points
  - Minor issue - going deeper than necessary
  - Cue: "LESS DEPTH" (if >5 points off)
  
- **Not deep enough (>95°):** Deduct deviation/1.0, max 40 points
  - Major issue - insufficient depth
  - Cue: "GO DEEPER" (if >5 points off)

#### 2. Knee Forward Position (30 points max)
**Optimal Threshold:** ≤45% of shin length

**Deductions:**
- **Excessive forward (>45%):** Deduct deviation/1.0, max 30 points
  - Weight too far forward
  - Cue: "KNEES BACK" (if >10 points off)

#### 3. Back Angle (30 points max)
**Optimal Threshold:** ≤50° from vertical

**Deductions:**
- **Excessive lean (>50°):** Deduct deviation/1.0, max 30 points
  - Torso leaning too far forward
  - Cue: "CHEST UP" (if >10 points off)

### Score Interpretation

| Score | Quality | Color | Meaning |
|-------|---------|-------|---------|
| **85-100** | Excellent | 🟢 Green | Near-perfect form |
| **70-84** | Good | 🟡 Yellow | Acceptable with minor issues |
| **50-69** | Fair | 🟠 Orange | Multiple issues, needs work |
| **0-49** | Poor | 🔴 Red | Significant form problems |

---

## UI Presentation

### Display Elements (Clean, Clinical Design)

#### 1. Form Quality Rating (Center)
- **Font:** 72pt monospaced, bold
- **Position:** Screen center
- **Display:** Large number (0-100)
- **Color:** Green/Yellow/Red based on score
- **Behavior:** 
  - Hidden during rep
  - Animates in on rep completion (spring effect)
  - Fades out after 2.5 seconds

#### 2. Coaching Cues (Below Rating)
- **Font:** 24pt heavy
- **Position:** Below quality score
- **Display:** Bold action cues (max 3)
- **Examples:** 
  - "GO DEEPER"
  - "KNEES BACK"
  - "CHEST UP"
  - "LESS DEPTH"
- **Behavior:**
  - Shows only if corrections needed
  - Fades with quality score

#### 3. Rep Count (Top Right)
- **Font:** 20pt semibold
- **Position:** Top right corner
- **Display:** "REPS: X"
- **Behavior:** Always visible, updates immediately

### Design Principles

✅ **Clinical, not gamified** - No badges, stars, or celebratory elements
✅ **Action-oriented** - Cues tell user what to DO, not what's wrong
✅ **Minimal text** - Bold, concise commands only
✅ **Quickly processed** - Large text, high contrast, brief display
✅ **Non-intrusive** - Appears only after rep, not during exercise

---

## Technical Implementation

### New Files

#### 1. `FormQualityTracker.swift`
Replaces `RepCounter.swift` with quality-based tracking:

```swift
final class FormQualityTracker {
    private(set) var totalReps: Int = 0
    private var totalQualityScore: Int = 0
    private(set) var lastRepQuality: Int?
    private(set) var lastRepCues: [String] = []
    
    func updateWithAnalysis(_ result: FormAnalysisResult)
    func getCurrentData() -> RepCountData
}
```

**Logic:**
- Collects quality scores from all frames during `.inSquat`
- Calculates average quality for completed rep
- Aggregates coaching cues (cues appearing in >33% of frames)
- Partial reps = 30 quality score + "GO DEEPER" cue

#### 2. Updated `FormAnalysisResult` (DataModels.swift)
```swift
struct FormAnalysisResult {
    let formQuality: Int  // 0-100 rating
    let kneeAngle: Double?
    let kneeForwardPercent: Double?
    let backAngle: Double?
    let squatState: SquatState
    let coachingCues: [String]  // Action-oriented feedback
    let scoreBreakdown: String?  // For console logging
}
```

#### 3. Updated `RepCountData` (DataModels.swift)
```swift
struct RepCountData {
    let totalReps: Int
    let averageFormQuality: Int  // Average across all reps
    let lastRepQuality: Int?  // Most recent rep score
    let lastRepCues: [String]  // Most recent coaching cues
}
```

### Modified Files

#### `SquatAnalyzer.swift`
- `analyzeFormInSquat()` now calculates quality rating
- Returns `FormAnalysisResult` with score + cues
- Console logs show point deductions

#### `CameraViewController.swift`
- Uses `FormQualityTracker` instead of `RepCounter`
- Added UI labels: `formQualityLabel`, `coachingCuesLabel`, `repCountLabel`
- `showRepCompletionFeedback()` displays rating with animation
- Removed verbose console logging

---

## Example Scenarios

### Scenario 1: Perfect Form
```
Measurements:
- Knee angle: 82° (in 70-95° range)
- Knee forward: 38% of shin (<45%)
- Back angle: 32° from vertical (<50°)

Deductions:
- Knee angle: 0 (optimal)
- Knee forward: 0 (optimal)
- Back angle: 0 (optimal)

Result: 100/100
Cues: (none)
Color: Green
```

### Scenario 2: Shallow Squat
```
Measurements:
- Knee angle: 110° (15° past 95°)
- Knee forward: 40% of shin (<45%)
- Back angle: 35° from vertical (<50°)

Deductions:
- Knee angle: -15 (110-95 = 15° shallow)
- Knee forward: 0 (optimal)
- Back angle: 0 (optimal)

Result: 85/100
Cues: "GO DEEPER"
Color: Green
```

### Scenario 3: Multiple Issues
```
Measurements:
- Knee angle: 105° (10° past 95°)
- Knee forward: 55% of shin (10% over 45%)
- Back angle: 58° from vertical (8° over 50°)

Deductions:
- Knee angle: -10 (not deep enough)
- Knee forward: -10 (too far forward)
- Back angle: -8 (leaning forward)

Result: 72/100
Cues: "GO DEEPER", "KNEES BACK", "CHEST UP"
Color: Yellow
```

### Scenario 4: Poor Form
```
Measurements:
- Knee angle: 120° (25° past 95°)
- Knee forward: 60% of shin (15° over 45%)
- Back angle: 62° from vertical (12° over 50°)

Deductions:
- Knee angle: -25 (quarter squat)
- Knee forward: -15 (way too forward)
- Back angle: -12 (excessive lean)

Result: 48/100
Cues: "GO DEEPER", "KNEES BACK", "CHEST UP"
Color: Red
```

---

## Advantages Over Binary System

### OLD System (Good/Bad):
- ❌ Binary: Either pass or fail
- ❌ No gradation: 51% good = 99% good
- ❌ Discouraging: All issues = total failure
- ❌ Not actionable: "Bad form" doesn't say what to fix

### NEW System (0-100 Rating):
- ✅ Quantitative: Precise measurement of form quality
- ✅ Proportional: Minor issues = small deductions
- ✅ Encouraging: Can see incremental improvement
- ✅ Actionable: Specific cues for corrections
- ✅ Scientific: Based on biomechanical deviations
- ✅ Objective: Consistent across all users

---

## Coaching Cues Reference

| Cue | Trigger | Meaning | Biomechanical Fix |
|-----|---------|---------|-------------------|
| **GO DEEPER** | Knee angle >95° by >5° | Not reaching parallel | Squat lower, break parallel |
| **LESS DEPTH** | Knee angle <70° by >10° | Going too deep | Don't descend as far |
| **KNEES BACK** | Knee forward >45% by >10% | Knees too far over toes | Sit back more, engage hips |
| **CHEST UP** | Back angle >50° by >10° | Torso leaning forward | Keep chest up, core tight |

### Cue Display Rules:
- Max 3 cues shown (priority: depth → knees → back)
- Only shown if deduction >5 points (depth) or >10 points (position/back)
- Aggregated across all `.inSquat` frames (must appear in >33% of frames)
- Bold, uppercase, action-oriented
- No explanations or measurements shown to user

---

## Console Output

### During Rep:
```
📐 Analyzing form using LEFT side (conf: 0.69)
   ═══════════════════════════════════
   📐 Knee Angle: 82.0° | Deduction: -0 pts
   📍 Knee Forward: 38.2% of shin | Deduction: -0 pts
   📏 Back Angle: 32.5° | Deduction: -0 pts
   ═══════════════════════════════════
   🎯 FORM QUALITY: 100/100
   ═══════════════════════════════════
```

### Rep Completion:
```
✅ REP #1 COMPLETED: Quality 95/100
   📋 Coaching: GO DEEPER
```

### Partial Rep:
```
⚠️  REP #2 PARTIAL: Quality 30/100 (insufficient depth)
```

---

## Migration Notes

### Backward Compatibility:
`FormAnalysisResult` includes:
```swift
var isGoodForm: Bool {
    return formQuality >= 70
}
```

This allows skeleton renderer and other systems to continue using boolean logic (green/red) based on 70% threshold.

### Files Deprecated:
- `RepCounter.swift` → Replaced by `FormQualityTracker.swift`

### Files Modified:
- `DataModels.swift` - New result/data structures
- `SquatAnalyzer.swift` - Quality scoring algorithm
- `CameraViewController.swift` - New UI + tracker integration

### Files Added:
- `FormQualityTracker.swift` - Quality-based rep tracking

---

## Future Enhancements

### Potential Additions:
1. **Session average quality** - Track overall session performance
2. **Quality history graph** - Show improvement over time
3. **Quality-based recommendations** - "Your depth improved 12%"
4. **Personalized cues** - Learn user's common issues
5. **Rep-by-rep comparison** - "Rep 5 was 15% better than Rep 1"

### Not Included (By Design):
- ❌ Gamification (badges, achievements, streaks)
- ❌ Social features (leaderboards, sharing)
- ❌ Excessive animations
- ❌ Verbose feedback
- ❌ During-rep interruptions

---

## Summary

**Form quality rating system provides:**
- ✅ Objective 0-100 score per rep
- ✅ Proportional deductions for deviations
- ✅ Clear, actionable coaching cues
- ✅ Clean, clinical UI presentation
- ✅ Science-based biomechanical assessment

**Result:** Users get quantitative feedback on exactly what needs improvement, presented in a format that can be quickly processed during active exercise.

