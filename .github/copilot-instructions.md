<!-- Purpose: short, actionable guidance for AI coding agents working on this Flutter project -->

# Copilot instructions — insightmind_app

This repository is a Flutter multi-platform app (mobile, web, desktop). Use the notes below to be immediately productive.

- Project entry: lib/main.dart (root MaterialApp). Small, vanilla Flutter app using StatefulWidgets (see MyHomePage / \_MyHomePageState).
- Package metadata: pubspec.yaml — Dart SDK constraint ^3.9.2, flutter_lints enabled, no extra dependencies currently (only cupertino_icons).
- Platforms: native folders exist (android/, ios/, windows/, linux/, macos/, web/). Plugin registrant files are generated under each platform (for example linux/flutter/generated_plugin_registrant.\*). Treat platform code as sensitive; update both native build files and Flutter manifest when adding native integrations.

Quick commands (run in project root):

- Install deps: flutter pub get
- Analyze: flutter analyze
- Format: dart format .
- Run tests: flutter test
- Run app: flutter run -d <device> (hot reload: press r in console or use IDE hot reload)
- Build: flutter build apk / flutter build ios / flutter build web

Project-specific conventions and patterns

- UI/state: current codebase uses direct StatefulWidgets and setState. No state-management package detected — if you add riverpod/bloc/provider, update pubspec.yaml and add small migration tests.
- Theme: app theme is set via ThemeData and ColorScheme.fromSeed in lib/main.dart. Prefer updating the seed color rather than many manual color overrides.
- Assets: no assets are currently declared in pubspec.yaml. If you add assets, register them under flutter.assets: and run flutter pub get.
- Lints: flutter_lints is active; run flutter analyze and follow reported fixes. Prefer fix suggestions from the analyzer before submitting PRs.

Integration & cross-component notes

- Native changes: modify platform-specific code under android/ or ios/ and run flutter clean then flutter pub get before testing. Update Gradle Kotlin DSL files under android/ if changing Android build configs.
- Generated files: do not commit generated plugin registrant files unless necessary. Tests and builds will regenerate them.

Important repo findings to avoid wasted edits

- lib/main.dart currently contains an invalid line that will fail analysis or runtime: the AppBar backgroundColor is set using an invalid expression like color(#002fff). Replace with Color(0xFF002FFF) or a Colors.<name> constant.
- pubspec.yaml has publish_to: 'none' so the package is intentionally private.

PR checklist for AI edits

1. Run dart format . and flutter analyze locally and fix issues.
2. Run flutter test and ensure tests (currently test/widget_test.dart) pass.
3. If adding dependencies, update pubspec.yaml, run flutter pub get, and include a short rationale in the PR description.
4. For native changes, document platform steps in the PR and smoke-test on the relevant platform(s).

Where to look next

- lib/ for app code and feature additions.
- test/ for sample tests to copy when adding new features.
- android/app/ and ios/Runner/ for native integration entry points.

If anything in this file is unclear or you want deeper guidance (state-management choice, folder-by-folder responsibilities, or example PR templates), tell me which area to expand.
