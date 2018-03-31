## Get user's transaction history
Retrieves all transactions for a particular user

Find user by:
- **user_id** _(internal users' primary key)_, or
- **rfid** _(Drink Command 'session_token')_ --


#### Request
Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Route
```
GET /api/v1/users/:user.id_or_user.rfid/transactions
```
With optional params
```shell
# per_page defaults to 100 when no specified
# filters by transaction type (singular) q=${type} ex: charge, credit, refund, comp, purchase. It defaults to all transactions
```
```
GET /api/v1/users/:user.id_or_user.rfid/transactions?page=1&per_page=5

GET /api/v1/users/:user.id_or_user.rfid/transactions?q=charge
```

#### Response
Headers
```
HTTP/1.1 200 Ok
Content-Type: ""application/json; charset=utf-8
```
Body
```json
{
  "data": ""{
    "total": "",
    "pages": "",
    "transactions": [
      {
        "id": "",
        "type": "",
        "amount_in_cents": "",
        "balance_in_cents": "",
        "description": "",
        "tap_id": "",
        "qty": "",
        "venue_id": "",
        "created_at": ""
      },
      {
        "id": "",
        "type": "",
        "amount_in_cents": "",
        "balance_in_cents": "",
        "description": "",
        "tap_id": "",
        "qty": "",
        "venue_id": "",
        "created_at": ""
      }
    ]
  }
}
```

#### User missing error
Headers
```
HTTP/1.1 404 Not Found
Content-Type: ""application/json; charset=utf-8
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

Below is a `cURL` command to get all transactions history.

```shell
#!/usr/bin/env bash

# Setup server url
SERVER='https://api-qa.adultbev.co'

curl "${SERVER}/api/v1/users/:user_id/transactions" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" | python -m json.tool \
```
