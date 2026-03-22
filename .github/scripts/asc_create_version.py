import urllib.request
import urllib.error
import json
import os
import sys

token = os.environ["JWT"].strip()
app_id = os.environ["ASC_APP_ID"].strip()
version = os.environ["VERSION"].strip()

body = json.dumps({
    "data": {
        "type": "appStoreVersions",
        "attributes": {
            "platform": "IOS",
            "versionString": version,
            "releaseType": "MANUAL",
        },
        "relationships": {
            "app": {"data": {"type": "apps", "id": app_id}}
        },
    }
}).encode()

req = urllib.request.Request(
    "https://api.appstoreconnect.apple.com/v1/appStoreVersions",
    data=body,
    headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"},
    method="POST",
)
try:
    resp = urllib.request.urlopen(req)
    data = json.loads(resp.read())
    print(data["data"]["id"])
except urllib.error.HTTPError as e:
    body = e.read().decode()
    sys.stderr.write("HTTP " + str(e.code) + ": " + body[:500] + "\n")
    sys.exit(1)
