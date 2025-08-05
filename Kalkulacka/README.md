# Holesovice Tracker

A beautiful iOS app for tracking alcohol and caffeine consumption with Apple Watch-style activity rings and blood alcohol content calculation.

## Features

### 🍷 Alcohol Tracking
- Track standard drinks with alcohol percentage
- Apple Watch-style activity ring showing progress toward daily limit (4 standard drinks)
- **Blood Alcohol Content (BAC) calculation** using the Widmark formula
- Add custom drinks with volume and alcohol content
- View detailed history with timestamps
- Delete entries with swipe gestures

### ☕ Caffeine Tracking
- Track caffeine consumption in milligrams
- Activity ring showing progress toward daily limit (400mg)
- Add various caffeinated beverages
- Comprehensive history view
- Easy entry deletion

### 👤 User Profile
- **Personal information**: Age, gender, weight, height
- **BMI calculation** with health category indicators
- **BAC calculation** based on personal data using scientific formulas
- Gender-specific alcohol distribution factors
- Automatic alcohol metabolism calculation

### 🎨 Beautiful UI
- Modern SwiftUI interface
- Apple Watch-inspired activity rings
- Tab-based navigation
- Smooth animations
- Intuitive drink entry forms
- **Edit buttons** in top navigation bars
- **Me button** for profile management

## App Structure

- **Two main screens**: Alcohol and Caffeine tracking
- **Activity ring**: Shows daily progress in the center top
- **BAC display**: Real-time blood alcohol content calculation
- **Add button**: Prominent + button below the ring
- **History**: Accessible via navigation links with edit mode
- **Top navigation**: Edit button (left) and Me button (right)
- **Data persistence**: Uses UserDefaults for local storage

## Technical Details

- Built with SwiftUI for iOS 17.0+
- MVVM architecture with ObservableObject
- Custom activity ring implementation
- Form-based data entry
- TabView navigation
- Local data persistence
- **Widmark formula** for BAC calculation
- **Gender-specific distribution factors**
- **Alcohol metabolism modeling**

## BAC Calculation

The app uses the **Widmark formula** to calculate blood alcohol content:

```
BAC = (Alcohol in grams / (Body weight in grams × Distribution factor)) × 100
```

- **Distribution factors**: Male (0.68), Female (0.55), Other (0.61, but hiddden in UI)
- **Alcohol metabolism**: Subtracts 0.015% per hour since first drink
- **Real-time updates**: BAC changes as you add drinks and time passes

## Getting Started

1. Open `HolesoviceTracker.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the app
4. Tap the **Me** button to set up your profile
5. Start tracking your drinks!

## Usage

1. **Set up your profile** by tapping the "Me" button and entering your details
2. **Switch between tabs** to track alcohol or caffeine
3. **Tap the + button** to add a new drink
4. **Fill in the details** (name, amount, alcohol % or caffeine content)
5. **View your progress** in the activity ring and BAC display
6. **Check history** to see all your entries
7. **Use edit mode** to delete entries you want to remove

The app automatically calculates standard drinks for alcohol, tracks total caffeine consumption, and provides real-time BAC estimates based on your personal data, helping you stay within recommended daily limits and make informed decisions about your consumption. 
