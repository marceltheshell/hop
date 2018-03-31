## Resend QR Code via MMS
#### Request
Headers
```
Authorization: Bearer <jwt>
Content-Type: application/json
Accept: application/json
```
Route
```
POST /api/v1/users/:user_id/qrcodes/deliver
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
    "status": "queued"
  }
}
```
