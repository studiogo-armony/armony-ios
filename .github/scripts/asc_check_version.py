import urllib.request
import urllib.error
import json
import os
import sys

token = os.environ["JWT"].strip()
app_id = os.environ["ASC_APP_ID"].strip()
version = os.environ["VERSION"].strip()

url = (
    "https://api.appstoreconnect.apple.com/v1/apps/"
    + app_id
    + "/appStoreVersions?filter[versionString]="
    + version
    + "&filter[platform]=IOS"
)
req = urllib.request.Request(
    url,
    headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"},
)
try:
    resp = urllib.request.urlopen(req)
    data = json.loads(resp.read())
    items = data.get("data", [])
    print("EXISTS:" + items[0]["id"] if items else "NOTFOUND")
except urllib.error.HTTPError as e:
    sys.stderr.write("HTTP " + str(e.code) + ": " + e.read().decode()[:300] + "\n")
    sys.exit(1)
