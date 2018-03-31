# README

```shell
bin/setup
```

# Deployment
Add the following ENV vars to heroku:
```
SECRET_KEY_BASE=<secret>
HOP_AUDIENCE_KEY=<secret>
ENCRYPT_BASE64_KEY=<secret>
```

# Generate the base64 encoded 'encrypt key':
```ruby
# Encryptor.generate_key( <password>, <salt> )
Encryptor.generate_key('my secret password', SecureRandom.hex(32))
```
