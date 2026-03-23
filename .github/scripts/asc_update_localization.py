import urllib.request
import urllib.error
import json
import os
import sys

token = os.environ["JWT"].strip()
loc_id = os.environ["LOC_ID"].strip()
release_notes = os.environ["RELEASE_NOTES"]

body = json.dumps({
    "data": {
        "type": "appStoreVersionLocalizations",
        "id": loc_id,
        "attributes": {"whatsNew": release_notes},
    }
}).encode()

req = urllib.request.Request(
    "https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/" + loc_id,
    data=body,
    headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"},
    method="PATCH",
)
try:
    resp = urllib.request.urlopen(req)
    data = json.loads(resp.read())
    print(data["data"]["id"])
except urllib.error.HTTPError as e:
    sys.stderr.write("HTTP " + str(e.code) + ": " + e.read().decode()[:300] + "\n")
    sys.exit(1)
