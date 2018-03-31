## Get Purchases
#### Request
Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Route
```
GET /api/v1/users/:user_id/purchases
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
    "total": 400,
    "pages": 4,
    "purchases": [
      {
        "id": "",
        "purchased_at": "",
        "amount_in_cents": "",
        "balance_in_cents": "",
        "venue_id": "",
        "qty": "",
        "tap_id":""
      },
      {
        "id": "",
        ...
      }
    ]
  }
}
```


## Create Purchase
#### Request
Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Route
```
POST /api/v1/users/:user_id/purchases
```
Body
```json
{
  "purchase": {
    "amount_in_cents": "",
    "employee_id": "",
    "qty": "",
    "venue_id": "",
    "tap_id": "",
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
    "id": "",
    "purchased_at": "",
    "amount_in_cents": "",
    "balance_in_cents": "",
    "venue_id": "",
    "qty": "",
    "tap_id": ""
  }
}

```


#### Error
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
