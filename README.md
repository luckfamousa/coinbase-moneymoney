# coinbase-moneymoney

Fetches balances from Coinbase API and returns them as securities

# Version 2.0

As of version 2.0, currencies whose number is `0` will no longer be displayed, possibly the individual history will disappear for this.

However, the entire history for the Coinbase account remains.

# Coinbase V3 API

Coinbase has released their new Advanced Trade API, which can be accessed at the endpoint: [https://api.coinbase.com/api/v3/brokerage/](https://api.coinbase.com/api/v3/brokerage/). The API documentation can be found here: [https://docs.cdp.coinbase.com/advanced-trade/docs/welcome](https://docs.cdp.coinbase.com/advanced-trade/docs/welcome).

The main challenge in developing this extension was implementing their new authentication method, which is based on JWT tokens. The JWT token is generated by the extension and sent to the API in the header of each request. JWT signing is done using Elliptic Curve Cryptography (ECC) with the `prime256v1` curve. Therefore, the extension makes use of some undocumented `MM` functions to sign the JWT token. The token is generated using the key name and private key provided by the user.

To avoid disrupting users who are still using the old API, this extension is created as a new extension and explicitly called `Coinbase V3`.

**Important:**

1. This extension will only work with the new Advanced Trade API and not with the old V2 API.
2. You must provide your credentials as a key name and a private key. In MoneyMoney, you need to enter the **key name** as the **username** and the **private key** as the **password**.

If you download your API credentials from Coinbase in JSON format, they will look like this:

```json
{
  "name": "organizations/.../apiKeys/...",
  "privateKey": "-----BEGIN EC PRIVATE KEY-----\nM...9\nA...e\nu...==\n-----END EC PRIVATE KEY-----\n"
}
```

Use the name as the key name and the privateKey as the private key. Do not change anything, and make sure to copy the entire key, including the `-----BEGIN EC PRIVATE KEY-----` and `-----END EC PRIVATE KEY-----` lines. Ensure that you do not include any accidental whitespace at the beginning or end of the key.

## Extension Setup

You can get a signed version of this extension from

* the `dist` directory in this repository

Once downloaded, move `Coinbase.lua` for V2 or `CoinbaseV3.lua` for V3 to your MoneyMoney Extensions folder.

**Note:** This extension requires MoneyMoney Version 2.2.18 (288) or newer.

## Account Setup

### Coinbase V2 API

1. Log in to your Coinbase account
2. Go to Settings → API
3. Click "New API Key"
4. Under "Accounts", enable checkboxes for accounts you want to use
5. Under "API v2 Permissions", check "wallet:user:read" and "wallet:accounts:read" (the others aren’t needed)
5. Click "Create"

### Coinbase V3 API

1. Log in to the developer portal at https://portal.cdp.coinbase.com/
2. Create or select a project
3. Go to API Keys
3. Click "Create API Key"
4. Give the key a name, e.g. "MoneyMoney"
5. Make sure that only `View (read-only)` is selected (we don't need to trade)
5. Click "Create & download"


### MoneyMoney

Add a new account (type "Coinbase Account") and use your Coinbase API key as username and your Coinbase API secret as password.

## Screenshots

![MoneyMoney screenshot with Coinbase balances](screen.png)

### API Key

https://www.coinbase.com/settings/api

![Screenshot 2021-04-16 at 11 55 04](https://user-images.githubusercontent.com/92227/115007901-cb74f200-9eaa-11eb-8db5-d87374d9d347.png)

![Screenshot 2021-04-16 at 11 54 59](https://user-images.githubusercontent.com/92227/115007908-cca61f00-9eaa-11eb-9ef8-b0cef8a66cf4.png)
