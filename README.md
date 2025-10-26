<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/noah-n-pham/form-check">
    <!-- Logo Image AI generated -->
    <img width="90" height="90" alt="image" src="https://github.com/user-attachments/assets/000b8542-e70c-453f-ac2a-0c4369543cea" /> 
  </a>

<h3 align="center">FormCheck</h3>

  <p align="center">
    Your AI-Powered Squat Spotter – Real-Time Form Analysis That Catches Bad Form Before It Catches You
    <br />
    <em>Built for UF AI Days Hackathon</em>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#key-features">Key Features</a></li>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#technical-highlights">Technical Highlights</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

**FormCheck** is an intelligent iOS workout companion that uses Apple's Vision framework and real-time computer vision to analyze squat form. Designed for iOS 18+ devices, FormCheck provides instant feedback on technique, counts reps, and delivers personalized coaching insights. You don't even need an internet connection!

### Why FormCheck?

- **🎯 Prevent Injuries**: Bad form is the #1 cause of workout injuries. FormCheck catches form issues in real-time.
- **💪 Improve Performance**: Scientific angle analysis and depth tracking ensure optimal technique.
- **📊 Track Progress**: Comprehensive session summaries with performance trends and coaching advice.
- **🔒 Private & Secure**: All processing happens on-device. No data leaves your phone.
- **🚀 Always Available**: No subscription, no internet required, no personal trainer needed.

### Key Features

#### 🎥 **Real-Time Form Analysis**
- Live skeletal overlay showing body positioning
- Color-coded feedback (green = good form, red = needs correction)
- Instant coaching cues during workout
- Precise angle measurements for knees and back

#### 📈 **Smart Rep Counting**
- Automatic rep detection with state machine
- Quality scoring for each rep (0-100)
- Animated counter with haptic feedback
- Prevents false counts from bouncing

#### 🧠 **Intelligent Coaching System**
- Detects 6+ common form issues:
  - Knees tracking too far forward
  - Insufficient depth
  - Excessive depth
  - Back angle problems
  - Hip shooting up early
  - Knee valgus (caving in)
- Provides actionable, specific coaching advice
- Tracks most common issues across session

#### 📊 **Comprehensive Session Summary**
- Total reps with average, highest, and lowest quality scores
- Performance rating with encouraging messages
- Most common form issue identification
- Performance trend analysis (improvement vs. fatigue)
- Personalized coaching recommendations

#### 🎨 **Beautiful Modern UI**
- Clean, intuitive 4-screen flow
- Exercise tutorial screens with proper form guidance
- Setup instructions for optimal camera placement
- Smooth animations and transitions
- Dark mode optimized interface

#### 📱 **Workout Options**
- **Barbell Back Squats**: For weighted training
- **Bodyweight Squats**: Perfect for beginners or mobility work

### Built With

**Core Technologies:**
* **Swift** - Modern, safe, and performant
* **UIKit** - Native iOS UI framework for all screens
* **AVFoundation** - Camera capture and video processing
  - `AVCaptureSession` - Camera session management
  - `AVCaptureVideoPreviewLayer` - Live camera preview
  - `AVCaptureVideoDataOutput` - Frame-by-frame video processing
* **Vision Framework** - Apple's ML-powered pose detection
  - `VNDetectHumanBodyPoseRequest` - 17-point body pose detection
  - `VNHumanBodyPoseObservation` - Joint position tracking
* **Core Animation** - Smooth overlays and visualizations
  - `CAShapeLayer` - Skeletal rendering on camera preview
  - `CALayer` - Custom UI elements and effects
* **Haptic Feedback** - `UIImpactFeedbackGenerator` for tactile confirmation

**Architecture:**
- Clean MVVM-inspired architecture
- Protocol-oriented design for modularity
- Real-time processing pipeline at 30 FPS
- Efficient state management for rep tracking

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

- **iOS 18.0+** (Required for latest Vision APIs)
- **iPhone 13 or newer** (Recommended for optimal performance)
  - Pro models offer enhanced camera capabilities
- **Xcode 15.0+** (For development)
- **macOS** (iOS development requires Mac)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/noah-n-pham/form-check.git
   cd form-check
   ```

2. **Open in Xcode**
   ```bash
   open FormCheck.xcodeproj
   ```

3. **Connect your iPhone**
   - Use a physical device (camera required)
   - Simulator won't work for camera features

4. **Configure signing**
   - Select your development team in project settings
   - Xcode will automatically provision the app

5. **Build and Run**
   - Select your iPhone as the target device
   - Press `Cmd + R` or click the Run button
   - Grant camera permissions when prompted

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Quick Start Guide

1. **Select Your Exercise**
   - Launch FormCheck on your iPhone
   - Choose between "Barbell Back Squats" or "Free Bodyweight Squats"

2. **Learn Proper Form**
   - Review the tutorial screen showing ideal form
   - Understand which muscles are targeted
   - Read through the setup instructions

3. **Position Your Camera**
   - Place iPhone 6-8 feet away at waist height
   - **IMPORTANT**: Use a side angle view (not front-facing)
   - Ensure your full body is visible in frame
   - Use landscape orientation for best results

4. **Start Your Workout**
   - Stand in frame until positioning guide disappears
   - Begin performing squats at your own pace
   - Watch real-time feedback on screen
   - Rep counter updates automatically

5. **Review Your Session**
   - Tap "End Set" when finished
   - Review comprehensive performance summary
   - Read personalized coaching advice
   - Understand your most common form issues

### Pro Tips

- **Lighting**: Ensure good, even lighting for best detection
- **Clothing**: Wear fitted clothing for accurate joint detection
- **Camera Angle**: Side view is critical for depth and knee tracking
- **Distance**: 6-8 feet provides optimal full-body capture
- **Controlled Tempo**: Slow, controlled reps allow better analysis

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- TECHNICAL HIGHLIGHTS -->
## Technical Highlights

### Computer Vision Pipeline

```
Camera Frame (30 FPS)
    ↓
AVCaptureVideoDataOutput
    ↓
Vision Framework (VNDetectHumanBodyPoseRequest)
    ↓
17-Point Skeletal Model
    ↓
Form Analysis Engine
    ↓
Real-Time Feedback + Skeletal Overlay
```

### Form Analysis System

**Squat Analyzer** evaluates:
- **Knee Angle**: Ideal range 80-120° at bottom
- **Knee Forward Distance**: Should stay behind toes
- **Back Angle**: Maintain upright torso (< 45° from vertical)
- **Hip Depth**: Thighs at least parallel to ground
- **Joint Confidence**: Only analyzes high-confidence detections

**Rep Counter** uses state machine:
```
Standing → Descending → In Squat → Ascending → Standing (Rep Complete!)
```

### Key Algorithms

- **Side Selection Logic**: Automatically chooses best camera angle (left/right)
- **Anti-Flickering**: Prevents rapid side switching during reps
- **Form Quality Scoring**: Weighted algorithm (0-100 scale)
- **Trend Analysis**: Compares first half vs second half performance
- **Issue Frequency Tracking**: Identifies patterns across workout

### Performance Optimizations

- Efficient frame processing at 30 FPS
- Single `CAShapeLayer` for all skeleton rendering
- Throttled console logging to reduce overhead
- Smart state detection to prevent false positives
- Background queue processing for Vision requests

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

### CS Majors

<img src="https://contrib.rocks/image?repo=noah-n-pham/form-check">

- **Noah Pham** (noah-n-pham) - noah.n.pham@gmail.com
- **Kenzo Fukuda** (kofki) - kenzof28@gmail.com  
- **Jonathan Tang** (Jonathan510T) - jonathant0842@gmail.com

### Mechanical Engineering Major

<img height="64" width="64" src="https://media.licdn.com/dms/image/v2/D5635AQENzoDA6Gp37g/profile-framedphoto-shrink_400_400/profile-framedphoto-shrink_400_400/0/1737068686781?e=1762095600&v=beta&t=KynEgleJQBrb9Iv5HN8SrIvpwo1vUabVh9uxoHlMhXs">

- **Matt Tang** - tangm1@ufl.edu

**Project Repository**: [https://github.com/noah-n-pham/form-check](https://github.com/noah-n-pham/form-check)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

This project was built for the **UF AI Days Hackathon 2025**.

Special thanks to:

* [**UF AI Days Hackathon**](https://ai.ufl.edu/about/ai-days/) - For hosting this amazing event
* [**Vobile**](https://vobilegroup.com/home?lang=en-us) - Event sponsor
* [**UF SASE**](https://ufsase.com/) - Supporting organization
* **Apple Developer Documentation** - Excellent Vision framework guides
* **UF Computer Science Department** - For our education and support

### Technologies & Resources

- Apple Vision Framework for pose detection
- SwiftUI & UIKit design patterns
- iOS Human Interface Guidelines
- Form analysis research from exercise science literature

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<div align="center">

**Built with ❤️ by the FormCheck Team**

*Making workouts safer, smarter, and more effective—one rep at a time.*

</div>

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/noah-n-pham/form-check.svg?style=for-the-badge
[contributors-url]: https://github.com/noah-n-pham/form-check/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/noah-n-pham/form-check.svg?style=for-the-badge
[forks-url]: https://github.com/noah-n-pham/form-check/network/members
[stars-shield]: https://img.shields.io/github/stars/noah-n-pham/form-check.svg?style=for-the-badge
[stars-url]: https://github.com/noah-n-pham/form-check/stargazers
