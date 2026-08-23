---
paths:
  - "**/*.tsx"
---

## Simulator Verification

**UI changes aren't verified until someone has actually looked at them running.**

`npx vitest run` / `npx tsc --noEmit` / `npx eslint` prove the code compiles and pure logic behaves — they do NOT
prove a screen renders correctly, a navigation flow works, or a visual regression didn't slip in. Per
`.claude/CLAUDE.md`, React Native components can't be rendered under vitest/jsdom at all, so for any change that
touches a screen, navigation, or visual component, simulator verification is the only real check available.

**When an agent (or the orchestrator) finishes a UI-affecting change** (new screen, screen refactor, nav
restructure, gated/conditional UI, style change), before calling it done:

1. Make sure a booted iOS simulator is available (`xcrun simctl list devices | grep Booted`) and an Expo dev
   server is running against the branch under test (`npx expo start --ios`, or open the running server via
   `xcrun simctl openurl <device-id> "exp://127.0.0.1:8081"` if one is already up).
2. Navigate to the affected screen(s)/flow(s) — reload the JS bundle first if the change is fresh
   (`xcrun simctl io booted screenshot` reads whatever is currently on screen, it does not itself refresh Metro).
3. Capture evidence:
   - Static states: `xcrun simctl io <device-id> screenshot <path>.png`
   - Multi-step flows (navigation, gated content unlocking, form submission): `xcrun simctl io <device-id>
     recordVideo <path>.mp4`, stop with Ctrl-C once the flow is demonstrated.
4. Actually look at the captured image/video (read it back, e.g. via the Read tool for a screenshot) before
   reporting success — don't just confirm the file was written. Check for: the intended content is visible, no
   error boundary/red-box, no obviously broken layout (overlap, cut-off text, wrong theme colors).
5. If something looks wrong, fix it and re-capture — don't report "done" off a screenshot you haven't reviewed.

Save captures to the scratchpad/worktree, not the repo (they're verification artifacts, not deliverables) unless
the user asks for one to be kept (e.g. for a PR description or release checklist).

This does not replace the existing test suite or the agent review pass — it's an additional, mandatory step for
anything a user would actually see, since none of the automated checks can catch a screen that's simply broken to
look at.

## Tapping through a flow (not just screenshotting a static state)

`simctl` has no built-in "tap at coordinate" command — driving an actual flow (filters, tab switches, form
fills) requires `cliclick` (`brew install cliclick`) sending real macOS mouse events at the Simulator window's
screen position, converted from the device-pixel coordinates you see in a screenshot. Two things reliably went
wrong doing this during a QA pass and cost most of a session to diagnose:

1. **Getting the point/pixel scale wrong.** `system_profiler SPDisplaysDataType`'s reported "Resolution" is not
   reliable for this — it did not match the actual coordinate scale in one session (a MacBook Air reported
   2560x1664 while the true pixel:point ratio was 2.0, not that ratio's ~0.87). Don't trust it. Instead get
   ground truth directly: `cliclick m:<x>,<y>` to move the cursor to a candidate point, then
   `screencapture -x -C <path>.png` (the `-C` flag draws the cursor into the capture) and read the image back to
   see exactly where the cursor landed vs. where you intended. Solve the scale/offset from that, not from
   inference. (`screencapture`/`CGWindowListCopyWindowInfo` need the Screen Recording permission granted to the
   calling process — if `screencapture` errors with "could not create image from display", that's the cause.)
2. **Focus silently drifting between clicks.** A `cliclick` call can silently miss if Simulator isn't the
   frontmost app — and focus can shift between two tool calls in the same session (e.g. after reading a
   screenshot back). Always precede every tap with `osascript -e 'tell application "Simulator" to activate'`
   and a short `sleep 0.5`, not just once at the start of a sequence.

**Getting a fresh guest/logged-out build to a real data screen without fighting the login UI**: rather than
tapping through "Continue as Guest"/sign-up forms (fragile, and see the auth-flow warning below), it's faster
and safer to seed the app's persisted state directly and relaunch: find the AsyncStorage manifest under the
simulator's data container (`.../Library/Application Support/<bundle-id>/RCTAsyncLocalStorage_V1/manifest.json`),
add the relevant key (e.g. this app's `@wtn_auth_mode_v1: "guest"`) with a quick Python edit, then
`xcrun simctl terminate booted <bundle-id> && xcrun simctl launch booted <bundle-id>` to have the app read it back
on boot. Confirm the exact key name/value shape in the relevant `services/storage.ts`-equivalent file first.

**Never tap "Sign in with Apple" while poking around a real device/simulator with a personal Apple ID signed in
at the OS level** — it is not a mock. A stray tap during blind coordinate-calibration triggered a real
Sign-in-with-Apple flow (including a real 2FA prompt) against the developer's actual Apple ID in one session.
If any screen has a native Apple/Google/etc. auth button anywhere near your calibration targets, verify your
coordinates against a low-risk element first, and if a real auth sheet appears anyway, stop and back out via
its own Cancel/X — don't tap through it "to see what happens," and don't enter any code it asks for.
