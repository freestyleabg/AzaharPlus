#!/bin/bash -ex

export NDK_CCACHE=$(which ccache)

if [ ! -z "${ANDROID_KEYSTORE_B64}" ]; then
    export ANDROID_KEYSTORE_FILE="${GITHUB_WORKSPACE}/ks.jks"
    base64 --decode <<< "${ANDROID_KEYSTORE_B64}" > "${ANDROID_KEYSTORE_FILE}"
fi

cd src/android
chmod +x ./gradlew

# By default, build only the "vanilla" flavor to avoid Google Play flavor CI breakages.
# Set ANDROID_BUILD_ALL_FLAVORS=1 to restore the old behavior (assembleRelease/bundleRelease).
if [ "${ANDROID_BUILD_ALL_FLAVORS:-0}" = "1" ]; then
    ./gradlew assembleRelease --stacktrace
    ./gradlew bundleRelease --stacktrace
else
    FLAVOR="${ANDROID_FLAVOR:-vanilla}"
    BUILD_TYPE="${ANDROID_BUILD_TYPE:-Release}"
    ./gradlew "assemble${FLAVOR^}${BUILD_TYPE}" --stacktrace
    ./gradlew "bundle${FLAVOR^}${BUILD_TYPE}" --stacktrace
fi

ccache -s -v

if [ ! -z "${ANDROID_KEYSTORE_B64}" ]; then
    rm "${ANDROID_KEYSTORE_FILE}"
fi
