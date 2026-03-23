import urllib.request
import urllib.error
import json
import os
import sys

token = os.environ["JWT"].strip()
version_id = os.environ["VERSION_ID"].strip()

url = (
    "https://api.appstoreconnect.apple.com/v1/appStoreVersions/"
    + version_id
    + "/appStoreVersionLocalizations"
)
req = urllib.request.Request(
    url,
    headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"},
)
try:
    resp = urllib.request.urlopen(req)
    data = json.loads(resp.read())
    for item in data.get("data", []):
        print(item["id"] + ":" + item["attributes"]["locale"])
except urllib.error.HTTPError as e:
    sys.stderr.write("HTTP " + str(e.code) + ": " + e.read().decode()[:300] + "\n")
    sys.exit(1)
