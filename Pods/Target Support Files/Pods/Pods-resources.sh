#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

realpath() {
  DIRECTORY="$(cd "${1%/*}" && pwd)"
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "${PODS_ROOT}/$1")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "MuPDF/platform/ios/iTunesArtwork2.png"
  install_resource "MuPDF/platform/ios/x_alt_blue.png"
  install_resource "MuPDF/platform/ios/x_alt_blue@2x.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_annot.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_annotation.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_arrow_left.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_arrow_right.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_cancel.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_check.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_clipboard.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_dir.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_doc.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_highlight.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_link.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_list.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_magnifying_glass.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_more.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_pen.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_print.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_proof.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_reflow.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_select.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_share.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_strike.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_trash.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_underline.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_updir.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/icon.png"
  install_resource "vfrReader/Graphics/Reader-Button-H.png"
  install_resource "vfrReader/Graphics/Reader-Button-H@2x.png"
  install_resource "vfrReader/Graphics/Reader-Button-N.png"
  install_resource "vfrReader/Graphics/Reader-Button-N@2x.png"
  install_resource "vfrReader/Graphics/Reader-Email.png"
  install_resource "vfrReader/Graphics/Reader-Email@2x.png"
  install_resource "vfrReader/Graphics/Reader-Export.png"
  install_resource "vfrReader/Graphics/Reader-Export@2x.png"
  install_resource "vfrReader/Graphics/Reader-Mark-N.png"
  install_resource "vfrReader/Graphics/Reader-Mark-N@2x.png"
  install_resource "vfrReader/Graphics/Reader-Mark-Y.png"
  install_resource "vfrReader/Graphics/Reader-Mark-Y@2x.png"
  install_resource "vfrReader/Graphics/Reader-Print.png"
  install_resource "vfrReader/Graphics/Reader-Print@2x.png"
  install_resource "vfrReader/Graphics/Reader-Thumbs.png"
  install_resource "vfrReader/Graphics/Reader-Thumbs@2x.png"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "MuPDF/platform/ios/iTunesArtwork2.png"
  install_resource "MuPDF/platform/ios/x_alt_blue.png"
  install_resource "MuPDF/platform/ios/x_alt_blue@2x.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_annot.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_annotation.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_arrow_left.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_arrow_right.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_cancel.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_check.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_clipboard.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_dir.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_doc.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_highlight.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_link.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_list.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_magnifying_glass.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_more.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_pen.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_print.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_proof.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_reflow.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_select.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_share.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_strike.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_trash.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_underline.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/ic_updir.png"
  install_resource "MuPDF/platform/android/res/drawable-ldpi/icon.png"
  install_resource "vfrReader/Graphics/Reader-Button-H.png"
  install_resource "vfrReader/Graphics/Reader-Button-H@2x.png"
  install_resource "vfrReader/Graphics/Reader-Button-N.png"
  install_resource "vfrReader/Graphics/Reader-Button-N@2x.png"
  install_resource "vfrReader/Graphics/Reader-Email.png"
  install_resource "vfrReader/Graphics/Reader-Email@2x.png"
  install_resource "vfrReader/Graphics/Reader-Export.png"
  install_resource "vfrReader/Graphics/Reader-Export@2x.png"
  install_resource "vfrReader/Graphics/Reader-Mark-N.png"
  install_resource "vfrReader/Graphics/Reader-Mark-N@2x.png"
  install_resource "vfrReader/Graphics/Reader-Mark-Y.png"
  install_resource "vfrReader/Graphics/Reader-Mark-Y@2x.png"
  install_resource "vfrReader/Graphics/Reader-Print.png"
  install_resource "vfrReader/Graphics/Reader-Print@2x.png"
  install_resource "vfrReader/Graphics/Reader-Thumbs.png"
  install_resource "vfrReader/Graphics/Reader-Thumbs@2x.png"
fi

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac

  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
