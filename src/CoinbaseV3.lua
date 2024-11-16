-- Inofficial Coinbase Extension (www.coinbase.com) for MoneyMoney
-- Fetches balances from Coinbase API V3 and returns them as securities
--
-- Username: Coinbase Key Name
-- Password: Coinbase Private Key
--
-- Copyright (c) 2024 Felix Nensa
-- Copyright (c) 2020-2022 Martin Wilhelmi
-- Copyright (c) 2017 Nico Lindemann
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking {
    version = 3.0,
    url = "https://api.coinbase.com",
    description = "Fetch balances from Coinbase API V3 and list them as securities",
    services = { "Coinbase Account" }
}

local apiKey
local apiSecret
local currency
local balances
local prices
local api_host = "api.coinbase.com"
local api_path = "/api/v3/brokerage/"
local market = "Coinbase"
local accountNumber = "Main"

function SupportsBank (protocol, bankCode)
    return protocol == ProtocolWebBanking and bankCode == "Coinbase Account"
end
  
function InitializeSession (protocol, bankCode, username, username2, password, username3)
    apiKey = username
    apiSecret = password
    -- Take currency of first fiat account, ignores pagination limit (default: 49)
    -- See: https://docs.cdp.coinbase.com/advanced-trade/reference/retailbrokerageapi_getaccounts/
    local accounts = queryPrivate("accounts")
    local size = accounts["size"]
    for i = 1, size do
        local account = accounts["accounts"][i]
        if account["type"] == "ACCOUNT_TYPE_FIAT" then
            currency = account["currency"]
            break
        end
    end
end

function ListAccounts (knownAccounts_notused)
    local account = {
        name = market,
        accountNumber = accountNumber,
        currency = currency,
        portfolio = true,
        type = "AccountTypePortfolio"
    }
    return {account}
end

function RefreshAccount(account_notused, since_notused)
    local s = {}
    local accounts = queryPrivate("accounts")

    local size = accounts["size"]
    for i = 1, size do
        local account = accounts["accounts"][i]
        if account["type"] == "ACCOUNT_TYPE_FIAT" then
            s[#s+1] = {
                name = account["name"],
                market = market,
                currency = account["currency"],
                amount = account["available_balance"]["value"]
            }
        else
            
            local prices = queryPrivate("market/products/" .. account["currency"] .. "-" .. currency)
            
            if prices == nil or prices["error"] then
                s[#s+1] = {
                    name = account["name"],
                    market = market,
                    currency = account["currency"],
                    quantity = account["available_balance"]["value"],
                    amount = nil,
                    price = nil
                }
            else
                s[#s+1] = {
                    name = account["name"],
                    market = market,
                    currency = account["currency"],
                    quantity = account["available_balance"]["value"],
                    amount = account["available_balance"]["value"] * prices["price"],
                    price = prices["price"]
                }
            end
        end
    end

    return {securities = s}
end

function EndSession ()
end

-------------------- Helper functions --------------------

-- Function to pad a byte string to a specific length with leading zeros
local function pad_to_length(data, length)
    if #data < length then
        data = string.rep("\0", length - #data) .. data
    elseif #data > length then
        data = data:sub(-length)  -- Trim to the required length if longer
    end
    return data
end

-- Function to convert a DER-encoded signature to concatenated r || s format
-- Based on https://stackoverflow.com/a/69109085/5347900
local function der_to_concat_rs(der_signature)
    local pos = 1
    assert(der_signature:byte(pos) == 0x30, "Expected SEQUENCE")
    pos = pos + 1  -- Skip SEQUENCE tag

    local length = der_signature:byte(pos)
    pos = pos + 1

    -- Extract r value
    assert(der_signature:byte(pos) == 0x02, "Expected INTEGER for r")
    pos = pos + 1
    local r_len = der_signature:byte(pos)
    pos = pos + 1
    local r = der_signature:sub(pos, pos + r_len - 1)
    pos = pos + r_len

    -- Extract s value
    assert(der_signature:byte(pos) == 0x02, "Expected INTEGER for s")
    pos = pos + 1
    local s_len = der_signature:byte(pos)
    pos = pos + 1
    local s = der_signature:sub(pos, pos + s_len - 1)
    pos = pos + s_len

    -- Ensure r and s are 32 bytes by adding leading zeros if necessary
    r = pad_to_length(r, 32)
    s = pad_to_length(s, 32)

    -- Concatenate r || s
    return r .. s
end

-- Function to create JWT token using ES256 and MM helper functions
function create_jwt(apiSecret, header, payload)
    local json_header = JSON():set(header):json()
    local json_payload = JSON():set(payload):json()

    -- Ensure header and payload are BASE64 encoded
    local encoded_header = MM.base64urlencode(json_header)
    local encoded_payload = MM.base64urlencode(json_payload)

    local signature_input = encoded_header .. "." .. encoded_payload

    -- Load and parse the EC private key
    local key = apiSecret
    key = string.match(key, "BEGIN EC PRIVATE KEY%-%-%-%-%-%s*(.*)%-%-%-%-%-END EC PRIVATE KEY")
    key = string.gsub(key, "%s+", "")
    key = MM.base64decode(key)

    local der = MM.derdecode(MM.derdecode(key)[1][2])
    local d = der[2][2]
    local p = MM.derdecode(der[4][2])[1][2]
    local x = string.sub(p, string.len(p) - 63, string.len(p) - 32)
    local y = string.sub(p, string.len(p) - 31)

    -- Sign the data using MM.ecSign
    local signature = MM.ecSign({curve="prime256v1", d=d, x=x, y=y}, signature_input, "ecdsa sha256")
    local rs_signature = der_to_concat_rs(signature)
    local encoded_signature = MM.base64urlencode(rs_signature)

    -- Construct and return the JWT
    return encoded_header .. "." .. encoded_payload .. "." .. encoded_signature
end

-- Generate a hexadecimal nonce
local function generate_hex_nonce(length)
    local res = {}
    local hex_chars = '0123456789abcdef'

    for i = 1, length do
        local rand_index = math.random(1, #hex_chars)
        table.insert(res, hex_chars:sub(rand_index, rand_index))
    end

    return table.concat(res)
end

-- Query the advanced trade API with a private method
-- See: https://docs.cdp.coinbase.com/advanced-trade/reference/
function queryPrivate(method)
    local request_method = "GET"
    local nonce = generate_hex_nonce(64)
    local uri = request_method .. " " .. api_host .. api_path .. method
    local nbf = os.time()
    local exp = nbf + 120
    local header = {alg = "ES256", kid = apiKey, nonce = nonce, typ = "JWT"}
    local payload = {sub = apiKey, iss = "cdp", nbf = nbf, exp = exp, uri = uri}
    local jwt_token = create_jwt(apiSecret, header, payload)
    
    local path = api_path .. method
    local headers = {}
    headers["Accept"] = "application/json"
    headers["Authorization"] = "Bearer " .. jwt_token
    
    local connection = Connection()
    local content = connection:request("GET", url .. path, nil, nil, headers)
  
    local json = JSON(content)
    return json:dictionary()
end