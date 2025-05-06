# Auth0 Airways Native App

This sample iOS application demonstrates how to build a loyalty airline app using [Auth0.swift](https://github.com/auth0/Auth0.swift). It extends the standard Auth0 Swift Quickstart with **native-to-web SSO**, **SSO session token injection**, and a full airline-style experience, modeled after British Airways Executive Club.

## ✈️ Features

* ✅ Login/logout using Universal Login
* ✅ Secure token storage via CredentialsManager
* ✅ Native to Web SSO with `session_transfer`
* ✅ Cookie injection into `WKWebView`
* ✅ Authenticated WebView for booking flights
* ✅ Drawer-style UI with airline-style dashboard
* ✅ Option to toggle SSO per user action

## Requirements

* iOS 15+
* Xcode 14+ (15.3+ for Universal Links support)
* Auth0 Native Application

## Configuration

### 1. Setup Callback URLs in Auth0

For **iOS**:

```
https://YOUR_AUTH0_DOMAIN/ios/YOUR_BUNDLE_ID/callback
YOUR_BUNDLE_ID://YOUR_AUTH0_DOMAIN/ios/YOUR_BUNDLE_ID/callback
```

Example:

```
https://nelson.jp.auth0.com/ios/com.example.MyApp/callback
com.example.MyApp://nelson.jp.auth0.com/ios/com.example.MyApp/callback
```

Make sure your application type in Auth0 is set to **Native**.

---

### 2. Configure Associated Domains (optional, for Universal Links)

* Add this in Signing & Capabilities → Associated Domains:

```
webcredentials:nelson.jp.auth0.com
```

* In the Auth0 dashboard → Advanced Settings → Device Settings:

  * Team ID: *Your Apple Team ID*
  * App ID: *Your app's bundle identifier*

> ✅ Required for SSO via Universal Links on iOS 17.4+

---

### 3. Configure `Auth0.plist`

Rename `Auth0.plist.example` → `Auth0.plist` and set:

```xml
<key>ClientId</key>
<string>aRhJa59DVCRZVmsI9v4pLBVGRNXRoYyo</string>
<key>Domain</key>
<string>nelson.jp.auth0.com</string>
```

---

## 🔐 Native to Web SSO Integration

We exchange the refresh token for a session transfer token and inject it into a cookie for `WKWebView`:

```swift
Auth0
  .authentication()
  .ssoExchange(withRefreshToken: refreshToken)
  .start { result in
    switch result {
    case .success(let ssoCredentials):
      let cookie = HTTPCookie(properties: [
        .domain: "nelson.jp.auth0.com",
        .path: "/",
        .name: "auth0_session_transfer_token",
        .value: ssoCredentials.sessionTransferToken,
        .expires: Date().addingTimeInterval(TimeInterval(ssoCredentials.expiresIn)),
        .secure: true,
        .httpOnly: true
      ])!

      let webView = WKWebView()
      webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie!) {
        let url = URL(string: "https://auziros-club.vercel.app")!
        let request = URLRequest(url: url)
        webView.load(request)

        let vc = UIViewController()
        vc.view = webView
        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
      }
    case .failure(let error):
      print("SSO exchange failed: \(error)")
    }
  }
```

## 🧪 Toggle: Use SSO or Open Direct

Users can toggle between opening the booking experience:

* ✅ With SSO via session token
* 🚫 Or as a guest (just loads URL directly in WebView)

## 🗂 Project Structure Highlights

* `DashboardView.swift` – main airline dashboard
* `BottomSheetView.swift` – interactive drawer
* `DrawerListItem.swift` – menu entries
* `openBookingWebView()` – core SSO + WebView logic

## 📦 Dependencies

* [Auth0.swift](https://github.com/auth0/Auth0.swift)
* SwiftUI + UIKit hybrid
* `WKWebView` with cookie injection

## 📣 Support

For bugs, use [GitHub Issues](https://github.com/auth0-samples/auth0-ios-swift-sample/issues)
For Auth0 questions, go to [Auth0 Community](https://community.auth0.com)

## 📄 License

MIT © Auth0 / Custom extensions by @nelson

---

Made with ❤️ for the Auziros Club loyalty team ✈️
