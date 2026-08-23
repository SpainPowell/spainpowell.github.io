---
name: run-ios-simulator
description: Launch the mobile/ Expo app in the iOS Simulator using its EAS dev-client build. Use when asked to run, launch, open, or preview the app on the simulator, or to verify a mobile UI change is actually rendering (per simulator-verification.md).
---

# Run the iOS Simulator (mobile/)

**Expo Go does not work for this app.** `react-native-google-mobile-ads` (AdMob) is a native module with no
Expo Go equivalent — the app requires a real dev-client build installed on the simulator, per
`.claude/CLAUDE.md` ("EAS dev-build"). `npx expo start` only starts the Metro bundler; it does not by itself
put anything on screen.

## Happy path

1. **Check for a running Metro bundler** before starting a new one — a leftover session often already has one:
   ```bash
   lsof -i :8081 | grep node   # or: ps aux | grep "expo start"
   ```
   If nothing is listening, start one from `mobile/`: `cd mobile && npx expo start -c --port 8081` (run in the
   background; don't block on it).

2. **Boot a simulator** if none is booted:
   ```bash
   xcrun simctl list devices | grep -i booted
   xcrun simctl boot <UDID>            # e.g. iPhone 16 Pro on iOS 18.3
   open -a Simulator
   ```

3. **Find or build a dev-client `.app`.** Prefer reusing an already-built one — a full build is slow (5-15 min).
   Check `~/Library/Developer/Xcode/DerivedData/WinTheNumbers-*/Build/Products/Debug-iphonesimulator/WinTheNumbers.app`.
   **Do not trust the most-recently-modified one blindly** — see "Known issue" below; multiple stale builds
   accumulate across sessions and several may be missing the AdMob native module.

   To build fresh **against the existing native project** (`mobile/ios/` is a real checked-out CocoaPods
   project, not regenerated from scratch each time):
   ```bash
   cd mobile
   xcodebuild -workspace ios/WinTheNumbers.xcworkspace -scheme WinTheNumbers -configuration Debug \
     -sdk iphonesimulator -destination "id=<UDID>" \
     -derivedDataPath /tmp/wtn-build build
   ```
   Use a **scratch `-derivedDataPath`**, not the default DerivedData location — reusing the default can silently
   relink against stale intermediate objects from a build that predates a native dependency change (this is how
   the AdMod-module-missing failure below was first hit).

   Only fall back to `npx expo run:ios --device "<name>"` (which re-runs `pod install`) if `ios/Pods` is
   genuinely out of sync with `node_modules` — see the known issue: that path is broken.

4. **Install + launch**:
   ```bash
   xcrun simctl install <UDID> <path-to-WinTheNumbers.app>
   xcrun simctl launch <UDID> com.spainpowell.winthenumbers
   ```

5. **Point the dev-client at Metro.** First launch shows a "Development servers" list (green dot = reachable).
   **Tap the actual list entry** (e.g. via `cliclick`, per `.claude/rules/simulator-verification.md`'s
   coordinate-calibration guidance) — this is the only reliable way to connect. **Do not** script this with
   `xcrun simctl openurl <UDID> "exp://…"` — see "Known issue" below; `exp://` is Expo Go's URL scheme, not this
   app's, and if Expo Go is present on the simulator it silently intercepts the URL instead of the dev-client.
   If you must script the connection, this app's own registered scheme (derived from `app.config.ts`'s `slug`)
   is `exp+winthe-numbers-mobile://` — confirm the exact scheme with
   `grep -A2 CFBundleURLSchemes <path-to-app>/Info.plist` before relying on it, since it changes if `slug` does.

6. **Verify it actually rendered** — screenshot and read it back (per `.claude/rules/simulator-verification.md`):
   ```bash
   xcrun simctl io <UDID> screenshot /path/to/shot.png
   ```
   A red error overlay means the dev-client build is bad, *or* you connected the wrong app (see known issue
   below) — don't assume it's your code change without ruling both out.

## Known issue: `exp://` silently connects to Expo Go instead of this app's dev-client

If Expo Go (`host.exp.Exponent`) is installed on the same simulator — easy to end up with from earlier,
unrelated session work — `xcrun simctl openurl <UDID> "exp://…"` connects to **Expo Go**, not the WinTheNumbers
dev-client, because `exp://` is Expo Go's registered scheme and this app has no `exp` scheme registered (only
`com.spainpowell.winthenumbers` and `exp+winthe-numbers-mobile`). Expo Go then loads the same Metro-served bundle
itself and — since it can't support custom native modules — throws the **exact same-looking crash**:
`[runtime not ready]: Invariant Violation: TurboModuleRegistry.getEnforcing(...): 'RNGoogleMobileAdsModule' could
not be found`. This is not a build problem or a native-module registration bug; the real dev-client process sits
quietly on its own launcher screen the whole time, untouched.

This produced a full day of misdirected native-build debugging in one session (deep instrumentation of
`RCTTurboModuleManager`, `TurboModuleBinding`, `RCTInstance`, etc. — all of which turned out to be correct,
unmodified, working code) before being traced back to this exact `openurl exp://` scripting shortcut. **Before
trusting any redbox reproduced via `openurl exp://`**, either:
- Confirm which process actually rendered it (`xcrun simctl spawn <UDID> launchctl list | grep -i <bundle-id>` —
  or just check the app's own name/UI chrome in the screenshot, not just the error text), or
- Uninstall Expo Go from the verification simulator entirely: `xcrun simctl uninstall <UDID> host.exp.Exponent`,
  or
- Connect via the real launcher-tap flow (step 5 above) instead of scripting `openurl`.

If you hit a *build-time* pod-install failure (codegen errors, dependency conflicts), tell the user rather than
silently downgrading/patching a package — that's a real dependency decision, not implied by "launch the
simulator." (`react`/`react-native` are pinned to Expo SDK 55's exact tested versions per
`.claude/rules/ci-native-build-alignment.md` — don't bump them to "fix" a build issue without reading that rule
first.)
