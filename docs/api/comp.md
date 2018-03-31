## Adds credit to user's hope account
Adds credit balance to customer's HOP account balance (no external Bridgepay request)

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
POST /api/v1/users/:user_id/comps
```
Body
```json
{
  "comp": {
    "amount_in_cents": "",
    "employee_id": "",
    "venue_id": "",
    "description": ""
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
    "comp": {
      "id": 961244813,
      "comp_at": "2017-04-05T21:30:54Z",
      "amount_in_cents": 500,
      "balance_in_cents": 3700,
      "venue_id": "",
      "employee_id": ""
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
    "code": "",
    "message": "",
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
    "code": 10010,
    "message": "Comp transaction failure",
    "errors": {
      "amount_in_cents": [
        "must be greater than or equal to 0"
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
      "record": [
        "Record for User :id was not found"
      ]
    }
  }
}
```

## Test Examples
Below is a `cURL` command to test posting a "Comp" to the customer's hop account.
A "Comp" would be reflected as a deposit to the customer's hop account balance.
No transactions will be sent to the Customer's credit card.

```shell
#!/usr/bin/env bash

# Setup server url
SERVER='https://api-qa.adultbev.co'

#########
# Post a credit. Any user should work for testing comps
#########

curl "${SERVER}/api/v1/users/:id/comp" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
     -d $'{
          "comp":{  
            "amount_in_cents": "500"
            }
          }' | python -m json.tool \

```
