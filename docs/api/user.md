## Get Users
#### Request
Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Query Params
```
page=<integer>      : page of users to load, defaults to 1.
per_page=<integer>  : number of results to load, defaults to 100.
q=<string>          : Search term, defaults to nil.
```
Route
```
GET /api/v1/users
```

#### Response
Headers
```
HTTP/1.1 200 Ok
Content-Type: application/json; charset=utf-8
```
Body
```json
{
  "data": {
    "total": 100,
    "pages": 1,
    "users": [
      {
        "id": "",
        "created_at": "",
        "type": "",
        "role": "",
        "first_name": "",
        "last_name": "",
        "middle_name": "",
        "gender": "",
        "dob": "",
        "phone": "",
        "email": "",
        "deactivated_at": "",
        "image_id": "",
        "rfid": "",
        "balance_in_cents": "",
        "addresses": [
          {
            "id": "",
            "address_type": "billing",
            "street1": "",
            "street2": "",
            "city": "",
            "state": "",
            "country": "",
            "postal": ""
          }
        ],
        "identification": {
          "id": "",
          "identification_type": "",
          "issuer": "",
          "expires_at": "",
          "image_id": ""
        },
        "payment_method": {
          "id": "",
          "token": "",
          "expires_at": "",
          "card_type": "",
          "masked_number": ""
        }
      },
      {
        "id": "",
        "created_at": "",
        "type": "",
        "role": "",
        ...
      }
    ]
  }
}
```

#### Example:
```shell
curl -X "GET" "https://api-qa.adultbev.co/api/v1/users" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <jwt>"
```


## Get User
#### Request
Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Route
```
GET /api/v1/users/:id_or_rfid
```

#### Response
Headers
```
HTTP/1.1 200 Ok
Content-Type: application/json; charset=utf-8
```
Body
```json
{
  "data": {
    "user": {
      "id": "",
      "type": "",
      "role": "",
      "first_name": "",
      "last_name": "",
      "middle_name": "",
      "height_in_cm": "",
      "weight_in_kg": "",
      "gender": "",
      "dob": "",
      "phone": "",
      "email": "",
      "deactivated_at": "",
      "image_id": "",
      "balance_in_cents": "",
      "rfid": "",
      "addresses": [
        {
          "id": "",
          "address_type": "billing",
          "street1": "",
          "street2": "",
          "city": "",
          "state": "",
          "country": "",
          "postal": ""
        }
      ],
      "identification": {
        "id": "",
        "identification_type": "",
        "issuer": "",
        "expires_at": "",
        "image_id": ""
      },
      "payment_method": {
        "id": "",
        "token": "",
        "expires_at": "",
        "card_type": "",
        "masked_number": ""
      }
    }
  }
}
```
#### Example:
```shell
curl "https://api-qa.adultbev.co/api/v1/users/1" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <jwt>"
```


## Create User
#### Request
Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Route
```
POST /api/v1/users
```
Parameter requirements
```
user
  email             : required (if no phone) & unique
  phone             : required (if no email) & unique
  rfid              : unique

address (optional)
  postal     : required

identification (optional)
  expires_at : required

payment_method (optional)
  token      : required & unique
  expires_at : required
```
Body
```json
{
  "user": {
    "first_name": "",
    "last_name": "",
    "middle_name": "",
    "height_in_cm": "",
    "weight_in_kg": "",
    "gender": "",
    "dob": "",
    "phone": "",
    "email": "",
    "password": "",
    "image_id": "",
    "rfid": "",
    "employee_id": "",
    "addresses": [
      {
        "address_type": "billing",
        "street1": "",
        "street2": "",
        "city": "",
        "state": "",
        "country": "",
        "postal": ""
      },
      {
        "address_type": "default",
        "street1": "",
        "street2": "",
        "city": "",
        "state": "",
        "country": "",
        "postal": ""
      }
    ],
    "identification": {
      "identification_type": "",
      "issuer": "",
      "expires_at": "",
      "image_id": "",
    },
    "payment_method": {
      "token": "",
      "expires_at": "",
      "card_type": "",
      "masked_number": ""
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
    "user": {
      "id": "",
      "type": "",
      "role": "",
      "first_name": "",
      "last_name": "",
      "middle_name": "",
      "height_in_cm": "",
      "weight_in_kg": "",
      "gender": "",
      "dob": "",
      "phone": "",
      "email": "",
      "deactivated_at": "",
      "image_id": "",
      "rfid": "",
      "balance_in_cents": "",
      "addresses": [
        {
          "id": "",
          "address_type": "billing",
          "street1": "",
          "street2": "",
          "city": "",
          "state": "",
          "country": "",
          "postal": ""
        }
      ],
      "identification": {
        "id": "",
        "identification_type": "",
        "issuer": "",
        "expires_at": "",
        "image_id": "",
      },
      "payment_method": {
        "id": "",
        "token": "",
        "expires_at": "",
        "card_type": "",
        "masked_number": ""
      }
    }
  }
}
```
#### Example:
```shell
curl -X "POST" "https://api-qa.adultbev.co/api/v1/users" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <jwt>" \
     -d $'{
  "user": {
    "email": "testing@tester.com",
    "password": "123456",
    "last_name": "Tester",
    "first_name": "Test"
    ...
  }
}'

```


## Update User
#### Request

Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Route
```
PUT /api/v1/users/:id #rfid is only accepted with GET/DELETE requests
```
Body
```json
{
  "user": {
    "id": "",
    "first_name": "",
    "last_name": "",
    "middle_name": "",
    "height_in_cm": "",
    "weight_in_kg": "",
    "gender": "",
    "dob": "",
    "phone": "",
    "email": "",
    "image_id": "",
    "rfid": "",
    "addresses": [
      {
        "id": "billing",
        "address_type": "",
        "street1": "",
        "street2": "",
        "city": "",
        "state": "",
        "country": "",
        "postal": ""
      }
    ],
    "identification": {
      "id": "",
      "identification_type": "",
      "issuer": "",
      "expires_at": "",
      "image_id": "",
    },
    "payment_method": {
      "id": "",
      "token": "",
      "expires_at": "",
      "card_type": "",
      "masked_number": ""
    }
  }
}
```

#### Response
Headers
```
HTTP/1.1 201 updated
Content-Type: application/json; charset=utf-8
```
Body
```json
{
  "data": {
    "status": "updated"
  }
}
```
#### Example:
```shell
curl -X "PUT" "https://api-qa.adultbev.co/api/v1/users/1" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <jwt>" \
     -d $'{
  "user": {
    "email": "testing@tester.com",
    "password": "123456",
    "last_name": "Tester",
    "first_name": "Test"
    ...
  }
}'

```


## Delete User
The default behavior is to "deactivate" the users' account. This keeps it
in tact without loosing their data, however, they are no longer visible.
_To permanently remove a user account, use the `force` parameter._

#### Request
Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Query Params
```
force=true      : physically remove user account permanently. CAUTION: cannot be undone!!!
```
Route
```
DELETE /api/v1/users/:id_or_rfid
```

#### Response
Headers
```
HTTP/1.1 201 Deleted
Content-Type: application/json; charset=utf-8
```
Body
```json
{
  "data": {
    "status": "deleted"
  }
}
```
#### Example:
```shell
curl -X "DELETE" "https://api-qa.adultbev.co/api/v1/users/1" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <jwt>"
```


#### Errors
Headers
```
HTTP/1.1 400 Bad Request
Content-Type: application/json; charset=utf-8
```

Body
```json
{
  "data": {
    "message": "",
    "code": "",
    "errors": {
        "first_name": [
            "not blank",
            "too short"
        ],
        "email": [
            "not blank"
        ],
        "billing_address": {
          "street1": [
              "not blank"
            ]
        },
        "default_address": {
          "postal": [
            "not blank"
          ]
        },
        "identification": {
          "issuer": [
            "not blank"
          ]
        },
        "payment_method": {
          "expires_at": [
            "in the past"
          ]
      }
    }
  }
}
```
