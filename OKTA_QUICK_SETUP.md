# Quick Okta Setup Checklist

## ✅ What You've Already Done
- ✅ Created Okta application: "Expense-Tracker-iOS"
- ✅ Client ID: `Ooaxzioxyr8HluG8U697`
- ✅ PKCE enabled (secure!)
- ✅ Client authentication: None (correct for Native apps)

## 🔧 What You Need to Do Now

### 1. Find Your Okta Domain (2 minutes)

**Option A: Check Browser URL**
- When you're logged into Okta Admin Console, look at the URL
- It will be: `https://dev-XXXXXX.okta.com` or `https://yourcompany.okta.com`
- Copy the domain part (everything before `.okta.com`)

**Option B: Check Top Right Corner**
- Look at the top right of your Okta console
- Your domain might be displayed there

**Option C: Check Email**
- Check any Okta emails you received
- They usually contain your Okta domain

### 2. Configure Redirect URI in Okta (1 minute)

1. In your Okta Admin Console, go to your app: **Expense-Tracker-iOS**
2. Click on the **"Sign On"** tab (next to "General")
3. Scroll down to **"Sign-in redirect URIs"**
4. Click **"Edit"**
5. Add this URI:
   ```
   shivvyas.ExpenseTracker:/callback
   ```
6. Click **"Save"**

### 3. Update Your Code (1 minute)

1. Open `ExpenseTracker/Model/OktaConfig.swift`
2. Replace `YOUR_OKTA_DOMAIN` with your actual domain
   ```swift
   static let issuer = "https://dev-XXXXXX.okta.com/oauth2/default"
   ```
   (Replace `dev-XXXXXX` with your actual domain)

### 4. Verify Your Bundle Identifier

1. In Xcode, select your project
2. Go to the **ExpenseTracker** target
3. Check **Bundle Identifier** - it should be `shivvyas.ExpenseTracker`
4. If it's different, update the redirect URI in Okta to match

## 🔒 Security Notes

**Your Client ID is SAFE:**
- ✅ Client IDs are meant to be public
- ✅ They're included in every OAuth app
- ✅ They cannot access your system alone
- ✅ PKCE provides the security (which you have enabled)

**What's Actually Secret:**
- ❌ Client Secrets (you don't have one - correct!)
- ❌ Access Tokens (stored securely in Keychain)
- ❌ Refresh Tokens (stored securely in Keychain)

## 🧪 Test Your Setup

1. Build and run your app
2. Tap "Sign In with Okta"
3. You should be redirected to Okta login
4. After login, you'll be redirected back to your app

## ❌ Common Issues

**"Invalid redirect URI" error:**
- Make sure the redirect URI in Okta matches exactly: `shivvyas.ExpenseTracker:/callback`
- Check your bundle identifier matches

**"Invalid client" error:**
- Verify your Client ID is correct: `Ooaxzioxyr8HluG8U697`
- Check your issuer URL is correct

**Can't find Okta domain:**
- Check the browser URL when logged into Okta
- Look for "eunos-integrator-2523748" - that might be part of your domain
- Your domain might be: `eunos-integrator-2523748.okta.com`

## 📞 Need Help?

If you can't find your domain, you can:
1. Check Okta emails for your domain
2. Look at the browser URL when accessing Okta
3. Check the Okta dashboard URL

Once you have your domain, just replace `YOUR_OKTA_DOMAIN` in `OktaConfig.swift`!

