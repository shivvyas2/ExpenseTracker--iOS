# How to Find Your Okta Domain

## Method 1: Check Your Browser URL (Easiest) ⭐

1. **Look at the address bar** when you're logged into Okta Admin Console
2. The URL will look like one of these:
   - `https://dev-123456.okta.com/admin/app/...`
   - `https://yourcompany.okta.com/admin/app/...`
   - `https://eunos-integrator-2523748.okta.com/admin/app/...`
3. **Copy the part before `.okta.com`**
   - Example: If URL is `https://dev-123456.okta.com/admin/...`
   - Your domain is: `dev-123456`
   - Your issuer URL will be: `https://dev-123456.okta.com/oauth2/default`

## Method 2: Check Top Right Corner

1. Look at the **top right corner** of your Okta Admin Console
2. You might see your domain displayed there
3. It could show something like: `eunos-integrator-2523748`

## Method 3: Check Your Email

1. Look for any **emails from Okta** (welcome email, setup emails)
2. They usually contain your Okta domain in the links or text
3. The domain will be in any Okta-related URLs in the email

## Method 4: Check Okta Dashboard URL

1. When you first log into Okta, check the main dashboard URL
2. It will show your domain clearly in the address bar

## Method 5: From Your Current Screen

Based on your Okta console screenshot:
- I can see "eunos-integrator-2523748" in the top right
- Your domain is likely: **`eunos-integrator-2523748`**
- Your issuer URL should be: **`https://eunos-integrator-2523748.okta.com/oauth2/default`**

## Quick Test

Once you have your domain, test it by:
1. Opening a new browser tab
2. Going to: `https://YOUR_DOMAIN.okta.com`
3. If it loads the Okta login page, you have the correct domain!

## What to Do Next

1. **Copy your domain** (e.g., `eunos-integrator-2523748`)
2. **Open** `ExpenseTracker/Model/OktaConfig.swift`
3. **Replace** `YOUR_OKTA_DOMAIN` with your domain:
   ```swift
   static let issuer = "https://eunos-integrator-2523748.okta.com/oauth2/default"
   ```

## Still Can't Find It?

If you're still having trouble:
1. **Check the browser URL** - it's always in the address bar
2. **Look at any Okta links** you've clicked
3. **Check your Okta account settings** - the domain is usually displayed there

