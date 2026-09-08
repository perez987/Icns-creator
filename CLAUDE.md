# CLAUDE.md

## Project Summary
- **Icns Creator** is a native macOS SwiftUI app for converting image files into `.iconset` folders and `.icns` files.
- Main app source is under `Icns creator/Icns creator/`.

## Key Areas
- `Icns creator/Icns creator/Icns_creatorApp.swift`: app lifecycle, global state container, window behavior.
- `Icns creator/Icns creator/Views/`: SwiftUI UI and interaction flow.
- `Icns creator/Icns creator/Model/`: icon generation, image processing, filesystem/window helpers.
- `Icns creator/Icns creator/*/*.lproj/Localizable.strings`: localization resources.

## Build & Run
- Open `Icns creator/Icns creator.xcodeproj` in Xcode and run the **Icns creator** scheme.
- Command-line checks (from repository root):
  - `xcodebuild -project "Icns creator/Icns creator.xcodeproj" -scheme "Icns creator" -configuration Debug build`

## Agent Guidelines
- Keep changes small and scoped to the requested task.
- Preserve existing SwiftUI structure (`Views` vs `Model`) and avoid moving unrelated logic.
- When adding or changing user-facing text, update localization strings consistently.
- Be careful with paths containing spaces (`Icns creator/...`) when writing scripts or commands.
- Prefer existing image/export pipelines in `IconGenerationService.swift` and `ImageProcessing.swift` over introducing parallel implementations.
