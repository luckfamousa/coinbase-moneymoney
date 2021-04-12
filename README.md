# coinbase-moneymoney

Fetches balances from Coinbase API and returns them as securities

## Extension Setup

You can get a signed version of this extension from

* the `dist` directory in this repository

Once downloaded, move `Coinbase.lua` to your MoneyMoney Extensions folder.

**Note:** This extension requires MoneyMoney Version 2.2.18 (288) or newer.

## Account Setup

### Coinbase

1. Log in to your Coinbase account
2. Go to Settings → API
3. Click "New API Key"
4. Under "Accounts", enable checkboxes for accounts you want to use
5. Under "API v2 Permissions", check "wallet:user:read" and "wallet:accounts:read" (the others aren’t needed)
5. Click "Create"

### MoneyMoney

Add a new account (type "Coinbase Account") and use your Coinbase API key as username and your Coinbase API secret as password.

## Screenshots

![113115847-23ee9300-920d-11eb-89a6-82afadbb3851](https://user-images.githubusercontent.com/92227/114431575-eea85480-9bbf-11eb-990e-e7c0a6dfd72b.png)

![113115787-1507e080-920d-11eb-92b3-89198627a5d8](https://user-images.githubusercontent.com/92227/114431581-efd98180-9bbf-11eb-918e-e733adb7dedd.png)

![MoneyMoney screenshot with Coinbase balances](screen.png)
