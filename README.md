# coinbase-moneymoney

Fetches balances from Coinbase API and returns them as securities

# Version 2.0

As of version 2.0, currencies whose number is `0` will no longer be displayed, possibly the individual history will disappear for this.

However, the entire history for the Coinbase account remains.

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

![MoneyMoney screenshot with Coinbase balances](screen.png)

### API Key

https://www.coinbase.com/settings/api

![Screenshot 2021-04-16 at 11 55 04](https://user-images.githubusercontent.com/92227/115007901-cb74f200-9eaa-11eb-8db5-d87374d9d347.png)

![Screenshot 2021-04-16 at 11 54 59](https://user-images.githubusercontent.com/92227/115007908-cca61f00-9eaa-11eb-9ef8-b0cef8a66cf4.png)
