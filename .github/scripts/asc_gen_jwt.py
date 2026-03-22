import jwt
import time
import os
import sys

key = open(sys.argv[1]).read()
payload = {
    "iss": os.environ["ASC_ISSUER_ID"],
    "iat": int(time.time()),
    "exp": int(time.time()) + 1100,
    "aud": "appstoreconnect-v1",
}
headers = {"kid": os.environ["ASC_KEY_ID"]}
print(jwt.encode(payload, key, algorithm="ES256", headers=headers))
