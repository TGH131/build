#!/bin/bash

curl -LsO "https://cdn2.ltolfiles.com/up_4563288/unp.apk" || exit 1

DIR="$(pwd)"


if [ ! -e "$DIR/unp.apk" ]; then
	
	echo -e "\e[1;31mError: APK not found\e[0m"
    exit 1
	
fi

echo "Downloading required packages..."


CLI_VERSION="$(curl -s "https://api.github.com/repos/revanced/revanced-cli/releases/latest" -L -s $(if [ -z "$GITHUB_TOKEN" ]; then echo -H "Authorization: token $GITHUB_TOKEN" ;fi) | grep "tag_name")"
CLI_VERSION="${CLI_VERSION:16:-2}"


echo "USING CLI $CLI_VERSION"

if ! curl "https://github.com/revanced/revanced-cli/releases/download/v$CLI_VERSION/revanced-cli-$CLI_VERSION-all.jar" -L -s -o "$DIR/revanced-cli.jar"; then exit 1; fi

# Get latest integrations version
INTEGRATIONS_VERSION="$(curl -s "https://api.github.com/repos/revanced/revanced-integrations/releases/latest" -L -s $(if [ -z "$GITHUB_TOKEN" ]; then echo -H "Authorization: token $GITHUB_TOKEN" ;fi) | grep "tag_name")"
INTEGRATIONS_VERSION="${INTEGRATIONS_VERSION:16:-2}"

echo "USING INTEGRATIONS v$INTEGRATIONS_VERSION "

if ! curl -Lso "$DIR/integrations.apk" "https://github.com/revanced/revanced-integrations/releases/download/v$INTEGRATIONS_VERSION/app-release-unsigned.apk" ; then exit 1; fi

# Get latest patches version
PATCHES_VERSION="$(curl -s "https://api.github.com/repos/revanced/revanced-patches/releases/latest" -L -s $(if [ -z "$GITHUB_TOKEN" ]; then echo -H "Authorization: token $GITHUB_TOKEN" ;fi) | grep "tag_name")"
PATCHES_VERSION="${PATCHES_VERSION:16:-2}"

echo "USING PATCH v$PATCHES_VERSION"

   
if ! curl -Lso "$DIR/revanced-patches.jar" "https://github.com/revanced/revanced-patches/releases/download/v$PATCHES_VERSION/revanced-patches-$PATCHES_VERSION.jar" ; then exit 1; fi

echo "Executing the CLI..."


java -jar "revanced-cli.jar" --experimental -a "unp.apk" -b "revanced-patches.jar" -m "integrations.apk" -o "pat.apk" -e "custom-branding" -i "enable-wide-searchbar" -i "force-vp9-codec"

zip -d pat.apk "lib/armeabi-v7a/*" "lib/x86_64/*" "lib/x86/*" || exit 1

$ANDROID_SDK_ROOT/build-tools/33.0.0/zipalign -p -f 4 pat.apk alpat.apk || exit 1

sudo apt-get install -y zstd
zstd --ultra -22 alpat.apk -o zippy.zip
#zip -q -9 zippy.zip alpat.apk

exit 0

