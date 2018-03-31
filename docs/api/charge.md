## Create CC Charge
Charge customers credit card (on file) and add to their HOP account balance.

Find user by:
- **user_id** _(internal users' primary key)_, or
- **rfid** _(Drink Command 'session_token')_ -- **NOT SUPPORTED YET (FUTURE)**


#### Request
Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Route
```
POST /api/v1/users/:user_id/charges
```
**_(if "payment_method" is not passed, it defaults to the one on record )_**

Body
```json
{
  "charge": {
    "amount_in_cents": "",
    "payment_method": {
      "token": "",
      "expires_at": "",
    }  
  }
}
```

#### Response
Headers
```
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
```
Body
```json
{
  "data": {
    "charge": {
      "id": 961244813,
      "charge_at": "2017-04-05T21:30:54Z",
      "amount_in_cents": 500,
      "balance_in_cents": 3700,
      "metadata": {
        "Token": "1000000074340019",
        "ExpirationDate": "0818",
        "AuthorizationCode": "128375",
        "ReferenceNumber": null,
        "AuthorizedAmount": "500",
        "OriginalAmount": "500",
        "GatewayTransID": "221763504",
        "GatewayMessage": "A01 - Approved",
        "InternalMessage": "Approved: 128375 (approval code)",
        "GatewayResult": "00000",
        "AVSMessage": null,
        "AVSResult": null,
        "CVMessage": null,
        "CVResult": null,
        "TransactionCode": "3307b1c8-ac62-43db-8f66-8a4060023a41",
        "TransactionDate": "20170327",
        "RemainingAmount": "0",
        "IsoCountryCode": "840",
        "IsoCurrencyCode": "USD",
        "IsoTransactionDate": "2017-03-27 13:18:59.43",
        "IsoRequestDate": "2017-03-27 13:18:59.43",
        "NetworkReferenceNumber": null,
        "MerchantCategoryCode": null,
        "NetworkMerchantId": null,
        "NetworkTerminalId": null,
        "CardType": null,
        "MaskedPan": null,
        "ResponseTypeDescription": "sale",
        "IsCommercialCard": "False",
        "StreetMatchMessage": null,
        "WalletID": null,
        "WalletPaymentMethodID": null,
        "WalletResponseCode": null,
        "WalletResponseMessage": null
      }
    }
  }
}
```

#### Generic Error Format
Headers
```
HTTP/1.1 404 Not Found
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "message": "",
    "code": "",
    "errors":{
      ...
    }
  }
}
```

#### Denied Error
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 10006,
    "message": "Charge transaction failure",
    "errors": {
      "charge": [
        "Denied by customer's bank"
      ]
    }
  }
}
```

#### Payment method missing error
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 10006,
    "message": "Charge transaction failure",
    "errors": {
      "payment": [
        "details are missing"
      ]
    }
  }
}
```

#### User missing error
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 10004,
    "message": "Record not found",
    "errors": {
      "user": [
        "not found"
      ]
    }
  }
}
```
## Test Examples

Below is a `cURL` command to test posting a "Charge" to the customer's credit card.
A "Charge" would be reflected as a deposit to the customer's hop account balance.

```shell
#!/usr/bin/env bash

# Setup server url
SERVER='https://api-qa.adultbev.co'

#########
# Post a Charge.
# User_id 16 should work.
# payment_method is optional when then user already has one on record.
#########

curl "${SERVER}/api/v1/users/:id/charges" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
     -d $'{
          "charge":{  
            "amount_in_cents": "500",
            "payment_method": {
              "token": 12345,
              "expires_at": "2018-01-01"
              }
            }
          }' | python -m json.tool \

```
