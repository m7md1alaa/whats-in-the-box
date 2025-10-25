# 📦 **what's in the box**

> A **local-first home inventory app** that helps you remember _what’s inside your storage boxes_ — powered by **on-device AI** and built with **SwiftUI**.

---

## 🧠 Concept

**Problem:**
We all have dozens of storage boxes, drawers, and shelves filled with random items — cables, headphones, old gadgets, souvenirs — and it’s impossible to remember _where anything is_.

**Solution:**
"what's in the box" lets you take a **photo of each box**, uses **on-device image recognition** to identify its contents, and then makes it **searchable offline**.
You can later type “headphones” and immediately see _which box_ they’re in — all without cloud storage or internet.

---

## ✨ Core Idea

> “A private, AI-powered memory for your physical storage.”

Each photo becomes a _mini-database_ of recognized items.
When you need something, you just search for it — the app shows:

- the box photo,
- where it’s stored (e.g. “Shelf A, top left”),
- and all recognized objects inside.

All data stays **on your device** — respecting the local-first philosophy.

---

## 🧩 Core Features

| Feature                    | Description                                                                                     |
| -------------------------- | ----------------------------------------------------------------------------------------------- |
| 📷 **Smart Box Scan**      | Take a picture of a storage box; the app identifies items using on-device ML (Vision + CoreML). |
| 🏷️ **Automatic Tagging**   | Detected objects are saved as searchable tags (“headphones”, “charger”, “book”).                |
| 🔍 **Fast Local Search**   | Type to instantly find which box contains an item. Works fully offline.                         |
| 📍 **Location Hint**       | Optionally note where the box is stored (“garage shelf”, “bedroom closet”).                     |
| 🧠 **On-Device ML**        | All object recognition happens locally, using CoreML models like YOLOv8.                        |
| 🔒 **Local-First Storage** | No accounts, no cloud. Everything saved in loca SwiftData.                                      |
| 🧾 **Export/Backup**       | Users can export all data and images manually — because _your data is yours_.                   |

---

## 🧠 Architectural Philosophy: Local-First + FSD

The project follows **Feature-Sliced Design (FSD)** adapted for SwiftUI:

```
Sources/
├── App/          → App entry, routing, environment
├── Pages/        → Full screens (Home, Box Detail)
├── Widgets/      → UI components (Box list, Search bar)
├── Features/     → Use cases (Box scanning, Search)
├── Entities/     → Core models & repositories
└── Shared/       → Utilities, services, common components
```

## 🔒 Local-First Principles

Storify is designed under the **“Your data is your data”** philosophy:

- No required accounts.
- No third-party analytics.
- All processing done on device.
- Optional manual backup/export.
- Optional peer-to-peer sync (future roadmap).

---

## 🗺️ Future Roadmap

| Phase    | Features                                          |
| -------- | ------------------------------------------------- |
| **MVP**  | Box scanning, ML detection, search, basic storage |
| **v1.1** | Manual tagging, export/import                     |
| **v1.2** | Shelf/location AR overlay                         |
| **v2.0** | Optional CloudKit sync, multi-device support      |
| **v3.0** | Custom CoreML fine-tuning for your own items      |

---

## 🧑‍💻 Tech Summary

| Stack         |                                     |
| ------------- | ----------------------------------- |
| Language      | Swift 6                             |
| Frameworks    | SwiftUI, CoreML, Vision, GRDB.swift |
| iOS Target    | iOS 26+                             |
| Design System | SF Symbols, Dynamic Type            |
| Architecture  | FSD-inspired modular + local-first  |
| Privacy       | 100% offline, sandboxed data        |

---

# Theme System Documentation

## Overview

This app uses a centralized theme system that automatically adapts to light/dark mode. All UI components should use these theme properties instead of hardcoded colors or fonts.

---

## 🔧 Usage Guide

### 1. Setup (Already Done)

The theme is injected at the root level in `ContentView.swift`:

```swift
struct ContentView: View {
    @StateObject var themeManager = ThemeManager()

    var body: some View {
        NavigationView {
            HomeView()
                .environmentObject(themeManager)
        }
    }
}
```

### 2. Access Theme in Any View

Use `@EnvironmentObject` to access the theme:

```swift
struct YourView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Text("Hello World")
            .font(themeManager.selectedTheme.largeTitleFont)
            .foregroundColor(themeManager.selectedTheme.primaryThemeColor)
    }
}
```

### 3. Common Patterns

#### Text Styling

```swift
Text("Title")
    .font(themeManager.selectedTheme.textTitleFont)
    .foregroundColor(themeManager.selectedTheme.bodyTextColor)
```

#### Button Styling

```swift
Button("Confirm") {
    // action
}
.font(themeManager.selectedTheme.normalBtnTitleFont)
.foregroundColor(.white)
.padding()
.background(themeManager.selectedTheme.primaryThemeColor)
.cornerRadius(8)
```

#### Input/Container Background

```swift
VStack {
    // content
}
.padding()
.background(themeManager.selectedTheme.textBoxColor)
.cornerRadius(8)
```

---

## ⚠️ Important Rules

### ❌ DON'T

- **Never** use hardcoded colors like `.blue`, `.red`, `Color(red:green:blue:)`
- **Never** use hardcoded fonts like `.system(size:)`, `.title`, `.body`
- **Never** use `Color("SomeName")` directly without adding it to the theme

### ✅ DO

- **Always** access colors through `themeManager.selectedTheme`
- **Always** access fonts through `themeManager.selectedTheme`
- **Always** add new colors to `Assets.xcassets` with light/dark variants
- **Always** add new color/font properties to the `ThemeProtocol` and `Main` theme

---

## 🆕 Adding New Colors

### Step 1: Add to Asset Catalog

1. Open `Assets.xcassets`
2. Click `+` → Color Set
3. Name it with `mn` prefix (e.g., `mnSuccessColor`)
4. Set Appearances → "Any, Dark"
5. Define light and dark variants

### Step 2: Add to Theme Protocol

```swift
protocol ThemeProtocol {
    // ... existing properties
    var successColor: Color { get }  // Add new property
}
```

### Step 3: Implement in Main Theme

```swift
struct Main: ThemeProtocol {
    // ... existing properties
    var successColor: Color { return Color("mnSuccessColor") }
}
```

### Step 4: Use in Views

```swift
Text("Success!")
    .foregroundColor(themeManager.selectedTheme.successColor)
```

---

## 🆕 Adding New Fonts

### Step 1: Add to Theme Protocol

```swift
protocol ThemeProtocol {
    // ... existing properties
    var smallCaptionFont: Font { get }  // Add new font
}
```

### Step 2: Implement in Main Theme

```swift
struct Main: ThemeProtocol {
    // ... existing properties
    var smallCaptionFont: Font = .custom("MartelSans-Regular", size: 14.0)
}
```

---

## 🔄 Switching Themes at Runtime

The system supports multiple themes. To add a new theme:

### Step 1: Create New Theme

```swift
struct DarkTheme: ThemeProtocol {
    var largeTitleFont: Font = .custom("MartelSans-ExtraBold", size: 30.0)
    // ... implement all protocol requirements
}
```

### Step 2: Switch Theme

```swift
Button("Switch to Dark Theme") {
    themeManager.setTheme(DarkTheme())
}
```

---

## 📁 File Structure

```
whats-in-the-box/
├── Assets.xcassets/
│   ├── mnPrimaryThemeColor.colorset/
│   ├── mnSecondoryThemeColor.colorset/
│   ├── mnAffirmBtnTitleColor.colorset/
│   ├── mnNegativeBtnTitleColor.colorset/
│   ├── mnBodyTextColor.colorset/
│   └── mnTextBoxColor.colorset/
└── Sources/
    ├── Shared/
    │   └── Theme.swift (ThemeProtocol, ThemeManager, Main)
    └── Views/
        ├── ContentView.swift (Theme injection)
        └── HomeView.swift (Example usage)
```

---

## 🐛 Troubleshooting

### "Cannot find color 'mnXXXColor'"

- Ensure color is added to `Assets.xcassets`
- Check color name matches exactly (case-sensitive)
- Verify color has both light and dark variants

### "Cannot find font 'MartelSans-XXX'"

- Ensure font files are added to project
- Check font is listed in `Info.plist` under "Fonts provided by application"
- Verify font name matches PostScript name

### Theme not updating

- Ensure `ThemeManager` is `@StateObject` in root view
- Ensure child views use `@EnvironmentObject`
- Check `.environmentObject(themeManager)` is applied

---

## 📚 Quick Reference

### All Theme Properties

**Fonts:**

- `largeTitleFont` - 30pt ExtraBold
- `textTitleFont` - 24pt ExtraBold
- `normalBtnTitleFont` - 20pt SemiBold
- `boldBtnTitleFont` - 20pt Bold
- `bodyTextFont` - 18pt Light
- `captionTxtFont` - 20pt SemiBold

**Colors:**

- `primaryThemeColor` - Main brand color
- `secondoryThemeColor` - Accent color
- `affirmBtnTitleColor` - Success/confirm
- `negativeBtnTitleColor` - Cancel/destructive
- `bodyTextColor` - Main text
- `textBoxColor` - Backgrounds/containers

---

## 🚀 Example Flow

1. User taps **“New Box”**
2. Takes a **photo** of the box
3. App **runs object detection** locally
4. Displays the detected items → user confirms/edits names
5. User optionally adds **location hint**
6. Data saved locally and becomes searchable instantly
7. Later, user types **“headphones”** → app shows which box contains them

---
