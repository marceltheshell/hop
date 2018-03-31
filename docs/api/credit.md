## Creates CC Credit
Credit customers credit card (on file) and deducts amount from  customer's HOP account balance w.

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
POST /api/v1/users/:user_id/credits
```
Body
```json
{
  "credit": {
    "amount_in_cents": ""
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
    "credit": {
      "id": 961244813,
      "credit_at": "2017-04-05T21:30:54Z",
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
        "GatewayMessage": "A02 - Credit Posted",
        "InternalMessage": "Credit Posted",
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
        "ResponseTypeDescription": "credit",
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
    "message": "Credit transaction failure",
    "errors": {
      "credit": [
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
    "message": "Credit transaction failure",
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
HTTP/1.1 404 Not Found
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
Below is a `cURL` command to test posting a "Credit" to the customer's credit card.
A "Credit" would be reflected as a debit to the customer's hop account balance

```shell
#!/usr/bin/env bash

# Setup server url
SERVER='https://api-qa.adultbev.co'

#########
# Post a credit. User_id 16 should work for testing credits
#########

curl "${SERVER}/api/v1/users/:id/credits" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
     -d $'{
          "credit":{  
            "amount_in_cents": "500"
            }
          }' | python -m json.tool \

```
