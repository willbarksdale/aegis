# Defender AI

**Your cosmic guardian against scams, deepfakes, and super-persuasion.**

A zero-trust, privacy-first AI that runs entirely on your device. Paste any suspicious message, link, or crypto address and get instant risk analysis.

## Features

- 🛡️ **Local AI Analysis** - Everything runs on-device, no data leaves your phone
- 🎯 **Scam Detection** - Catches phishing, fake urgency, authority spoofing
- 🔗 **Link Analysis** - Identifies suspicious URLs and domains
- 💰 **Crypto Safety** - Validates addresses and detects wallet drainer patterns
- 🧠 **Manipulation Detection** - Spots emotional blackmail and super-persuasion tactics

## Project Structure

```
lib/
├── main.dart              # App entry point
├── core/
│   ├── theme.dart         # Cosmic dark theme
│   └── constants.dart     # App constants & defensive prompt
├── screens/
│   └── home_screen.dart   # Main UI (one-pager)
└── services/
    └── model_service.dart # Model download via Dio
```

## Tech Stack

- **Flutter** - Cross-platform UI
- **flutter_llama** - Local LLM inference (llama.cpp)
- **Dio** - Simple HTTP downloads
- **flutter_riverpod** - State management
- **flutter_animate** - Smooth animations

## Getting Started

```bash
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## Model

Uses **Llama 3.2 3B Instruct (Q5_K_M)** - a 2.3GB quantized model optimized for mobile inference.

Download happens in-app on first launch.

## Roadmap

- [ ] Full flutter_llama integration for real analysis
- [ ] iOS Share Extension for quick checks
- [ ] Clipboard watcher mode
- [ ] History of scanned messages
- [ ] Widget for home screen

---

Built with paranoia. Stay safe out there. 🛡️
