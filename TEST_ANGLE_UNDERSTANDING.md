# Angle Understanding Test

## Knee Angle Calculation

### Points Used:
- `pointA` = Hip
- `vertex` = Knee (angle measured here)
- `pointC` = Ankle

### What This Measures:
**Interior angle at the knee** between:
- Vector 1: Knee → Hip (thigh)
- Vector 2: Knee → Ankle (shin)

### Expected Values:

#### Standing Straight:
```
   Hip
    |
    | Thigh (straight)
    |
   Knee
    |
    | Shin (straight)
    |
  Ankle

Angle: ~180° (fully extended leg)
```

#### Parallel Squat (90° at knee):
```
  Hip —————
         Thigh
            \
            Knee (90°)
             |
             | Shin
             |
           Ankle

Angle: ~90° (right angle = parallel depth)
```

#### Deep Squat:
```
  Hip —————
       Thigh
         \
         Knee (70°)
          |
          | Shin
          |
        Ankle

Angle: 70° (acute angle = deep squat)
```

### Current Thresholds:
- MIN: 70° (deep squat)
- MAX: 95° (just below parallel)

### Problem Analysis:

**If all reps are being counted as bad, one of these is happening:**

1. **Angles are consistently outside 70-95° range**
   - Too high (>95°): Quarter squats, not deep enough
   - Too low (<70°): Going too deep (unlikely)

2. **Knee forward threshold too strict**
   - 25% of shin length might be too low

3. **Back angle threshold too strict**
   - 50° from vertical might catch too many people

Let me check console logs to see actual values...

