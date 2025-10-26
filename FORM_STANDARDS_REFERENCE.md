# Barbell Back Squat Form Standards - Quick Reference

## Current Thresholds (Final Version)

### ✅ Knee Angle: 70° - 95°
**Measurement:** Interior angle at knee joint (Hip → Knee ← Ankle)

| Angle | Depth | Status |
|-------|-------|--------|
| **<70°** | Too deep | ❌ BAD - "Going too deep" |
| **70°** | Below parallel (deep) | ✅ GOOD |
| **80°** | Below parallel | ✅ GOOD |
| **90°** | Parallel (ideal) | ✅ GOOD |
| **95°** | At-parallel (minimum) | ✅ GOOD |
| **>95°** | Quarter squat | ❌ BAD - "Not deep enough" |
| **110°** | Shallow quarter squat | ❌ BAD |
| **180°** | Standing straight | N/A |

### ✅ Knee Forward Position: ≤25% of Shin Length
**Measurement:** Horizontal knee-to-ankle distance as percentage of shin length (vertical knee-to-ankle distance)

**Formula:** `(knee_forward_distance / shin_length) × 100`

| Percentage | Status | Example (300px shin) |
|------------|--------|---------------------|
| **0-20%** | ✅ EXCELLENT | 0-60px |
| **20-25%** | ✅ GOOD | 60-75px |
| **>25%** | ❌ BAD - "Knees too far forward" | >75px |

**Why normalized by shin length?**
- ✅ **Scales with body size:** Tall/short users judged by same biomechanical standard
- ✅ **Camera distance independent:** Works at 5ft or 8ft from camera
- ✅ **Biomechanically sound:** 25% of shin length is consistent across populations

**Rationale:** Some forward knee travel is natural (up to 25% of shin), but excessive forward drift (>25%) indicates:
- Weight shifted too far forward
- Poor hip drive
- Lack of sitting back into the squat

### ✅ Back Angle: ≤50° from vertical
**Measurement:** Angle of shoulder-hip line from vertical axis

| Angle | Status |
|-------|--------|
| **0-30°** | ✅ EXCELLENT - Very upright |
| **30-50°** | ✅ GOOD - Acceptable lean |
| **>50°** | ❌ BAD - "Keep back more upright" |

**Rationale:** Some forward lean is natural in barbell back squats, but excessive lean indicates poor core stability or weight too far forward.

---

## Form Analysis Logic

### Good Form Criteria (ALL must pass):
1. ✅ Knee angle: 70° ≤ angle ≤ 95°
2. ✅ Knee forward: ≤25% of shin length
3. ✅ Back angle: ≤50° from vertical

### Bad Form (ANY can fail):
- ❌ Knee angle <70° → "Going too deep"
- ❌ Knee angle >95° → "Not deep enough"
- ❌ Knee forward >25% of shin → "Knees too far forward"
- ❌ Back angle >50° → "Keep back more upright"

---

## Common Form Issues Detected

### Issue: "Not deep enough"
- **Cause:** Knee angle >95° (quarter squat)
- **Fix:** Squat deeper until thighs are at least parallel to ground
- **Target:** Aim for 85-95° at bottom

### Issue: "Going too deep"
- **Cause:** Knee angle <70° (extreme depth)
- **Fix:** Control descent, stop at parallel or slightly below
- **Note:** Rare issue, only for extreme "ass-to-grass" squats

### Issue: "Knees too far forward"
- **Cause:** Knee forward distance >25% of shin length
- **Fix:** Sit back more, engage hips, push through heels
- **Indicator:** Weight shifted too far forward
- **Example:** If shin is 200px, knees are >50px forward

### Issue: "Keep back more upright"
- **Cause:** Back angle >50° from vertical
- **Fix:** Chest up, core tight, maintain neutral spine
- **Indicator:** Core weakness or bar position too low

---

## Testing Guide

### Good Form Examples (Should PASS):
```
Example 1: Parallel Squat (Tall User)
- Knee angle: 92° ✅
- Shin length: 400px
- Knee forward: 90px (22.5% of shin) ✅
- Back angle: 42° ✅
Result: GOOD FORM ✅

Example 2: Deep Squat (Short User)
- Knee angle: 75° ✅
- Shin length: 200px
- Knee forward: 45px (22.5% of shin) ✅
- Back angle: 38° ✅
Result: GOOD FORM ✅
```

### Bad Form Examples (Should FAIL):
```
Example 1: Quarter Squat
- Knee angle: 105° ❌ (too shallow)
- Shin length: 300px
- Knee forward: 60px (20% of shin) ✅
- Back angle: 35° ✅
Result: BAD FORM ❌ - "Not deep enough"

Example 2: Excessive Knee Forward (Tall User)
- Knee angle: 88° ✅
- Shin length: 380px
- Knee forward: 110px (28.9% of shin) ❌
- Back angle: 40° ✅
Result: BAD FORM ❌ - "Knees too far forward"

Example 3: Excessive Knee Forward (Short User)
- Knee angle: 90° ✅
- Shin length: 180px
- Knee forward: 55px (30.6% of shin) ❌
- Back angle: 40° ✅
Result: BAD FORM ❌ - "Knees too far forward"

Example 4: Excessive Forward Lean
- Knee angle: 90° ✅
- Shin length: 250px
- Knee forward: 55px (22% of shin) ✅
- Back angle: 58° ❌ (leaning too far)
Result: BAD FORM ❌ - "Keep back more upright"
```

---

## Rationale Behind Thresholds

### Why 70-95° for knee angle?
- **95° = Parallel depth:** Industry standard minimum for "full squat"
- **70° = Below parallel:** Excellent depth without extreme range
- **Rejects quarter squats:** >95° is insufficient depth
- **Prevents extreme depth:** <70° may cause joint stress

### Why 25% of shin length for knee forward?
- **Biomechanically consistent:** Same standard for all body types (tall/short)
- **Allows natural movement:** Up to 25% forward travel is biomechanically sound
- **Catches excessive drift:** >25% indicates weight too far forward
- **Scale independent:** Works at any camera distance (5ft, 8ft, etc.)
- **Body size adaptive:** Automatically scales with user's shin length
- **Based on biomechanics:** Percentage-based measurements are standard in kinesiology

### Why 50° for back angle?
- **Allows natural lean:** Back squats require some forward torso angle
- **Prevents "good morning":** Excessive lean is dangerous under load
- **Maintains spine safety:** Ensures weight stays balanced
- **Standard across literature:** Aligned with coaching recommendations

---

## Version History

| Version | Knee Angle | Knee Forward | Notes |
|---------|------------|--------------|-------|
| V1 (Original) | 50-70° | 30px | Too strict (fixed pixels) |
| V2 (First fix) | 70-110° | 80px | Too lenient (fixed pixels) |
| V3 | 70-95° | 50px | Proper depth (still fixed pixels) |
| **V4 (Current)** | **70-95°** | **25% of shin** | ✅ **Normalized thresholds** |

**Current version uses body-proportion-based thresholds that scale with user size and camera distance.**

### Key Innovation (V4):
- **Normalized measurements:** Knee forward is now a percentage of shin length
- **Body size independent:** Works for tall, short, and all body types
- **Camera distance agnostic:** Consistent assessment at any camera distance
- **Biomechanically sound:** Based on body segment relationships, not arbitrary pixels

