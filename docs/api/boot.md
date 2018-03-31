## Service User Login & Boot Data

Authenticate and load application specific settings. Only "Service" accounts can use this endpoint. "Customers" will be denied accesses, use /auth/token instead.

#### Request
Headers
```
Content-Type: application/json
Accept: application/json
```
Route
```
POST /api/v1/boot
```
Body
```json
{
  "auth": {
    "email": "employee-app@test.com",
    "password": "123456",
  }
}
```
OR for **RFID** authentication:
```json
{
  "auth": {
    "rfid": "123456789ABC"
  }
}
```
OR for **PIN** authentication:
```json
{
  "auth": {
    "pin": "123456"
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
    "jwt": "<redacted>",
    "resources": {
      "self": "/api/v1/boot",
      "auth": "/api/v1/auth/token",
      "users": "/api/v1/users",
      "charges": "/api/v1/users/:user_id/charges",
      "purchases": "/api/v1/users/:user_id/purchases",
      "credits": "/api/v1/users/:user_id/credits",
      "comps": "/api/v1/users/:user_id/comps"
    },
    "bridge_pay": {
      "username": "<redacted>",
      "password": "<redacted>",
      "merchant_code": "<redacted>",
      "merchant_account": "<redacted>"
    },
    "aws": {
      "region": "RegionString",
      "bucket": "BucketString",
      "identity_id": "IdentityString",
      "identity_pool_id": "PoolString",
      "uploads": {
        "pattern": "uploads/:uuid.jpg",
        "prefix": "uploads/",
        "suffix": "jpg",
        "content_type": "image/jpeg"
      },
      "hires": {
        "pattern": "hires/:uuid.jpg",
        "prefix": "hires/",
        "suffix": "jpg",
        "content_type": "image/jpeg"
      },
      "lowres": {
        "pattern": "lowres/:uuid.jpg",
        "prefix": "lowres/",
        "suffix": "jpg",
        "content_type": "image/jpeg"
      }
    },
    "venues": [
      {
        "id": 980190962,
        "drinkcommand_id": "123",
        "name": "Test Venue",
        "cameras": [
          {
            "style": "podium",
            "tap_id": "nil",
            "url": "rtsp://admin:123456@192.168.88.94:7070/stream1",
            "name": "Camera #1"
          }
        ]
      }
    ]
  }
}
```

#### Example with email/password:
```shell
curl -X "POST" "https://api-qa.adultbev.co/api/v1/boot" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -d $'{
  "auth": {
    "email": "hop-employee-app-staging@bluerocket.us",
    "password": "cf1099b50ccfcd37e8ca693deebaa2f7"
  }
}'
```

#### Example with RFID:
```shell
curl -X "POST" "https://api-qa.adultbev.co/api/v1/boot" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -d $'{
  "auth": {
    "rfid": "123456ABC"
  }
}'
```

#### Example with PIN (6 digits & unique):
```shell
curl -X "POST" "https://api-qa.adultbev.co/api/v1/boot" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -d $'{
  "auth": {
    "pin": "123456"
  }
}'
```

#### Error
Headers
```
HTTP/1.1 401 Unauthorized
Content-Type: application/json; charset=utf-8
```
Body
```json
{
  "data": {
    "code": 10005,
    "message": "Unauthorized",
    "errors": {
      "access": [
        "Unauthorized"
      ]
    }
  }
}
```
