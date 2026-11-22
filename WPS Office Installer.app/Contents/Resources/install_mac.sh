#!/bin/sh
APPLICATIONS_DIR="/Applications"
APP_NAME="wpsoffice.app"
TOOL_PATH="$1"
SOURCE_PACKAGE_DIR="$2"
SOURCE_APP_PATH="$3"
TEMP_DIR="$3/temp/"
INSTALL_PATH="$APPLICATIONS_DIR/$APP_NAME"

if [ ! -f "$SOURCE_PACKAGE_DIR" ]; then
  echo "failed: source package '$SOURCE_PACKAGE_DIR' does not exist"
  exit 1
fi

"$TOOL_PATH" x -snld -y "$SOURCE_PACKAGE_DIR" -o"$SOURCE_APP_PATH" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "7z decompress failed"
  exit 1
fi

echo "source app path: $SOURCE_APP_PATH/$APP_NAME"
chown -R root:staff "$SOURCE_APP_PATH/$APP_NAME" && chmod -R 775 "$SOURCE_APP_PATH/$APP_NAME"
xattr -d -r com.apple.quarantine "$SOURCE_APP_PATH/$APP_NAME"
if [ $? -ne 0 ]; then
  echo "failed to remove quarantine attribute from $SOURCE_APP_PATH"
  exit 1
fi

if [ -e "$INSTALL_PATH" ]; then
    mkdir -p "$TEMP_DIR"
    mv "${INSTALL_PATH}" "${TEMP_DIR}"
fi
mv "$SOURCE_APP_PATH/$APP_NAME" "$APPLICATIONS_DIR/"
if [ -e "${INSTALL_PATH}" ]; then
    echo "install success"
else
    echo "install failed, restore old app"
    if [ -e "${TEMP_DIR}${APP_NAME}" ]; then
        mv "${TEMP_DIR}${APP_NAME}" "${INSTALL_PATH}"
    fi
fi
rm -rf "${TEMP_DIR}"

