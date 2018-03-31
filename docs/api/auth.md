## Auth & Login

#### Request
Headers
```
Content-Type: application/json
Accept: application/json
```
Route
```
POST /api/v1/auth/token
```
Body
```json
{
  "auth": {
    "email": "david.bradford@bluerocket.us",
    "password": "123456"
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
    "jwt": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0ODk1OTExMzcsImF1ZCI6IjY4NTMzMmM1ZWI0OGRjMjRhM2E0MDdmN2IxMzRjMTgxMjQzZjhjNTk5Y2FjYjhiMzBhMTM5ZWVkOGE4YzQ1NGZlMzlmYzU1MjJlNGQ5OTgyN2FiMTU0NzMxMDM0YjlkMmJjMzBhZjU2ZjEyYjhmOGNlMjFmMzgxYjc0MDkxZmFkIiwic3ViIjo5ODAxOTA5NjJ9.lWUniKFcsKTgSWtRflgBpA1YNQrtuqFDtz27ebh2rfs",
    "user": {
      "id": "",
      ...
    }
  }
}
```

#### Example
```shell
curl -X "POST" "https://api-qa.adultbev.co/api/v1/auth/token" \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -d $'{
  "auth": {
    "email": "hop-employee-app-staging@bluerocket.us",
    "password": "cf1099b50ccfcd37e8ca693deebaa2f7"
  }
}'
```

#### Error
Headers
```
HTTP/1.1 401 Unauthorized
Content-Type: application/json; charset=utf-8
```
