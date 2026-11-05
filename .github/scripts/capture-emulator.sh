#!/usr/bin/env bash
# Capture real Android screenshots + a demo GIF on a booted emulator.
# Run as ONE command by .github/workflows/capture.yml (android-emulator-runner runs every
# `script:` line in its own shell, so background jobs and `wait` must live in this file).
#
# Usage: capture-emulator.sh <flutter|expo>
# Expects a booted emulator on emulator-5554. Expo: release APK already built.
# Output: screenshots/NN-*.png (3+) and screenshots/demo.gif. Exits non-zero if either is
# missing, so a green run always means usable media.
#
# Changes from the make-poc-pod 0.2.0 template:
#  1. Flutter demo: the APKs are built BEFORE recording starts and `flutter drive` runs the
#     prebuilt binary (--use-application-binary), so the recording is not spent on a Gradle
#     build. The walkthrough prints PP_DEMO_START / PP_DEMO_END to logcat and the GIF is cut
#     to exactly that window.
#  2. Screenshots are only collected from the folders the capture writes (Maestro output
#     dirs), never the whole checkout, and stale PNGs from earlier commits are cleared first
#     so the ">= 3 PNGs" check cannot pass on old files.
#  3. Every pipeline whose left or right side can legitimately fail (grep with no match,
#     find on a missing dir) is guarded, so `set -o pipefail` cannot abort the run early.
set -euxo pipefail
STACK=${1:?flutter|expo}
DEVICE=emulator-5554
REC_LIMIT=60          # seconds; screenrecord stops itself and finalizes the mp4
GIF_MAX=25            # seconds of walkthrough kept in the GIF

# Fresh output dirs: the checkout may already contain committed screenshots.
rm -rf maestro-out capture-tmp
mkdir -p screenshots maestro-out capture-tmp
find screenshots -maxdepth 1 -type f \( -name '*.png' -o -name '*.gif' \) -delete

# Emulator system dialogs ("Pixel Launcher isn't responding") can cover the app.
adb shell settings put global hide_error_dialogs 1 || true
adb shell am broadcast -a android.intent.action.CLOSE_SYSTEM_DIALOGS || true

if [ "$STACK" = flutter ]; then
  # Build both test APKs up front (no-op if the workflow already built them).
  mkdir -p capture-apks
  build_apk() { # <target> <out>
    if [ -s "$2" ]; then return 0; fi
    flutter build apk --debug --target "$1"
    cp build/app/outputs/flutter-apk/app-debug.apk "$2"
  }
  build_apk integration_test/screenshot_test.dart capture-apks/shots.apk
  build_apk integration_test/demo_test.dart capture-apks/demo.apk
fi

# ---------------------------------------------------------------------------
# 1) stills
if [ "$STACK" = expo ]; then
  APP_ID=${APP_ID:-$(node -p "require('./app.json').expo.android.package")}
  adb install -r android/app/build/outputs/apk/release/app-release.apk
  # Warm-up launch so neither flow (nor the recording) starts on a cold JS load.
  adb shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1
  sleep 15
  adb shell am force-stop "$APP_ID"
  maestro test --test-output-dir maestro-out .maestro/screenshots.yaml
  # Only Maestro's own output dirs, never the checkout.
  for d in maestro-out "$HOME/.maestro/tests"; do
    [ -d "$d" ] || continue
    find "$d" -type f -name '[0-9][0-9]-*.png' -exec cp -n {} screenshots/ \;
  done
else
  # test_driver/integration_test.dart writes screenshots/NN-name.png
  flutter drive --driver test_driver/integration_test.dart --target integration_test/screenshot_test.dart \
    --use-application-binary capture-apks/shots.apk -d "$DEVICE"
fi

N=$(find screenshots -maxdepth 1 -type f -name '[0-9][0-9]-*.png' | wc -l)
[ "$N" -ge 3 ] || { echo "capture: only $N PNGs in screenshots/"; exit 1; }

# ---------------------------------------------------------------------------
# 2) demo walkthrough
if [ "$STACK" = flutter ]; then
  # Install first so the recording window holds only launch + walkthrough.
  adb install -r -t capture-apks/demo.apk
fi
adb logcat -c || true
REC_T0=$(adb shell date +%s | tr -d '\r')
adb shell screenrecord --time-limit "$REC_LIMIT" --size 540x1200 /sdcard/ademo.mp4 &
REC=$!
sleep 1
if [ "$STACK" = expo ]; then
  maestro test --test-output-dir maestro-out .maestro/demo.yaml || true
else
  flutter drive --driver test_driver/integration_test.dart --target integration_test/demo_test.dart \
    --use-application-binary capture-apks/demo.apk -d "$DEVICE" || true
fi
# screenrecord ends on its own at REC_LIMIT; never kill it (a killed mp4 has no moov atom).
wait "$REC" || true
adb pull /sdcard/ademo.mp4 capture-tmp/ademo.mp4

# Trim to the walkthrough using the logcat markers (device epoch seconds). Missing markers
# (e.g. Expo) fall back to the whole recording, capped at GIF_MAX.
adb logcat -d -v epoch > capture-tmp/logcat.txt || true
mark() { grep -m1 "$1" capture-tmp/logcat.txt | awk '{print $1}' || true; }
START=$(mark PP_DEMO_START); END=$(mark PP_DEMO_END)
TRIM=()
if [ -n "$START" ] && [ -n "$END" ]; then
  SS=$(awk -v s="$START" -v t="$REC_T0" 'BEGIN{d=s-t-0.3; if(d<0)d=0; printf "%.2f", d}')
  DUR=$(awk -v s="$START" -v e="$END" -v m="$GIF_MAX" 'BEGIN{d=e-s+0.8; if(d>m)d=m; printf "%.2f", d}')
  TRIM=(-ss "$SS" -t "$DUR")
  echo "capture: walkthrough at +${SS}s for ${DUR}s"
else
  TRIM=(-t "$GIF_MAX")
  echo "capture: no PP_DEMO markers, using the first ${GIF_MAX}s"
fi
ffmpeg -y "${TRIM[@]}" -i capture-tmp/ademo.mp4 -vf "fps=12,scale=300:-1:flags=lanczos,palettegen=stats_mode=diff" capture-tmp/pal.png
ffmpeg -y "${TRIM[@]}" -i capture-tmp/ademo.mp4 -i capture-tmp/pal.png \
  -lavfi "fps=12,scale=300:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3" screenshots/demo.gif
[ -s screenshots/demo.gif ] || { echo "capture: no demo.gif"; exit 1; }
SIZE=$(stat -c %s screenshots/demo.gif)
[ "$SIZE" -lt 3145728 ] || echo "capture: warning, demo.gif is $SIZE bytes (> 3 MB)"
ls -la screenshots
