# Capture flow

How the screenshots and the demo GIF in `screenshots/` are produced. Everything runs on a GitHub
Actions Android emulator; nothing is mocked in the media.

## Re-run the capture

```sh
gh workflow run capture.yml -R nhucsau1995/petal-path-coaching --ref main
gh run list -R nhucsau1995/petal-path-coaching --workflow capture.yml -L 1
gh run watch <run-id> -R nhucsau1995/petal-path-coaching --exit-status
rm -rf screenshots && gh run download <run-id> -R nhucsau1995/petal-path-coaching -n capture -D screenshots
```

The run takes about 10-15 minutes. A green run always means 3+ PNGs and a `demo.gif` exist.

## What the workflow does

1. `ubuntu-latest` runner, KVM enabled, Java 17, Flutter pinned to 3.35.0 (the version the
   code is verified with).
2. Builds two debug APKs before the emulator boots: one for
   `integration_test/screenshot_test.dart`, one for `integration_test/demo_test.dart`.
3. Boots an API 34 Pixel 6 emulator (`reactivecircus/android-emulator-runner`) and runs
   `.github/scripts/capture-emulator.sh flutter` as one command.
4. Stills: `flutter drive --use-application-binary` runs the screenshot test. It taps through the
   key screens and calls `binding.takeScreenshot('NN-name')`;
   `test_driver/integration_test.dart` writes each one to `screenshots/NN-name.png`.
5. Demo: the demo APK is installed first, then `screenrecord` starts (it stops itself, so the mp4
   is always finalized) and `flutter drive` runs the paced walkthrough on the prebuilt binary.
   The walkthrough logs `PP_DEMO_START` / `PP_DEMO_END`; the script cuts the recording to that
   window and converts it to a 12 fps, 300 px GIF with an ffmpeg palette pass.
6. Uploads the `capture` artifact (PNGs + GIF) and a `capture-debug` artifact (raw mp4, logcat).

## Run it on a local emulator instead

With a booted emulator on `emulator-5554` and ffmpeg installed:

```sh
flutter pub get
bash .github/scripts/capture-emulator.sh flutter
```

The script builds the two APKs itself when `capture-apks/` is empty.

## Checks without a device

```sh
flutter pub get && flutter analyze && flutter test
```

`test/flutter_test_config.dart` loads the real fonts so the widget tests measure the same text
widths as a phone.
