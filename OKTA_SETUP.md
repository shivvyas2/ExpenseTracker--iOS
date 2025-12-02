# Okta Authentication Setup Guide

This guide will help you set up Okta authentication in your Expense Tracker iOS app.

## Prerequisites

1. An Okta Developer Account (free at https://developer.okta.com)
2. Xcode 15.0 or later
3. iOS 17.5 or later

## Step 1: Configure Okta Application

1. Log in to your Okta Developer Console
2. Navigate to **Applications** > **Applications**
3. Click **Create App Integration**
4. Choose:
   - **Sign-in method**: OIDC - OpenID Connect
   - **Application type**: Native Application
5. Configure the following:
   - **App integration name**: Expense Tracker iOS
   - **Sign-in redirect URIs**: `com.okta.ios:/callback` or `shivvyas.ExpenseTracker:/callback`
   - **Sign-out redirect URIs**: (optional) `com.okta.ios:/logout`
   - **Controlled access**: Allow everyone in your organization to access (or configure as needed)
6. Click **Save**
7. Copy the following values:
   - **Client ID**
   - **Okta Domain** (e.g., `https://dev-123456.okta.com`)

## Step 2: Add Okta SDK to Xcode Project

1. Open your project in Xcode
2. Go to **File** > **Add Package Dependencies...**
3. Enter the package URL: `https://github.com/okta/okta-oidc-ios`
4. Select **Up to Next Major Version** and choose the latest version (e.g., 3.11.0)
5. Click **Add Package**
6. Select the **OktaOidc** product and click **Add Package**

## Step 3: Update Configuration

1. Open `ExpenseTracker/Model/OktaConfig.swift`
2. Replace the placeholder values:
   ```swift
   static let issuer = "https://YOUR_OKTA_DOMAIN.okta.com/oauth2/default"
   static let clientId = "YOUR_CLIENT_ID"
   ```
3. Update the redirect URI to match your bundle identifier:
   ```swift
   static let redirectUri = "shivvyas.ExpenseTracker:/callback"
   ```

## Step 4: Configure URL Scheme

1. In Xcode, select your project in the navigator
2. Select the **ExpenseTracker** target
3. Go to the **Info** tab
4. Expand **URL Types**
5. Click the **+** button to add a new URL Type
6. Configure:
   - **Identifier**: `OktaCallback`
   - **URL Schemes**: `shivvyas.ExpenseTracker` (or your bundle identifier)
   - **Role**: Editor

Alternatively, you can add this to your Info.plist (if you're using a custom Info.plist):
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>shivvyas.ExpenseTracker</string>
        </array>
        <key>CFBundleURLName</key>
        <string>OktaCallback</string>
    </dict>
</array>
```

## Step 5: Update AuthenticationViewModel

The `AuthenticationViewModel.swift` file contains placeholder code for the Okta SDK integration. Once you've added the Okta SDK package, you'll need to:

1. Import the Okta SDK:
   ```swift
   import OktaOidc
   ```

2. Update the `login()` method to use the actual Okta SDK:
   ```swift
   func login() {
       isLoading = true
       errorMessage = nil
       
       let config = OktaOidcConfig(
           issuer: OktaConfig.issuer,
           clientId: OktaConfig.clientId,
           redirectUri: OktaConfig.redirectURI,
           scopes: OktaConfig.scopes
       )
       
       OktaOidc.default().signIn(with: config) { [weak self] stateManager, error in
           DispatchQueue.main.async {
               if let error = error {
                   self?.errorMessage = error.localizedDescription
                   self?.isLoading = false
               } else if let stateManager = stateManager {
                   self?.handleLoginSuccess(stateManager: stateManager)
               }
           }
       }
   }
   ```

3. Update `handleLoginSuccess` to store tokens from the state manager:
   ```swift
   private func handleLoginSuccess(stateManager: OktaOidcStateManager) {
       // Store tokens
       stateManager.writeToSecureStorage()
       
       // Decode user info from ID token
       if let idToken = stateManager.idToken,
          let userInfo = decodeUserInfo(from: idToken) {
           self.userInfo = userInfo
       }
       
       isAuthenticated = true
       isLoading = false
   }
   ```

4. Update `logout()` to use Okta SDK:
   ```swift
   func logout() {
       isLoading = true
       
       if let stateManager = OktaOidcStateManager.readFromSecureStorage() {
           OktaOidc.default().signOutOfOkta(with: stateManager) { error in
               DispatchQueue.main.async {
                   stateManager.clear()
                   self.clearStoredTokens()
                   self.isAuthenticated = false
                   self.userInfo = nil
                   self.isLoading = false
               }
           }
       } else {
           clearStoredTokens()
           isAuthenticated = false
           userInfo = nil
           isLoading = false
       }
   }
   ```

5. Update `handleOktaCallback` in `ExpenseTrackerApp.swift`:
   ```swift
   private func handleOktaCallback(url: URL) {
       OktaOidc.default().receiveRedirect(url) { [weak self] stateManager, error in
           DispatchQueue.main.async {
               if let error = error {
                   self?.authViewModel.errorMessage = error.localizedDescription
               } else if let stateManager = stateManager {
                   self?.authViewModel.handleLoginSuccess(stateManager: stateManager)
               }
           }
       }
   }
   ```

## Step 6: Test the Integration

1. Build and run the app
2. You should see the login screen
3. Tap "Sign In with Okta"
4. You should be redirected to Okta's login page
5. After successful login, you'll be redirected back to the app
6. The app should show the main expense tracker interface

## Troubleshooting

### Common Issues

1. **"Invalid redirect URI" error**
   - Ensure the redirect URI in Okta matches exactly with your app's URL scheme
   - Check that the URL scheme is properly configured in Info.plist

2. **"Client ID not found" error**
   - Verify your Client ID in `OktaConfig.swift`
   - Ensure the Okta domain is correct

3. **Callback not working**
   - Check that the URL scheme is registered in Info.plist
   - Verify the redirect URI matches in both Okta and your app

4. **Token refresh issues**
   - Ensure refresh tokens are being stored securely
   - Check token expiry times

## Security Notes

- Never commit your Okta credentials to version control
- Consider using environment variables or a secure configuration file
- Use Keychain for storing sensitive tokens (Okta SDK does this automatically)
- Implement proper token refresh logic
- Handle token expiration gracefully

## Additional Resources

- [Okta iOS SDK Documentation](https://github.com/okta/okta-oidc-ios)
- [Okta Developer Documentation](https://developer.okta.com/docs/)
- [OpenID Connect Guide](https://developer.okta.com/docs/guides/implement-oauth-for-ios/)

