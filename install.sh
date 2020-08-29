#!/bin/bash

INSTALL_PATH="/opt/robo3t"
GITHUB_JSON_RESPONSE=$(curl -s -XGET 'https://api.github.com/repos/Studio3T/robomongo/releases/latest')
CURRENT_VERSION=$(echo "$GITHUB_JSON_RESPONSE" | grep "tag_name" | sed -En "s/^.*\"v//p" | sed -En "s/\".*$//p")
DOWNLOAD_URL=$(echo "$GITHUB_JSON_RESPONSE" | grep "browser_download_url" | grep "linux" | sed -En "s/^.*http/http/p" | sed -En "s/\".*$//p")
FILE_NAME=$(echo "$DOWNLOAD_URL" | sed -En "s/^.*\///p")

function install_latest_version {
	echo "Current version: $CURRENT_VERSION"
	echo "Installed version: $1"
	echo "Download URL: $DOWNLOAD_URL"
	echo "File name: $FILE_NAME"
	wget -P /tmp "$DOWNLOAD_URL"
	sudo tar -xzf "/tmp/$FILE_NAME" -C /opt
	sudo rm "/tmp/$FILE_NAME"
	sudo mv "$INSTALL_PATH"* "$INSTALL_PATH"
	sudo wget -O "${INSTALL_PATH}/bin/icon.png" "https://raw.githubusercontent.com/Studio3T/robomongo/master/install/macosx/robomongo.iconset/icon_256x256.png"
	sudo su -c "echo '$CURRENT_VERSION' > '${INSTALL_PATH}/version'"
	echo "Robo 3T v${CURRENT_VERSION} installed"
}

if [ ! -d "$INSTALL_PATH" ]; then
	echo "Starting install process"
	install_latest_version "-"
	echo -e "[Desktop Entry]\nEncoding=UTF-8\nIcon=${INSTALL_PATH}/bin/icon.png\nName=Robo3T\nExec=robo3t\nTerminal=false\nType=Application\nCategories=Development;" > ~/.local/share/applications/robo3t.desktop
	sudo ln -s "${INSTALL_PATH}/bin/robo3t" /usr/bin/robo3t
else
	INSTALLED_VERSION=$(cat "${INSTALL_PATH}/version")
	if [ "$CURRENT_VERSION" \> "$INSTALLED_VERSION" ]; then
		echo "Starting update process"
		sudo rm -rf "$INSTALL_PATH"
		install_latest_version "$INSTALLED_VERSION"
	else
		echo "Robo 3T is already up-to-date (v${CURRENT_VERSION})"
	fi
fi
