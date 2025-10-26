# Debug State Detection Issues

## 🔍 What Was Changed

### **Critical Fixes:**

1. **Lowered depth threshold**: 50px → 30px (more forgiving)
2. **Removed frame counter**: Was requiring 3 consecutive frames (too strict)
3. **Simplified state machine**: Clear, predictable transitions
4. **Enhanced debugging**: See hip/knee positions and drop amount every frame

---

## 🧪 Test This Now

### **Step 1: Check Raw Values**

1. Build and run
2. Stand in side view
3. **Watch Xcode console for:**

```
🔍 DEPTH CHECK: Hip Y=XXX, Knee Y=YYY, Drop=ZZZpx
   Deep Squat (>30px): false, Partial (10-30px): false
   Current State: standing
   Hip Movement: 0px
```

**Write down these values when standing:**
- Hip Y: ________
- Knee Y: ________
- Drop: ________

---

### **Step 2: Squat Down Slowly**

**Watch console as you squat:**

```
🔍 DEPTH CHECK: Hip Y=350, Knee Y=450, Drop=-100px  ← Hip ABOVE knee (standing)
   ...

🔍 DEPTH CHECK: Hip Y=450, Knee Y=450, Drop=0px  ← Hip AT knee level
   Hip Movement: 10px ↓ DOWN
   → Transition: Standing → Descending  ← Should see this!
   ...

🔍 DEPTH CHECK: Hip Y=480, Knee Y=450, Drop=30px  ← Hip BELOW knee
   → Transition: Descending → InSquat ✅  ← CRITICAL! Must see this!
   ...
```

---

## 📊 Understanding the Drop Amount

### **What "Drop" Means:**

In screen coordinates (Y increases downward):

```
Standing Position:
  Shoulder Y=200
      ↓
    Hip Y=300  ←──┐
      ↓          │ Drop = hipY - kneeY
   Knee Y=450  ←─┘      = 300 - 450
      ↓                 = -150 (NEGATIVE)
  Ankle Y=550

Drop < 0 = Hip ABOVE knee (standing)
```

```
Squat Position:
  Shoulder Y=200
      ↓
      ↓ (torso leans forward)
    Hip Y=480  ←──┐
      ↓          │ Drop = hipY - kneeY
   Knee Y=450  ←─┘      = 480 - 450
      ↓                 = +30 (POSITIVE)
  Ankle Y=550

Drop > 30 = Hip BELOW knee (squat) ✅
```

---

## 🎯 Diagnostic Questions

### **Question 1: What is your Drop value when squatting?**

**Test:** Do a deep squat, read console

**If Drop is negative (-100, -50, etc.):**
- Problem: Hip is not dropping below knee in screen space
- Possible cause: 
  - Camera angle too high/low
  - Not squatting deep enough
  - Coordinate detection issue

**If Drop is 0-29px:**
- Problem: Hip dropping, but not enough
- Threshold: Need > 30px
- Solution: Squat deeper OR move closer to camera

**If Drop is 30+px:**
- ✅ Good! State should transition to `.inSquat`
- Check console for "→ Transition: Descending → InSquat"

---

### **Question 2: Do you see state transitions?**

**Expected sequence:**
```
Standing
   → Transition: Standing → Descending
Descending ⬇️
   → Transition: Descending → InSquat ✅
In Squat 🏋️
   → Transition: InSquat → Ascending
Ascending ⬆️
   → Transition: Ascending → Standing (rep complete!)
Standing
```

**If you only see:**
```
Standing
   → Transition: Standing → Descending
Descending ⬇️
Standing
```

**Problem:** Never reaching `.inSquat` state
- Drop amount not exceeding 30px
- Need to squat deeper

---

## 🔧 Potential Fixes Based on Your Values

### **Scenario 1: Drop is always negative**

**Diagnosis:** Hip never drops below knee

**Possible Causes:**
1. Camera positioned too high or too low
2. Not squatting deep enough (partial squats)
3. Y coordinate system inverted (unlikely, since skeleton works)

**Solutions:**
- Squat deeper (hips should go below knees)
- Adjust camera height (chest level optimal)
- Check if you're doing proper depth squats

---

### **Scenario 2: Drop is 10-29px**

**Diagnosis:** Squatting, but not deep enough for threshold

**Solution:** Lower the threshold temporarily for testing:

```swift
// In SquatAnalyzer.swift, line ~103
let isDeepSquat = hipDropAmount > 15.0  // Lower to 15px for testing
```

Or squat deeper!

---

### **Scenario 3: Drop is 30+px but no state change**

**Diagnosis:** State machine logic issue

**Check:** Console should show:
```
→ Transition: Descending → InSquat ✅
```

If not appearing, there's a logic bug.

---

## 📝 What to Report

Please run the app and report these values:

### **When Standing:**
- Hip Y: ________
- Knee Y: ________
- Drop: ________
- State: ________

### **When in Deep Squat (bottom position):**
- Hip Y: ________
- Knee Y: ________
- Drop: ________
- State: ________ (should be "In Squat")
- Do you see "→ Transition: Descending → InSquat"? Yes/No

### **Console Output:**
Copy/paste the console output from doing one complete squat.

---

## 🎯 Expected Debug Output

### **Good Working Example:**

```
🔍 DEPTH CHECK: Hip Y=300, Knee Y=450, Drop=-150px
   Deep Squat (>30px): false
   Current State: standing
   Hip Movement: 0px

[User starts to squat]

🔍 DEPTH CHECK: Hip Y=380, Knee Y=450, Drop=-70px
   Deep Squat (>30px): false
   Current State: standing
   Hip Movement: 80px ↓ DOWN
   → Transition: Standing → Descending
   ✨ STATE CHANGED: standing → descending

🔍 DEPTH CHECK: Hip Y=450, Knee Y=450, Drop=0px
   Deep Squat (>30px): false
   Current State: descending
   Hip Movement: 70px ↓ DOWN

🔍 DEPTH CHECK: Hip Y=485, Knee Y=450, Drop=35px
   Deep Squat (>30px): true ✅
   Current State: descending
   Hip Movement: 35px ↓ DOWN
   → Transition: Descending → InSquat ✅
   ✨ STATE CHANGED: descending → inSquat

📐 Analyzing form using right side
   Knee Angle: 92.3°
   Knee Angle Good: true
   Overall Form: ✅ GOOD

🎯 Form Analysis:
   State: In Squat 🏋️
   Form: ✅ GOOD
   Knee Angle: 92.3°
   Reps: 0 total

[User starts to rise]

🔍 DEPTH CHECK: Hip Y=450, Knee Y=450, Drop=0px
   Deep Squat (>30px): false
   Current State: inSquat
   Hip Movement: -35px ↑ UP
   → Transition: InSquat → Ascending
   ✨ STATE CHANGED: inSquat → ascending

🔍 DEPTH CHECK: Hip Y=300, Knee Y=450, Drop=-150px
   Deep Squat (>30px): false
   Current State: ascending
   Hip Movement: -150px ↑ UP
   → Transition: Ascending → Standing (rep complete!)
   ✨ STATE CHANGED: ascending → standing

🎯 Form Analysis:
   State: Standing
   Reps: 1 total (✅ 1 good, ❌ 0 bad) ← Rep counted!
```

---

## 🚨 If You Don't See "InSquat" State

The console will tell you exactly why:

**Look for:**
```
🔍 DEPTH CHECK: Hip Y=XXX, Knee Y=YYY, Drop=ZZZpx
   Deep Squat (>30px): false  ← This should be TRUE when squatting!
```

**If "Deep Squat" is always false:**
- Drop value is ≤ 30px
- You need to squat deeper
- OR lower the threshold

**Quick Fix to Test:**
Temporarily change threshold to 15px in `SquatAnalyzer.swift` line 103:
```swift
let isDeepSquat = hipDropAmount > 15.0  // More sensitive
```

This will help determine if it's a depth issue or code issue.

---

## ✅ Verification Steps

1. **Run app** with new debug code
2. **Do ONE slow squat**
3. **Copy entire console output**
4. **Check for:**
   - Hip Y and Knee Y values
   - Drop calculation (hipY - kneeY)
   - "Deep Squat (>30px): true" when at bottom
   - State transitions appearing
   - "→ Transition: Descending → InSquat" message

The debug logs will tell us exactly what's wrong! 🔍

