#!/bin/bash

set -e
if [[ -n $CI_ARCHIVE_PATH ]]; then

    UPLOAD_SYMBOLS_PATH="$CI_DERIVED_DATA_PATH/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"

    if [ ! -f "$UPLOAD_SYMBOLS_PATH" ]; then
        echo "Error: upload-symbols script not found at $UPLOAD_SYMBOLS_PATH" >&2
        exit 1
    fi

    INFO_PLIST_PATH=""

    if [ "$CI_XCODE_SCHEME" == "Armony" ]; then
        INFO_PLIST_PATH='../Armony/Resources/Firebase/GoogleService-Info.plist'
    else
        INFO_PLIST_PATH='../Armony/Resources/Firebase/GoogleService-Info-Debug.plist'
    fi

"$UPLOAD_SYMBOLS_PATH" -gsp "$INFO_PLIST_PATH" -p ios "$CI_ARCHIVE_PATH/dSYMs"

else
    echo "Archive path isn't available. Unable to run dSYMs uploading script."
fi
