# 📦 **what's in the box**
> A **local-first home inventory app** that helps you remember *what’s inside your storage boxes* — powered by **on-device AI** and built with **SwiftUI**.

---

## 🧠 Concept

**Problem:**
We all have dozens of storage boxes, drawers, and shelves filled with random items — cables, headphones, old gadgets, souvenirs — and it’s impossible to remember *where anything is*.

**Solution:**
"what's in the box" lets you take a **photo of each box**, uses **on-device image recognition** to identify its contents, and then makes it **searchable offline**.
You can later type “headphones” and immediately see *which box* they’re in — all without cloud storage or internet.

---

## ✨ Core Idea

> “A private, AI-powered memory for your physical storage.”

Each photo becomes a *mini-database* of recognized items.
When you need something, you just search for it — the app shows:

* the box photo,
* where it’s stored (e.g. “Shelf A, top left”),
* and all recognized objects inside.

All data stays **on your device** — respecting the local-first philosophy.

---

## 🧩 Core Features

| Feature                    | Description                                                                                     |
| -------------------------- | ----------------------------------------------------------------------------------------------- |
| 📷 **Smart Box Scan**      | Take a picture of a storage box; the app identifies items using on-device ML (Vision + CoreML). |
| 🏷️ **Automatic Tagging**  | Detected objects are saved as searchable tags (“headphones”, “charger”, “book”).                |
| 🔍 **Fast Local Search**   | Type to instantly find which box contains an item. Works fully offline.                         |
| 📍 **Location Hint**       | Optionally note where the box is stored (“garage shelf”, “bedroom closet”).                     |
| 🧠 **On-Device ML**        | All object recognition happens locally, using CoreML models like YOLOv8.                        |
| 🔒 **Local-First Storage** | No accounts, no cloud. Everything saved in loca SwiftData.                                      |
| 🧾 **Export/Backup**       | Users can export all data and images manually — because *your data is yours*.                   |

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

* No required accounts.
* No third-party analytics.
* All processing done on device.
* Optional manual backup/export.
* Optional peer-to-peer sync (future roadmap).

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

## 🚀 Example Flow

1. User taps **“New Box”**
2. Takes a **photo** of the box
3. App **runs object detection** locally
4. Displays the detected items → user confirms/edits names
5. User optionally adds **location hint**
6. Data saved locally and becomes searchable instantly
7. Later, user types **“headphones”** → app shows which box contains them

---