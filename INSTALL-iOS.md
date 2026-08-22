# Install on iPhone / iPad

This package is an iOS-friendly Progressive Web App (PWA) of Drone Flight Test Reporter.

## Option A — Install from GitHub Pages (recommended)

1. On your iPhone/iPad, open Safari.
2. Go to the published app URL for this repository (GitHub Pages).
3. Tap the **Share** button.
4. Tap **Add to Home Screen**.
5. Confirm the name, then tap **Add**.

The app opens in standalone mode like a native app.

## Option B — Host this package yourself

1. Unzip `drone-flight-test-reporter-ios-1.0.0.zip`.
2. Host the folder over **HTTPS** (GitHub Pages, Netlify, nginx, etc.).
   - Service workers and reliable iOS install require HTTPS (or localhost).
3. Open the hosted `index.html` in Safari.
4. Use **Share → Add to Home Screen**.

## Notes

- Use Safari for the most reliable iOS home-screen install experience.
- Voice notes depend on Speech Recognition support in the browser.
- This is not an App Store `.ipa`. It installs as a home-screen web app.
