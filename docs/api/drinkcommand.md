## Drink Command: Hop API integration

Version: 1.1 -- 2017-05-05

The following APIs will be made available to Drink Command for integration purposes.

- [Get Customer Info](#get-customer-info)
- [Create Charge](#create-charge)
- [Create Line Item](#create-line-item)
- [Test examples](#test-examples)


#### API Authentication
Blue Rocket will provide a JWT token _(without expiration)_ for Drink command to include in the HTTP **'Authorization'** header.
Example HTTP headers:
```
Authorization: Bearer <token here>
Content-Type: application/json
Accept: application/json
```

##### URLs
- Staging / QA: https://api-qa.adultbev.co
- Production: https://api.adultbev.co


## Get Customer Information
Retrieve the _viewable_ payment details for a particular customer using the **session token** _(ie: RFID number)_.

#### Request
Route
```
GET /api/v1/drinkcommand/customer/:session_token
```
Request Headers
```
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json
```

#### Response
Headers
```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
```
Body
```json
{
  "data": {
    "first_name": "test",
    "last_name": "testerine",
    "name_on_card": "Test T Tester",
    "card_type": "visa",
    "masked_number": "********5555",
    "expires_at": "2018-01-01",
    "balance_in_cents": 3200,
    "credit_limit_in_cents": 20000
  }
}
```

#### Payment Details Missing Error
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 20401,
    "message": "Payment information failure",
    "errors": {
      "payment": [
        "not available"
      ]
    }
  }
}
```

#### Payment Expired Error
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 20401,
    "message": "Payment information failure",
    "errors": {
      "payment": [
        "has expired"
      ]
    }
  }
}
```

#### Session token Error
Headers
```
HTTP/1.1 404 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 20404,
    "message": "User with session token not found",
    "errors": {
      "session_token": [
        "missing or invalid"
      ]
    }
  }
}
```

#### Generic error format
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "message": "",
    "code": "",
    "errors": {
      ...
    }
  }
}
```

## Create Charge
Process and apply amount _(in cents)_ to balance using the customers credit card on file.
Use the **session token** _(ie: RFID number)_ to locate the customer account.

#### Request
Route
```
POST /api/v1/drinkcommand/charge/:session_token
```
Request Headers
```
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json
```
Request Body
```json
{
  "charge": {
    "amount_in_cents": 500,
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
    "amount_in_cents": 500,
    "balance_in_cents": 2000,
    "reference_number": "717083"
  }
}
```

#### Invalid Token Error
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 20400,
    "message": "Charge transaction failure",
    "errors": {
      "charge": [
        "Invalid Token"
      ]
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
    "code": 20400,
    "message": "Charge transaction failure",
    "errors": {
      "charge": [
        "Denied by customer's bank"
      ]
    }
  }
}
```

#### Insufficient funds error
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 20400,
    "message": "Charge transaction failure",
    "errors": {
      "charge": [
        "Insufficient funds"
      ]
    }
  }
}
```

#### Invalid card error
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 20400,
    "message": "Charge transaction failure",
    "errors": {
      "charge": [
        "Invalid Account Number"
      ]
    }
  }
}
```


## Create Line Item
Store and process a "line item" from Drink Command system.
Use the **session token** _(ie: RFID number)_ to locate the customer account.

#### Request
Route
```
POST /api/v1/drinkcommand/line_item/:session_token
```
Request Headers
```
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json
```
Request Body
```json
{
  "line_item": {
    "line_item_id": "a097ca3e-d7c8-4850-b654-835a7d3fe294",
    "session_uuid": "58d2fa8c55098",
    "created_at": "2017-05-02 10:37:21 (-0700)",
    "account_type": "PRODUCT",
    "account_name": "Blue Moon",
    "product_code": "blue_moon",
    "volume_units": 70,
    "money_units": -175,
    "tap_id": "1b",
    "price_money_units": 25,
    "price_volume_units": 10,
    "note": null,
    "venue_id": 123
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
    "line_item_id": "a097ca3e-d7c8-4850-b654-835a7d3fe294",
    "status": "pending"
  }
}
```

#### Duplicate Line item ID
Headers
```
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
```
Body
```json
{
  "data": {
    "line_item_id": "a097ca3e-d7c8-4850-b654-835a7d3fe294",
    "status": "processed"
  }
}
```


#### Line item ID missing
Headers
```
HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "code": 20402,
    "message": "Line item failure",
    "errors": {
      "line_item": [
        "Line item ID can't be blank"
      ]
    }
  }
}
```

## Test Examples
Below is a series of `cURL` commands to test various API conditions.

```shell
#!/usr/bin/env bash

# Setup server url
SERVER='https://api-qa.adultbev.co'

# Auth Token for staging env
TOKEN='<goes here>'

#########
# Get Payment Details
#########

## Successful customer details:
curl "${SERVER}/api/v1/drinkcommand/customer/1685583841" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}"


## Expired customer details:
curl "${SERVER}/api/v1/drinkcommand/customer/1685583842" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}"

## Missing customer details:
curl "${SERVER}/api/v1/drinkcommand/customer/1685583843" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}"

## Missing session token:
curl "${SERVER}/api/v1/drinkcommand/customer/1685583844" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}"


#########
# Charge / Add value
#########

## Successful Charge
curl -X "POST" "${SERVER}/api/v1/drinkcommand/charge/1685583841" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
     -d $'{
  "charge": {
    "amount_in_cents": "500"
  }
}'

## Denied Error
curl -X "POST" "${SERVER}/api/v1/drinkcommand/charge/1685583841" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
     -d $'{
  "charge": {
    "amount_in_cents": "125"
  }
}'

## Insufficient Funds Error
curl -X "POST" "${SERVER}/api/v1/drinkcommand/charge/1685583841" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
     -d $'{
  "charge": {
    "amount_in_cents": "12000"
  }
}'

## Invalid Card Error
curl -X "POST" "${SERVER}/api/v1/drinkcommand/charge/1685583841" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
     -d $'{
  "charge": {
    "amount_in_cents": "7000"
  }
}'

## Network Error
curl -X "POST" "${SERVER}/api/v1/drinkcommand/charge/1685583841" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
     -d $'{
  "charge": {
    "amount_in_cents": "13000"
  }
}'

#########
# Submit a Line Item
#########

## Successful submission
curl -X "POST" "${SERVER}/api/v1/drinkcommand/line_item/1685583841" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
     -d $'{
  "line_item": {
    "line_item_id": "a097ca3e-d7c8-4850-b654-835a7d3fe294",
    "session_uuid": "58d2fa8c55098",
    "created_at": "2017-05-02 10:37:21 (-0700)",
    "account_type": "PRODUCT",
    "account_name": "Blue Moon",
    "product_code": "blue_moon",
    "volume_units": 70,
    "money_units": -175,
    "tap_id": "1b",
    "price_money_units": 25,
    "price_volume_units": 10,
    "note": null,
    "venue_id": "123"
  }
}'
```
